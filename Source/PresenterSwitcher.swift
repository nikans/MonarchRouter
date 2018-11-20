//
//  PresenterSwitcher.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 20/11/2018.
//  Copyright © 2018 nikans.com. All rights reserved.
//

import UIKit


public struct RoutePresenterSwitcher: RoutePresenterType
{
    /// Sets the specified option as currently selected.
    public let setOptionSelected: (_ option: UIViewController) -> ()
    
    /**
     Initializer for Switcher type RoutePresenter.
     - parameter getPresentable: callback receiving optional route parameters and returning a VC.
     - parameter setOptionSelected: sets the specified option as currently selected.
     */
    public init(
        getPresentable: @escaping () -> (UIViewController),
        setOptionSelected: @escaping  (_ option: UIViewController) -> ()
    ) {
        self.getPresentable = getPresentable
        self.setOptionSelected = setOptionSelected
    }
    
    
    /**
     Creates a lazy wrapper around a presenter creation function that wraps presenter scope, but does not get created until invoked.
     
     - parameter createPresentable: callable that returns the presentable item (UIViewController)
     - returns: RoutePresenter
     */
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
