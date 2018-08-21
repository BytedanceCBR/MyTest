#
# Be sure to run `pod lib lint AKShareServicePlugin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AKShareServicePlugin'
  s.version          = '0.1.0'
  s.summary          = '爱看分享关系服务插件'
  s.description      = '爱看分享关系服务插件'


  s.homepage         = 'https://github.com/fengjingjun/AKShareServicePlugin'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fengjingjun' => 'fengjingjun@bytedance.com' }
  s.source           = { :git => 'https://github.com/fengjingjun/AKShareServicePlugin.git', :tag => s.version.to_s }

  s.source_files     = 'Classes/**/*.{h,m}'
  s.resources        = 'Classes/TTShare.xcassets'

  s.ios.deployment_target = '7.0'

  s.dependency 'TTBaseLib'
  s.dependency 'TTTracker'
  s.dependency 'TTUIWidget'
  s.dependency 'TTShare/TTShareBasic/TTWeChatShare'
  s.dependency 'TTShare/TTShareBasic/TTQQShare'
  s.dependency 'TTShare/TTShareBusiness/TTShareWeChatBusiness'
  s.dependency 'TTShare/TTShareBusiness/TTShareQQBusiness'
  s.dependency 'TTUserSettings'
  s.dependency 'TTServiceKit', '>= 0.4.1'
  s.dependency 'Aspects', '>= 1.4'
  s.dependency 'TTKitchen'


end
