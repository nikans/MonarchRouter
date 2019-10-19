//
//  AppRoutes.swift
//  MonarchRouterExample
//
//  Created by Eliah Snakin on 19.10.2019.
//  Copyright © 2019 nikans.com. All rights reserved.
//

import Foundation



/// Your app custom Routes enum and Paths for them.
enum AppRoute
{
    case login
    case onboarding(name: String)
    case first
    case firstDetail
    case firstDetailParametrized(id: String)
    case second
    case secondDetail
    case third(id: String)
    case fourth(id: String)
    case fifth
    case modal
    case modalParametrized(id: String)
    
    var path: String {
        switch self {
        case .login:                            return "login"
        case .onboarding(let name):             return "onboarding/" + name
        case .first:                            return "first"
        case .firstDetail:                      return "firstDetail"
        case .firstDetailParametrized(let id):  return "firstDetailParametrized/" + id
        case .second:                           return "second"
        case .secondDetail:                     return "secondDetail"
        case .third(let id):                    return "third/" + id
        case .fourth(let id):                   return "fourth/" + id
        case .fifth:                            return "fifth"
        case .modal:                            return "modal"
        case .modalParametrized(let id):        return "modalParametrized/" + id
        }
    }
}
