//
//  Presenter.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 15/11/2018.
//  nikans.com
//

import UIKit



/// Represents arguments parsed from Path string
public typealias RouteParameters = Dictionary<String, Any>


/// Any `RoutePresenter` object.
public protocol RoutePresenterType
{
    /// Returns the actual presentable object.
    var getPresentable: () -> (UIViewController) { get }
    
    /// Allows to configure the presentable with parameters.
    var setParameters: (_ parameters: RouteParameters, _ presentable: UIViewController) -> () { get }
    
    /// Clears up when the router is no longer selected.
    /// For example used to dismiss presented modals.
    var unwind: (_ presentable: UIViewController) -> () { get }
}



/// Used to present the endpoint.
public struct RoutePresenter: RoutePresenterType
{
    /// Default initializer for RoutePresenter.
    /// - parameter getPresentable: Callback returning a Presentable object.
    /// - parameter setParameters: Optional callback to configure a Presentable with given `RouteParameters`.
    /// - parameter unwind: Optional callback executed when the Presentable is no longer presented. You can use it to dissmiss modals, etc.
    public init(
        getPresentable: @escaping () -> (UIViewController),
        setParameters: ((_ parameters: RouteParameters, _ presentable: UIViewController) -> ())? = nil,
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
    
    
    /// Callback executed when a modal view is requested to be presented.
    public var presentModal: (_ modal: UIViewController, _ over: UIViewController) -> () = { _,_ in }
    
    public let getPresentable: () -> (UIViewController)
    public var setParameters: (_ parameters: RouteParameters, _ presentable: UIViewController) -> () = { _,_ in }
    public var unwind: (_ presentable: UIViewController) -> () = { _ in }
    
    
    /// A lazy wrapper around a Presenter creation function that wraps presenter scope, but the Presentable does not get created until invoked.
    /// - parameter createPresentable: Callback returning a Presentable object.
    /// - parameter setParameters: Optional callback to configure a Presentable with given `RouteParameters`.
    /// - parameter presentModal: Optional callback to handle modals presentation.
    /// - parameter unwind: Optional callback executed when the Presentable is no longer presented. You can use it to dissmiss modals, etc.
    /// - returns: RoutePresenter
    public static func lazyPresenter(
        _ createPresentable: @escaping () -> (UIViewController),
        setParameters: ((_ parameters: RouteParameters, _ presentable: UIViewController) -> ())? = nil,
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
}
