#
# Be sure to run `pod lib lint TTNewsAccountBusiness.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTNewsAccountBusiness'
  s.version          = '0.2.4'
  s.summary          = '爱看账号业务逻辑封装'
  s.description      = '爱看账号业务逻辑封装'

  s.homepage         = 'https://github.com/fengjingjun/TTNewsAccountBusiness'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fengjingjun' => 'fengjingjun@bytedance.com' }
  s.source           = { :git => 'https://github.com/fengjingjun/TTNewsAccountBusiness.git', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'

  s.source_files = 'Classes/**/*'
  
  s.subspec 'SSCookieManager' do |ss|
    ss.requires_arc = true
    ss.source_files = 'Classes/AccountCookie/*.{h,m}'
    ss.public_header_files = 'Classes/AccountCookie/*.h'
  end

  s.subspec 'Classes' do |ss|
    ss.requires_arc = true
    ss.source_files = 'Classes/**/*.{h,m}', 'Classes/TTAccountBusiness.{h,m}'
    ss.public_header_files = 'Classes/**/*.h', 'Classes/TTAccountBusiness.h'
    ss.private_header_files = 'Classes/AccountManager/**/AccountManager.h'
    ss.dependency "TTAccountSDK/Account"
    ss.dependency "TTAccountSDK/WeChatAccount"
    ss.dependency "TTAccountLogin"
    ss.dependency "TTPlatformBaseLib/TTKeyChainStorage"
    ss.dependency "TTServiceKit"
    ss.dependency "TTInstallService"
  end

end
