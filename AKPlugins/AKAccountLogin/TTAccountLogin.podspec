#
# Be sure to run `pod lib lint TTAccountLogin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTAccountLogin'
  s.version          = '0.1.0'
  s.summary          = '头条账号登录UI'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                        头条账号UI。
                        使用TTAccountSDK的接口，封装头条登录UI界面。
                       DESC

  s.homepage         = 'https://code.byted.org/TTIOS/tt_pods_account_login'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nice2Me' => 'liuzuopeng@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/tt_pods_account_login.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'


  # ARC
  s.requires_arc = true



  # 全局依赖
  s.dependency "JSONModel"
  s.dependency "TTBaseLib"
  s.dependency "TTUIWidget"
  s.dependency "TTReachability"
  s.dependency "TTMonitor"
  s.dependency "TTTracker"
  s.dependency "TTPlatformBaseLib/TTTrackerWrapper"
  s.dependency "TTAccountSDK" 
  # s.dependency "TTNetworkManager"



  s.source_files = 'TTAccountLogin/Classes/**/*'
  s.exclude_files = "TTAccountLogin/Classes/AccountLoginUIKit"



   # AccountLoginUI
  s.subspec 'AccountLoginUIKit' do |ss|
    ss.source_files = 'TTAccountLogin/Classes/AccountLogin{UIKit, Utils}/**/*.{h,m,mm}'
  end



  s.resource_bundles = {
    'TTAccountLogin' => ['TTAccountLogin/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
