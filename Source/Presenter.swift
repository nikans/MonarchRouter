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
    var getPresentable: () -> (UIViewController) { get }
    
    /// Allows to configure the presentable with parameters
    var setParameters: (_ presentable: UIViewController, _ parameters: RouteParameters?) -> () { get }
}


public struct RoutePresenter: RoutePresenterType
{
    public let getPresentable: () -> (UIViewController)
    
    /**
     Default initializer for RoutePresenter.
     - parameter getPresentable: callback receiving optional route parameters and returning a VC.
     */
    public init(getPresentable: @escaping () -> (UIViewController), setParameters: ((_ presentable: UIViewController, _ parameters: RouteParameters?) -> ())? = nil)
    {
        self.getPresentable = getPresentable
        if let setParameters = setParameters {
            self.setParameters = setParameters
        }
    }
    
    /// Allows to configure the presentable with parameters
    public var setParameters: (_ presentable: UIViewController, _ parameters: RouteParameters?) -> () = { _,_ in }
}


public struct RoutePresenterStack: RoutePresenterType
{
    public let getPresentable: () -> (UIViewController)
    
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
        getPresentable: @escaping () -> (UIViewController),
        setStack: @escaping  ([UIViewController]) -> (),
        prepareRootPresentable: @escaping  (UIViewController) -> ()
    ) {
        self.getPresentable = getPresentable
        self.setStack = setStack
        self.prepareRootPresentable = prepareRootPresentable
    }
    
    public let setParameters: (_ presentable: UIViewController, _ parameters: RouteParameters?) -> () = { _,_ in }
}


public struct RoutePresenterFork: RoutePresenterType
{
    public let getPresentable: () -> (UIViewController)
    
    /// Sets the options for router to choose from.
    public let setOptions: ([UIViewController]) -> ()
    
    /// Sets the specified option as currently selected.
    public let setOptionSelected: (UIViewController) -> ()
    
    /**
     Initializer for Fork type RoutePresenter.
     - parameter getPresentable: callback receiving optional route parameters and returning a VC.
     - parameter setOptions: sets the options for router to choose from.
     - parameter setOptionSelected: sets the specified option as currently selected.
     */
    public init(
        getPresentable: @escaping () -> (UIViewController),
        setOptions: @escaping  ([UIViewController]) -> (),
        setOptionSelected: @escaping  (UIViewController) -> ()
    ) {
        self.getPresentable = getPresentable
        self.setOptions = setOptions
        self.setOptionSelected = setOptionSelected
    }
    
    public let setParameters: (_ presentable: UIViewController, _ parameters: RouteParameters?) -> () = { _,_ in }
}


public struct RoutePresenterSwitcher: RoutePresenterType
{    
    public let getPresentable: () -> (UIViewController)
    
    /// Sets the specified option as currently selected.
    public let setOptionSelected: (UIViewController) -> ()
    
    /**
     Initializer for Switcher type RoutePresenter.
     - parameter getPresentable: callback receiving optional route parameters and returning a VC.
     - parameter setOptionSelected: sets the specified option as currently selected.
     */
    public init(
        getPresentable: @escaping () -> (UIViewController),
        setOptionSelected: @escaping  (UIViewController) -> ()
    ) {
        self.getPresentable = getPresentable
        self.setOptionSelected = setOptionSelected
    }
    
    public let setParameters: (_ presentable: UIViewController, _ parameters: RouteParameters?) -> () = { _,_ in }
}



/**
 Creates a lazy wrapper around a presenter creation function that wraps presenter scope, but does not get created until invoked.
 
 - parameter createPresentable: callable that returns the presentable item (UIViewController)
 - returns: RoutePresenter
 */
public func cachedPresenter(
    _ createPresentable: @escaping () -> (UIViewController),
    setParameters: ((_ presentable: UIViewController, _ parameters: RouteParameters?) -> ())? = nil
) -> RoutePresenter
{
    weak var presentable: UIViewController? = nil
    
    let maybeCachedPresentable: () -> (UIViewController) = {
        if let cachedPresentable = presentable {
            return cachedPresentable
        }
        
        let newPresentable = createPresentable()
        presentable = newPresentable
        return newPresentable
    }
    return RoutePresenter(getPresentable: maybeCachedPresentable, setParameters: setParameters)
}
