#
# Be sure to run `pod lib lint FHCHousePush.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FHCHousePush'
  s.version          = '0.1.0'
  s.summary          = 'A short description of FHCHousePush.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://code.byted.org/fproject/FHCHousePush'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhangjing' => 'zhangjing.2018@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:fproject/FHCHousePush.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'FHCHousePush/Classes/**/*.{h,m}'
  s.resources = ['FHCHousePush/Assets/*.xcassets','FHCHousePush/Assets/images/*']

  # s.resource_bundles = {
  #   'FHCHousePush' => ['FHCHousePush/Assets/*.png']
  # }

  #s.public_header_files = 'FHHousePush/Classes/Initialize/FHHandleAPNSTask.h' , 'FHHousePush/Classes/Manager/*.h'
  #s.private_header_files = 'FHHousePush/Classes/**/*.h'
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
