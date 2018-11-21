//
//  PresenterFork.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 20/11/2018.
//  Copyright © 2018 nikans.com. All rights reserved.
//

import UIKit


public struct RoutePresenterFork: RoutePresenterType
{
    /// Initializer for Fork type RoutePresenter.
    /// - parameter getPresentable: Callback returning a Presentable.
    /// - parameter setOptions: Sets the options for Router to choose from.
    /// - parameter setOptionSelected: Sets the specified option as currently selected.
    public init(
        getPresentable: @escaping () -> (UIViewController),
        setOptions: @escaping  (_ options: [UIViewController], _ container: UIViewController) -> (),
        setOptionSelected: @escaping  (_ option: UIViewController, _ container: UIViewController) -> ()
    ) {
        self.getPresentable = getPresentable
        self.setOptions = setOptions
        self.setOptionSelected = setOptionSelected
    }
    
    
    /// Sets the options for Router to choose from.
    public let setOptions: (_ options: [UIViewController], _ container: UIViewController) -> ()
    
    /// Sets the specified option as currently selected.
    public let setOptionSelected: (_ option: UIViewController, _ container: UIViewController) -> ()
    
    
    
    /// Creates a lazy wrapper around a presenter creation function that wraps presenter scope, but does not get created until invoked.
    /// - parameter createPresentable: Callback that returns the Presentable item.
    /// - parameter setOptions: Sets the options for Router to choose from.
    /// - parameter setOptionSelected: Sets the specified option as currently selected.
    /// - returns: RoutePresenter
    public static func lazyPresenter(
        _ createPresentable: @escaping () -> (UIViewController),
        setOptions: @escaping  (_ options: [UIViewController], _ container: UIViewController) -> (),
        setOptionSelected: @escaping  (_ option: UIViewController, _ container: UIViewController) -> ()
    ) -> RoutePresenterFork
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
        
        return RoutePresenterFork(getPresentable: maybeCachedPresentable, setOptions: setOptions, setOptionSelected: setOptionSelected)
    }
    
    
    // Immutable, since either configured during init, or doesn't apply.
    public let getPresentable: () -> (UIViewController)
    public let setParameters: (_ presentable: UIViewController, _ parameters: RouteParameters?) -> () = { _,_ in }
    public let unwind: (_ presentable: UIViewController) -> () = { _ in }
}
