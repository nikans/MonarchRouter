//
//  RoutingRequest.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 15.11.2019.
//  Copyright © 2019 nikans.com. All rights reserved.
//

import Foundation



public protocol RoutingRequestType
{
    func resolve(for route: RouteType) -> RoutingResolvedRequestType
}



extension URL: RoutingRequestType
{
    public func resolve(for route: RouteType) -> RoutingResolvedRequestType
    {
        let pathComponents: [PathComponentType] = self.pathComponents.enumerated().map { (i, pathComponent) in
            if route.components.count > i, case .parameter(let name, _, _) = route.components[i] {
                return PathParameter(name, pathComponent)
            }
            
            return PathConstant(pathComponent)
        }
        
        
        var queryParameters: [QueryParameterType] = []
        
        if  let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
        {
            for item in queryItems {
                queryParameters.append(QueryParameter(item.name, item.value))
            }
        }
        
        return RoutingRequest(pathComponents: pathComponents, queryParameters: queryParameters, fragment: self.fragment)
    }
}



extension String: RoutingRequestType
{
    public func resolve(for route: RouteType) -> RoutingResolvedRequestType
    {
        guard let string = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: string) else {
            fatalError()
            // TODO:
        }
        
        return url.resolve(for: route)
    }
}



public protocol RoutingResolvedRequestType
{
    var pathComponents: [PathComponentType] { get }
    var pathParameters: [PathParameterType] { get }
    var queryParameters: [QueryParameterType] { get }
    var fragment: String? { get }
}



public struct RoutingRequest: RoutingResolvedRequestType
{
    public var pathComponents: [PathComponentType]
    public var pathParameters: [PathParameterType] {
        return pathComponents.compactMap { element in
            guard let element = element as? PathParameterType else { return nil }
            return element
        }
    }
    
    public var queryParameters: [QueryParameterType]
    public var fragment: String?
}
