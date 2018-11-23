//
//  AppCoordinator.swift
//  MonarchRouterExample
//
//  Created by Eliah Snakin on 16/11/2018.
//  nikans.com
//

import UIKit
import MonarchRouter

/// Creating the app's Coordinator hierarchy.
func createCoordinator(dispatcher: ProvidesRouteDispatch, setRootView: @escaping (UIViewController)->()) -> RoutingUnitType
{
    return
        // Top level app sections' switcher
        RoutingUnit(sectionsSwitcherRoutePresenter(setRootView)).switcher([
        
        // Login
        RoutingUnit(lazyMockPresenter(for: .login, routeDispatcher: dispatcher)).endpoint(
            predicate: { $0 == AppRoute.login.path }
        ),
        
        // Onboarding
        RoutingUnit(lazyNavigationRoutePresenter()).stack([
            
            // Parametrized welcome page (just for test)
            RoutingUnit(lazyOnboardingPresenter(routeDispatcher: dispatcher)).endpoint(
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
        RoutingUnit(lazyTabBarRoutePresenter(
            optionsDescription: [
                (title: "First", icon: nil, route: .first),
                (title: "Second", icon: nil, route: .second),
                (title: "Third", icon: nil, route: .third(id: "-thirdInitial")),
                (title: "Fourth", icon: nil, route: .fourth(id: "-fourthInitial")),
                (title: "Fifth", icon: nil, route: .fifth)
            ],
            routeDispatcher: dispatcher)).fork([
            
            // First nav stack
            RoutingUnit(lazyNavigationRoutePresenter()).stack([
                
                // First
                RoutingUnit(lazyMockPresenter(for: .first, routeDispatcher: dispatcher)).endpoint(
                    predicate: { $0 == AppRoute.first.path },
                    children: [
                    
                    // Detail
                    RoutingUnit(lazyMockPresenter(for: .firstDetail, routeDispatcher: dispatcher)).endpoint(
                        predicate: { $0 == AppRoute.firstDetail.path },
                        children: [
                        
                        // Parametrized Detail
                        RoutingUnit(lazyParametrizedPresenter(routeDispatcher: dispatcher)).endpoint(
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
            RoutingUnit(lazyNavigationRoutePresenter()).stack([
            
                // Second
                RoutingUnit(lazyMockPresenter(for: .second, routeDispatcher: dispatcher)).endpoint(
                    predicate: { $0 == AppRoute.second.path },
                    children: [
                    
                    // Detail
                    RoutingUnit(lazyMockPresenter(for: .secondDetail, routeDispatcher: dispatcher)).endpoint(
                        predicate: { $0 == AppRoute.secondDetail.path }
                    )
                ])
            ]),
            
            // Third nav stack
            RoutingUnit(lazyNavigationRoutePresenter()).stack([
            
                // Third (parametrized)
                RoutingUnit(lazyParametrizedPresenter(routeDispatcher: dispatcher)).endpoint(
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
            RoutingUnit(lazyParametrizedPresenter(routeDispatcher: dispatcher)).endpoint(
                predicate: { path in
                    path.matches("fourth/(?<id>[\\w\\-\\.]+)")
                }, parameters: { (path) -> RouteParameters in
                    var arguments = RouteParameters()
                    if let id = path.capturedGroups(withRegex: "fourth/(?<id>[\\w\\-\\.]+)").first { arguments["id"] = id }
                    return arguments
                }
            ),
            
            // Fifth
            RoutingUnit(lazyMockPresenter(for: .fifth, routeDispatcher: dispatcher)).endpoint(
                predicate: { $0 == AppRoute.fifth.path },
                modals: [
                
                // Modal
                RoutingUnit(unenchancedLazyTabBarRoutePresenter()).fork([
                    RoutingUnit(lazyNavigationRoutePresenter()).stack([
                        RoutingUnit(lazyParametrizedPresenter(routeDispatcher: dispatcher)).endpoint(
                            predicate: { path in
                                path.matches("modalParametrized/(?<id>[\\w\\-\\.]+)")
                            }, parameters: { (path) -> RouteParameters in
                                var arguments = RouteParameters()
                                if let id = path.capturedGroups(withRegex: "modalParametrized/(?<id>[\\w\\-\\.]+)").first { arguments["id"] = id }
                                return arguments
                            }
                        ),
                        
                        RoutingUnit(lazyMockPresenter(for: .modal, routeDispatcher: dispatcher)).endpoint(
                            predicate: { $0 == AppRoute.modal.path }
                        )
                    ])
                ])
            ])
        ])
    ])
}
