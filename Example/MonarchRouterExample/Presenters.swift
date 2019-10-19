//
//  Presenters.swift
//  MonarchRouterExample
//
//  Created by Eliah Snakin on 16/11/2018.
//  nikans.com
//

import UIKit
import MonarchRouter
import Differ



// MARK: - App sections' switcher

/// Presenter for top level app sections' switcher.
/// It doesn't actually have any Presentable, setting the window's rootViewController via a callback instead.
/// This one is not lazy, because it's unnecessasy.
func sectionsSwitcherRoutePresenter(_ setRootView: @escaping (UIViewController)->()) -> RoutePresenterSwitcher
{
    var rootPresentable: UIViewController?
    
    return RoutePresenterSwitcher(
        getPresentable: {
            guard let vc = rootPresentable
                else { fatalError("Cannot get Presentable for the Switcher type root RoutingUnit. Probably there's no other RoutingUnit resolving the requested Path?") }
            return vc
        },
        setOptionSelected: { option in
            rootPresentable = option
            setRootView(option)
        }
    )
}



// MARK: - Tab bar

/// Describes the view and action for a tab bar item.
typealias TabBarItemDescription = (title: String, icon: UIImage?, route: AppRoute)

/// Mock Tab Bar Controller delegate that dispatch routes on tap.
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
        routeDispatcher.dispatchRoute(optionsDescriptions[index].route, options: [.junctionsOnly])
    }
}

var tabBarDelegate: ExampleTabBarDelegate!


/// Lazy Presenter for a Tab Bar Controller with a delegate.
func lazyTabBarRoutePresenter(optionsDescription: [TabBarItemDescription], routeDispatcher: ProvidesRouteDispatch) -> RoutePresenterFork
{
    return RoutePresenterFork.lazyPresenter({
            let tabBarController = UITabBarController()
            tabBarDelegate = ExampleTabBarDelegate(optionsDescriptions: optionsDescription, routeDispatcher: routeDispatcher)
            tabBarController.delegate = tabBarDelegate
            return tabBarController
        },
        setOptions: { options, container in
            let tabBarController = container as! UITabBarController
            tabBarController.setViewControllers(options, animated: true)
            optionsDescription.enumerated().forEach { i, description in
                guard options.count > i else { return }
                options[i].tabBarItem.title = description.title
                options[i].tabBarItem.image = description.icon
            }
        },
        setOptionSelected: { option, container in
            let tabBarController = container as! UITabBarController
            tabBarController.selectedViewController = option
        }
    )
}


/// Lazy Presenter for a Tab Bar Controller without a delegate.
func unenchancedLazyTabBarRoutePresenter() -> RoutePresenterFork
{
    return RoutePresenterFork.lazyPresenter({
            UITabBarController()
        },
        setOptions: { options, container in
            let tabBarController = container as! UITabBarController
            tabBarController.setViewControllers(options, animated: true)
        },
        setOptionSelected: { option, container in
            let tabBarController = container as! UITabBarController
            tabBarController.selectedViewController = option
        }
    )
}



// MARK: - Navigation stack

// Lazy Presenter for a Navigation Controller.
func lazyNavigationRoutePresenter() -> RoutePresenterStack
{
    return RoutePresenterStack.lazyPresenter({
        UINavigationController()
    },
    setStack: { (newStack, container) in
        let navigationController = container as! UINavigationController
        let currentStack = navigationController.viewControllers
        
        // same, do nothing
        if currentStack.count == newStack.count, currentStack.last == newStack.last {
            return
        }
        
        // only one, pop to root
        if newStack.count == 1 && currentStack.count > 1 {
            navigationController.popToRootViewController(animated: true)
        }
        
        // pop
        if currentStack.count > newStack.count {
            navigationController.setViewControllers(newStack, animated: true)
        }
        
        // push
        else {
            let diff = patch(from: currentStack, to: newStack)
            diff.forEach({ change in
                switch change {
                    
                case .insertion(let idx, let vc):
                    if idx == newStack.count - 1 {
                        navigationController.pushViewController(vc, animated: true)
                    } else {
                        navigationController.viewControllers.insert(vc, at: idx)
                    }
                case .deletion(let idx):
                    navigationController.viewControllers.remove(at: idx)
                }
            })
        }
    },
    prepareRootPresentable: { (rootPresentable, container) in
        let navigationController = container as! UINavigationController
        guard navigationController.viewControllers.count == 0 else { return }
        navigationController.setViewControllers([rootPresentable], animated: false)
    })
}



