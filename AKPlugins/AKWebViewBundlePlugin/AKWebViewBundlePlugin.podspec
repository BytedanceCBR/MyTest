#
# Be sure to run `pod lib lint AKWebViewBundlePlugin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AKWebViewBundlePlugin'
  s.version          = '0.1.0'
  s.summary          = '爱看webView容器插件'
  s.description      = '爱看webView容器插件'

  s.homepage         = 'https://github.com/fengjingjun/AKWebViewBundlePlugin'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fengjingjun' => 'fengjingjun@bytedance.com' }
  s.source           = { :git => 'https://github.com/fengjingjun/AKWebViewBundlePlugin.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files     = 'Classes/**/*.{h,m}'
  s.resources        = 'Classes/Resources/**/*'
  s.prefix_header_file = 'Classes/TTWebViewBundle-prefix.pch'

  s.dependency 'TTBaseLib'
  s.dependency 'TTThemed'
  s.dependency 'TTSettingsManager'
  s.dependency 'TTNetworkManager', '<3'
  s.dependency 'TTPlatformBaseLib'
  s.dependency 'TTTracker'
  s.dependency 'TTNetBusiness'
  s.dependency 'TTRexxar'
  s.dependency 'TTAdModule'
  s.dependency 'TTImpression'
  s.dependency 'Masonry'
  s.dependency 'AKShareServicePlugin'
  s.dependency 'TTShare/TTShareBasic/TTWeChatShare'
  s.dependency 'TTShare/TTShareBasic/TTQQShare'
  s.dependency 'TTShare/TTShareBusiness/TTShareWeChatBusiness'
  s.dependency 'TTShare/TTShareBusiness/TTShareQQBusiness'
  s.dependency 'BDTBasePlayer'
  
end
