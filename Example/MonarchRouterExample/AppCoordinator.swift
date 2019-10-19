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
func appCoordinator(dispatcher: ProvidesRouteDispatch, setRootView: @escaping (UIViewController)->()) -> RoutingUnitType
{
    return
        // Top level app sections' switcher
        RoutingUnit(sectionsSwitcherRoutePresenter(setRootView)).switcher([
        
        // Login
        RoutingUnit(lazyMockPresenter(for: .login, routeDispatcher: dispatcher))
            .endpoint(path: AppRoute.login.path),
        
        // Onboarding
        RoutingUnit(lazyNavigationRoutePresenter()).stack([
            
            // Parametrized welcome page
            RoutingUnit(lazyOnboardingPresenter(routeDispatcher: dispatcher))
                .endpoint(
                    // note that only path component of the uri is matched here
                    path: "onboarding"
                )
        ]),
        
        // Tabbar
        RoutingUnit(lazyTabBarRoutePresenter(
            optionsDescription: [
                (title: "First",  icon: nil, route: .first),
                (title: "Second", icon: nil, route: .second),
                (title: "Third",  icon: nil, route: .third(id: "-thirdInitial")),
                (title: "Fourth", icon: nil, route: .fourth(id: "-fourthInitial")),
                (title: "Fifth",  icon: nil, route: .fifth)
            ],
            routeDispatcher: dispatcher)).fork([
            
            // First nav stack
            RoutingUnit(lazyNavigationRoutePresenter()).stack([
                
                // First
                RoutingUnit(lazyMockPresenter(for: .first, routeDispatcher: dispatcher)).endpoint(
                    path: AppRoute.first.path,
                    children: [
                    
                    // Detail
                    RoutingUnit(lazyMockPresenter(for: .firstDetail, routeDispatcher: dispatcher)).endpoint(
                        path: AppRoute.firstDetail.path,
                        children: [
                        
                        // Parametrized Detail
                        RoutingUnit(lazyParametrizedPresenter(routeDispatcher: dispatcher))
                            .endpoint(path: "firstDetailParametrized")
                    ])
                ])
            ]),
            
            // Second nav stack
            RoutingUnit(lazyNavigationRoutePresenter()).stack([
            
                // Second
                RoutingUnit(lazyMockPresenter(for: .second, routeDispatcher: dispatcher)).endpoint(
                    path: AppRoute.second.path,
                    children: [
                    
                    // Detail
                    RoutingUnit(lazyMockPresenter(for: .secondDetail, routeDispatcher: dispatcher))
                        .endpoint(path: AppRoute.secondDetail.path)
                ])
            ]),
            
            // Third nav stack
            RoutingUnit(lazyNavigationRoutePresenter()).stack([
            
                // Third (parametrized)
                RoutingUnit(lazyParametrizedPresenter(routeDispatcher: dispatcher)).endpoint(
                    pathPredicate: { path in
                        path.matches("third/(?<id>[\\w\\-\\.]+)")
                    },
                    pathParameters: { (path) -> PathParameters in
                        var arguments = PathParameters()
                        if let id = path.capturedGroups(withRegex: "third/(?<id>[\\w\\-\\.]+)").first {
                            arguments["id"] = id
                            arguments["route"] = AppRoute.third(id: id)
                        }
                        return arguments
                    }
                )
            ]),
            
            // Fourth (parametrized)
            RoutingUnit(lazyParametrizedPresenter(routeDispatcher: dispatcher)).endpoint(
                pathPredicate: { path in
                    path.matches("fourth/(?<id>[\\w\\-\\.]+)")
                },
                pathParameters: { (path) -> PathParameters in
                    var arguments = PathParameters()
                    if let id = path.capturedGroups(withRegex: "fourth/(?<id>[\\w\\-\\.]+)").first {
                        arguments["id"] = id
                        arguments["route"] = AppRoute.fourth(id: id)
                    }
                    return arguments
                }
            ),
            
            // Fifth
            RoutingUnit(lazyMockPresenter(for: .fifth, routeDispatcher: dispatcher)).endpoint(
                path: AppRoute.fifth.path,
                modals: [
                
                // Modal
                RoutingUnit(unenchancedLazyTabBarRoutePresenter()).fork([
                    RoutingUnit(lazyNavigationRoutePresenter()).stack([
                        RoutingUnit(lazyParametrizedPresenter(routeDispatcher: dispatcher)).endpoint(
                            pathPredicate: { path in
                                path.matches("modalParametrized/(?<id>[\\w\\-\\.]+)")
                            },
                            pathParameters: { (path) -> PathParameters in
                                var arguments = PathParameters()
                                if let id = path.capturedGroups(withRegex: "modalParametrized/(?<id>[\\w\\-\\.]+)").first {
                                    arguments["id"] = id
                                    arguments["route"] = AppRoute.modalParametrized(id: id)
                                }
                                return arguments
                            }
                        ),
                        
                        RoutingUnit(lazyMockPresenter(for: .modal, routeDispatcher: dispatcher))
                            .endpoint(path: AppRoute.modal.path)
                    ])
                ])
            ])
        ])
    ])
}
