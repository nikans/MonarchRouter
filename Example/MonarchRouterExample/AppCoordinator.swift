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
        Router(lazyMockPresenter(for: .login, routeDispatcher: store)).endpoint(
            predicate: { $0 == AppRoute.login.path }
        ),
        
        // Onboarding
        Router(lazyNavigationRoutePresenter()).stack([
            
            // Parametrized welcome page (just for test)
            Router(lazyOnboardingPresenter(routeDispatcher: store)).endpoint(
                predicate: { path in
                    path.matches("onboarding/(?<name>[\\w\\-\\.]+)") },
                parameters: { (path) -> RouteParameters in
                    var arguments = RouteParameters()
                    if let name = path.capturedGroups(withRegex: "onboarding/(?<name>[\\w\\-\\.]+)").first { arguments["name"] = name }
                    return arguments
                }
            )
        ]),
        
        // Tabbar
        Router(lazyTabBarRoutePresenter(
            optionsDescription: [
                (title: "First", icon: nil, route: .first),
                (title: "Second", icon: nil, route: .second),
                (title: "Third", icon: nil, route: .third(id: "-thirdInitial")),
                (title: "Fourth", icon: nil, route: .fourth(id: "-fourthInitial")),
                (title: "Fifth", icon: nil, route: .fifth)
            ],
            routeDispatcher: store)).fork([
            
            // First nav stack
            Router(lazyNavigationRoutePresenter()).stack([
                
                // First
                Router(lazyMockPresenter(for: .first, routeDispatcher: store)).endpoint(
                    predicate: { $0 == AppRoute.first.path },
                    children: [
                    
                    // Detail
                    Router(lazyMockPresenter(for: .firstDetail, routeDispatcher: store)).endpoint(
                        predicate: { $0 == AppRoute.firstDetail.path },
                        children: [
                        
                        // Parametrized Detail
                        Router(lazyParametrizedPresenter(routeDispatcher: store)).endpoint(
                            predicate: { path in
                                path.matches("firstDetailParametrized/(?<id>[\\w\\-\\.]+)")
                            },
                            parameters: { (path) -> RouteParameters in
                                var arguments = RouteParameters()
                                if let id = path.capturedGroups(withRegex: "firstDetailParametrized/(?<id>[\\w\\-\\.]+)").first { arguments["id"] = id }
                                return arguments
                            }
                        )
                    ])
                ])
            ]),
            
            // Second nav stack
            Router(lazyNavigationRoutePresenter()).stack([
            
                // Second
                Router(lazyMockPresenter(for: .second, routeDispatcher: store)).endpoint(
                    predicate: { $0 == AppRoute.second.path },
                    children: [
                    
                    // Detail
                    Router(lazyMockPresenter(for: .secondDetail, routeDispatcher: store)).endpoint(
                        predicate: { $0 == AppRoute.secondDetail.path }
                    )
                ])
            ]),
            
            // Third nav stack
            Router(lazyNavigationRoutePresenter()).stack([
            
                // Third (parametrized)
                Router(lazyParametrizedPresenter(routeDispatcher: store)).endpoint(
                    predicate: { path in
                        path.matches("third/(?<id>[\\w\\-\\.]+)")
                    },
                    parameters: { (path) -> RouteParameters in
                        var arguments = RouteParameters()
                        if let id = path.capturedGroups(withRegex: "third/(?<id>[\\w\\-\\.]+)").first { arguments["id"] = id }
                        return arguments
                    }
                )
            ]),
            
            // Fourth (parametrized)
            Router(lazyParametrizedPresenter(routeDispatcher: store)).endpoint(
                predicate: { path in
                    path.matches("fourth/(?<id>[\\w\\-\\.]+)")
                }, parameters: { (path) -> RouteParameters in
                    var arguments = RouteParameters()
                    if let id = path.capturedGroups(withRegex: "fourth/(?<id>[\\w\\-\\.]+)").first { arguments["id"] = id }
                    return arguments
                }
            ),
            
            // Fifth
            Router(lazyMockPresenter(for: .fifth, routeDispatcher: store)).endpoint(
                predicate: { $0 == AppRoute.fifth.path },
                modals: [
                
                // Modal
                Router(unenchancedLazyTabBarRoutePresenter()).fork([
                    Router(lazyNavigationRoutePresenter()).stack([
                        Router(lazyParametrizedPresenter(routeDispatcher: store)).endpoint(
                            predicate: { path in
                                path.matches("modalParametrized/(?<id>[\\w\\-\\.]+)")
                            }, parameters: { (path) -> RouteParameters in
                                var arguments = RouteParameters()
                                if let id = path.capturedGroups(withRegex: "modalParametrized/(?<id>[\\w\\-\\.]+)").first { arguments["id"] = id }
                                return arguments
                            }
                        ),
                        
                        Router(lazyMockPresenter(for: .modal, routeDispatcher: store)).endpoint(
                            predicate: { $0 == AppRoute.modal.path }
                        )
                    ])
                ])
            ])
        ])
    ])
}
