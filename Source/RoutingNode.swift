//
//  Store.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 21/11/2018.
//  nikans.com
//

import UIKit



/// Any `RoutingNode` object.
/// Hierarchy of `RoutingNodeType` objects forms an app coordinator.
public protocol RoutingNodeType
{
    /// Returns Routers stack for provided Request.
    /// Configured for each respective `RoutingNode` type.
    var testRequest: (_ request: RoutingRequestType, _ routers: [RoutingNodeType]) -> [RoutingNodeType] { get }
    
    /// Passes actions to the Presenter to update the view for provided Request.
    /// Configured for each respective `RoutingNode` type.
    var performRequest: (_ request: RoutingRequestType, _ routers: [RoutingNodeType], _ options: [DispatchRouteOption]) -> () { get }
    
    /// Called when the `RoutingNode` does not handle a Request anymore.
    func unwind()
    
    /// The Presentable to return if this `RoutingNode` matches the Request.
    /// - returns: A Presentable object.
    func getPresentable() -> UIViewController
    
    /// Determines should this `RoutingNode` or it's child handle the given Request.
    /// Configured for each respective `RoutingNode` type.
    var shouldHandleRoute: (_ request: RoutingRequestType) -> Bool { get }
    
    /// Determines should this `RoutingNode` handle the given Request by itself.
    /// Configured for each respective `RoutingNode` type.
    var shouldHandleRouteExclusively: (_ request: RoutingRequestType) -> Bool { get }
}



/// The `RoutingNode` is a structure that collects functions together that are related to the same endpoint or intermidiate routing point.
/// Each `RoutingNode` also requires a Presenter, to which any required changes are passed.
public struct RoutingNode<Presenter: RoutePresenterType>: RoutingNodeType
{
    /// Primary initializer for a `RoutingNode`.
    /// - parameter presenter: A Presenter object to pass UI changes to.
    public init(_ presenter: Presenter) {
        self.presenter = presenter
    }
    
    /// Presenter to pass UI changes to.
    internal fileprivate(set) var presenter: Presenter
    
    public func getPresentable() -> UIViewController {
        return presenter.getPresentable()
    }
    
    public fileprivate(set) var shouldHandleRoute: (_ request: RoutingRequestType) -> Bool
        = { _ in false }
    
    public fileprivate(set) var shouldHandleRouteExclusively: (_ request: RoutingRequestType) -> Bool = { _ in false }
    
    public fileprivate(set) var testRequest: (RoutingRequestType, [RoutingNodeType]) -> [RoutingNodeType] = { _,_ in [] }
    
    public fileprivate(set) var performRequest: (_ request: RoutingRequestType, _ routers: [RoutingNodeType], _ dispatchOptions: [DispatchRouteOption]) -> ()
        = { _,_,_ in }
    
    public func unwind() -> () {
        presenter.unwind(presenter.getPresentable())
    }
}


