#
# Be sure to run `pod lib lint AKCommentPlugin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AKCommentPlugin'
  s.version          = '0.1.0'
  s.summary          = '爱看评论业务插件'
  s.description      = '爱看评论业务插件'

  s.homepage         = 'https://github.com/fengjingjun/AKCommentPlugin'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fengjingjun' => 'fengjingjun@bytedance.com' }
  s.source           = { :git => 'https://github.com/fengjingjun/AKCommentPlugin.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Classes/**/*'
  
  s.dependency 'TTAccountSDK/Account'
  s.dependency 'TTAccountSDK/ThirdPartyAccountFoundation/PlatformLoginCore'
  s.dependency 'TTAccountSDK/WeChatAccount'
  # s.dependency 'TTAccountSDK/TencentQQAccount', '3.0.5'
  # s.dependency 'TTAccountSDK/TencentWBAccount', '3.0.5'
  # s.dependency 'TTAccountSDK/SinaWeiboAccount', '3.0.5'
  # s.dependency 'TTAccountSDK/RenRenAccount', '3.0.5'
  # s.dependency 'TTAccountSDK/TianYiAccount', '3.0.5'
  # s.dependency 'TTAccountSDK/TTVideoAccount', '3.0.5'
  # s.dependency 'TTAccountSDK/TTToutiaoAccount', '3.0.5'
  # s.dependency 'TTAccountSDK/TTAwemeAccount', '3.0.5'
  # s.dependency 'TTAccountSDK/TTHotsoonAccount', '3.0.5'
  # s.dependency 'TTAccountSDK/TTCarAccount', '3.0.5'
  # s.dependency 'TTAccountSDK/TTWukongAccount', '3.0.5'
  # s.dependency 'TTAccountSDK/TTFinanceAccount', '3.0.5'
  s.dependency 'TTNetworkManager', '< 3'
  s.dependency 'TTPlatformUIModel/TTModel'
  s.dependency 'TTPlatformBaseLib'
  s.dependency 'TTBaseLib'
  s.dependency 'TTThemed'
  s.dependency 'TTUIWidget'
  s.dependency 'JSONModel'
  s.dependency 'BDTArticle'
  s.dependency 'SDWebImage'
  s.dependency 'YYWebImage'
  s.dependency 'YYCache'
  s.dependency 'Crashlytics'
  s.dependency 'TTFriendRelation'
  s.dependency 'TTEntry'
  s.dependency 'TTServiceKit'
  s.dependency 'TTImpression'
  s.dependency 'TTBatchItemAction'
  s.dependency 'TTVerifyKit'
  s.dependency 'TTReporter'
  s.dependency 'TTAvatar'
  s.dependency 'TTRoute'
  s.dependency 'TTPushAuthorizationManager'
  s.dependency 'TTPersistence'
  s.dependency 'TTServiceProtocols'
  s.dependency 'TTNewsAccountBusiness'
  s.dependency 'AKShareServicePlugin'
  s.dependency 'TTShare/TTShareBasic/TTWeChatShare'
  s.dependency 'TTShare/TTShareBasic/TTQQShare'
  s.dependency 'TTShare/TTShareBusiness/TTShareWeChatBusiness'
  s.dependency 'TTShare/TTShareBusiness/TTShareQQBusiness'
  s.dependency 'TTDiggButton'
  s.dependency 'TTImage'
  s.dependency 'TTMonitor'
  s.dependency 'TTNetBusiness'
  s.dependency 'TTKitchen'
  s.dependency 'TTUGCFoundation/TTUGCRichText'
  s.dependency 'TTUGCFoundation/RequestMonitor'
  s.dependency 'TTUGCFoundation/TTUGCApiModel'
  s.dependency 'TTUGCFoundation/TTUGCActionDataService'

end
