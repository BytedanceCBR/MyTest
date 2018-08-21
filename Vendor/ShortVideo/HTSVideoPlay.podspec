#
# Be sure to run `pod lib lint HTSVideoPlay.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HTSVideoPlay'
  s.version          = '0.3.9'
  s.summary          = 'Hotsoon Video Play'
  s.description      = <<-DESC
                        Hotsoon Video Play for Toutiao
                       DESC

  s.homepage         = 'https://code.byted.org/songli.02/HTSVideoPlay'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'SongLi.02' => 'songli.02@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:songli.02/HTSVideoPlay.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'HTSVideoPlay/Classes/**/*.{h,m}'
  s.compiler_flags = '-Werror=unguarded-availability'
  #Suppress warning in RACObserve()

  s.xcconfig = { 'USER_HEADER_SEARCH_PATHS' => '"${PROJECT_DIR}/../TTHTSVideo/TSVShortVideoDetailExitManager/" "${PROJECT_DIR}/../TTHTSVideo/TSVShortVideoDataFetchManager/" "${PROJECT_DIR}/../TTHTSVideo/TTHTSUtils/" "${PROJECT_DIR}/../Model/DataModel" "${PROJECT_DIR}/../../Common/data/ListDataManager/" "${PROJECT_DIR}/../../Common/TTCustomAnimation/" "${PROJECT_DIR}/../TTUGC/Common/UIWidget/TTUGCAttributedLabel/" "${PROJECT_DIR}/../../Common/View/SSLabel/" "${PROJECT_DIR}/../TTUGC/Feature/Emoji/" "${PROJECT_DIR}/../TTAppRuntime/API/" "${PROJECT_DIR}/../TTService/ServiceTodo/JsBridgeWebViewService/SSWebView/"' }

  s.resources = ['HTSVideoPlay/Assets/HTSVideoPlay.xcassets',
                 'HTSVideoPlay/Assets/HTSVideoPlay_ad.xcassets',
                 'HTSVideoPlay/Assets/HTSVideoPlay.bundle']

  s.frameworks = 'UIKit', 'Foundation'

  s.dependency 'Mantle'
  s.dependency 'SDWebImage'
  s.dependency 'Masonry'
  s.dependency 'TTUIWidget'
  s.dependency 'TTBaseLib'
  s.dependency 'TTNetworkManager'
  s.dependency 'TTReachability'
  s.dependency 'ReactiveObjC'
  s.dependency 'TTRoute'
  s.dependency 'YYCache'
  s.dependency 'TTImpression'
  s.dependency 'TTVideoService'
  s.dependency 'MBProgressHUD'
  s.dependency 'TTServiceKit'
  s.dependency 'TTFlowStatisticsManager'
  s.dependency 'YYWebImage', '~> 1.0.4'
  s.dependency 'TTAdModule'

  #Referenced in UGCVideo.h
  s.dependency 'TTImage'
  s.dependency 'TTUIWidget'
  s.dependency 'TTMonitor'
  s.dependency 'IESVideoPlayer'
  s.dependency 'AKShareServicePlugin'
  s.dependency 'TTShare/TTShareBasic/TTWeChatShare'
  s.dependency 'TTShare/TTShareBasic/TTQQShare'
  s.dependency 'TTShare/TTShareBusiness/TTShareWeChatBusiness'
  s.dependency 'TTShare/TTShareBusiness/TTShareQQBusiness'

  s.dependency 'TTBatchItemAction'
  s.dependency 'TTPlatformUIModel'

  s.dependency 'TSVToolkit', '~> 0.1.1'

  s.subspec 'Yoga' do |ss|
    ss.source_files = 'yoga/**/*.{c,h}'
    ss.requires_arc = false
    ss.public_header_files = 'yoga/*.h'
    ss.compiler_flags = [
      '-fno-omit-frame-pointer',
      '-fexceptions',
      '-Wall',
      '-Werror',
      '-std=c11',
      '-fPIC'
    ]
  end

  s.subspec 'YogaKit' do |ss|
    ss.dependency 'HTSVideoPlay/Yoga'
    ss.source_files = 'YogaKit/**/*.{h,m}'
    ss.public_header_files = 'YogaKit/{YGLayout,UIView+Yoga}.h'
    ss.private_header_files = 'YogaKit/YGLayout+Private.h'
  end
end
