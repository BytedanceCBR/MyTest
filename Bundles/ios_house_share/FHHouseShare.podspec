#
# Be sure to run `pod lib lint FHHouseShare.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FHHouseShare'
  s.version          = '0.1.0'
  s.summary          = 'A short description of FHHouseShare.'
  s.homepage         = 'https://code.byted.org/TTIOS/FHHouseShare'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'molijie' => 'molijie@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/FHHouseShare.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'FHHouseShare/Classes/**/*.{h,m}'
  
  # s.resource_bundles = {
  #   'FHHouseShare' => ['FHHouseShare/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'TTKitchen'
end
