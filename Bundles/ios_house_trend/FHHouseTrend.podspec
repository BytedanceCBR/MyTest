#
# Be sure to run `pod lib lint FHHouseTrend.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FHHouseTrend'
  s.version          = '0.1.0'
  s.summary          = 'A short description of FHHouseTrend.'
  s.homepage         = 'https://code.byted.org/TTIOS/FHHouseTrend'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'guchunhui' => 'guchunhui@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:fproject/ios_house_trend.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'FHHouseTrend/Classes/**/*.{h,m}'

  s.resources = ['FHHouseTrend/Assets/*.xcassets']
  
  # s.resource_bundles = {
  #   'FHHouseTrend' => ['FHHouseTrend/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'TTKitchen'
end
