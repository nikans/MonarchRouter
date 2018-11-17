//
//  Router.swift
//  MonarchRouterExample
//
//  Created by Eliah Snakin on 16/11/2018.
//  Copyright © 2018 nikans.com. All rights reserved.
//

import Foundation
import MonarchRouter

enum AppRoute
{
    case login
    case main
    case detail
    case second
    case page(id: String)
    
    var route: String {
        switch self {
        case .login:    return "login"
        case .main:     return "main"
        case .detail:   return "detail"
        case .second:   return "second"
        case .page(let id):
                        return "page/" + id
        }
    }
}



func appCoordinator(setRootView: @escaping (UIViewController)->()) -> UIViewController
{
    var router: RouterType!
    let store = RouterStore() { _ = router.setPath($0.route) }
    router = createRouter(store, setRootView: setRootView)
    
    store.setRoute(.login)
    
    return router.getPresentable()
}


protocol ProvidesRouteDispatch
{
    func dispatchRoute(_ route: AppRoute)
}


/// State for the router
struct RouterStore: ProvidesRouteDispatch
{
//    var setPath: (String) -> ()
    
    var setRoute: ((AppRoute) ->())!
    
    init(setPath: @escaping (AppRoute) ->()) {
        self.setRoute = setPath
    }
    
    func dispatchRoute(_ route: AppRoute) {
        setRoute(route)
    }
}

