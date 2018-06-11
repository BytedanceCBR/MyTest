#
# Be sure to run `pod lib lint StartTest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BDStartUp'
  s.version          = '0.1.0'
  s.summary          = 'A short description of BDStartUp.'
  s.homepage         = 'https://code.byted.org/TTIOS/BDStartUp'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jialei' => 'jialei.jay@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/BDStartUp.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'BDStartUp/Classes/**/*.{h,m}'
  
   s.resource_bundles = {
     'BDStartUp' => ['BDStartUp/Assets/**/*.plist']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'TTKitchen'
end
