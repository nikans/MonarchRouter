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
            routeDispatcher.dispatchRoute(AppRoute.main)
        }, backgroundColor: .purple)
        
    case .main:
        vc.configure(title: "Main screen", buttonTitle: "Detail", buttonAction: {
            routeDispatcher.dispatchRoute(AppRoute.detail)
        }, backgroundColor: .magenta)
        
    case .detail:
        vc.configure(title: "Detail screen", buttonTitle: nil, buttonAction: nil, backgroundColor: .red)
        
    case .second:
        vc.configure(title: "Second screen", buttonTitle: nil, buttonAction: nil, backgroundColor: .orange)
        
    case .page(_):
        fatalError("This VC is built elsewhere")
    }
    
    return vc
}
