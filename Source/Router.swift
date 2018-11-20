import UIKit


public protocol RouterType
{
    var setPath: (_ path: String, _ routers: [RouterType]) -> [RouterType] { get }
    func unwind() -> ()
    
    func getPresentable() -> UIViewController    
    var shouldHandleRoute: (_ path: String) -> Bool { get }
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
    public func getPresentable() -> UIViewController {
        return presenter.getPresentable()
    }
    
    /// Determines should this Router handle the given path.
    /// Configured for each respective Router type.
    public internal(set) var shouldHandleRoute: (_ path: String) -> Bool
        = { _ in false }
    
    /// Passes actions to the Presenter to update the view for the provided path.
    /// Configured for each respective Router type.
    public var setPath: (_ path: String, _ routers: [RouterType]) -> [RouterType]
        = { _,_ in [] }
    
    public func unwind() -> () {
        presenter.unwind(presenter.getPresentable())
    }
}


extension Router where Presenter == RoutePresenterStack
{
    /// Stack router can be used to organize routes in navigation stack.
    public func stack(_ stack: [RouterType]) -> Router
    {
        var router = self
        
        router.shouldHandleRoute = { path in
            // checking if any of the children can handle the route
            return stack.contains { subRouter in subRouter.shouldHandleRoute(path) }
        }
        
        router.setPath = { path, routers in
            if let stackItem = stack.firstResult({ stackItem in stackItem.shouldHandleRoute(path) ? stackItem : nil })
            {
                let stackRouters = stackItem.setPath(path, [])
                
                // passing the navigation stack to the presenter
                router.presenter.setStack(stackRouters.map({ subRouter in subRouter.getPresentable() }))

                return routers + [router] + stackRouters
            }
            
            return routers + [router]
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
        
        router.setPath = { path, routers in
            // passing children as options for the presenter
            router.presenter.setOptions(options.map { option in option.getPresentable() })
            
            if let option = options.firstResult({ option in option.shouldHandleRoute(path) ? option : nil })
            {
                // setup the presenter for matching Router and set it as an active option
                router.presenter.setOptionSelected(option.getPresentable())
                return option.setPath(path, routers + [router])
            }
            
            return routers + [router]
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
        
        router.setPath = { path, routers in
            // finding an option to handle the route
            if let option = options.firstResult({ option in option.shouldHandleRoute(path) ? option : nil })
            {
                // setup the presenter for matching Router and set it as an active option
                router.presenter.setOptionSelected(option.getPresentable())
                return option.setPath(path, routers + [router])
            }
            
            return routers + [router]
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
        
        router.setPath = { path, routers in
            let params = parameters?(path)
            
            if isMatching(path) {
                // setting parameters
                let presentable = router.getPresentable()
                router.presenter.setParameters(presentable, params)
                
                // dismissing modal if needed
                router.presenter.presentModal(nil, presentable)
                
                return routers + [router]
            }
            
            else if let modal = modals.firstResult({ modal in modal.shouldHandleRoute(path) ? modal : nil })
            {
                let presentable = router.getPresentable()
                router.presenter.presentModal(modal.getPresentable(), presentable)
                return modal.setPath(path, routers + [router])
            }
            
            else if let child = children.firstResult({ child in child.shouldHandleRoute(path) ? child : nil })
            {
                return child.setPath(path, routers + [router])
            }
            
            return routers
        }
        
        return router
    }
}
