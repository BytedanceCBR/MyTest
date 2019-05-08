#
# Be sure to run `pod lib lint FHHouseMine.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FHHouseMine'
  s.version          = '0.1.0'
  s.summary          = 'A short description of FHHouseMine.'
  s.homepage         = 'https://code.byted.org/TTIOS/FHHouseMine'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'guchunhui' => 'guchunhui@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:fproject/ios_house_mine.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'FHHouseMine/Classes/**/*.{h,m,mm}'
  
  s.resources = ['FHHouseMine/Assets/*.xcassets']

  # s.resource_bundles = {
  #   'FHHouseMine' => ['FHHouseMine/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'TTKitchen'
end
