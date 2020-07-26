#
# Be sure to run `pod lib lint FHHouseRealtorDetail.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FHHouseRealtorDetail'
  s.version          = '0.1.0'
  s.summary          = 'A short description of FHHouseRealtorDetail.'
  s.homepage         = 'https://code.byted.org/TTIOS/FHHouseRealtorDetail'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liuyu.shelley' => 'liuyu.shelley@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/FHHouseRealtorDetail.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'FHHouseRealtorDetail/Classes/**/*.{h,m}'
  
  s.resources = ['FHHouseRealtorDetail/Assets/*.xcassets','FHHouseRealtorDetail/Assets/*.jpg']
  
  # s.resource_bundles = {
  #   'FHHouseRealtorDetail' => ['FHHouseRealtorDetail/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'TTKitchen'
end
