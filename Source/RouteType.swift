//
//  RouteType.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 13.11.2019.
//  Copyright © 2019 nikans.com. All rights reserved.
//

import Foundation



public enum RouteComponent {
    case constant(String)
    case parameter(name: String, type: Any.Type?, isMatching: ((_ value: Any) -> Bool)? )
    case anything
    case everything
    
    func isMatching(pathComponent: PathComponentType) -> Bool {
        switch self {
            
        case .constant(let name):
            guard let pathComponent = pathComponent as? PathConstant else { return false }
            return pathComponent.name == name
            
        case .parameter(let name, let parameterType, let isMatching):
            // path component is not a parameter
            guard let pathComponent = pathComponent as? PathParameterType
                else { return false }
            
            // undefined route parameter match closure (ok)
            guard let isMatching = isMatching
                else { return pathComponent.name == name }
            
            // path parameter type does not match route parameter type
            guard isMatching(pathComponent.anyValue)
                else { return false }
            
//            guard let parameterType = parameterType
//                else { return pathComponent.name == name }
//
//            guard type(of: pathComponent.anyValue) == parameterType
//                else { return false }
            
            return pathComponent.name == name
            
        case .anything, .everything:
            return true
        }
    }
}


public protocol RouteType
{
    var components: [RouteComponent] { get }
    func isMatching(path: Path) -> Bool
    func isMatching(request: RoutingRequestType) -> Bool
}

extension RouteType
{
    public func isMatching(path: Path) -> Bool {
        guard components.count > 0 else { return false }
        
        for (i, routeComponent) in components.enumerated() {
            if path.count <= i || !routeComponent.isMatching(pathComponent: path[i]) {
                return false
            }
        }
        
        if path.count > components.count, let lastComponent = components.last {
            switch lastComponent {
            case .anything, .everything:
                return true
            default:
                return false
            }
        }
        
        return true
    }
    
    public func isMatching(request: RoutingRequestType) -> Bool {
        guard components.count > 0 else { return false }
        
        let request = request.resolve(for: self)
//        print(components)
        for (i, routeComponent) in components.enumerated() {
            if request.pathComponents.count <= i {
                switch routeComponent {
                case .anything, .everything:
                    break
                default:
                    return false
                }
            } else if !routeComponent.isMatching(pathComponent: request.pathComponents[i]) {
                return false
            }
        }
        
        if request.pathComponents.count > components.count, let lastComponent = components.last {
            switch lastComponent {
            case .anything, .everything:
                return true
            default:
                return false
            }
        }
        
        return true
    }
}


extension String: RouteType
{
    public var components: [RouteComponent] {
        return self.components(separatedBy: "/")
            .filter({ $0.count > 0 })
            .map { component in
                if component == "..." {
                    return .anything
                }
                
                if component == ":_" {
                    return .everything
                }
                
                if component.hasPrefix(":") {
                    let name = String(component.dropFirst())
                    return .parameter(name: name, type: nil, isMatching: nil)
                }
                
                return .constant(component)
            }
    }
}


struct RouteString: RouteType
{
    typealias ParameterValidation = (name: String, pattern: String)
    
    init(_ predicate: String, parametersValidation: [ParameterValidation]? = nil) {
        let parametersValidation: Dictionary<String, String> = parametersValidation?.mapToDictionary { parameter in
            return (parameter.name, parameter.pattern)
        } ?? [:]
        
        self.components = predicate.components(separatedBy: "/")
            .filter({ $0.count > 0 })
            .map { component in
                if component == "..." {
                    return .anything
                }
                
                if component == ":_" {
                    return .everything
                }
                
                if component.hasPrefix(":") {
                    let name = String(component.dropFirst())
                    
                    let isMatching: ((_ value: Any) -> Bool)?
                    if let parameterValidation = parametersValidation[name] {
                        isMatching = { value in
                            guard let value = value as? String else { return false }
                            return value.matches(parameterValidation)
                        }
                    } else {
                        isMatching = nil
                    }
                    
                    return .parameter(name: name, type: nil, isMatching: isMatching)
                }
                
                return .constant(component)
        }
    }
    
    let components: [RouteComponent]
}


extension Array: RouteType where Element == RouteComponent
{
    public var components: [RouteComponent] {
        return self
    }
    
    init(_ components: [RouteComponent]) {
        self = components
    }
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



public typealias Path = [PathComponentType]

extension Path {
    public init(_ components: [PathComponentType]) {
        self = components
    }
}



struct Test {
    init() {
//        let route: Route = [.constant("test"), .parameter(name: "id", type: Int.self)]
        let route = "user/:id/..."
//        let route = RouteString("user/:id/...", parametersValidation: [(name: "id", pattern: "[\\w\\-\\.]+")])
        
//        let path = Path([PathConstant("user"), PathParameter("id", "shit"), PathParameter("name", "loh")])
        let request = "user/shit"

        print(route.isMatching(request: request))
        print(request.resolve(for: route))
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




public protocol RoutingRequestType
{
    func resolve(for route: RouteType) -> RoutingResolvedRequestType
}

extension URL: RoutingRequestType
{
    public func resolve(for route: RouteType) -> RoutingResolvedRequestType
    {
        let pathComponents: [PathComponentType] = self.pathComponents.enumerated().map { (i, pathComponent) in
            if route.components.count > i, case .parameter(let name, let parameterType, _) = route.components[i] {
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
