//
//  RouteType.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 13.11.2019.
//  Copyright © 2019 nikans.com. All rights reserved.
//

import Foundation



public enum RouteComponent
{
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
    func isMatching(path: [PathComponentType]) -> Bool
    func isMatching(request: RoutingRequestType) -> Bool
}



extension RouteType
{
    public func isMatching(path pathComponents: [PathComponentType]) -> Bool
    {
        guard components.count > 0 else { return false }
        
        for (i, routeComponent) in components.enumerated() {
            if pathComponents.count <= i {
                switch routeComponent {
                case .anything, .everything:
                    break
                default:
                    return false
                }
            } else if !routeComponent.isMatching(pathComponent: pathComponents[i]) {
                return false
            }
        }
        
        if pathComponents.count > components.count, let lastComponent = components.last {
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
        let pathComponents = request.pathComponents
        return isMatching(path: pathComponents)
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



public struct RouteString: RouteType
{
    public typealias ParameterValidation = (name: String, pattern: String)
    
    public init(_ predicate: String, parametersValidation: [ParameterValidation]? = nil)
    {
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
    
    public let components: [RouteComponent]
}



extension Array: RouteType where Element == RouteComponent
{
    public var components: [RouteComponent] {
        return self
    }
    
    public init(_ components: [RouteComponent]) {
        self = components
    }
}
