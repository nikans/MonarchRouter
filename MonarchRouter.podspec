Pod::Spec.new do |s|
  s.name             = 'MonarchRouter'
  s.version          = '1.1.2'
  s.summary          = 'A lightweight yet powerful state-based router written in Swift.'

  s.description      = <<-DESC
A lightweight yet powerful functional state-based router written in Swift.

Common URL conventions are used for routing. It's designed for you to feel at home if you ever developed a server-side app routing.

Monarch Router is a declarative routing handler that decouples ViewControllers from each other via Coordinator and Presenters. It fits right in with Redux style state flow and reactive frameworks.

The Coordinator is constructed by declaring a route hierarchy mapped with a URL structure. Presenters abstract UI creation and modification.

Monarch butterflies weight less than 1 gram but cover thousands of miles during their migration. It's considered an iconic pollinator and one of the most beautiful butterfly species.

Features:

- [x] Navigating complex ViewControlles hierarchy and unwinding on path change.
- [x] Parsing and passing route parameters to endpoints, following URL conventions.
- [x] Deeplinking to handle Push Notifications, Shortcuts and Universal Links.
- [x] Navigating forks (tabbar-like presenters).
- [x] Navigating stacks (i.e. navigation controller).
- [x] Opening and dismissing modals, with their own hierarchy.
- [x] Switching top-level app sections via changing the window's rootViewController.
- [x] Scenes handling.
- [ ] Handling navigation in universal apps. *(PRs welcome!)*
- [ ] Properly abstracting Router layer to handle navigation in macOS apps.
                       DESC

  s.homepage         = 'https://github.com/nikans/MonarchRouter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'nikans' => 'eliah@nikans.com' }
  s.source           = { :git => 'https://github.com/nikans/MonarchRouter.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Sources/MonarchRouter/**/*.swift'
  s.frameworks = 'UIKit'
  s.requires_arc  = true
  s.swift_version = '5.0'
  s.screenshots = [ 'https://raw.githubusercontent.com/nikans/MonarchRouter/master/Media/logo%402x.png' ]
end
