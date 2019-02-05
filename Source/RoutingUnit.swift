//
//  Store.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 21/11/2018.
//  nikans.com
//

import UIKit


/// Any `RoutingUnit` object.
public protocol RoutingUnitType
{
    /// Returns Routers stack for provided Path.
    /// Configured for each respective `RoutingUnit` type.
    var testPath: (_ path: String, _ routers: [RoutingUnitType]) -> [RoutingUnitType] { get }
    
    /// Passes actions to the Presenter to update the view for provided Path.
    /// Configured for each respective `RoutingUnit` type.
    var setPath: (_ path: String, _ routers: [RoutingUnitType], _ options: [DispatchRouteOption]) -> () { get }
    
    /// Called when the `RoutingUnit` no handles a new Path.
    func unwind()
    
    /// The Presentable to return if this `RoutingUnit` matches the path.
    /// - returns: A Presentable object.
    func getPresentable() -> UIViewController
    
    /// Determines should this `RoutingUnit` or it's child handle the given Path.
    /// Configured for each respective `RoutingUnit` type.
    var shouldHandleRoute: (_ path: String) -> Bool { get }
    
    /// Determines should this `RoutingUnit` handle the given Path by itself.
    /// Configured for each respective `RoutingUnit` type.
    var shouldHandleRouteExclusively: (_ path: String) -> Bool { get }
    
    
    var servedPaths: Set<String> { get }
}



/// The `RoutingUnit` is a structure that collects functions together that are related to the same endpoint or intermidiate routing point.
/// Each `RoutingUnit` also requires a Presenter, to which any required changes are passed.
public struct RoutingUnit<Presenter: RoutePresenterType>: RoutingUnitType
{
    /// Primary initializer for a `RoutingUnit`.
    /// - parameter presenter: A Presenter object to pass UI changes to.
    public init(_ presenter: Presenter) {
        self.presenter = presenter
    }
    
    /// Presenter to pass UI changes to.
    internal fileprivate(set) var presenter: Presenter
    
    public func getPresentable() -> UIViewController {
        return presenter.getPresentable()
    }
    
    public fileprivate(set) var shouldHandleRoute: (_ path: String) -> Bool
        = { _ in false }
    
    public fileprivate(set) var shouldHandleRouteExclusively: (_ path: String) -> Bool = { _ in false }
    
    public fileprivate(set) var testPath: (String, [RoutingUnitType]) -> [RoutingUnitType] = { _,_ in [] }
    
    public fileprivate(set) var setPath: (_ path: String, _ routers: [RoutingUnitType], _ dispatchOptions: [DispatchRouteOption]) -> ()
        = { _,_,_ in }
    
    public func unwind() -> () {
        presenter.unwind(presenter.getPresentable())
    }
    
    /// Paths that Router currently serve.
    /// Fork Router can serve several Paths simultaniously.
    /// This property should be set in `setPath` closure.
    /// 
    public fileprivate(set) var servedPaths: Set<String> = []
}


