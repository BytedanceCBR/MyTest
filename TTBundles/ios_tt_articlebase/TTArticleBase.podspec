#
# Be sure to run `pod lib lint TTArticleBase.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTArticleBase'
  s.version          = '0.1.0'
  s.summary          = 'A short description of TTArticleBase.'
  s.homepage         = 'https://code.byted.org/TTIOS/TTArticleBase'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'guchunhui' => 'guchunhui@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/TTArticleBase.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'TTArticleBase/Classes/**/*.{h,hpp,m,mm,c,cpp}'
  
  s.resources = ["TTArticleBase/Assets/*.xcassets","TTArticleBase/Assets/*.bundle","TTArticleBase/Assets/AppAlert/*.png","TTArticleBase/Assets/SSQRCode/*.png","TTArticleBase/Assets/NetworkStubFiles/*"]

  s.vendored_libraries = ["TTArticleBase/Classes/**/*.a"]

  s.pod_target_xcconfig = {'GCC_PREPROCESSOR_DEFINITIONS' => 'SD_WEBP=1'}
  # s.resource_bundles = {
  #   'TTArticleBase' => ['TTArticleBase/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'TTKitchen'
end
