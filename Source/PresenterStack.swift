//
//  PresenterStack.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 20/11/2018.
//  Copyright © 2018 nikans.com. All rights reserved.
//

import UIKit


public struct RoutePresenterStack: RoutePresenterType
{
    /// Initializer for Stack type RoutePresenter.
    /// - parameter getPresentable: Callback returning a Presentable.
    /// - parameter setStack: Sets the navigation stack.
    /// - parameter prepareRootPresentable: Presets root Presentable when the stack's own Presentable is requested.
    public init(
        getPresentable: @escaping () -> (UIViewController),
        setStack: @escaping  (_ stack: [UIViewController], _ container: UIViewController) -> (),
        prepareRootPresentable: @escaping  (_ rootPresentable: UIViewController, _ container: UIViewController) -> ()
    ) {
        self.getPresentable = getPresentable
        self.setStack = setStack
        self.prepareRootPresentable = prepareRootPresentable
    }
    
    
    /// Presets root Presentable when the stack's own Presentable is requested.
    public var prepareRootPresentable: (_ rootPresentable: UIViewController, _ container: UIViewController) -> ()
    
    /// Sets the navigation stack.
    public let setStack: (_ stack: [UIViewController], _ container: UIViewController) -> ()
    
    
    
    /// Creates a lazy wrapper around a presenter creation function that wraps presenter scope, but does not get created until invoked.
    /// - parameter createPresentable: Callback that returns the Presentable item.
    /// - parameter setStack: Sets the navigation stack.
    /// - parameter prepareRootPresentable: Presets root Presentable when the stack's own Presentable is requested.
    /// - returns: RoutePresenter
    public static func lazyPresenter(
        _ createPresentable: @escaping () -> (UIViewController),
        setStack: @escaping  (_ stack: [UIViewController], _ container: UIViewController) -> (),
        prepareRootPresentable: @escaping  (_ rootPresentable: UIViewController, _ container: UIViewController) -> ()
    ) -> RoutePresenterStack
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
        
        return RoutePresenterStack(getPresentable: maybeCachedPresentable, setStack: setStack, prepareRootPresentable: prepareRootPresentable)
    }
    
    
    // Immutable, since either configured during init, or doesn't apply.
    public let getPresentable: () -> (UIViewController)
    public let setParameters: (_ presentable: UIViewController, _ parameters: RouteParameters?) -> () = { _,_ in }
    public let unwind: (_ presentable: UIViewController) -> () = { _ in }
}
