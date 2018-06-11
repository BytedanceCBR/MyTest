#
# Be sure to run `pod lib lint Demo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Bubble'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Bubble.'
  s.homepage         = 'https://code.byted.org/TTIOS/Bubble'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'linlin.leo' => 'linlin.leo@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/Bubble.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Bubble/Classes/**/*.{h,swift}'
  
  # s.resource_bundles = {
  #   'Demo' => ['Demo/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'TTKitchen'
end
