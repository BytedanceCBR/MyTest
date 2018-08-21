#
# Be sure to run `pod lib lint TTServiceProtocols.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTServiceProtocols'
  s.version          = '0.0.5'
  s.summary          = '头条服务协议库'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  所有需要暴露给业务层或者其他pods的方法都写在这里
                       DESC

  s.homepage         = 'https://code.byted.org/TTIOS/tt_pods_service_protocols'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fengyadong' => 'fengyadong@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/tt_pods_service_protocols.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'TTServiceProtocols/Classes/**/*'
  
  # s.resource_bundles = {
  #   'TTServiceProtocols' => ['TTServiceProtocols/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
