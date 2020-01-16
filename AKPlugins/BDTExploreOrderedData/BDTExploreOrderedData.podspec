#
# Be sure to run `pod lib lint BDTExploreOrderedData.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BDTExploreOrderedData'
  s.version          = '0.1.7'
  s.summary          = 'ExploreOrderedData是一个包含ExploreOrderedData类的pod库，方便其它pod依赖它'

  s.description      = <<-DESC
ExploreOrderedData是一个包含ExploreOrderedData类的pod库，方便其它pod依赖它
                       DESC

  s.homepage         = 'https://code.byted.org/TTIOS/BDTExploreOrderedData'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'peiyun007' => 'peiyun@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/BDTExploreOrderedData.git', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'
  s.source_files = 'BDTExploreOrderedData/Classes/**/*'

end
