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
        getPresentable: {
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


typealias TabBarItemDescription = (title: String, icon: UIImage?, route: AppRoute)

class ExampleTabBarDelegate: NSObject, UITabBarControllerDelegate
{
    init(optionsDescriptions: [TabBarItemDescription], routeDispatcher: ProvidesRouteDispatch) {
        self.optionsDescriptions = optionsDescriptions
        self.routeDispatcher = routeDispatcher
    }
    
    let optionsDescriptions: [TabBarItemDescription]
    let routeDispatcher: ProvidesRouteDispatch
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
    {
        let index = tabBarController.selectedIndex
        guard optionsDescriptions.count > index else { return }
        routeDispatcher.dispatchRoute(optionsDescriptions[index].route)
    }
}

var tabBarDelegate: ExampleTabBarDelegate!


func tabBarRoutePresenter(optionsDescription: [TabBarItemDescription], routeDispatcher: ProvidesRouteDispatch) -> RoutePresenterFork
{
    let tabBarController = UITabBarController()
    tabBarDelegate = ExampleTabBarDelegate(optionsDescriptions: optionsDescription, routeDispatcher: routeDispatcher)
    tabBarController.delegate = tabBarDelegate
    
    return RoutePresenterFork(
        getPresentable: {
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
        getPresentable: {
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


func conditionalPresenter(routeDispatcher: ProvidesRouteDispatch) -> RoutePresenter
{
    let presenter = cachedPresenter(
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "GENERIC_VC")
    },
    setParameters: { presentable, parameters in
        if let presentable = presentable as? ViewController, let id = parameters?["id"] as? String
        {
            presentable.configure(title: "ID: \(id)", buttonTitle: "Second", buttonAction: {
                routeDispatcher.dispatchRoute(AppRoute.second)
            }, backgroundColor: .red)
        }
    })
    
    return presenter
}

func onboardingPresenter(routeDispatcher: ProvidesRouteDispatch) -> RoutePresenter
{
    let presenter = cachedPresenter(
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "GENERIC_VC")
    },
    setParameters: { presentable, parameters in
        if let presentable = presentable as? ViewController, let name = parameters?["name"] as? String
        {
            presentable.configure(title: "Welcome, \(name)", buttonTitle: "Okay", buttonAction: {
                routeDispatcher.dispatchRoute(AppRoute.first)
            }, backgroundColor: .red)
        }
    })
    
    return presenter
}


func cachedPresenter(for route: AppRoute, routeDispatcher: ProvidesRouteDispatch) -> RoutePresenter
{
    let presenter = cachedPresenter({
        return buildEndpoint(for: route, routeDispatcher: routeDispatcher)
    })
    
    return presenter
}
