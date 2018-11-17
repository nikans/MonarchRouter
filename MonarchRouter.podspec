#
# Be sure to run `pod lib lint MonarchRouter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MonarchRouter'
  s.version          = '0.1.0'
  s.summary          = 'A lightweight yet powerful state-based router written in Swift.'

  s.description      = <<-DESC
Monarch Router is a declarative routing handler that decouples ViewControllers from each other. It follows a Coordinator and Presenter pattern, also referred to as Flow Controllers.

Monarch Router makes an excellent MVVM companion and fits right in with Redux style State Flow and Reactive frameworks.

The Coordinator is constructed by declaring a route hierarchy mapped with a URL structure.

Monarch Router is inspired by Featherweight Router.
                       DESC

  s.homepage         = 'https://github.com/nikans/MonarchRouter'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'nikans' => 'ilya@nikans.com' }
  s.source           = { :git => 'https://github.com/nikans/MonarchRouter.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/**/*.swift'
  s.frameworks = 'UIKit'
  s.requires_arc  = true
  s.swift_version = '4.2'
end
