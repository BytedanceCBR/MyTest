#
# Be sure to run `pod lib lint TTPhotoScrollVC.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTPhotoScrollVC'
  s.version          = '0.1.6'
  s.summary          = '头条图片浏览器库'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  头条图片浏览器库
                       DESC

  s.homepage         = 'https://code.byted.org/TTIOS/tt_pods_photo_scroll'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fengyadong' => 'fengyadong@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/tt_pods_photo_scroll.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'TTPhotoScrollVC/Classes/**/*'
  s.dependency 'TTThemed'
  s.dependency 'TTImagePicker/Category'
  s.dependency 'SDWebImage'
  s.dependency 'TTTracker'
  s.dependency 'TTImagePreviewAnimateManager'


  # s.resource_bundles = {
  #   'TTPhotoScrollVC' => ['TTPhotoScrollVC/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
