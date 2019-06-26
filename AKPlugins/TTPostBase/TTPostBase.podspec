#
# Be sure to run `pod lib lint TTPostBase.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTPostBase'
  s.version          = '0.1.4'
  s.summary          = 'A short description of TTPostBase.'
  s.homepage         = 'https://code.byted.org/TTIOS/ios_house_post_base'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhangyuanke' => 'zhangyuanke@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/ios_house_ugc.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Classes/**/*.{h,m}'
 

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'TTKitchen'
end
