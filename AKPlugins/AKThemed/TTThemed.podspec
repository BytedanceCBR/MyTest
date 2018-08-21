#
# Be sure to run `pod lib lint TTThemed.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTThemed'
  s.version          = '0.1.0'
  s.summary          = 'A short description of TTThemed.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://code.byted.org/TTIOS/tt_pods_theme'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'suruiqiang' => 'suruiqiang@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/tt_pods_theme.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'
  s.requires_arc = true
  s.source_files = 'TTThemed/Classes/**/*'

  s.resource_bundles = {
     'TTThemed' => ['TTThemed/Assets/**/*.plist']
  }

  s.dependency 'TTBaseLib'
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
