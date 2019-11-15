//
//  AppCoordinator.swift
//  MonarchRouterExample
//
//  Created by Eliah Snakin on 16/11/2018.
//  nikans.com
//

import UIKit
import MonarchRouter





//struct Test {
//    init() {
////        let route: Route = [.constant("test"), .parameter(name: "id", type: Int.self)]
//        let route = "user/:id/..."
////        let route = RouteString("user/:id/...", parametersValidation: [(name: "id", pattern: "[\\w\\-\\.]+")])
//
////        let path = Path([PathConstant("user"), PathParameter("id", "shit"), PathParameter("name", "loh")])
//        let request = "user/shit"
//
//        print(route.isMatching(request: request))
//        print(request.resolve(for: route))
//    }
//}





/// Creating the app's Coordinator hierarchy.
func appCoordinator(dispatcher: ProvidesRouteDispatch, setRootView: @escaping (UIViewController)->()) -> RoutingNodeType
{
//    return RoutingNode(sectionsSwitcherRoutePresenter(setRootView)).switcher([])
    
    return
        // Top level app sections' switcher
        RoutingNode(sectionsSwitcherRoutePresenter(setRootView)).switcher([
        
        // Login
        RoutingNode(lazyMockPresenter(for: .login, routeDispatcher: dispatcher))
            .endpoint(AppRoute.login.path),
        
        // Onboarding
        RoutingNode(lazyNavigationRoutePresenter()).stack([
            
            // Parametrized welcome page
            RoutingNode(lazyOnboardingPresenter(routeDispatcher: dispatcher))
                .endpoint(
                    // note that only path component of the uri is matched here
                    "onboarding"
                )
        ]),
        
        // Tabbar
        RoutingNode(lazyTabBarRoutePresenter(
            optionsDescription: [
                (title: "First",  icon: nil, route: .first),
                (title: "Second", icon: nil, route: .second),
                (title: "Third",  icon: nil, route: .third(id: "-thirdInitial")),
                (title: "Fourth", icon: nil, route: .fourth(id: "-fourthInitial")),
                (title: "Fifth",  icon: nil, route: .fifth)
            ],
            routeDispatcher: dispatcher)).fork([
            
            // First nav stack
            RoutingNode(lazyNavigationRoutePresenter()).stack([
                
                // First
                RoutingNode(lazyMockPresenter(for: .first, routeDispatcher: dispatcher)).endpoint(
                    AppRoute.first.path,
                    children: [
                    
                    // Detail
                    RoutingNode(lazyMockPresenter(for: .firstDetail, routeDispatcher: dispatcher)).endpoint(
                        AppRoute.firstDetail.path,
                        children: [
                        
                        // Parametrized Detail
                        RoutingNode(lazyParametrizedPresenter(routeDispatcher: dispatcher))
                            .endpoint("firstDetailParametrized")
                    ])
                ])
            ]),
            
            // Second nav stack
            RoutingNode(lazyNavigationRoutePresenter()).stack([
            
                // Second
                RoutingNode(lazyMockPresenter(for: .second, routeDispatcher: dispatcher)).endpoint(AppRoute.second.path,
                    children: [
                    
                    // Detail
                    RoutingNode(lazyMockPresenter(for: .secondDetail, routeDispatcher: dispatcher))
                        .endpoint(AppRoute.secondDetail.path)
                ])
            ]),
            
            // Third nav stack
            RoutingNode(lazyNavigationRoutePresenter()).stack([
            
                // Third (parametrized)
                RoutingNode(lazyParametrizedPresenter(routeDispatcher: dispatcher)).endpoint(
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
            RoutingNode(lazyParametrizedPresenter(routeDispatcher: dispatcher)).endpoint(
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
            RoutingNode(lazyMockPresenter(for: .fifth, routeDispatcher: dispatcher)).endpoint(
                AppRoute.fifth.path,
                modals: [
                
                // Modal
                RoutingNode(unenchancedLazyTabBarRoutePresenter()).fork([
                    RoutingNode(lazyNavigationRoutePresenter()).stack([
                        RoutingNode(lazyParametrizedPresenter(routeDispatcher: dispatcher)).endpoint(
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
                        
                        RoutingNode(lazyMockPresenter(for: .modal, routeDispatcher: dispatcher))
                            .endpoint(AppRoute.modal.path)
                    ])
                ])
            ])
        ])
    ])
}
