//
//  Store.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 21/11/2018.
//  nikans.com
//

import Foundation



public enum DispatchRouteOption
{
    /// Keeps presented VCs if only need to switch the junction option
    case junctionsOnly
}



/// State Store for the Router.
/// Initialize one to change routes via `dispatchRoute(_ request:)`.
public final class RouterStore
{
    /// Primary method to make a Routing Request.
    /// - parameter request: Routing Request.
    /// - parameter options: Special options for navigation (see `DispatchRouteOption` enum).
    public func dispatchRoute(_ request: RoutingRequestType, options: [DispatchRouteOption] = []) {
        self.state = routerReducer(request: request, router: router(), state: self.state, options: options)
    }
    
    
    /// Primary initializer for a new `RouterStore`.
    /// - parameter router: Describes the Coordinator hierarchy for the current application. Autoclosure.
    public init(router: @autoclosure @escaping () -> RoutingNodeType) {
        self.router = router
        self.state = RouterState()
        self.reducer = routerReducer(request:router:state:options:)
    }

    
    /// Initializer allowing for overriding the State and Reducer.
    /// - parameter router: Describes the Coordinator hierarchy for the current application. Autoclosure.
    /// - parameter state: State holds the current `RoutingNodes` stack.
    /// - parameter reducer: Function to calculate a new State.
    public init(
        router: @autoclosure @escaping () -> RoutingNodeType,
        state: RouterStateType,
        reducer: @escaping (_ request: RoutingRequestType, _ router: RoutingNodeType, _ state: RouterStateType, _ options: [DispatchRouteOption]) -> RouterStateType)
    {
        self.router = router
        self.state = state
        self.reducer = reducer
    }
    
    
    /// Describes the Coordinator hierarchy for the current application.
    let router: () -> RoutingNodeType
    
    /// State holds the current `RoutingNodes` stack.
    var state: RouterStateType
    
    /// Function to calculate a new State.
    /// Implements navigation via `RoutingNodeType`'s `setRequest` callback.
    /// Unwinds unused `RoutingNodes` (see `RoutingNodeType`'s `unwind()` function).
    let reducer: (_ request: RoutingRequestType, _ router: RoutingNodeType, _ state: RouterStateType, _ options: [DispatchRouteOption]) -> RouterStateType
}


/// Describes `RouterState` object.
/// State holds the stack of Routers.
public protocol RouterStateType
{
    /// The stack of Routers.
    var routersStack: [RoutingNodeType] { get set }
}

/// State holds the current Routers stack.
struct RouterState: RouterStateType
{
    /// The resulting Routers after performing the Request.
    var routersStack = [RoutingNodeType]()
}



/// Function to calculate a new State.
/// Implements navigation via `RoutingNodeType`'s `performRequest` callback.
/// Unwinds unused `RoutingNode`s (see `RoutingNodeType`'s `unwind()` function).
/// - parameter request: Request to perform.
/// - parameter router: Describes the Coordinator hierarchy for the current application.
/// - parameter state: State holds the current `RoutingNodes` stack.
func routerReducer(request: RoutingRequestType, router: RoutingNodeType, state: RouterStateType, options: [DispatchRouteOption]) -> RouterStateType
{
    // Performs the Request and returns a new Routers stack
    let newRoutersStack = router.testRequest(request, [])
    router.performRequest(request, [], options)
    
    // Finding the first RoutingNode in the stack that is not the same as in the previous Routers stack
    if let firstDifferenceIndex = state.routersStack.enumerated().first(where: { (i, element) -> Bool in
        guard newRoutersStack.count > i else { return true }
        return element.getPresentable() != newRoutersStack[i].getPresentable()
    })?.offset
    {
        // Unwinding unused Routers in reversed order
        state.routersStack[firstDifferenceIndex ..< min(newRoutersStack.count, state.routersStack.count)]
            .reversed()
            .forEach { $0.unwind() }
    }
    
    return RouterState(routersStack: newRoutersStack)
}
