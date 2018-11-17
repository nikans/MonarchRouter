//
//  Presenters.swift
//  MonarchRouterExample
//
//  Created by Eliah Snakin on 16/11/2018.
//  Copyright © 2018 nikans.com. All rights reserved.
//

import UIKit
import MonarchRouter
import Dwifft


func sectionsSwitcherRoutePresenter(_ setRootView: @escaping (UIViewController)->()) -> RoutePresenterSwitcher
{
    var rootPresentable: UIViewController?
    
    return RoutePresenterSwitcher(
        getPresentable: { _ in
            guard let vc = rootPresentable
                else { fatalError("Cannot get presentable for root router. Probably there's no Router resolving the requested path?") }
            return vc
        },
        setOptionSelected: {
            rootPresentable = $0
            setRootView($0)
        }
    )
}


typealias TabBarItemDescription = (title: String, icon: UIImage?)

func tabBarRoutePresenter(optionsDescription: [TabBarItemDescription]) -> RoutePresenterFork
{
    let tabBarController = UITabBarController()
    
    return RoutePresenterFork(
        getPresentable: { _ in
            tabBarController
        },
        setOptions: { setVCs in
            tabBarController.setViewControllers(setVCs, animated: true)
            optionsDescription.enumerated().forEach { i, description in
                guard setVCs.count > i else { return }
                setVCs[i].tabBarItem.title = description.title
                setVCs[i].tabBarItem.image = description.icon
            }
        },
        setOptionSelected: {
            tabBarController.selectedViewController = $0
        }
    )
}


func navigationRoutePresenter() -> RoutePresenterStack
{
    let navigationController = UINavigationController()
    
    return RoutePresenterStack(
        getPresentable: { _ in
            navigationController
        },
        setStack: { replaceVCs in
            let currentStack = navigationController.viewControllers
            
            // same, do nothing
            if currentStack.count == replaceVCs.count, currentStack.last == replaceVCs.last {
                return
            }
            
            // only one, pop to root
            if replaceVCs.count == 1 && currentStack.count > 1 {
                navigationController.popToRootViewController(animated: true)
            }
            
            // pop
            if currentStack.count > replaceVCs.count {
                navigationController.setViewControllers(replaceVCs, animated: true)
            }
            // push
            else {
                let diff = Dwifft.diff(currentStack, replaceVCs)
                diff.forEach({ (step) in
                    switch step {
                    case .delete(let idx, _):
                        navigationController.viewControllers.remove(at: idx)
                    case .insert(let idx, let vc):
                        if idx == replaceVCs.count-1 {
                            navigationController.pushViewController(vc, animated: true)
                        } else {
                            navigationController.viewControllers.insert(vc, at: idx)
                        }
                    }
                })
            }
        },
        prepareRootPresentable: { setVC in
            guard navigationController.viewControllers.count == 0 else { return }
            navigationController.setViewControllers([setVC], animated: false)
        }
    )
}


func conditionalPresenter() -> RoutePresenter
{
    let presenter = cachedPresenter({ (arguments) -> UIViewController in
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GENERIC_VC") as! ViewController
        
        if let id = arguments?["id"] as? String
        {
            vc.configure(title: "ID: \(id)", buttonTitle: nil, buttonAction: nil, backgroundColor: .green)
        }
        
        return vc
    })
    
    return presenter
}


func cachedPresenter(for route: AppRoute, routeDispatcher: ProvidesRouteDispatch) -> RoutePresenter
{
    let presenter = cachedPresenter({ (arguments) -> UIViewController in
        return buildEndpoint(for: route, routeDispatcher: routeDispatcher)
    })
    
    return presenter
}
