//
//  AppCoordinator.swift
//  MonarchRouterExample
//
//  Created by Eliah Snakin on 16/11/2018.
//  Copyright © 2018 nikans.com. All rights reserved.
//

import UIKit
import MonarchRouter


func createRouter(_ store: RouterStore, setRootView: @escaping (UIViewController)->()) -> RouterType
{
    return Router(sectionsSwitcherRoutePresenter(setRootView)).switcher([
        
        // Login
        Router(cachedPresenter(for: .login, routeDispatcher: store)).endpoint(predicate: { $0 == AppRoute.login.route }),
        
        // Main — Tabbar
        Router(tabBarRoutePresenter(optionsDescription: [(title: "First", icon: nil), (title: "Second", icon: nil), (title: "Third", icon: nil)])).fork([
            
            // Dashboard nav stack
            Router(navigationRoutePresenter()).stack([
                
                // Dashboard
                Router(cachedPresenter(for: .main, routeDispatcher: store)).endpoint(predicate: { $0 == AppRoute.main.route }, children: [
                    
                    // Detail
                    Router(cachedPresenter(for: .detail, routeDispatcher: store)).endpoint(predicate: { $0 == AppRoute.detail.route })
                ])
            ]),
            
            // Second
            Router(cachedPresenter(for: .second, routeDispatcher: store)).endpoint(predicate: { $0 == AppRoute.second.route }),
            
            // Third (parametrized)
            Router(conditionalPresenter()).endpoint(predicate: { path in path.matches("page/(?<id>[\\w\\-\\.]+)") }, parameters: { (path) -> RouteParameters in
                var arguments = RouteParameters()
                if let id = path.capturedGroups(withRegex: "page/(?<id>[\\w\\-\\.]+)").first {
                    arguments["id"] = id
                }
                return arguments
            })
        ])
    ])
}
