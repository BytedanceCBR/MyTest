#
# Be sure to run `pod lib lint TTArticle.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTArticle'
  s.version          = '0.1.0'
  s.summary          = 'A short description of TTArticle.'
  s.homepage         = 'https://code.byted.org/TTIOS/TTArticle'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'guchunhui' => 'guchunhui@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/TTArticle.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'TTArticle/Classes/**/*.{h,hpp,m,mm,c,cpp}'

  #s.resources = []
  # s.resource_bundles = {
  #   'TTArticle' => ['TTArticle/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'TTKitchen'
end
