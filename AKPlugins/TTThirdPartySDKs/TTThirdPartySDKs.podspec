#
# Be sure to run `pod lib lint TTThirdPartySDKs.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTThirdPartySDKs'
  s.version          = '0.0.4'
  s.summary          = '第三方SDK'
  s.description      = <<-DESC
  头条共用第三方SDK，支付，分享，SSO登录等都依赖本库
  DESC

  s.homepage         = 'https://code.byted.org/TTIOS/tt_pods_thirdpartysdks'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fengyadong' => 'fengyadong@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/tt_pods_thirdpartysdks.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'
  
  #QQ平台SDK集成
  s.subspec 'QQSDK' do |ss|
    ss.source_files = 'TTThirdPartySDKs/QQSDK/**/*.{h,m}'
    ss.public_header_files = 'TTThirdPartySDKs/QQSDK/**/*.h'
    ss.vendored_frameworks = 'TTThirdPartySDKs/QQSDK/TencentOpenAPI.framework'
    ss.resources = ['TTThirdPartySDKs/QQSDK/*.{bundle}']
    ss.ios.frameworks = 'CoreTelephony', 'SystemConfiguration','UIKit', 'Foundation', 'CFNetwork'
    ss.ios.libraries = 'z', 'sqlite3.0', 'c++', 'iconv'
  end

  #微信平台SDK集成
  s.subspec 'WeChatSDK' do |ss|
    ss.source_files = 'TTThirdPartySDKs/WeChatSDK/**/*.{h,m}'
    ss.public_header_files = 'TTThirdPartySDKs/WeChatSDK/**/*.h'
    ss.vendored_library = 'TTThirdPartySDKs/WeChatSDK/libWeChatSDK.a'
    ss.frameworks = 'MobileCoreServices', 'SystemConfiguration','CoreTelephony','UIKit', 'Foundation', 'CFNetwork'
    ss.libraries = 'z', 'sqlite3.0', 'c++'
  end

  #新浪微博平台SDK集成
  s.subspec 'WeiboSDK' do |ss|
    ss.source_files = 'TTThirdPartySDKs/WeiboSDK/**/*.{h,m}'
    ss.public_header_files = 'TTThirdPartySDKs/WeiboSDK/**/*.h'
    ss.resources = ['TTThirdPartySDKs/WeiboSDK/Resource/*.{bundle}']
    ss.vendored_library = 'TTThirdPartySDKs/WeiboSDK/libWeiboSDK.a'
    ss.framework = 'QuartzCore','ImageIO','SystemConfiguration','Security','CoreTelephony','CoreText','UIKit', 'Foundation', 'CFNetwork'
    ss.libraries = 'z', 'sqlite3.0'
  end

  #支付宝支付SDK集成
  s.subspec 'AlipaySDK' do |ss|
    ss.source_files = 'TTThirdPartySDKs/AlipaySDK/**/*.{h,m}'
    ss.public_header_files = 'TTThirdPartySDKs/AlipaySDK/**/*.h'
    ss.vendored_frameworks = 'TTThirdPartySDKs/AlipaySDK/AlipaySDK.framework'
    ss.frameworks = 'SystemConfiguration', 'CoreTelephony', 'QuartzCore', 'CoreText', 'CoreGraphics', 'UIKit', 'Foundation', 'CFNetwork', 'CoreMotion'
    ss.resources = ['TTThirdPartySDKs/AlipaySDK/*.{bundle}']
    ss.libraries = 'c++', 'z'
  end

  #支付宝分享SDK集成
  s.subspec 'AliShareSDK' do |ss|
    ss.source_files = 'TTThirdPartySDKs/AliShareSDK/**/*.{h,m}'
    ss.public_header_files = 'TTThirdPartySDKs/AliShareSDK/**/*.h'
    ss.vendored_library = 'TTThirdPartySDKs/AliShareSDK/libAPOpenSdk.a'
    ss.frameworks = 'SystemConfiguration', 'CoreTelephony', 'QuartzCore', 'CoreText', 'CoreGraphics', 'UIKit', 'Foundation', 'CFNetwork', 'CoreMotion'
    ss.libraries = 'c++', 'z'
  end

  #钉钉SDK集成
  s.subspec 'DingDingSDK' do |ss|
    ss.source_files = 'TTThirdPartySDKs/DingDingSDK/**/*.{h,m}'
    ss.public_header_files = 'TTThirdPartySDKs/DingDingSDK/**/*.h'
    ss.vendored_frameworks = 'TTThirdPartySDKs/DingDingSDK/DTShareKit.framework'
    ss.frameworks = 'SystemConfiguration', 'CoreTelephony', 'QuartzCore', 'CoreText', 'CoreGraphics', 'UIKit', 'Foundation', 'CFNetwork', 'CoreMotion'
    ss.libraries = 'c++', 'z'
  end

  s.frameworks = 'UIKit', 'CoreGraphics', 'Foundation'

end
