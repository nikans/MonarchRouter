# MonarchRouter

[![Version](https://img.shields.io/cocoapods/v/MonarchRouter.svg?style=flat)](https://cocoapods.org/pods/MonarchRouter)
[![License](https://img.shields.io/cocoapods/l/MonarchRouter.svg?style=flat)](https://cocoapods.org/pods/MonarchRouter)
[![Platform](https://img.shields.io/cocoapods/p/MonarchRouter.svg?style=flat)](https://cocoapods.org/pods/MonarchRouter)

![Monarch Router](https://github.com/nikans/MonarchRouter/blob/master/Media/logo@2x.png)


*Powerful functional state-based router written in Swift.* 

Monarch Router is a declarative routing handler that is capable of managing complex View Controllers hierarchy transitions automatically, decoupling View Controllers from each other via Coordinator and Presenters. It fits right in with Redux style state flow and reactive frameworks.

The Coordinator is constructed by declaring a route hierarchy mapped with a URL structure. Presenters abstract UI creation and modification. Common URL-handling conventions are used for routing. It's designed for you to feel at home if you ever developed a server-side app routing.

Monarch Router is distributed via [SPM](https://github.com/nikans/MonarchRouter#swift-package-manager) and [Cocoapods](https://github.com/nikans/MonarchRouter#cocoapods).

> Monarch butterflies weight less than 1 gram but cover thousands of miles during their migration. It's considered an iconic pollinator and one of the most beautiful butterfly species.


## Features

- [x] Navigating complex View Controllers hierarchy automatically — frome anywhere to anywhere in your app.
- [x] Parsing and passing route parameters to endpoint View Controllers, following URL conventions.
- [x] Deeplinking to handle Push Notifications, Shortcuts and Universal Links.
- [x] Navigating forks (tabbar-like presenters).
- [x] Navigating stacks (i.e. navigation controller).
- [x] Opening and dismissing modals, with their own hierarchy.
- [x] Switching top-level app sections via changing the window's rootViewController.
- [x] Scenes handling.
- [ ] Handling navigation in universal apps. *(PRs welcome!)*
- [ ] Properly abstracting Router layer to handle navigation in macOS apps.


## Glossary

- `Router`: your app's routing Coordinator (root `RoutingNode` with children); or more broadly speaking, this whole thing. 
- `RoutingNode`: a structure that collects functions together that are related to the same endpoint or intermidiate routing point with children. Each `RoutingNode` also requires a `Presenter`, to which any required changes are passed.
- `RoutePresenter`: a structure used to create and configure a `Presentable` (i.e. `UIViewController`). There're several types of presenters: endpoint, stack (for navigation tree), fork (for tabs), switcher (for uncoupled apps sections).
- `Presentable`: an actual object to be displayed (i.e. `UIViewController`).
- Lazy Presenter: a lazy wrapper around a presenter creation function that wraps presenter scope, but the `Presentable` does not get created until invoked.

- `RoutingRequest`: a URL or URL-like structure used to define the endpoint you want to navigate to.
- `Route`: a structure that defines matching rules for a `RoutingRequest` to trigger routing to a certain `RoutingNode`.

- `RouterStore`: holds the State for the router. Provides a method to dispatch a `RoutingRequest` and modify the State via a Reducer.
- `RouterState`: holds the stack of active `RoutingNode`s.
- `RouterReducer`: a function to calculate a new State. Implements navigation via `RoutingNode`'s callback. Unwinds unused `RoutingNode`s.


## Basic flow

1. `RouteRequest` is dispatched on a `RouterStore`. The request is a URL, or URL-like structure. 
2. The new State is calculated by a reducer, matching the request against a Coordinator hierarchy. Each Node in the hierarchy is associated with a `Route` (a matching rule) and a `Presenter` that abstracts the UI.
3. Unused nodes and corresponding presentables are being unwound, presentables hierarchy reloaded based on caclulated State.


## Example

The example project illustrates the basic usage of the router, as well as some not-trivial use cases, such as modals handling.

If you prefer using Cocoapods, rather than SPM, clone the repo, and run `pod install` from the Example directory first.

**See [Example App](https://github.com/nikans/MonarchRouter/tree/master/Example).**


## How to use

### 0. Start with creating a `RouterStore`. 
Persist it in your App- or SceneDelegate.

```swift
// Initializing Router and setting root VC
let coordinator = appCoordinator()
let router = RouterStore(router: coordinator)

self.appRouter = router
```


### 1. Define your App's `Routes`. 
Routes are rules used to match against `RoutingRequest`s. 

```swift
/// Your app custom Routes
enum AppRoute: String, RouteType
{
    case login = "login"
    case today = "today"
    case story = "today/story/:type/:id"
    case books = "books"
    case book  = "books/:id"
}
```

A route is consisted of `RouteComponent`s. These components are matched to the `RouteRequest`'s `PathComponent`s (see below).

There are several ways to define a `Route`:


#### `String` conforms to `RouteType`.

- Components are separated with `/`
- Constant components are just strings (i.e. `login`)
- Parameter components are prefixed with `:`
- To match anything for a component use `:_`
- To match everything to the end of the path use `...`


#### Use built-in `RouteString` structure to create RegExp-validated routes.

```swift
typealias ParameterValidation = (name: String, pattern: String)
init(_ predicate: String, parametersValidation: [ParameterValidation]? = nil)
```

- Use the stated above rules to set a predicate string.
- Optionally add a `ParameterValidation` array, where `name` is a parameter name (without `:`) and `pattern` is a RegExp.


#### Array of `RouteComponent`s conforms to `RouteType`.

Build your `Route` with `RouteComponent` enum:

```swift
enum RouteComponent 
{
    /// Matches a constant component
    case constant(String)
    
    /// Matches a parameter component
    /// - parameter name: parameter name to match
    /// - parameter isMatching: optional closure to match parameter value
    case parameter(name: String, isMatching: ((_ value: Any) -> Bool)? )
    
    /// Matches any path component for a route component
    case anything
    
    /// Matches any path to the end
    case everything
}
```


### 1.1. Optionally define a set of `RoutingRequest`s. 

`RoutingRequest` is matched against `Route`s associated with a `RoutingNode`. 

To make things easy, Monarch Router uses  `URL`s or valid URL-like `String`s to trigger routing. 

URL parts available:
- path components (`books/:id`)
- query items (`?name=eliah`)
- fragment (`#documentation`)


You can dispatch `URL` or `String` directly. Alternatively you can create a custom enum:

```swift
enum AppRoutingRequest: RoutingRequestType
{
    case login
    case today
    case story(type: String, id: Int, title: String)
    case books
    case book(id: Int, title: String?)

    var request: String {
        switch self {
        case .login:
        return "login"

        case .today:
        return "today"

        case .story(let type, let id, let title):
        return "today/story/\(type)/\(id)?title=\(title)"

        case .books:
        return "books"

        case .book(let id, let title):
        return "books/\(id)?title=\(title ?? "")"
    }
}
```

If for your convenience you've decided to define a custom `RoutingRequestType` enum, you'll need a resolver function. Since here we're mapping our requests to a `String`, we'll use it's built-in resolver.

```swift
func resolve(for route: RouteType) -> RoutingResolvedRequestType {
    return request.resolve(for: route)
}
```

Matched Presenters can be parametrized with resolved `RouteParameters` object (see below). 

> Only path parameters are used for matching, though you can configure your presentable based on query parameters and fragment.


### 1.2. Dispatch routing requests on the `RouterStore` object 

```swift
router.dispatch(.login)
```

You may want to hide your `RouterStore` implementation behind a specialized `ProvidesRouteDispatch` protocol, i.e:

```swift
protocol ProvidesRouteDispatch: class
{
    /// Extension method to change the Route.
    /// - parameter request: `AppRoutingRequest` to navigate to.
    func dispatch(_ request: AppRoutingRequest)
}

extension RouterStore: ProvidesRouteDispatch { 
    func dispatch(_ request: AppRoutingRequest) {
        dispatch(request.request)
    }
}
```

But first we need to create a Coordinator.


### 2. Create your app's Coordinator

The Coordinator is a hierarchial `RoutingNode` structure. 

```swift
/// Creating the app's Coordinator hierarchy.
func appCoordinator() -> RoutingNodeType
{    
    return
    
    // Top level app sections' switcher
    RoutingNode(sectionsSwitcherRoutePresenter()).switcher([

        // Login 
        // (section 0)
        RoutingNode(lazyPresenter(for: .login))
            .endpoint(AppRoute.login),

        // Tabbar 
        // (section 1)
        RoutingNode(lazyTabBarRoutePresenter()).fork([

                // Today nav stack
                // (tab 0)
                RoutingNode(lazyNavigationRoutePresenter()).stack([

                    // Today
                    RoutingNode(lazyPresenter(for: .today))
                        .endpoint(AppRoute.today, modals: [

                        // Story 
                        // (presented modally)
                        RoutingNode(lazyPresenter(for: .story))
                            .endpoint(AppRoute.story)
                    ])
                ]),

                // Books nav stack
                // (tab 1)
                RoutingNode(lazyNavigationRoutePresenter()).stack([

                    // Books
                    // (master)
                    RoutingNode(lazyPresenter(for: .books))
                        .endpoint(AppRoute.books, children: [

                        // Book
                        // (detail)
                        RoutingNode(lazyPresenter(for: .book))
                            .endpoint(AppRoute.book)
                        ])
                ])
            ])
    ])
}
```

Depending on it's `Presenter`, a `RoutingNode` can execute one of four types of behavior: 
- endpoint
- stack (i.e. navigation tree)
- fork (i.e. tabs)
- switcher (decoupled app's sections)

Each `RoutingNode` either matches a `RoutingRequest` against it's `Route` (i.e. `.endpoint(AppRoute.today)`) or against its childrens' routes (not-endpoint type nodes). The suitable sub-hierarchy is then selected, the `RouterState` is reduced to a new one. 

The new nodes stack's `Presenter`s are then instantiating their `Presentable`s (i.e. `UIViewController`s) if necessary, and the app's navigation hierarchy is rebuilt automatically. 

UI magic is abstracted in the Presenters.


### 3. Create `Presenter`s

#### Presentable configuration

The main goal of presenters is to create a `Presentable` object. So, when you define a `Presenter` you have to pass a closure for the creation of a Presentable: `getPresentable: () -> (UIViewController)`. 
Currently, only `UIViewController` subtypes are supported.

If a `Presenter` was called with some `RouteParameter`s, an optional closure allowing for the `Presentable` configuration is called: `setParameters: ((_ parameters: RouteParameters, _ presentable: UIViewController) -> ())`.

> *Note*: Conform your Presentable to `RouteParametrizedPresentable` to handle this automatically. 

An optional closure `unwind: (_ presentable: UIViewController) -> ()` is called when the node is no longer selected. You can set it if your Presentable requires any special behavior. 

**Important**: Every `Presenter` can be instantiated directly or lazily. It's advised to use lazy initialization in your Coordinator hierarchy, otherwise all the presentables will be instantiated on the app launch.


#### Built-in Presenters

##### `RoutePresenter` 
is used for endpoint presentation.

The endpoint Presenter is able to present and dismiss modals with the hierarchy of their own. The corresponding closures are called: 

```swift
/// Callback executed when a modal view is requested to be presented.
presentModal: (_ modal: UIViewController, _ over: UIViewController) -> ()

/// Callback executed when a presenter is required to close its modal.
dismissModal: ((_ modal: UIViewController)->())
```
Modal presentation works out of the box, so you may want to use those for the special behavior only.

##### `RoutePresenterFork` 
is used for tabbar-style presentation. 

Special closures are used to configurate a Presentable (i.e. `UITabBarController`) 
```swift
/// Sets the options for Router to choose from
setOptions: (_ options: [UIViewController], _ container: UIViewController) -> ()

/// Sets the specified option as currently selected.
setOptionSelected: (_ option: UIViewController, _ container: UIViewController) -> ()
```
> Use `.junctionsOnly` dispatch option when switching to a tab by it's root Route, when the tab already contains presented stack.

##### `RoutePresenterStack`
is used to organize other Presenters in a navigation stack (i.e. `UINavigationController`).

```swift
/// Sets the navigation stack
setStack: (_ stack: [UIViewController], _ container: UIViewController) -> ()

/// Presets root Presentable when the stack's own Presentable is requested
prepareRootPresentable: (_ rootPresentable: UIViewController, _ container: UIViewController) -> ()
```

##### `RoutePresenterSwitcher`
is used to switch between decoupled app sections (i.e. login sequence, main sequence...)

```swift
/// Sets the specified option as currently selected.
setOptionSelected: (_ option: UIViewController) -> ()
```

This Presenter may probably don't have a Presentable.


#### Example Presenters

The Example app contains several useful Presenters, not made part of the library, i.e: 

- `UITabBarController` presenter built on `RoutePresenterFork` with a delegate to dispatch routing request on tap.
- `UINavigationController` presenter built on `RoutePresenterStack` with relevant pop/push/etc behavior.
- Sections switch presenter built on `RoutePresenterSwitcher`, with ability to set `window`'s `rootViewController`.


## Principle concepts

### UI is a representation of State

As the State changes over time, so will the UI projection of that State.
Given any State value the UI must be predictable and repeatable.

### Device dependent state should be separate from the router State.

Displaying the same State on a phone and tablet for example, can result in different UIs. The device dependent state should remain on that device. An OS X and iOS app can use the same State and logic classes and interchange Routers for representing the State.

*Not fully implemented yet. PRs welcome!*

### UI can generate actions to update the nodes stack in the State

The user tapping a back button is easy to capture and generate an action that updates the State, which causes the UI change. But a user 'swiping' back a view is harder to capture. It should instead generate an action on completion to update the State. Then, if the current UI already matches the new State no UI changes are necessary.


## Installation

### Swift Package Manager

Using Xcode UI: go to your Project Settings -> Swift Packages and add `git@github.com:nikans/MonarchRouter.git` there.

To integrate using Apple's Swift package manager, without Xcode integration, add the following as a dependency to your Package.swift:

```swift
.package(url: "git@github.com:nikans/MonarchRouter.git", .upToNextMajor(from: "1.1.2"))
```

### CocoaPods

To install it, simply add the following line to your Podfile:

```ruby
pod 'MonarchRouter', '~> 1.1.2'
```

You may find the last release version [here](https://github.com/nikans/MonarchRouter/releases).


## Requirements

Currently only iOS/iPhone 8.0+ is properly supported, but theoretically it's easyly extended to support Universal apps. MacOS support requires a new layer of abstraction with generics and stuff, and I think that it's clearer to use as it is for now. *But you are very welcome to contribute!*

- [x] iOS/iPhone
- [ ] iOS/Universal
- [ ] macOS


## Author

Eliah Snakin: eliah@nikans.com

Monarch Router emerged from crysalis of [Featherweight Router](https://github.com/FeatherweightLabs/FeatherweightRouter).


## License

MonarchRouter is available under the MIT license. See the LICENSE file for more info.
