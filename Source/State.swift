//
//  Store.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 21/11/2018.
//  nikans.com
//

import Foundation


/// State Store for the Router.
/// Initialize one to change routes via `dispatchRoute(_ path: String)`.
public final class RouterStore
{
    /// Describes the Router hierarchy for the current application.
    let router: () -> RoutingUnitType
    
    /// State holds the current `RoutingUnits` stack.
    var state: RouterStateType
    
    /// Function to calculate a new State.
    /// Implements Route switching via `RoutingUnitType`'s `setPath` callback.
    /// Unwinds unused RouteUnits (see `RoutingUnitType`'s `unwind()` function).
    let reducer: (_ path: String, _ router: RoutingUnitType, _ state: RouterStateType) -> RouterStateType
    
    /// Primary initializer for a new `RouterStore`.
    /// - parameter router: Describes the Router hierarchy for the current application. Autoclosure.
    public init(router: @autoclosure @escaping () -> RoutingUnitType) {
        self.router = router
        self.state = RouterState()
        self.reducer = routerReducer(path:router:state:)
    }
    
    /// Initializer allowing for overriding the State and Reducer.
    /// - parameter router: Describes the Router hierarchy for the current application. Autoclosure.
    /// - parameter state: State holds the current `RoutingUnits` stack.
    /// - parameter reducer: Function to calculate a new State.
    public init(
        router: @autoclosure @escaping () -> RoutingUnitType,
        state: RouterStateType,
        reducer: @escaping (_ path: String, _ router: RoutingUnitType, _ state: RouterStateType) -> RouterStateType)
    {
        self.router = router
        self.state = state
        self.reducer = reducer
    }
    
    /// Primary method to change the route.
    /// You can extend `RouterStore` with a method to accept your routes enum and delegate route switching to this method.
    /// - parameter path: String Path to route to.
    public func dispatchRoute(_ path: String) {
        self.state = routerReducer(path: path, router: router(), state: self.state)
    }
}


///
public protocol RouterStateType
{
    var routersStack: [RoutingUnitType] { get set }
}

/// State holds the current Routers stack.
struct RouterState: RouterStateType
{
    /// The resulting Routers stack after applying the path.
    var routersStack = [RoutingUnitType]()
}



/// Function to calculate a new State.
/// Implements route switching via `RoutingUnitType`'s `setPath` callback.
/// Unwinds unused Routers (see `RoutingUnitType`'s `unwind()` function).
/// - parameter path: String Path to route to.
/// - parameter router: Describes the Router hierarchy for the current application.
/// - parameter state: State holds the current `RoutingUnits` stack.
func routerReducer(path: String, router: RoutingUnitType, state: RouterStateType) -> RouterStateType
{
    // Switching the route and returns a new Routers stack
    let newRoutersStack = router.setPath(path, [])
    
    // Finding the first RoutingUnit in the stack that is not the same as in the previous Routers stack
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
