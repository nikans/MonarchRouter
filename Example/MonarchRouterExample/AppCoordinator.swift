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
func appCoordinator(router: ProvidesRouteDispatch, setRootView: @escaping (UIViewController)->()) -> RoutingNodeType
{    
    return
        // Top level app sections' switcher
        RoutingNode(sectionsSwitcherRoutePresenter(setRootView)).switcher([
        
        // Login
        RoutingNode(lazyPresenter(for: .login, router: router))
            .endpoint(AppRoute.login),
        
        // Onboarding nav stack
        RoutingNode(lazyNavigationRoutePresenter()).stack([
            
            // Parametrized welcome page
            RoutingNode(lazyPresenter(for: .onboarding, router: router))
                .endpoint(AppRoute.onboarding)
        ]),
        
        // Tabbar
        RoutingNode(lazyTabBarRoutePresenter(
            optionsDescription: [
                (title: "Today",  icon: nil, request: .today),
                (title: "Books", icon: nil, request: .books),
                (title: "Profile",  icon: nil, request: .profile)
            ],
            router: router)).fork([
            
            // Today nav stack
            RoutingNode(lazyNavigationRoutePresenter()).stack([
                
                // Today
                RoutingNode(lazyPresenter(for: .today, router: router))
                    .endpoint(AppRoute.today, children: [
                    
                    // All news
                    RoutingNode(lazyPresenter(for: .allNews, router: router))
                        .endpoint(AppRoute.allNews)
                    
                    ], modals: [
                    
                    // Story
                    RoutingNode(lazyPresenter(for: .story, router: router))
                        .endpoint(AppRoute.story)
                ])
            ]),
            
            // Books nav stack
            RoutingNode(lazyNavigationRoutePresenter()).stack([
            
                // Books
                RoutingNode(lazyPresenter(for: .books, router: router))
                    .endpoint(AppRoute.books, children: [
                    
                    // Book
                    RoutingNode(lazyPresenter(for: .book, router: router))
                        .endpoint(AppRoute.book)
                        
                    // Book categories
//                    RoutingNode(lazyMockPresenter(for: .booksCategory, routeDispatcher: dispatcher))
//                        .endpoint(AppRoute.booksCategory)
                ])
            ]),
            
            // Profile nav stack
            RoutingNode(lazyNavigationRoutePresenter()).stack([
                
                // Profile
                RoutingNode(lazyPresenter(for: .profile, router: router))
                    .endpoint(AppRoute.profile, modals: [
                        
                        // Tabbar
                        RoutingNode(lazyTabBarRoutePresenter(
                            optionsDescription: [
                                (title: "Orders",  icon: nil, request: .orders),
                                (title: "Delivery",  icon: nil, request: .deliveryInfo)
                            ],
                            router: router)).fork([
                                
                                // Orders nav stack
                                RoutingNode(lazyNavigationRoutePresenter()).stack([
                        
                                    // Orders done
                                    RoutingNode(lazyPresenter(for: .orders, router: router))
                                        .endpoint(AppRoute.orders)
                                ]),
                                
                                // Delivery info
                                RoutingNode(lazyPresenter(for: .deliveryInfo, router: router))
                                    .endpoint(AppRoute.deliveryInfo)
                        ])
                ])
            ])
        ])
    ])
}
