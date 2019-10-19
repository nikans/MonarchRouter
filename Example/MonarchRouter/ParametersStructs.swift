//
//  ParametersStructs.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 19.10.2019.
//  Copyright © 2019 nikans.com. All rights reserved.
//

import Foundation



/// Represents arguments parsed from path component of Path string
public typealias PathParameters = [String: Any?]



/// Parameters structure the presentable is parametrized with.
public struct RouteURIParameters
{
    public init(uri: URL, pathParameters: PathParameters?)
    {
        let string: String = uri.absoluteString
        let path: String = uri.path
        let query: String? = uri.query
        let queryParameters: [String: String?]?
        let fragment: String? = uri.fragment
        
        if  let components = URLComponents(url: uri, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
        {
            var parameters = [String: String?]()
            for item in queryItems {
                parameters[item.name] = item.value
            }
            queryParameters = parameters
        } else {
            queryParameters = nil
        }
        
        self = RouteURIParameters(string: string, path: path, pathParameters: pathParameters, query: query, queryParameters: queryParameters, fragment: fragment)
    }
    
    public init(uriString: String, pathParameters: PathParameters?) {
        guard let uri = URL(string: uriString) else {
            self = RouteURIParameters(string: uriString, path: uriString, pathParameters: pathParameters, query: nil, queryParameters: nil, fragment: nil)
            return
        }
        
        self = RouteURIParameters(uri: uri, pathParameters: pathParameters)
    }
    
    init(string: String, path: String, pathParameters: PathParameters?, query: String?, queryParameters: [String: String?]?, fragment: String?)
    {
        self.string = string
        self.path = path
        self.pathParameters = pathParameters
        self.query = query
        self.queryParameters = queryParameters
        self.fragment = fragment
    }
    
    public let string: String
    
    public let path: String
    
    public let pathParameters: PathParameters?
    public var stringPathParameters: [String: String?]? {
        return pathParameters?.compactMapValues({
            guard let stringValue = $0 as? String else { return nil }
            return stringValue
        })
    }
    public func pathParameter(_ key: String) -> String? {
        return stringPathParameters?[key] ?? nil
    }
    public func pathParameter<T>(_ key: String) -> T? {
        guard let parameter = pathParameters?[key] as? T else { return nil }
        return parameter
    }
    
    public let query: String?
    public let queryParameters: [String: String?]?
    
    public let fragment: String?
}



/// Indicates a presentable can be automatically parametrized.
public protocol URIParametrizedPresentable
{
    func configure(with uriParameters: RouteURIParameters)
}
