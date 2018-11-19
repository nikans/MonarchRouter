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
        
        // Onboarding
        Router(navigationRoutePresenter()).stack([
//            Router(cachedPresenter(for: .onboarding, routeDispatcher: store)).endpoint(predicate: { $0 == AppRoute.onboarding.route })
            
            // Parametrized welcome page (just for test)
            Router(onboardingPresenter(routeDispatcher: store)).endpoint(predicate: { path in path.matches("onboarding/(?<name>[\\w\\-\\.]+)") }, parameters: { (path) -> RouteParameters in
                var arguments = RouteParameters()
                if let name = path.capturedGroups(withRegex: "onboarding/(?<name>[\\w\\-\\.]+)").first {
                    arguments["name"] = name
                }
                return arguments
            })
        ]),
        
        // Tabbar
        Router(tabBarRoutePresenter(optionsDescription: [
            (title: "First", icon: nil, route: .first),
            (title: "Second", icon: nil, route: .second),
            (title: "Third", icon: nil, route: .third(id: "-thirdInitial")),
            (title: "Fourth", icon: nil, route: .fourth(id: "-fourthInitial")),
            (title: "Fifth", icon: nil, route: .fifth)
        ], routeDispatcher: store)).fork([
            
            // First nav stack
            Router(navigationRoutePresenter()).stack([
                
                // First
                Router(cachedPresenter(for: .first, routeDispatcher: store)).endpoint(predicate: { $0 == AppRoute.first.route }, children: [
                    
                    // Detail
                    Router(cachedPresenter(for: .firstDetail, routeDispatcher: store)).endpoint(predicate: { $0 == AppRoute.firstDetail.route }, children: [
                        
                        // Parametrized Detail
                        Router(conditionalPresenter(routeDispatcher: store)).endpoint(predicate: { path in path.matches("firstDetailParametrized/(?<id>[\\w\\-\\.]+)") }, parameters: { (path) -> RouteParameters in
                            var arguments = RouteParameters()
                            if let id = path.capturedGroups(withRegex: "firstDetailParametrized/(?<id>[\\w\\-\\.]+)").first {
                                arguments["id"] = id
                            }
                            return arguments
                        })
                    ])
                ])
            ]),
            
            // Second nav stack
            Router(navigationRoutePresenter()).stack([
            
                // Second
                Router(cachedPresenter(for: .second, routeDispatcher: store)).endpoint(predicate: { $0 == AppRoute.second.route }, children: [
                    
                    // Detail
                    Router(cachedPresenter(for: .secondDetail, routeDispatcher: store)).endpoint(predicate: { $0 == AppRoute.secondDetail.route })
                ])
            ]),
            
            // Third nav stack
            Router(navigationRoutePresenter()).stack([
            
                // Third (parametrized)
                Router(conditionalPresenter(routeDispatcher: store)).endpoint(predicate: { path in path.matches("third/(?<id>[\\w\\-\\.]+)") }, parameters: { (path) -> RouteParameters in
                    var arguments = RouteParameters()
                    if let id = path.capturedGroups(withRegex: "third/(?<id>[\\w\\-\\.]+)").first {
                        arguments["id"] = id
                    }
                    return arguments
                })
            ]),
            
            // Fourth (parametrized)
            Router(conditionalPresenter(routeDispatcher: store)).endpoint(predicate: { path in path.matches("fourth/(?<id>[\\w\\-\\.]+)") }, parameters: { (path) -> RouteParameters in
                var arguments = RouteParameters()
                if let id = path.capturedGroups(withRegex: "fourth/(?<id>[\\w\\-\\.]+)").first {
                    arguments["id"] = id
                }
                return arguments
            }),
            
            // Fifth
            Router(cachedPresenter(for: .fifth, routeDispatcher: store)).endpoint(predicate: { $0 == AppRoute.fifth.route })
        ])
    ])
}
