#
# Be sure to run `pod lib lint AKWDPlugin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AKWDPlugin'
  s.version          = '0.1.0'
  s.summary          = '爱看问答业务插件'
  s.description      = '爱看问答业务插件'

  s.ios.deployment_target = '8.0'
  s.homepage         = 'https://code.byted.org/TTIOS/tt_business_wenda'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fengjingjun' => 'fengjingjun@bytedance.com' }
  s.source           = { :git => 'https://github.com/fengjingjun/AKWDPlugin.git', :tag => s.version.to_s }
  s.source_files     =  'Common/**/*.{h,m}',
                        'Model/**/*.{h,m}',
                        'Pages/**/*.{h,m}',
                        'HelpManager/**/*.{h,m}'
                        # 'Kuaida/**/*.{h,m}',
                        # 'Module/**/*.{h,m}'


  s.resources        =  'Resources/WDResource.xcassets',
                        'Resources/wd_iconfont.ttf',
                        'Resources/WDDebugViewController.storyboard'

#-------二方------

    s.dependency 'TTBaseLib'
    s.dependency 'TTUIWidget'
    s.dependency 'TTImage'
    s.dependency 'TTEntityBase'
    s.dependency 'TTBatchItemAction'
    s.dependency 'TTNetworkManager'
    s.dependency 'TTMonitor'
    s.dependency 'TTPersistence'
    s.dependency 'AKShareServicePlugin'
    s.dependency 'TTShare/TTShareBasic/TTWeChatShare'
    s.dependency 'TTShare/TTShareBasic/TTQQShare'
    s.dependency 'TTShare/TTShareBusiness/TTShareWeChatBusiness'
    s.dependency 'TTShare/TTShareBusiness/TTShareQQBusiness'
    s.dependency 'TTPhotoScrollVC'
    s.dependency 'TTImagePreviewAnimateManager'
    s.dependency 'TTUserSettings'
    s.dependency 'TTTracker'
    s.dependency 'TTRexxar'
    s.dependency 'AKWebViewBundlePlugin'
    s.dependency 'TTRoute'
    s.dependency 'TTImpression'
    s.dependency 'TTImagePicker/Category'
    s.dependency 'TTAvatar'
    s.dependency 'TTVerifyKit'
    s.dependency 'TTPlatformBaseLib'
    s.dependency 'TTPlatformUIModel'
    s.dependency 'TTReporter'
    s.dependency 'TTFriendRelation'
    s.dependency 'TTAdModule'
    s.dependency 'TTEntry'
    s.dependency 'TTNetBusiness'
    s.dependency 'TTPushAuthorizationManager'
    s.dependency 'TTAccountSDK/Account'
    s.dependency 'TTAccountSDK/ThirdPartyAccountFoundation/PlatformLoginCore'
    s.dependency 'TTAccountSDK/WeChatAccount'
    s.dependency 'TTAccountLogin'
    s.dependency 'TTNewsAccountBusiness'
    s.dependency 'AKCommentPlugin'

#-------三方------

    s.dependency 'TTTAttributedLabel'
    s.dependency 'JSONModel'
    s.dependency 'Fabric'
    s.dependency 'Crashlytics'
    s.dependency 'KVOController'
    s.dependency 'RSSwizzle'
    s.dependency 'YYImage'
    s.dependency 'YYWebImage'

end
