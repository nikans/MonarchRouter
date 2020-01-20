//
//  PresenterStack.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 20/11/2018.
//  nikans.com
//

import UIKit



/// Can be used to organize other Presenters in a navigation stack.
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
    
    
    
    /// A lazy wrapper around a Presenter creation function that wraps presenter scope, but the Presentable does not get created until invoked.
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
    public let setParameters: (_ parameters: RouteParameters, _ presentable: UIViewController) -> () = { _,_ in }
    public let unwind: (_ presentable: UIViewController) -> () = { _ in }
}
