//
//  EndpointBuilder.swift
//  MonarchRouterExample
//
//  Created by Eliah Snakin on 16/11/2018.
//  Copyright © 2018 nikans.com. All rights reserved.
//

import UIKit
import MonarchRouter


func buildEndpoint(for route: AppRoute, routeDispatcher: ProvidesRouteDispatch) -> UIViewController
{
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "GENERIC_VC") as! ViewController
    
    switch route {
    case .login:
        vc.configure(title: "Login screen", buttonTitle: "Login", buttonAction: {
            routeDispatcher.dispatchRoute(AppRoute.onboarding(name: "USERNAME"))
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
            routeDispatcher.dispatchRoute(AppRoute.modal)
        }, backgroundColor: .darkGray)
      
    case .modal:
        vc.configure(title: "Modal screen", buttonTitle: "Dismiss", buttonAction: {
            vc.dismiss(animated: true, completion: nil)
//            routeDispatcher.dispatchRoute(AppRoute.fifth)
        }, backgroundColor: .blue)
        
    case .modal2:
        vc.configure(title: "Modal screen", buttonTitle: "Back to fifth", buttonAction: {
//            routeDispatcher.dispatchRoute(AppRoute.fifth)
        }, backgroundColor: .red)
        
    case .onboarding(_), .firstDetailParametrized(_), .third(_), .fourth(_):
        fatalError("This VC is built elsewhere")
    }
    
    return vc
}
