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
    /// Primary method to change the path.
    /// You can extend `RouterStore` with a method to accept your routes enum and delegate paths switching to this method.
    /// - parameter path: String Path to navigate to.
    /// - parameter keepSubroutes: Defines should a more long Path should remain, if presented.
    /// - warning: If you opt in using `keepSubroutes: false` i.e. for Fork Routers (TabBarController), you have to make sure, that your endpoint VCs call `dispatchRoute(:)` with their respective Path on `viewDidAppear(:)` for navigation controller consistency. See Example implementation for details.
    public func dispatchRoute(_ path: String, keepSubroutes: Bool = false) {
        self.state = routerReducer(path: path, router: router(), state: self.state, keepSubroutes: keepSubroutes)
    }
    
    
    /// Primary initializer for a new `RouterStore`.
    /// - parameter router: Describes the Coordinator hierarchy for the current application. Autoclosure.
    public init(router: @autoclosure @escaping () -> RoutingUnitType) {
        self.router = router
        self.state = RouterState()
        self.reducer = routerReducer(path:router:state:keepSubroutes:)
    }

    
    /// Initializer allowing for overriding the State and Reducer.
    /// - parameter router: Describes the Coordinator hierarchy for the current application. Autoclosure.
    /// - parameter state: State holds the current `RoutingUnits` stack.
    /// - parameter reducer: Function to calculate a new State.
    public init(
        router: @autoclosure @escaping () -> RoutingUnitType,
        state: RouterStateType,
        reducer: @escaping (_ path: String, _ router: RoutingUnitType, _ state: RouterStateType, _ keepSubroutes: Bool) -> RouterStateType)
    {
        self.router = router
        self.state = state
        self.reducer = reducer
    }
    
    
    /// Describes the Coordinator hierarchy for the current application.
    let router: () -> RoutingUnitType
    
    /// State holds the current `RoutingUnits` stack.
    var state: RouterStateType
    
    /// Function to calculate a new State.
    /// Implements navigation via `RoutingUnitType`'s `setPath` callback.
    /// Unwinds unused `RoutingUnits` (see `RoutingUnitType`'s `unwind()` function).
    let reducer: (_ path: String, _ router: RoutingUnitType, _ state: RouterStateType, _ keepSubroutes: Bool) -> RouterStateType
}


/// Describes `RouterState` object.
/// State holds the stack of Routers.
public protocol RouterStateType
{
    /// The stack of Routers.
    var routersStack: [RoutingUnitType] { get set }
}

/// State holds the current Routers stack.
struct RouterState: RouterStateType
{
    /// The resulting Routers after applying the path.
    var routersStack = [RoutingUnitType]()
}



/// Function to calculate a new State.
/// Implements navigation via `RoutingUnitType`'s `setPath` callback.
/// Unwinds unused `RoutingUnit`s (see `RoutingUnitType`'s `unwind()` function).
/// - parameter path: String Path to navigate to.
/// - parameter router: Describes the Coordinator hierarchy for the current application.
/// - parameter state: State holds the current `RoutingUnits` stack.
func routerReducer(path: String, router: RoutingUnitType, state: RouterStateType, keepSubroutes: Bool) -> RouterStateType
{
    // Changes the Path and returns a new Routers stack
    let newRoutersStack = router.testPath(path, [])
    router.setPath(path, [], keepSubroutes)
    
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
