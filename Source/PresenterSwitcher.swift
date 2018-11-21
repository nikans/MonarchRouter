//
//  PresenterSwitcher.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 20/11/2018.
//  nikans.com
//

import UIKit


/// Can be used to switch top level app sections.
public struct RoutePresenterSwitcher: RoutePresenterType
{
    /// Initializer for Switcher type RoutePresenter.
    /// - parameter getPresentable: Callback returning a Presentable.
    /// - parameter setOptionSelected: Sets the specified option as currently selected.
    public init(
        getPresentable: @escaping () -> (UIViewController),
        setOptionSelected: @escaping  (_ option: UIViewController) -> ()
    ) {
        self.getPresentable = getPresentable
        self.setOptionSelected = setOptionSelected
    }
    
    
    /// Sets the specified option as currently selected.
    public let setOptionSelected: (_ option: UIViewController) -> ()
    
    
    
    /// Creates a lazy wrapper around a presenter creation function that wraps presenter scope, but does not get created until invoked.
    /// - parameter createPresentable: Callback that returns the Presentable item.
    /// - parameter setOptionSelected: Sets the specified option as currently selected.
    /// - returns: RoutePresenter
    public static func lazyPresenter(
        _ createPresentable: @escaping () -> (UIViewController),
        setOptionSelected: @escaping  (_ option: UIViewController) -> ()
    ) -> RoutePresenterSwitcher
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
        
        return RoutePresenterSwitcher(getPresentable: maybeCachedPresentable, setOptionSelected: setOptionSelected)
    }
    
    
    // Immutable, since either configured during init, or doesn't apply.
    public let getPresentable: () -> (UIViewController)
    public let setParameters: (_ presentable: UIViewController, _ parameters: RouteParameters?) -> () = { _,_ in }
    public let unwind: (_ presentable: UIViewController) -> () = { _ in }
}
