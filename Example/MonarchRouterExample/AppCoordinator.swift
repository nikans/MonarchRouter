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
//    return RoutingUnit(sectionsSwitcherRoutePresenter(setRootView)).switcher([])
    
    return
        // Top level app sections' switcher
        RoutingUnit(sectionsSwitcherRoutePresenter(setRootView)).switcher([
        
        // Login
        RoutingUnit(lazyMockPresenter(for: .login, routeDispatcher: dispatcher))
            .endpoint(AppRoute.login.path),
        
        // Onboarding
        RoutingUnit(lazyNavigationRoutePresenter()).stack([
            
            // Parametrized welcome page
            RoutingUnit(lazyOnboardingPresenter(routeDispatcher: dispatcher))
                .endpoint(
                    // note that only path component of the uri is matched here
                    "onboarding"
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
                    AppRoute.first.path,
                    children: [
                    
                    // Detail
                    RoutingUnit(lazyMockPresenter(for: .firstDetail, routeDispatcher: dispatcher)).endpoint(
                        AppRoute.firstDetail.path,
                        children: [
                        
                        // Parametrized Detail
                        RoutingUnit(lazyParametrizedPresenter(routeDispatcher: dispatcher))
                            .endpoint("firstDetailParametrized")
                    ])
                ])
            ]),
            
            // Second nav stack
            RoutingUnit(lazyNavigationRoutePresenter()).stack([
            
                // Second
                RoutingUnit(lazyMockPresenter(for: .second, routeDispatcher: dispatcher)).endpoint(AppRoute.second.path,
                    children: [
                    
                    // Detail
                    RoutingUnit(lazyMockPresenter(for: .secondDetail, routeDispatcher: dispatcher))
                        .endpoint(AppRoute.secondDetail.path)
                ])
            ]),
            
            // Third nav stack
            RoutingUnit(lazyNavigationRoutePresenter()).stack([
            
                // Third (parametrized)
                RoutingUnit(lazyParametrizedPresenter(routeDispatcher: dispatcher)).endpoint(
                    isMatching: { path in
                        "third/:id".isMatching(request: path)
//                        path.matches(predicate: "third/(?<id>[\\w\\-\\.]+)")
                    },
                    resolve: { request in
                        request.resolve(for: "third/:id")
//                        var arguments = PathParameters()
//                        print(path.routingRequest.capturedGroups(withRegex: "third/(?<id>[\\w\\-\\.]+)"))
//                        if let id = path.routingRequest.capturedGroups(withRegex: "third/(?<id>[\\w\\-\\.]+)").first {
//                            arguments["id"] = id
//                            arguments["route"] = AppRoute.third(id: id)
//                        }
//                        return arguments
//                        return [:]
                    }
                )
            ]),
            
            // Fourth (parametrized)
            RoutingUnit(lazyParametrizedPresenter(routeDispatcher: dispatcher)).endpoint(
                isMatching: { path in
                    "fourth/:id".isMatching(request: path)
//                    path.matches(predicate: "fourth/(?<id>[\\w\\-\\.]+)")
                },
                resolve: { request in
                    request.resolve(for: "third/:id")
//                    var arguments = PathParameters()
//                    if let id = path.routingRequest.capturedGroups(withRegex: "fourth/(?<id>[\\w\\-\\.]+)").first {
//                        arguments["id"] = id
//                        arguments["route"] = AppRoute.fourth(id: id)
//                    }
//                    return arguments
//                    return [:]
                }
            ),
            
            // Fifth
            RoutingUnit(lazyMockPresenter(for: .fifth, routeDispatcher: dispatcher)).endpoint(
                AppRoute.fifth.path,
                modals: [
                
                // Modal
                RoutingUnit(unenchancedLazyTabBarRoutePresenter()).fork([
                    RoutingUnit(lazyNavigationRoutePresenter()).stack([
                        RoutingUnit(lazyParametrizedPresenter(routeDispatcher: dispatcher)).endpoint(
                            isMatching: { path in
                                "modalParametrized/:id".isMatching(request: path)
//                                path.matches(predicate: "modalParametrized/(?<id>[\\w\\-\\.]+)")
                            },
                            resolve: { request in
                                request.resolve(for: "third/:id")
//                                var arguments = PathParameters()
//                                if let id = path.routingRequest.capturedGroups(withRegex: "modalParametrized/(?<id>[\\w\\-\\.]+)").first {
//                                    arguments["id"] = id
//                                    arguments["route"] = AppRoute.modalParametrized(id: id)
//                                }
//                                return arguments
//                                return [:]
                            }
                        ),
                        
                        RoutingUnit(lazyMockPresenter(for: .modal, routeDispatcher: dispatcher))
                            .endpoint(AppRoute.modal.path)
                    ])
                ])
            ])
        ])
    ])
}
