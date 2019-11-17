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
/// Initialize one to change routes via `dispatch(_ request:)`.
public final class RouterStore
{
    /// Primary method to make a Routing Request.
    /// - parameter request: Routing Request.
    /// - parameter options: Special options for navigation (see `DispatchRouteOption` enum).
    public func dispatch(_ request: RoutingRequestType, options: [DispatchRouteOption] = []) {
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
    func unwind(stack: [RoutingNodeType], comparing newStack: [RoutingNodeType])
    {
        // Recursively called for each substack
        stack.enumerated().forEach { (i, element) in
            if let substack = element.substack {
                unwind(stack: substack, comparing: newStack[safe: i]?.substack ?? [])
            }
        }
        
        // Dismissing substacks that are not present anymore
        stack.enumerated()
            .filter({ (i, node) in
                return node.substack != nil && newStack[safe: i]?.substack == nil
            })
            .reversed()
            .forEach { (_, node) in
                node.dismissSubstack()
            }
        
        // Finding the first RoutingNode in the stack that is not the same as in the previous Routers stack
        if let firstDifferenceIndex = stack.enumerated().first(where: { (i, node) in
            guard newStack.count > i else { return true }
            return node.getPresentable() != newStack[i].getPresentable()
        })?.offset
        {
            // Unwinding unused `RoutingNode`s in reversed order
            stack[firstDifferenceIndex ..< stack.count]
                .reversed()
                .forEach { node in
                    node.dismissSubstack()
                    node.unwind()
            }
        }
    }
    
    
    // Getting a new `RoutingNode`s stack for a given Request
    let newRoutersStack = router.testRequest(request, [])
    
    // Unwinding unused Routers
    unwind(stack: state.routersStack, comparing: newRoutersStack)
    
    // Changing state
    router.performRequest(request, [], options)
    
    return RouterState(routersStack: newRoutersStack)
}