extension RoutingNode where Presenter == RoutePresenter
{
    /// Endpoint `RoutingNode` represents an actual target to navigate to, configured with `RouteParameters` based on `RoutingRequest`.
    /// - parameter isMatching: A closure to determine whether this `RoutingNode` should handle the Request.
    /// - parameter resolve: A closure to resolve the Request based on Route to configure a Presentable with.
    /// - parameter children: `RoutingNode`s you can navigate to from this unit, i.e. in navigation stack.
    /// - parameter modals: `RoutingNode`s you can present as modals from this one.
    /// - returns: Modified `RoutingNode`
    public func endpoint(
        isMatching: @escaping ((_ request: RoutingRequestType) -> Bool),
        resolve: @escaping ((_ request: RoutingRequestType) -> RoutingResolvedRequestType),
        children: [RoutingNodeType] = [],
        modals: [RoutingNodeType] = []
    ) -> RoutingNode
    {
        var router = self
        
        router.shouldHandleRoute = { request in
            // checking if this RoutingNode or any of the children or modals can handle the Request
            return isMatching(request)
                || children.contains { $0.shouldHandleRoute(request) }
                || modals.contains { $0.shouldHandleRoute(request) }
        }
        
        router.shouldHandleRouteExclusively = { request in
            return isMatching(request)
        }
        
        router.testRequest = { request, routers in
            // this RoutingNode handles the Request
            if isMatching(request) {
                return routers + [router]
            }
            
            // should present a modal to handle the Request
            else if let modal = modals.firstResult({ modal in modal.shouldHandleRoute(request) ? modal : nil })
            {
                return modal.testRequest(request, routers + [router])
            }
                
            // this RoutingNode's child handles the Request
            else if let child = children.firstResult({ child in child.shouldHandleRoute(request) ? child : nil })
            {
                return child.testRequest(request, routers + [router])
            }
            
            return routers
        }
        
        router.performRequest = { request, routers, dispatchOptions in
            
            // this RoutingNode handles the Request
            if isMatching(request) {
                let presentable = router.getPresentable()

                //
                // setting parameters
                let resolvedRequest = resolve(request)
                let routeParameters = RouteParameters(request: resolvedRequest)
                router.presenter.setParameters(routeParameters, presentable)
            }
                
            // should present a modal to handle the Request
            else if let modal = modals.firstResult({ modal in modal.shouldHandleRoute(request) ? modal : nil })
            {
                let presentable = router.getPresentable()
                router.presenter.presentModal(modal.getPresentable(), presentable)
                modal.performRequest(request, routers + [router], dispatchOptions)
            }
                
            // this RoutingNode's child handles the Request
            else if let child = children.firstResult({ child in child.shouldHandleRoute(request) ? child : nil })
            {
                child.performRequest(request, routers + [router], dispatchOptions)
            }
            
            // this RoutingNode cannot handle the Request
            else { }
        }
        
        return router
    }
    
    
    /// Convenience method for Endpoint `RoutingNode` creation, `route` is checked for match with default rules.
    /// Endpoint `RoutingNode` represents an actual target to navigate to, configured with `RouteParameters` based on `RoutingRequest`.
    /// - parameter route: A `RouteType` to determine whether this `RoutingNode` should handle the Request.
    /// - parameter children: `RoutingNode`s you can navigate to from this unit, i.e. in navigation stack.
    /// - parameter modals: `RoutingNode`s you can present as modals from this one.
    /// - returns: Modified `RoutingNode`
    public func endpoint(
        _ route: RouteType,
        children: [RoutingNodeType] = [],
        modals: [RoutingNodeType] = []
    ) -> RoutingNode
    {
        endpoint(isMatching: { route.isMatching(request: $0) }, resolve: { $0.resolve(for: route) }, children: children, modals: modals)
    }
}



extension RoutingNode where Presenter == RoutePresenterStack
{
    /// Stack `RoutingNode` can be used to organize other `RoutingNode`s in a navigation stack.
    /// - parameter stack: `RoutingNode`s in this navigation stack.
    /// - returns: Modified `RoutingNode`
    public func stack(_ stack: [RoutingNodeType]) -> RoutingNode
    {
        var router = self
        
        router.shouldHandleRoute = { request in
            // checking if any of the children can handle the Request
            return stack.contains { subRouter in subRouter.shouldHandleRoute(request) }
        }
        
        router.shouldHandleRouteExclusively = { request in
            return stack.first?.shouldHandleRouteExclusively(request) ?? false
        }
        
        router.testRequest = { request, routers in
            // some item in stack handles the Request
            if let stackItem = stack.firstResult({ stackItem in stackItem.shouldHandleRoute(request) ? stackItem : nil })
            {
                let stackRouters = stackItem.testRequest(request, [])
                return routers + [router] + stackRouters
            }
            
            // no item found
            return routers + [router]
        }
        
        router.performRequest = { request, routers, dispatchOptions in
            
            // `junctionsOnly` dispatch option
            if dispatchOptions.contains(.junctionsOnly) {
                // some item in the stack handles the Request
                if let stackItem = stack.firstResult({ stackItem in stackItem.shouldHandleRoute(request) ? stackItem : nil })
                {
                    let presentable = router.presenter.getPresentable()
                    stackItem.performRequest(request, [], dispatchOptions)
                    router.presenter.prepareRootPresentable(stackItem.getPresentable(), presentable)
                }
                return
            }
            
            // default dispatch options
            
            // some item in the stack handles the Request
            if let stackItem = stack.firstResult({ stackItem in stackItem.shouldHandleRoute(request) ? stackItem : nil })
            {
                let presentable = router.presenter.getPresentable()
                let stackRouters = stackItem.testRequest(request, [])
                stackItem.performRequest(request, [], dispatchOptions)
                
                // passing the navigation stack to the Presenter
                router.presenter.setStack(stackRouters.map({ subRouter in subRouter.getPresentable() }), presentable)
            }
            
            // no item found
            else { }
        }
        
        return router
    }
}



