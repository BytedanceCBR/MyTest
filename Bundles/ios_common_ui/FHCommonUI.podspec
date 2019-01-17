#
# Be sure to run `pod lib lint FHCommonUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FHCommonUI'
  s.version          = '0.1.0'
  s.summary          = 'A short description of FHCommonUI.'
  s.homepage         = 'https://code.byted.org/fproject/ios_common_ui'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'guchunhui' => 'guchunhui@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:fproject/ios_common_ui.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'FHCommonUI/Classes/**/*.{h,m}'

  s.resources = ['FHCommonUI/Assets/*.xcassets']
  
  # s.resource_bundles = {
  #   'FHCommonUI' => ['FHCommonUI/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'TTKitchen'
end
