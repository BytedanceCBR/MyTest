#
# Be sure to run `pod lib lint TTHTSVideo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTHTSVideo'
  s.version          = '0.1.0'
  s.summary          = 'A short description of TTHTSVideo.'
  s.homepage         = 'https://code.byted.org/TTIOS/TTHTSVideo'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'guchunhui' => 'guchunhui@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/TTHTSVideo.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'TTHTSVideo/Classes/**/*.{h,hpp,m,mm,c,cpp}'
  
  # s.resource_bundles = {
  #   'TTHTSVideo' => ['TTHTSVideo/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'TTKitchen'
end
