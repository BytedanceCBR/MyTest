#
# Be sure to run `pod lib lint AKPay.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AKPay'
  s.version          = '0.1.0'
  s.summary          = '头条支付库'
  s.description      = <<-DESC
主要包含支付宝和微信支付两种支付方式
                       DESC

  s.homepage         = 'https://www.toutiao.com'
  s.license          = 'MIT'
  s.author           = { 'fengjingjun' => 'fengjingjun@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/tt_pods_pay.git', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source_files = 'AKPay/PayService/**/*.{h,m}'
  s.public_header_files = 'AKPay/PayService/**/*.h'
  s.resources = 'AKPay/PaySDK/Resource/*'
  s.dependency 'TTThirdPartySDKs/WeChatSDK'

end
