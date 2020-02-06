#
# Be sure to run `pod lib lint TTAdModule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTAdModule'
  s.version          = '0.1.25'
  s.summary          = 'The Ad Module for tt_pods_ios'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://code.byted.org/TTIOS/tt_pods_ad'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yinhao' => 'yinhao@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/tt_pods_ad.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'TTAdModule/Classes/**/*'
  
#  s.ios.resource_bundles = {
#    'TTAdModule' => ['TTAdModule/Assets/Images.xcassets']
#}
  s.resources = 'TTAdModule/Assets/Images.xcassets'
  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'OpenGLES', 'GLkit'
  
end
