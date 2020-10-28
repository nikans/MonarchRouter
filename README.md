# MonarchRouter

[![Version](https://img.shields.io/cocoapods/v/MonarchRouter.svg?style=flat)](https://cocoapods.org/pods/MonarchRouter)
[![License](https://img.shields.io/cocoapods/l/MonarchRouter.svg?style=flat)](https://cocoapods.org/pods/MonarchRouter)
[![Platform](https://img.shields.io/cocoapods/p/MonarchRouter.svg?style=flat)](https://cocoapods.org/pods/MonarchRouter)

![Monarch Router](https://github.com/nikans/MonarchRouter/blob/master/Media/logo@2x.png)

A lightweight yet powerful state-based router written in Swift. 

Common URL conventions are used for routing. It's designed for you feel at home if you ever developed a server-side app routing. 

Monarch Router is a declarative routing handler that decouples ViewControllers from each other via Coordinator and Presenters. It fits right in with Redux style State Flow and Reactive frameworks.

The Coordinator is constructed by declaring a route hierarchy mapped with a URL structure. Presenters abstract UI creation and modification.

Monarch Router is distributed via SPM and Cocoapods.

*Monarch butterflies weight less than 1 gram but cover thousands of miles during their migration. It's considered an iconic pollinator and one of the most beautiful butterfly species.*


## Features

- [x] Navigating complex ViewControlles hierarchy and unwinding on path change.
- [x] Deeplinking to handle Push Notifications, Shortcuts and Universal Links.
- [x] Switching top-level app sections via changing the window's rootViewController.
- [x] Navigating forks (tab bar like presenters).
- [x] Navigating stacks (i.e. navigation controller).
- [x] Opening and dismissing modals, with their own hierarchy.
- [x] Parsing and passing route parameters to endpoints, following URL conventions.
- [x] Scenes handling.
- [ ] Handling navigation in universal apps. *(PRs welcome!)*
- [ ] Properly abstracting Router layer to handle navigation in macOS apps.



## Glossary

- `Router`: your app's routing Coordinator (root `RoutingNode` with children); or more broadly speaking, this whole thing. 
- `RoutingNode`: a structure that collects functions together that are related to the same endpoint or intermidiate routing point with children. Each `RoutingNode` also requires a `Presenter`, to which any required changes are passed.
- `RoutePresenter`: a structure used to create and configure a `Presentable` (i.e. `UIViewController`). There're several types of presenters: endpoint, stack (for navigation tree), fork (for tabs), switcher (for inconsequent apps sections).
- `Lazy presenter`: a lazy wrapper around a presenter creation function that wraps presenter scope, but the `Presentable` does not get created until invoked.
- `Presentable`: an actual object to be displayed (i.e. `UIViewController`).

- `RoutingRequest`: a URL or URL-like structure used to define the endpoint you want to navigate to.
- `Route`: a structure that defines matching rules for a `RoutingRequest` to trigger routing to a certain `RoutingNode`.

- `RouterStore`: holds the State for the router. Provides a method to dispatch a `RoutingRequest` and modify the State via a Reducer.
- `RouterState`: holds the stack of active `RoutingNode`s.
- `RouterReducer`: a function to calculate a new State. Implements navigation via `RoutingNode`'s callback. Unwinds unused `RoutingNode`s.


## Example

The example project illustrates the basic usage of the router, as well as some not-trivial use cases, such as modals handling and deeplinking.

If you prefer using Cocoapods, rather than SPM, clone the repo, and run `pod install` from the Example directory first.

**See [Example App](https://github.com/nikans/MonarchRouter/tree/master/Example).**


## How to use

### 0. You may start with creating a `RouterStore`. 
Persist it in your App- or SceneDelegate.

```swift
// Initializing Router and setting root VC
let coordinator = appCoordinator()
let router = RouterStore(router: coordinator)

self.appRouter = router
```


### 1. Define your App's `Routes`. 
Routes are used to match against `RoutingRequest`s.

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
- To match everything to the end of the string use `...`


#### Use built-in `RouteString` structure to create parametrized routes.

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
```


### 1.1. Optionally define a set of `RoutingRequest`s. 

`RoutingRequest` is matched against `Route`s, associated with some `RoutingNode`. 

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


### 1.2. Dispatch routing requests on the `RouterStore` object 

```swift
router.dispatch(.login)
```

You may want to reveal your `RouterStore` to your app as some specialized `ProvidesRouteDispatch` protocol, i.e:

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

```
/// Creating the app's Coordinator hierarchy.
func appCoordinator(...) -> RoutingNodeType
{    
    return
    
    // Top level app sections' switcher
    RoutingNode(sectionsSwitcherRoutePresenter(...)).switcher([

        // Login 
        // (section 0)
        RoutingNode(lazyPresenter(for: .login, ...))
            .endpoint(AppRoute.login),

        // Tabbar 
        // (section 1)
        RoutingNode(lazyTabBarRoutePresenter(...)).fork([

                // Today nav stack
                // (tab 0)
                RoutingNode(lazyNavigationRoutePresenter()).stack([

                    // Today
                    RoutingNode(lazyPresenter(for: .today, ...))
                        .endpoint(AppRoute.today, modals: [

                        // Story 
                        // (presented modally)
                        RoutingNode(lazyPresenter(for: .story, ...))
                            .endpoint(AppRoute.story)
                    ])
                ]),

                // Books nav stack
                // (tab 1)
                RoutingNode(lazyNavigationRoutePresenter()).stack([

                    // Books
                    // (master)
                    RoutingNode(lazyPresenter(for: .books, ...))
                        .endpoint(AppRoute.books, children: [

                        // Book
                        // (detail)
                        RoutingNode(lazyPresenter(for: .book, ...))
                            .endpoint(AppRoute.book)
                        ])
                ])
            ])
    ])
}
```

Each `RoutingNode` either matches a `RoutingRequest` against it's `Route` (i.e. `.endpoint(AppRoute.today)`) or against it's childrens' (not-endpoint type nodes). The suitable sub-hierarchy is then selected, the `RouterState` is reduced to a new one. 

The new nodes stack's `Presenter`s are then instantiating their `Presentable`s (i.e. `UIViewController`s) if necessary, and the app's navigation hierarchy is rebuilt automatically. 

For the magic to happen, you'll need to use or create some presenters first.


### 3. Create Presenters

TBA (see Example app)



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
.package(url: "git@github.com:nikans/MonarchRouter.git", .upToNextMajor(from: "1.1.0"))
```

### CocoaPods

To install it, simply add the following line to your Podfile:

```ruby
pod 'MonarchRouter', '~> 1.1'
```

You may find the last release version [here](https://github.com/nikans/MonarchRouter/releases).


## Requirements

Currently only iOS/iPhone 8.0+ is properly supported, but theoretically it's easyly extended to support Universal apps. MacOS support requires a new layer of abstraction with generics and stuff, and I think that it's clearer to use as it is for now. *But you are very welcome to contribute!*

- [x] iOS/iPhone
- [ ] iOS/Universal
- [ ] macOS


## Author

Eliah Snakin: eliah@nikans.com

Monarch Router emerged from crysalis of Featherweight Router.


## License

MonarchRouter is available under the MIT license. See the LICENSE file for more info.
