#
# Be sure to run `pod lib lint TTAD.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTAD'
  s.version          = '0.1.0'
  s.summary          = 'A short description of TTAD.'
  s.homepage         = 'https://code.byted.org/TTIOS/TTAD'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'toutiao' => 'toutiao@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/TTAD.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'TTAD/Classes/**/*.{h,hpp,m,mm,c,cpp}'

  s.vendored_libraries =  "TTAD/Classes/**/*.a"
  s.vendored_frameworks = "TTAD/Classes/**/*.framework"
  
  # s.resource_bundles = {
  #   'TTAD' => ['TTAD/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'TTKitchen'
end
