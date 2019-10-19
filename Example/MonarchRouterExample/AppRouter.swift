//
//  RoutingUnit.swift
//  MonarchRouterExample
//
//  Created by Eliah Snakin on 16/11/2018.
//  nikans.com
//

import Foundation
import MonarchRouter



/// Sets up the Router and root view controller.
func createAppRouter(setRootView: @escaping (UIViewController)->()) -> RouterStore
{
    var router: RoutingUnitType!
    
    // creating a Store for the Router and passing a callback to get a Coordinator (RoutingUnits hierarchy) to it
    let store = RouterStore(router: router)
    
    // creating a Coordinator hierarchy for the Router
    router = createCoordinator(dispatcher: store, setRootView: setRootView)
    
    return store
}


/// Describes the object capable of Routes switching.
protocol ProvidesRouteDispatch
{
    /// Extension method to change the route.
    /// - parameter route: `AppRoute` to navigate to.
    func dispatchRoute(_ route: AppRoute)
    
    /// Extension method to change the route.
    /// - parameter route: `AppRoute` to navigate to.
    /// - parameter options: Special options for navigation (see `DispatchRouteOption` enum).
    func dispatchRoute(_ route: AppRoute, options: [DispatchRouteOption])
}

// Extending `RouterStore` to accept `AppRoute` instead of string Path.
extension RouterStore: ProvidesRouteDispatch
{
    func dispatchRoute(_ route: AppRoute) {
        dispatchRoute(route.path)
    }
    
    func dispatchRoute(_ route: AppRoute, options: [DispatchRouteOption]) {
        dispatchRoute(route.path, options: options)
    }
}
