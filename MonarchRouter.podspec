Pod::Spec.new do |s|
  s.name             = 'MonarchRouter'
  s.version          = '0.9.1'
  s.summary          = 'A lightweight yet powerful state-based router written in Swift.'

  s.description      = <<-DESC
A lightweight yet powerful state-based router written in Swift.

Monarch Router is a declarative routing handler that decouples ViewControllers from each other via Coordinator and Presenters. Monarch Router fits right in with Redux style State Flow and Reactive frameworks.

The Coordinator is constructed by declaring a route hierarchy mapped with a URL structure. Presenters abstract UI creation and modification.

Monarch butterflies weight less than 1 gram but cover thousands of miles during their migration. It's considered an iconic pollinator and one of the most beautiful butterfly species.

Features:

- [x] Navigating complex ViewControlles hierarchy and unwinding on path change.
- [+] Switching top-level app sections via setting the window's rootViewController.
- [+] Navigating forks (tab bar like presenters).
- [+] Navigating stacks (i.e. navigation controller).
- [+] Opening and dismissing modals.
- [+] Passing and parsing route parameters to endpoints.
- [ ] Handling navigation in universal apps. (PRs welcome!)
- [ ] Properly abstracting Router layer to handle navigation in macOS apps.
                       DESC

  s.homepage         = 'https://github.com/nikans/MonarchRouter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'nikans' => 'ilya@nikans.com' }
  s.source           = { :git => 'https://github.com/nikans/MonarchRouter.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/**/*.swift'
  s.frameworks = 'UIKit'
  s.requires_arc  = true
  s.swift_version = '4.2'
  s.screenshots = [ 'https://raw.githubusercontent.com/nikans/MonarchRouter/master/Media/logo%402x.png' ]
end