// MARK: - General

/// Lazy Presenter for a VC that is configured based on a Route.
func lazyParametrizedPresenter(routeDispatcher: ProvidesRouteDispatch) -> RoutePresenter
{
    let presenter = RoutePresenter.lazyPresenter({
        return mockVC()
    },
    setParameters: { parameters, presentable in
        if  let presentable = presentable as? MockViewController,
            let id: String = parameters.pathParameter("id"),
            let route: AppRoute = parameters.pathParameter("route")
        {
            presentable.configure(title: "ID: \(id)", didAppearAction: {
                routeDispatcher.dispatchRoute(route)
            }, buttonTitle: "Second", buttonAction: {
                routeDispatcher.dispatchRoute(AppRoute.second)
            }, backgroundColor: .red)
        }
    })
    
    return presenter
}

/// Lazy Presenter for a VC that is configured based on a Route.
func lazyOnboardingPresenter(routeDispatcher: ProvidesRouteDispatch) -> RoutePresenter
{
    var presenter = RoutePresenter.lazyPresenter({
        mockVC()
    },
    setParameters: { parameters, presentable in
        if let presentable = presentable as? MockViewController, let name: String = parameters.pathParameter("name")
        {
            presentable.configure(title: "Welcome, \(name)", didAppearAction: {
                routeDispatcher.dispatchRoute(AppRoute.onboarding(name: name))
            }, buttonTitle: "Okay", buttonAction: {
                routeDispatcher.dispatchRoute(AppRoute.first)
            }, backgroundColor: .red)
        }
    })
    
    weak var presentedModal: UIViewController? = nil
    presenter.presentModal = { modal, parent in
        guard modal != presentedModal else { return }
        parent.present(modal, animated: true)
        presentedModal = modal
    }
    presenter.unwind = { presentable in
        presentedModal?.dismiss(animated: true, completion: nil)
        presentedModal = nil
    }
    
    return presenter
}

/// Lazy Presenter for a mock VC. Implements modals presentation.
func lazyMockPresenter(for route: AppRoute, routeDispatcher: ProvidesRouteDispatch) -> RoutePresenter
{
    var presenter = RoutePresenter.lazyPresenter({
        return buildEndpoint(for: route, routeDispatcher: routeDispatcher)
    })
    
    weak var presentedModal: UIViewController? = nil
    presenter.presentModal = { modal, parent in
        guard modal != presentedModal else { return }
        parent.present(modal, animated: true)
        presentedModal = modal
    }
    presenter.unwind = { presentable in
        presentedModal?.dismiss(animated: true, completion: nil)
        presentedModal = nil
    }
    
    return presenter
}

/// NOT lazy Presenter for a mock VC, just to notice the difference. Implements modals presentation.
func mockPresenter(for route: AppRoute, routeDispatcher: ProvidesRouteDispatch) -> RoutePresenter
{
    let vc = buildEndpoint(for: route, routeDispatcher: routeDispatcher)
    
    var presenter = RoutePresenter.lazyPresenter({
        return vc
    })
    
    weak var presentedModal: UIViewController? = nil
    presenter.presentModal = { modal, _ in
        guard modal != presentedModal else { return }
        vc.present(modal, animated: true)
        presentedModal = modal
    }
    presenter.unwind = { presentable in
        presentedModal?.dismiss(animated: true, completion: nil)
        presentedModal = nil
    }
    
    return presenter
}
