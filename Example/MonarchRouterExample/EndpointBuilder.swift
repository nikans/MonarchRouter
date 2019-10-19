//
//  EndpointBuilder.swift
//  MonarchRouterExample
//
//  Created by Eliah Snakin on 16/11/2018.
//  nikans.com
//

import UIKit
import MonarchRouter



/// Creates a mock VC.
func mockVC() -> MockViewController
{
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    return storyboard.instantiateInitialViewController() as! MockViewController
}


/// Creates VCs for non-parametrized Routes.
func buildEndpoint(for route: AppRoute, routeDispatcher: ProvidesRouteDispatch) -> UIViewController
{
    let vc = mockVC()
    
    switch route {
    case .login:
        vc.configure(title: "Login screen",buttonTitle: "Login", buttonAction: {
            routeDispatcher.dispatchRoute(AppRoute.onboarding(name: "USER NAME"))
        }, backgroundColor: .purple)
        
    case .first:
        vc.configure(title: "Main screen", buttonTitle: "Detail", buttonAction: {
            routeDispatcher.dispatchRoute(AppRoute.firstDetail)
        }, backgroundColor: .magenta)
        
    case .firstDetail:
        vc.configure(title: "First detail", buttonTitle: "Parametrized Detail", buttonAction: {
            routeDispatcher.dispatchRoute(AppRoute.firstDetailParametrized(id: "-firstDetail"))
        }, backgroundColor: .magenta)
        
    case .second:
        vc.configure(title: "Second screen", buttonTitle: "Second detail", buttonAction: {
            routeDispatcher.dispatchRoute(AppRoute.secondDetail)
        }, backgroundColor: .orange)
        
    case .secondDetail:
        vc.configure(title: "Second detail", buttonTitle: "First detail", buttonAction: {
            routeDispatcher.dispatchRoute(AppRoute.firstDetail)
        }, backgroundColor: .orange)
        
    case .fifth:
        vc.configure(title: "Fifth screen", buttonTitle: "Modal", buttonAction: {
            routeDispatcher.dispatchRoute(AppRoute.modalParametrized(id: "-someModal"))
        }, backgroundColor: .darkGray)
      
    case .modal:
        vc.configure(title: "Modal screen", buttonTitle: "Fifth", buttonAction: {
            routeDispatcher.dispatchRoute(AppRoute.fifth)
        }, backgroundColor: .blue)
        
    case .onboarding(_), .firstDetailParametrized(_), .third(_), .fourth(_), .modalParametrized(_):
        fatalError("This VC is built elsewhere")
    }
    
    return vc
}
