#
# Be sure to run `pod lib lint FHHouseEpidemicSituation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FHHouseEpidemicSituation'
  s.version          = '0.1.0'
  s.summary          = '疫情专题介绍'
  s.homepage         = 'https://code.byted.org/fproject/ios_house_esituation'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liuyu.shelley' => 'liuyu.shelley@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:fproject/ios_house_esituation.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'FHHouseEpidemicSituation/Classes/**/*.{h,m}'
  
  # s.resource_bundles = {
  #   'FHHouseEpidemicSituation' => ['FHHouseEpidemicSituation/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'TTKitchen'
end
