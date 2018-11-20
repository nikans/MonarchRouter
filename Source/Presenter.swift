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
    
    /// Allows to configure the presentable with parameters.
    var setParameters: (_ presentable: UIViewController, _ parameters: RouteParameters?) -> () { get }
    
    /// Clears up when the router is no longer selected.
    /// For example used to dismiss presented modals.
    var unwind: (_ presentable: UIViewController) -> () { get }
}



public struct RoutePresenter: RoutePresenterType
{
    /**
     Default initializer for RoutePresenter.
     - parameter getPresentable: callback receiving optional route parameters and returning a VC.
     */
    public init(
        getPresentable: @escaping () -> (UIViewController),
        setParameters: ((_ presentable: UIViewController, _ parameters: RouteParameters?) -> ())? = nil,
        unwind: ((_ presentable: UIViewController) -> ())? = nil
    ) {
        self.getPresentable = getPresentable
        if let setParameters = setParameters {
            self.setParameters = setParameters
        }
        if let unwind = unwind {
            self.unwind = unwind
        }
    }
    
    
    /**
     Creates a lazy wrapper around a presenter creation function that wraps presenter scope, but does not get created until invoked.
     
     - parameter createPresentable: callable that returns the presentable item (UIViewController)
     - returns: RoutePresenter
     */
    public static func lazyPresenter(
        _ createPresentable: @escaping () -> (UIViewController),
        setParameters: ((_ presentable: UIViewController, _ parameters: RouteParameters?) -> ())? = nil,
        presentModal: ((_ modal: UIViewController?, _ over: UIViewController) -> ())? = nil,
        unwind: ((_ presentable: UIViewController) -> ())? = nil
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
        var presenter = RoutePresenter(getPresentable: maybeCachedPresentable, setParameters: setParameters, unwind: unwind)
        if let presentModal = presentModal {
            presenter.presentModal = presentModal
        }
        return presenter
    }
    
    
    public let getPresentable: () -> (UIViewController)
    public var setParameters: (_ presentable: UIViewController, _ parameters: RouteParameters?) -> () = { _,_ in }
    public var unwind: (_ presentable: UIViewController) -> () = { _ in }
    
    /// Callback when a modal view is requested to be presented.
    public var presentModal: (_ modal: UIViewController, _ over: UIViewController) -> () = { _,_ in }
}
