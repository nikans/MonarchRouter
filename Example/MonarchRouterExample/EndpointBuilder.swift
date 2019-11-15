//
//  EndpointBuilder.swift
//  MonarchRouterExample
//
//  Created by Eliah Snakin on 16/11/2018.
//  nikans.com
//

import UIKit
import MonarchRouter



enum EndpointViewControllerId: String
{
    case login = "LoginViewController"
    case onboarding = "OnboardingViewController"
    case today = "TodayViewController"
    case story = "StoryViewController"
    case allNews = "AllNewsViewController"
    case books = "BooksViewController"
    case book = "BookViewController"
//    case booksCategory = ""
    case profile = "ProfileViewController"
    case orders = "OrdersViewController"
    case deliveryInfo = "DeliveryViewController"
    
    var identifier: String {
        return rawValue
    }
}


/// Creates VCs for Routes.
func buildEndpoint(_ endpoint: EndpointViewControllerId, router: ProvidesRouteDispatch) -> UIViewController
{
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: endpoint.identifier)
    if let vc = vc as? MonarchViewController {
        vc.configure(router: router)
    }
    
    return vc
}