extension RoutingUnit where Presenter == RoutePresenter
{
    /// Endpoint `RoutingUnit` representing an actual target to navigate to.
    /// - parameter predicate: A closure to determine whether this `RoutingUnit` should handle the Path.
    /// - parameter parameters: An optional closure to parse the Path into `RouteParameters` to configure a Presentable with.
    /// - parameter children: `RoutingUnit`s you can navigate to from this unit, i.e. in navigation stack.
    /// - parameter modals: `RoutingUnit`s you can present as modals from this one.
    /// - returns: Modified `RoutingUnit`
    public func endpoint(
        predicate isMatching: @escaping ((_ path: String) -> Bool),
        parameters: ((_ path: String) -> RouteParameters)? = nil,
        children: [RoutingUnitType] = [],
        modals: [RoutingUnitType] = []
    ) -> RoutingUnit
    {
        var router = self
        
        router.shouldHandleRoute = { path in
            // checking if this RoutingUnit or any of the children or modals can handle the Path
            return isMatching(path)
                || children.contains { $0.shouldHandleRoute(path) }
                || modals.contains { $0.shouldHandleRoute(path) }
        }
        
        router.shouldHandleRouteExclusively = { path in
            return isMatching(path)
        }
        
        router.testPath = { path, routers in
            // this RoutingUnit handles the Path
            if isMatching(path) {
                return routers + [router]
            }
            
            // should present a modal to handle the Path
            else if let modal = modals.firstResult({ modal in modal.shouldHandleRoute(path) ? modal : nil })
            {
                return modal.testPath(path, routers + [router])
            }
                
            // this RoutingUnit's child handles the Path
            else if let child = children.firstResult({ child in child.shouldHandleRoute(path) ? child : nil })
            {
                return child.testPath(path, routers + [router])
            }
            
            return routers
        }
        
        router.setPath = { path, routers, dispatchOptions in
            let params = parameters?(path)
            
            // this RoutingUnit handles the Path
            if isMatching(path) {
                // setting parameters
                let presentable = router.getPresentable()
                router.presenter.setParameters(params ?? [:], presentable)
                router.servedPaths = [path]
            }
                
            // should present a modal to handle the Path
            else if let modal = modals.firstResult({ modal in modal.shouldHandleRoute(path) ? modal : nil })
            {
                let presentable = router.getPresentable()
                router.presenter.presentModal(modal.getPresentable(), presentable)
                router.servedPaths = [path]
                modal.setPath(path, routers + [router], dispatchOptions)
            }
                
            // this RoutingUnit's child handles the Path
            else if let child = children.firstResult({ child in child.shouldHandleRoute(path) ? child : nil })
            {
                router.servedPaths = [path]
                child.setPath(path, routers + [router], dispatchOptions)
            }
            
            // this RoutingUnit cannot handle the Path
            else {
                router.servedPaths = []
            }
        }
        
        return router
    }
}


extension RoutingUnit where Presenter == RoutePresenterStack
{
    /// Stack `RoutingUnit` can be used to organize other `RoutingUnit`s in a navigation stack.
    /// - parameter stack: `RoutingUnit`s in this navigation stack.
    /// - returns: Modified `RoutingUnit`
    public func stack(_ stack: [RoutingUnitType]) -> RoutingUnit
    {
        var router = self
        
        router.shouldHandleRoute = { path in
            // checking if any of the children can handle the Path
            return stack.contains { subRouter in subRouter.shouldHandleRoute(path) }
        }
        
        router.shouldHandleRouteExclusively = { path in
            return stack.first?.shouldHandleRouteExclusively(path) ?? false
        }
        
        router.testPath = { path, routers in
            // some item in stack handles the Path
            if let stackItem = stack.firstResult({ stackItem in stackItem.shouldHandleRoute(path) ? stackItem : nil })
            {
                let stackRouters = stackItem.testPath(path, [])
                return routers + [router] + stackRouters
            }
            
            // no item found
            return routers + [router]
        }
        
        router.setPath = { path, routers, dispatchOptions in
            
            // `junctionsOnly` dispatch option
            if dispatchOptions.contains(.junctionsOnly) {
                // some item in stack handles the Path
                if let stackItem = stack.firstResult({ stackItem in stackItem.shouldHandleRoute(path) ? stackItem : nil })
                {
                    if router.servedPaths.count == 0 {
                        router.servedPaths = [path]
                    }
                    
                    let presentable = router.presenter.getPresentable()
                    stackItem.setPath(path, [], dispatchOptions)
                    router.presenter.prepareRootPresentable(stackItem.getPresentable(), presentable)
                }
                return
            }
            
            // default dispatch options
            
            // some item in stack handles the Path
            if let stackItem = stack.firstResult({ stackItem in stackItem.shouldHandleRoute(path) ? stackItem : nil })
            {
                router.servedPaths = [path]

                let presentable = router.presenter.getPresentable()
                let stackRouters = stackItem.testPath(path, [])
                stackItem.setPath(path, [], dispatchOptions)
                
                // passing the navigation stack to the Presenter
                router.presenter.setStack(stackRouters.map({ subRouter in subRouter.getPresentable() }), presentable)
            }
            
            // no item found
            else {
                router.servedPaths = [path]
            }
        }
        
        return router
    }
}


