import UIKit


public protocol RouterType
{
    var setPath: (_ path: String) -> () { get }
    
    func getPresentable() -> UIViewController
    func getPresentable(parameters: RouteParameters?) -> UIViewController
    
    var shouldHandleRoute: (_ path: String) -> Bool { get }
    var presentablesChain: (_ path: String) -> [UIViewController]? { get }
}



/**
 The Router is a structure that collects functions together that are related to the same routing unit.
 
 Each Router also requires a Presenter, to which any required changes are passed.
 */
public struct Router<Presenter: RoutePresenterType>: RouterType
{
    public init(_ presenter: Presenter) {
        self.presenter = presenter
    }
    
    /// Presenter to pass UI actions to.
    internal var presenter: Presenter
    
    /// The presentable to return if this Router matches the path.
    public func getPresentable(parameters: RouteParameters?) -> UIViewController
    {
        onGetPresentable(parameters)
        let presentable = presenter.getPresentable()
        presenter.setParameters(presentable, parameters)
        return presentable
    }
    
    public func getPresentable() -> UIViewController {
        return getPresentable(parameters: nil)
    }
    
    /// Called when `getPresentable(_:)` for this Router is called.
    internal var onGetPresentable: (_ parameters: RouteParameters?) -> ()
        = { _ in }
    
    /// Determines should this Router handle the given path.
    /// Configured for each respective Router type.
    public internal(set) var shouldHandleRoute: (_ path: String) -> Bool
        = { _ in false }
    
    /// Passes actions to the Presenter to update the view for the provided path.
    /// Configured for each respective Router type.
    public var setPath: (_ path: String) -> ()
        = { _ in }
    
    /// Returns an array of presentables that match the path. The actual array returned can vary depending on Router type.
    public internal(set) var presentablesChain: (_ path: String) -> [UIViewController]?
        = { _ in nil }
}


extension Router where Presenter == RoutePresenterStack
{
    /// Stack router can be used to organize routes in navigation stack.
    public func stack(_ stack: [RouterType]) -> Router
    {
        var router = self
        
        router.onGetPresentable = { parameters in
            // setting default root view controller if any
            if let rootChild = stack.first?.getPresentable(parameters: parameters) {
                router.presenter.prepareRootPresentable(rootChild)
            }
        }
        
        router.shouldHandleRoute = { path in
            // checking if any of the children can handle the route
            return stack.contains { subRouter in subRouter.shouldHandleRoute(path) }
        }
        
        router.setPath = { path in
            // passing the navigation stack to the presenter
            router.presenter.setStack(stack.firstResult({ subRouter in subRouter.presentablesChain(path) }) ?? [])
        }
        
        return router
    }
}


extension Router where Presenter == RoutePresenterFork
{
    /// Fork router can be used for tabbar-like navigation.
    public func fork(_ options: [RouterType]) -> Router
    {
        var router = self
        
        router.shouldHandleRoute = { path in
            // checking if any of the children can handle the route
            return options.contains { option in option.shouldHandleRoute(path) }
        }
        
        router.setPath = { path in
            // passing children as options for the presenter
            router.presenter.setOptions(options.map { option in option.getPresentable() })
            
            if let option = options.firstResult({ option in option.shouldHandleRoute(path) ? option : nil })
            {
                // setup the presenter for matching Router
                option.setPath(path)
                // and set it as an active option
                router.presenter.setOptionSelected(option.getPresentable())
            }
        }
        
        return router
    }
}


extension Router where Presenter == RoutePresenterSwitcher
{
    /// Switcher router can be used to switch sections of your app,
    /// like onboarding/login/main, by the means of changing
    /// rootViewController of a window or similar.
    /// This Router's presenter doesn't have an actual view.
    public func switcher(_ options: [RouterType]) -> Router
    {
        var router = self
        
        router.shouldHandleRoute = { path in
            // checking if any of the children can handle the route
            return options.contains { option in option.shouldHandleRoute(path) }
        }
        
        router.setPath = { path in
            // finding an option to handle the route
            if let option = options.firstResult({ option in option.shouldHandleRoute(path) ? option : nil })
            {
                // setup the presenter for matching Router
                option.setPath(path)
                // and set it as an active option
                router.presenter.setOptionSelected(option.getPresentable())
            }
        }
        
        return router
    }
}


extension Router where Presenter == RoutePresenter
{
    /// Endpoint router represents an actual target to navigate to.
    public func endpoint(
        predicate isMatching: @escaping ((_ path: String) -> Bool),
        parameters: ((_ path: String) -> RouteParameters)? = nil,
        children: [RouterType] = [],
        modals: [RouterType] = []
    ) -> Router
    {
        var router = self
        
        router.shouldHandleRoute = { path in
            // checking if this router or any of the children can handle the route
            return isMatching(path)
                || children.contains { $0.shouldHandleRoute(path) }
                || modals.contains { $0.shouldHandleRoute(path) }
        }
        
        router.setPath = { path in
            if isMatching(path) {
                // setting parameters
                let presentable = router.getPresentable()
                let params = parameters?(path)
                router.presenter.setParameters(presentable, params)
            }
            
            else if let modal = modals.firstResult({ modal in modal.shouldHandleRoute(path) ? modal : nil }) {
                let presentable = router.getPresentable()
                router.presenter.presentModal(modal.getPresentable(), presentable)
            }
        }
        
        router.presentablesChain = { path in
            let routeParameters = parameters?(path)
            
            // this Router is the required endpoint
            if isMatching(path) {
                return [router.getPresentable(parameters: routeParameters)]
            }
            
            // the child of this Router is the endpoint
            for child in children {
                if let stack = child.presentablesChain(path) {
                    return [router.getPresentable(parameters: routeParameters)] + stack
                }
            }
            
            // no match
            return nil
        }
        
        return router
    }
}
