# MonarchRouter

[![CI Status](https://img.shields.io/travis/nikans/MonarchRouter.svg?style=flat)](https://travis-ci.org/nikans/MonarchRouter)
[![Version](https://img.shields.io/cocoapods/v/MonarchRouter.svg?style=flat)](https://cocoapods.org/pods/MonarchRouter)
[![License](https://img.shields.io/cocoapods/l/MonarchRouter.svg?style=flat)](https://cocoapods.org/pods/MonarchRouter)
[![Platform](https://img.shields.io/cocoapods/p/MonarchRouter.svg?style=flat)](https://cocoapods.org/pods/MonarchRouter)

![Monarch Router](https://github.com/nikans/MonarchRouter/blob/master/Media/logo@2x.png)

A lightweight yet powerful state-based router written in Swift. 

Monarch Router is a declarative routing handler that decouples ViewControllers from each other via Coordinator and Presenters. Monarch Router fits right in with Redux style State Flow and Reactive frameworks.

The Coordinator is constructed by declaring a route hierarchy mapped with a URL structure. Presenters abstract UI creation and modification.

*Monarch butterflies weight less than 1 gram but cover thousands of miles during their migration. It's considered an iconic pollinator and one of the most beautiful butterfly species.*

## Features

- [x] Navigating complex ViewControlles hierarchy and unwinding on path change.
- [x] Deeplinking to handle Push Notifications, Shortcuts and Universal Links.
- [x] Switching top-level app sections via changing the window's rootViewController.
- [x] Navigating forks (tab bar like presenters).
- [x] Navigating stacks (i.e. navigation controller).
- [x] Opening and dismissing modals, with their own hierarchy.
- [x] Parsing and passing route parameters to endpoints.
- [ ] Handling navigation in universal apps. *(PRs welcome!)*
- [ ] Properly abstracting Router layer to handle navigation in macOS apps.

## Installation

MonarchRouter is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MonarchRouter'
```

You may find the last release version [here](https://github.com/nikans/MonarchRouter/releases).

## Requirements

Currently only iOS/iPhone 8.0+ is properly supported, but theoretically it's easyly extended to support Universal apps. MacOS support requires a new layer of abstraction with generics and stuff, and I think that it's clearer to use as it is for now. *But you are very welcome to contribute!*

- [x] iOS/iPhone
- [ ] iOS/Universal
- [ ] macOS

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## How to use

TODO

See Example App, it's pretty well documented.

## Glossary

TODO


## Principle concepts

### UI is a representation of State

As the State changes over time, so will the UI projection of that State.

Given any State value the UI must be predictable and repeatable.

### Device dependent state should be separate from the Application State.

Displaying the same State on a phone and tablet for example, can result in different UIs. The device dependent state should remain on that device. An OS X and iOS app can use the same State and logic classes and interchange Routers for representing the State.

*Not fully implemented yet. PRs welcome!*

### UI can generate actions to update Path values in the State

The user tapping a back button is easy to capture and generate and action that updates the State Path which causes the UI change. But a user 'swiping' back a view is harder to capture. It should instead generate an action on completion to update the State Path. Then, if the current UI already matches the new State no UI changes are necessary.

*Not fully implemented yet. PRs welcome!*


## Author

Eliah Snakin: eliah@nikans.com

Monarch Router emerged from crysalis of Featherweight Router.

## License

MonarchRouter is available under the MIT license. See the LICENSE file for more info.
