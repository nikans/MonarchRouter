//
//  ParametersStructs.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 19.10.2019.
//  Copyright © 2019 nikans.com. All rights reserved.
//

import Foundation



/// Parameters structure the presentable is parametrized with.
public struct RouteParameters
{
    init(request: RoutingResolvedRequestType) {
        self.pathParameters = request.pathParameters.mapToDictionary({ parameter in (parameter.name, parameter)
        })
        
        self.queryParameters = request.queryParameters.mapToDictionary({ parameter in (parameter.name, parameter) })
        
        self.fragment = request.fragment
    }
    
    var pathParameters: [String: PathParameterType]
    
    public var stringPathParameters: [String: String] {
        return pathParameters.compactMapValues({
            guard let stringValue = $0.anyValue as? String else { return nil }
            return stringValue
        })
    }
    public func pathParameter(_ key: String) -> String? {
        return stringPathParameters[key] ?? nil
    }
    public func pathParameter<T>(_ key: String) -> T? {
        guard let value = pathParameters[key]?.anyValue as? T else { return nil }
        return value
    }
    
    var queryParameters: [String: QueryParameterType?]
    
    public var stringQueryParameters: [String: String] {
        return queryParameters.compactMapValues({
            guard let stringValue = $0?.anyValue as? String else { return nil }
            return stringValue
        })
    }
    
    public func queryParameter(_ key: String) -> String? {
        return stringQueryParameters[key] ?? nil
    }
    
    public func queryParameter<T>(_ key: String) -> T? {
        guard let value = queryParameters[key]??.anyValue as? T else { return nil }
        return value
    }
    
    public var fragment: String?
}



public protocol PathComponentType {
    var name: String { get }
}



public protocol PathParameterType: PathComponentType {
    var anyValue: Any { get }
}



public struct PathConstant: PathComponentType
{
    public var name: String
    
    public init(_ name: String) {
        self.name = name
    }
}



public struct PathParameter<T>: PathParameterType
{
    public var name: String
    var value: T
    
    public init(_ name: String, _ value: T) {
        self.name = name
        self.value = value
    }
    
    public var anyValue: Any {
        return value
    }
}



public protocol QueryParameterType {
    var name: String { get }
    var anyValue: Any? { get }
}



public struct QueryParameter<T>: QueryParameterType
{
    public var name: String
    var value: T?
    
    public init(_ name: String, _ value: T?) {
        self.name = name
        self.value = value
    }
    
    public var anyValue: Any? {
        return value
    }
}



/// Indicates a presentable can be automatically parametrized.
public protocol RouteParametrizedPresentable
{
    func configure(with uriParameters: RouteParameters)
}
