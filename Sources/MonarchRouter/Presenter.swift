//
//  Presenter.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 15/11/2018.
//  nikans.com
//

import UIKit



/// Any `RoutePresenter` object.
public protocol RoutePresenterType
{
    /// Returns the actual presentable object.
    var getPresentable: () -> (UIViewController) { get }
    
    /// Allows to configure the presentable with parameters.
    var setParameters: (_ parameters: RouteParameters, _ presentable: UIViewController) -> () { get }
    
    /// Clears up when the node is no longer selected.
    var unwind: (_ presentable: UIViewController) -> () { get }
}



/// A presenter with enabled modals presentation functionality.
public protocol RoutePresenterCapableOfModalPresentationType
{
    /// Callback executed when a modal view is requested to be presented.
    var presentModal: (_ modal: UIViewController, _ over: UIViewController) -> () { get }
    
    /// Callback executed when a presenter is required to close its modal.
    var dismissModal: ((_ modal: UIViewController)->()) { get }
}



/// Used to present the endpoint.
public struct RoutePresenter: RoutePresenterType, RoutePresenterCapableOfModalPresentationType
{
    /// Default initializer for RoutePresenter.
    /// - parameter getPresentable: Callback returning a Presentable object.
    /// - parameter setParameters: Optional callback to configure a Presentable with given `RouteParameters`. Don't set if the Presentable conforms to `RouteParametrizedPresentable`.
    /// - parameter presentModal: Optional callback to define modals presentation. Default behaviour if undefined.
    /// - parameter dismissModal: Optional callback to define modals dismissal. Default behaviour if undefined.
    /// - parameter unwind: Optional callback executed when the Presentable is no longer presented.
    public init(
        getPresentable: @escaping () -> (UIViewController),
        setParameters: ((_ parameters: RouteParameters, _ presentable: UIViewController) -> ())? = nil,
        presentModal: ((_ modal: UIViewController, _ over: UIViewController) -> ())? = nil,
        dismissModal: ((_ modal: UIViewController)->())? = nil,
        unwind: ((_ presentable: UIViewController) -> ())? = nil
    ) {
        self.getPresentable = getPresentable
        
        if let setParameters = setParameters {
            self.setParameters = setParameters
        } else {
            self.setParameters = { parameters, presentable in
                guard let presentable = presentable as? RouteParametrizedPresentable else { return }
                presentable.configure(routeParameters: parameters)
            }
        }
        
        
        weak var presentedModal: UIViewController? = nil
        
        if let presentModal = presentModal {
            self.presentModal = presentModal
        } else {
            self.presentModal = { modal, parent in
                guard modal != presentedModal else { return }
                parent.present(modal, animated: true)
                presentedModal = modal
            }
        }
        
        if let dismissModal = dismissModal {
            self.dismissModal = dismissModal
        } else {
            self.dismissModal = { _ in
                presentedModal?.dismiss(animated: true, completion: nil)
                presentedModal = nil
            }
        }
        
        if let unwind = unwind {
            self.unwind = unwind
        }
    }
    
    
    
    public var presentModal: (_ modal: UIViewController, _ over: UIViewController) -> () = { _,_ in }
    public var dismissModal: ((_ modal: UIViewController)->()) = { _ in }
    
    public let getPresentable: () -> (UIViewController)
    public var setParameters: (_ parameters: RouteParameters, _ presentable: UIViewController) -> () = { _,_ in }
    public var unwind: (_ presentable: UIViewController) -> () = { _ in }
    
    
    
    /// A lazy wrapper around a Presenter creation function that wraps presenter scope, but the Presentable does not get created until invoked.
    /// - parameter getPresentable: Autoclosure returning a Presentable object.
    /// - parameter setParameters: Optional callback to configure a Presentable with given `RouteParameters`. Don't set if the Presentable conforms to `RouteParametrizedPresentable`.
    /// - parameter presentModal: Optional callback to define modals presentation. Default behaviour if undefined.
    /// - parameter dismissModal: Optional callback to define modals dismissal. Default behaviour if undefined.
    /// - parameter unwind: Optional callback executed when the Presentable is no longer presented.
    /// - returns: RoutePresenter
    public static func lazyPresenter(
        _ getPresentable: @escaping () -> (UIViewController),
        setParameters: ((_ parameters: RouteParameters, _ presentable: UIViewController) -> ())? = nil,
        presentModal: ((_ modal: UIViewController, _ over: UIViewController) -> ())? = nil,
        dismissModal: ((_ modal: UIViewController)->())? = nil,
        unwind: ((_ presentable: UIViewController) -> ())? = nil
    ) -> RoutePresenter
    {
        weak var presentable: UIViewController? = nil
        
        let maybeCachedPresentable: () -> (UIViewController) = {
            if let cachedPresentable = presentable {
                return cachedPresentable
            }
            
            let newPresentable = getPresentable()
            presentable = newPresentable
            return newPresentable
        }
        let presenter = RoutePresenter(getPresentable: maybeCachedPresentable, setParameters: setParameters, presentModal: presentModal, dismissModal: dismissModal, unwind: unwind)
        
        return presenter
    }
    
    /// An autoclosure lazy wrapper around a Presenter creation function that wraps presenter scope, but the Presentable does not get created until invoked.
    /// - parameter getPresentable: Autoclosure returning a Presentable object.
    /// - parameter setParameters: Optional callback to configure a Presentable with given `RouteParameters`. Don't set if the Presentable conforms to `RouteParametrizedPresentable`.
    /// - parameter presentModal: Optional callback to define modals presentation. Default behaviour if undefined.
    /// - parameter dismissModal: Optional callback to define modals dismissal. Default behaviour if undefined.
    /// - parameter unwind: Optional callback executed when the Presentable is no longer presented.
    /// - returns: RoutePresenter
    public static func lazyPresenter(
        wrap getPresentable: @escaping @autoclosure () -> (UIViewController),
        setParameters: ((_ parameters: RouteParameters, _ presentable: UIViewController) -> ())? = nil,
        presentModal: ((_ modal: UIViewController, _ over: UIViewController) -> ())? = nil,
        dismissModal: ((_ modal: UIViewController)->())? = nil,
        unwind: ((_ presentable: UIViewController) -> ())? = nil
    ) -> RoutePresenter
    {
        weak var presentable: UIViewController? = nil
        
        let maybeCachedPresentable: () -> (UIViewController) = {
            if let cachedPresentable = presentable {
                return cachedPresentable
            }
            
            let newPresentable = getPresentable()
            presentable = newPresentable
            return newPresentable
        }
        let presenter = RoutePresenter(getPresentable: maybeCachedPresentable, setParameters: setParameters, presentModal: presentModal, dismissModal: dismissModal, unwind: unwind)
        
        return presenter
    }
}