extension RoutingNode where Presenter == RoutePresenterFork
{
    /// Fork `RoutingNode` can be used for tabbar-like navigation.
    /// - parameter options: `RoutingNode`s in this navigation set.
    /// - returns: Modified `RoutingNode`
    public func fork(_ options: [RoutingNodeType]) -> RoutingNode
    {
        var router = self
        
        router.shouldHandleRoute = { request in
            // checking if any of the children can handle the Request
            return options.contains { option in option.shouldHandleRoute(request) }
        }
        
        router.testRequest = { request, routers in
            // this RoutingNode's option handles the Request
            if let option = options.firstResult({ option in option.shouldHandleRoute(request) ? option : nil })
            {
                return option.testRequest(request, routers + [router])
            }
            
            // no option found
            return routers + [router]
        }
        
        router.performRequest = { request, routers, dispatchOptions in
            let presentable = router.presenter.getPresentable()
            
            // passing children as options for the Presenter
            router.presenter.setOptions(options.map { option in option.getPresentable() }, presentable)
            
            // this RoutingNode's option handles the Request
            if let option = options.firstResult({ option in option.shouldHandleRoute(request) ? option : nil })
            {
                // setup the Presenter for matching RoutingNode and set it as an active option
                router.presenter.setOptionSelected(option.getPresentable(), presentable)
                
                // `junctionsOnly` dispatch option
                // keep presented VCs if we only need to switch option
                if  dispatchOptions.contains(.junctionsOnly),
                    option.shouldHandleRouteExclusively(request)
                {
                    option.performRequest(request, routers + [router], dispatchOptions)
                    return
                }
                
                // default dispatch options
                // perform new Request
                option.performRequest(request, routers + [router], dispatchOptions)
            }
            
            // no option found
            else { }
        }
        
        return router
    }
}



extension RoutingNode where Presenter == RoutePresenterSwitcher
{
    /// Switcher `RoutingNode` can be used to switch sections of your app, like onboarding/login/main, by the means of changing `rootViewController` of a window or similar.
    /// This RoutingNode's Presenter doesn't have an actual view.
    /// - parameter options: `RoutingNode`s in this navigation set.
    /// - returns: Modified `RoutingNode`
    public func switcher(_ options: [RoutingNodeType]) -> RoutingNode
    {
        var router = self
        
        router.shouldHandleRoute = { request in
            // checking if any of the children can handle the Request
            return options.contains { option in option.shouldHandleRoute(request) }
        }
        
        router.testRequest = { request, routers in
            // finding an option to handle the Request
            if let option = options.firstResult({ option in option.shouldHandleRoute(request) ? option : nil })
            {
                return option.testRequest(request, routers + [router])
            }
            
            // no option found
            return routers + [router]
        }
        
        router.performRequest = { request, routers, dispatchOptions in
            // finding an option to handle the Request
            if let option = options.firstResult({ option in option.shouldHandleRoute(request) ? option : nil })
            {
                // setup the presenter for matching Router and set it as an active option
                router.presenter.setOptionSelected(option.getPresentable())
                option.performRequest(request, routers + [router], dispatchOptions)
            }
            
            // no option found
            else { }
        }
        
        return router
    }
}
