//
//  Presenter.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 15/11/2018.
//  Copyright © 2018 AtlasBiomed. All rights reserved.
//

import UIKit


/**
 Represents arguments parsed from Path string
 */
public typealias RouteParameters = Dictionary<String, Any>



public protocol RoutePresenterType
{
    /// Returns the actual presentable object.
    var getPresentable: (_ parameters: RouteParameters?) -> (UIViewController) { get }
}


public struct RoutePresenter: RoutePresenterType
{
    public let getPresentable: (_ parameters: RouteParameters?) -> (UIViewController)
    
    /**
     Default initializer for RoutePresenter.
     - parameter getPresentable: callback receiving optional route parameters and returning a VC.
     */
    public init(getPresentable: @escaping (_ parameters: RouteParameters?) -> (UIViewController))
    {
        self.getPresentable = getPresentable
    }
}


public struct RoutePresenterStack: RoutePresenterType
{
    public let getPresentable: (_ parameters: RouteParameters?) -> (UIViewController)
    
    /// Presets root presentable when the stack's own presentable is requested.
    public var prepareRootPresentable: (UIViewController) -> ()
    
    /// Sets the navigation stack.
    public let setStack: ([UIViewController]) -> ()
    
    /**
     Initializer for Stack type RoutePresenter.
     - parameter getPresentable: callback receiving optional route parameters and returning a VC.
     - parameter setStack: sets the navigation stack.
     - parameter prepareRootPresentable: presets root presentable when the stack's own presentable is requested.
     */
    public init(
        getPresentable: @escaping (_ parameters: RouteParameters?) -> (UIViewController),
        setStack: @escaping  ([UIViewController]) -> (),
        prepareRootPresentable: @escaping  (UIViewController) -> ()
    ) {
        self.getPresentable = getPresentable
        self.setStack = setStack
        self.prepareRootPresentable = prepareRootPresentable
    }
}


public struct RoutePresenterFork: RoutePresenterType
{
    public let getPresentable: (_ parameters: RouteParameters?) -> (UIViewController)
    
    /// Sets the options for router to choose from.
    public let setOptions: ([UIViewController]) -> ()
    
    /// Sets the specified option as currently selected.
    public let setOptionSelected: (UIViewController) -> ()
    
    /**
     Initializer for Stack type RoutePresenter.
     - parameter getPresentable: callback receiving optional route parameters and returning a VC.
     - parameter setOptions: sets the options for router to choose from.
     - parameter setOptionSelected: sets the specified option as currently selected.
     */
    public init(
        getPresentable: @escaping (_ parameters: RouteParameters?) -> (UIViewController),
        setOptions: @escaping  ([UIViewController]) -> (),
        setOptionSelected: @escaping  (UIViewController) -> ()
    ) {
        self.getPresentable = getPresentable
        self.setOptions = setOptions
        self.setOptionSelected = setOptionSelected
    }
}


public struct RoutePresenterSwitcher: RoutePresenterType
{    
    public let getPresentable: (_ parameters: RouteParameters?) -> (UIViewController)
    
    /// Sets the specified option as currently selected.
    public let setOptionSelected: (UIViewController) -> ()
    
    /**
     Initializer for Stack type RoutePresenter.
     - parameter getPresentable: callback receiving optional route parameters and returning a VC.
     - parameter setOptionSelected: sets the specified option as currently selected.
     */
    public init(
        getPresentable: @escaping (_ parameters: RouteParameters?) -> (UIViewController),
        setOptionSelected: @escaping  (UIViewController) -> ()
    ) {
        self.getPresentable = getPresentable
        self.setOptionSelected = setOptionSelected
    }
}



/**
 Creates a lazy wrapper around a presenter creation function that wraps presenter scope, but does not get created until invoked.
 
 - parameter createPresentable: callable that returns the presentable item (UIViewController)
 - returns: RoutePresenter
 */
public func cachedPresenter(
    _ createPresentable: @escaping (_ parameters: RouteParameters?) -> (UIViewController))
    -> RoutePresenter
{
    weak var presentable: UIViewController? = nil
    
    let maybeCachedPresentable: (_ parameters: RouteParameters?) -> (UIViewController) = { params in
        if let cachedPresentable = presentable {
            return cachedPresentable
        }
        
        let newPresentable = createPresentable(params)
        presentable = newPresentable
        return newPresentable
    }
    
    return RoutePresenter(getPresentable: maybeCachedPresentable)
}
