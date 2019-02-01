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
    var setPath: (_ path: String, _ routers: [RoutingUnitType], _ keepSubroutes: Bool) -> () { get }
    
    /// Called when the `RoutingUnit` no handles a new Path.
    func unwind()
    
    /// The Presentable to return if this `RoutingUnit` matches the path.
    /// - returns: A Presentable object.
    func getPresentable() -> UIViewController
    
    /// Determines should this `RoutingUnit` handle the given Path.
    /// Configured for each respective `RoutingUnit` type.
    var shouldHandleRoute: (_ path: String) -> Bool { get }
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
    internal var presenter: Presenter
    
    public func getPresentable() -> UIViewController {
        return presenter.getPresentable()
    }
    
    public internal(set) var shouldHandleRoute: (_ path: String) -> Bool
        = { _ in false }
    
    public var testPath: (String, [RoutingUnitType]) -> [RoutingUnitType] = { _,_ in [] }
    
    public var setPath: (_ path: String, _ routers: [RoutingUnitType], _ keepSubroutes: Bool) -> ()
        = { _,_,_ in }
    
    public func unwind() -> () {
        presenter.unwind(presenter.getPresentable())
    }
    
    /// Paths that Router currently serve.
    /// Fork Router can serve several Paths simultaniously.
    /// This property should be set in `setPath` closure.
    internal var servedPaths: Set<String> = []
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
        
        router.setPath = { path, routers, keepSubroutes in
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
                modal.setPath(path, routers + [router], keepSubroutes)
            }
                
            // this RoutingUnit's child handles the Path
            else if let child = children.firstResult({ child in child.shouldHandleRoute(path) ? child : nil })
            {
                router.servedPaths = [path]
                child.setPath(path, routers + [router], keepSubroutes)
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
            router.servedPaths = [path]
            return stack.contains { subRouter in subRouter.shouldHandleRoute(path) }
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
        
        router.setPath = { path, routers, keepSubroutes in
            // some item in stack handles the Path
            if let stackItem = stack.firstResult({ stackItem in stackItem.shouldHandleRoute(path) ? stackItem : nil })
            {
                let presentable = router.presenter.getPresentable()
                let stackRouters = stackItem.testPath(path, [])
                stackItem.setPath(path, [], keepSubroutes)
                
                // passing the navigation stack to the Presenter
                router.presenter.setStack(stackRouters.map({ subRouter in subRouter.getPresentable() }), presentable)

                router.servedPaths = [path]
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
        
        router.setPath = { path, routers, keepSubroutes in
            let presentable = router.presenter.getPresentable()
            
            // passing children as options for the Presenter
            router.presenter.setOptions(options.map { option in option.getPresentable() }, presentable)
            
            // this RoutingUnit's option handles the Path
            if let option = options.firstResult({ option in option.shouldHandleRoute(path) ? option : nil })
            {
                // setup the Presenter for matching RoutingUnit and set it as an active option
                router.presenter.setOptionSelected(option.getPresentable(), presentable)
                
                guard keepSubroutes else {
                    // it's not required to keep presented Subroutes
                    router.servedPaths.remove(matching: { option.shouldHandleRoute($0) })
                    router.servedPaths.insert(path)
                    option.setPath(path, routers + [router], keepSubroutes)
                    return
                }
                
                // keep presented Subroutes and Path if currently presented Path is "longer" then requested Path
                // TODO: check if just count is enough
                if  let servedPathHandlingOption = router.servedPaths.filter({ option.shouldHandleRoute($0) }).first,
                    option.testPath(servedPathHandlingOption, routers + [router]).count > option.testPath(path, routers + [router]).count
                {
                    option.setPath(servedPathHandlingOption, routers + [router], keepSubroutes)
                }
                
                // set new Path
                else {
                    router.servedPaths.remove(matching: { option.shouldHandleRoute($0) })
                    router.servedPaths.insert(path)
                    option.setPath(path, routers + [router], keepSubroutes)
                }                
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
        
        router.setPath = { path, routers, keepSubroutes in
            // finding an option to handle the Path
            if let option = options.firstResult({ option in option.shouldHandleRoute(path) ? option : nil })
            {
                // setup the presenter for matching Router and set it as an active option
                router.presenter.setOptionSelected(option.getPresentable())
                
                router.servedPaths = [path]
                option.setPath(path, routers + [router], keepSubroutes)
            }
            
            // no option found
            else {
                router.servedPaths = [path]
            }
        }
        
        return router
    }
}
