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
    /// Sets the options for router to choose from.
    public let setOptions: (_ options: [UIViewController], _ container: UIViewController) -> ()
    
    /// Sets the specified option as currently selected.
    public let setOptionSelected: (_ option: UIViewController, _ container: UIViewController) -> ()
    
    /**
     Initializer for Fork type RoutePresenter.
     - parameter getPresentable: callback receiving optional route parameters and returning a VC.
     - parameter setOptions: sets the options for router to choose from.
     - parameter setOptionSelected: sets the specified option as currently selected.
     */
    public init(
        getPresentable: @escaping () -> (UIViewController),
        setOptions: @escaping  (_ options: [UIViewController], _ container: UIViewController) -> (),
        setOptionSelected: @escaping  (_ option: UIViewController, _ container: UIViewController) -> ()
    ) {
        self.getPresentable = getPresentable
        self.setOptions = setOptions
        self.setOptionSelected = setOptionSelected
    }
    
    
    /**
     Creates a lazy wrapper around a presenter creation function that wraps presenter scope, but does not get created until invoked.
     
     - parameter createPresentable: callable that returns the presentable item (UIViewController)
     - returns: RoutePresenter
     */
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