extension RoutingUnit where Presenter == RoutePresenterFork
{
    /// Fork `RoutingUnit` can be used for tabbar-like navigation.
    /// - parameter options: `RoutingUnit`s in this navigation set.
    /// - returns: Modified `RoutingUnit`
    public func fork(_ options: [RoutingUnitType]) -> RoutingUnit
    {
        var router = self
        
        router.shouldHandleRoute = { path in
            // checking if any of the children can handle the Path
            return options.contains { option in option.shouldHandleRoute(path) }
        }
        
        router.testPath = { path, routers in
            // this RoutingUnit's option handles the Path
            if let option = options.firstResult({ option in option.shouldHandleRoute(path) ? option : nil })
            {
                return option.testPath(path, routers + [router])
            }
            
            // no option found
            return routers + [router]
        }
        
        router.setPath = { path, routers, dispatchOptions in
            let presentable = router.presenter.getPresentable()
            
            // passing children as options for the Presenter
            router.presenter.setOptions(options.map { option in option.getPresentable() }, presentable)
            
            // this RoutingUnit's option handles the Path
            if let option = options.firstResult({ option in option.shouldHandleRoute(path) ? option : nil })
            {
                // setup the Presenter for matching RoutingUnit and set it as an active option
                router.presenter.setOptionSelected(option.getPresentable(), presentable)
                
                // `junctionsOnly` dispatch option
                // keep presented VCs if we only need to switch option
                if  dispatchOptions.contains(.junctionsOnly),
                    option.shouldHandleRouteExclusively(path)
                {
                    if !router.servedPaths.contains(where: { option.shouldHandleRoute($0) }) {
                        router.servedPaths.insert(path)
                    }
                    
                    option.setPath(path, routers + [router], dispatchOptions)
                    return
                }
                
                // default dispatch options
                // set new Path
                router.servedPaths.remove(matching: { option.shouldHandleRoute($0) })
                router.servedPaths.insert(path)
                option.setPath(path, routers + [router], dispatchOptions)
            }
            
            // no option found
            else {
                router.servedPaths.remove(path)
            }
        }
        
        return router
    }
}


extension RoutingUnit where Presenter == RoutePresenterSwitcher
{
    /// Switcher `RoutingUnit` can be used to switch sections of your app, like onboarding/login/main, by the means of changing `rootViewController` of a window or similar.
    /// This RoutingUnit's Presenter doesn't have an actual view.
    /// - parameter options: `RoutingUnit`s in this navigation set.
    /// - returns: Modified `RoutingUnit`
    public func switcher(_ options: [RoutingUnitType]) -> RoutingUnit
    {
        var router = self
        
        router.shouldHandleRoute = { path in
            // checking if any of the children can handle the Path
            return options.contains { option in option.shouldHandleRoute(path) }
        }
        
        router.testPath = { path, routers in
            // finding an option to handle the Path
            if let option = options.firstResult({ option in option.shouldHandleRoute(path) ? option : nil })
            {
                return option.testPath(path, routers + [router])
            }
            
            // no option found
            return routers + [router]
        }
        
        router.setPath = { path, routers, dispatchOptions in
            // finding an option to handle the Path
            if let option = options.firstResult({ option in option.shouldHandleRoute(path) ? option : nil })
            {
                // setup the presenter for matching Router and set it as an active option
                router.presenter.setOptionSelected(option.getPresentable())
                
                router.servedPaths = [path]
                option.setPath(path, routers + [router], dispatchOptions)
            }
            
            // no option found
            else {
                router.servedPaths = [path]
            }
        }
        
        return router
    }
}
