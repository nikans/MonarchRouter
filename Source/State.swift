//
//  Store.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 21/11/2018.
//  Copyright © 2018 nikans.com. All rights reserved.
//

import Foundation


/// State Store for the Router.
/// Initialize one to change routes via `dispatchRoute(_ path: String)`.
public final class RouterStore
{
    /// Describes the Router hierarchy for the current application.
    let router: () -> RoutingUnitType
    
    /// State holds the current `RoutingUnits` stack.
    var state: RouterState
    
    /// Function to calculate a new State.
    /// Implements Route switching via `RoutingUnitType`'s `setPath` callback.
    /// Unwinds unused RouteUnits (see `RoutingUnitType`'s `unwind()` function).
    let reducer: (_ path: String, _ router: RoutingUnitType, _ state: RouterState) -> RouterState
    
    /// Primary initializer for a new `RouterStore`.
    /// - parameter router: Describes the Router hierarchy for the current application. Autoclosure.
    public init(router: @autoclosure @escaping () -> RoutingUnitType) {
        self.router = router
        self.state = RouterState()
        self.reducer = routerReducer(path:router:state:)
    }
    
    /// Primary method to change the route.
    /// You can extend `RouterStore` with a method to accept your routes enum and delegate route switching to this method.
    /// - parameter path: String Path to route to.
    public func dispatchRoute(_ path: String) {
        self.state = routerReducer(path: path, router: router(), state: self.state)
    }
}



/// State holds the current Routers stack.
struct RouterState
{
    /// The resulting Routers stack after applying the path.
    var routersStack = [RoutingUnitType]()
}



/// Function to calculate a new State.
/// Implements route switching via `RoutingUnitType`'s `setPath` callback.
/// Unwinds unused Routers (see `RoutingUnitType`'s `unwind()` function).
func routerReducer(path: String, router: RoutingUnitType, state: RouterState) -> RouterState
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
