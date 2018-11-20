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
    case onboarding(name: String)
    case first
    case firstDetail
    case firstDetailParametrized(id: String)
    case second
    case secondDetail
    case third(id: String)
    case fourth(id: String)
    case fifth
    case modal, modal2
    
    var path: String {
        switch self {
        case .login:
            return "login"
        case .onboarding(let name):
            return "onboarding/" + name
        case .first:
            return "first"
        case .firstDetail:
            return "firstDetail"
        case .firstDetailParametrized(let id):
            return "firstDetailParametrized/" + id
        case .second:
            return "second"
        case .secondDetail:
            return "secondDetail"
        case .third(let id):
            return "third/" + id
        case .fourth(let id):
            return "fourth/" + id
        case .fifth:
            return "fifth"
        case .modal:
            return "modal"
        case .modal2:
            return "modal2"
        }
    }
}



func appCoordinator(setRootView: @escaping (UIViewController)->()) -> UIViewController
{
    var router: RouterType!
    let store = RouterStore() { _ = router.setPath($0.path) }
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

