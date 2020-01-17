#
# Be sure to run `pod lib lint TTUIWidget.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTUIWidget'
  s.version          = '0.10.28'
  s.summary          = 'ui组件库'
  s.description      = <<-DESC
  头条共用UI组件库，包括VC基类和路由Manager类
  DESC

  s.homepage         = 'http://code.byted.org/TTIOS/tt_pods_ui'
  s.license          = 'MIT'
  s.author           = { 'fengjingjun' => 'fengjingjun@bytedance.com' }
  s.source           = { :git => "git@code.byted.org:TTIOS/tt_pods_ui.git", :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.ios.resource_bundles = {
    'TTUIWidgetResources' => ['TTUIWidget/Assets/**/*.{xib,bundle,json}', 'TTUIWidget/Assets/Image.xcassets']
  }

s.subspec 'PopoverView' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/PopoverView/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/PopoverView/**/*.h'
    ss.dependency 'Masonry'
    ss.dependency 'TTThemed'
    ss.dependency 'TTBaseLib'
    ss.dependency 'TTPlatformBaseLib'
    ss.dependency 'BDTrackerProtocol'
end

s.subspec 'TTIndicatorView' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/TTIndicatorView/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/TTIndicatorView/**/*.h'
    ss.dependency 'TTBaseLib/TTDeviceHelper'
    ss.dependency 'TTBaseLib/TTCategory'
    ss.dependency 'TTBaseLib/TTLabelTextHelper'
    ss.dependency 'TTThemed'
end

s.subspec 'SSAlertViewBase' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/SSAlertViewBase/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/SSAlertViewBase/**/*.h'
    ss.dependency 'TTBaseLib/TTBaseTool'
    ss.dependency 'TTBaseLib/TTUIResponderHelper'
    ss.dependency 'TTBaseLib/TTCategory'
    ss.dependency 'TTThemed'
    ss.dependency 'Masonry'
end

s.subspec 'SSViewControllerBase' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/SSViewControllerBase/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/SSViewControllerBase/**/*.h'
    ss.dependency 'TTBaseLib/TTDeviceHelper'
    ss.dependency 'TTBaseLib/TTCategory'
    ss.dependency 'TTThemed'
    ss.dependency 'TTRoute'
    ss.dependency 'TTUIWidget/TTNavigationController'
end

s.subspec 'TTAlphaThemedButton' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/TTAlphaThemedButton/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/TTAlphaThemedButton/**/*.h'
    ss.dependency 'TTBaseLib/TTCategory'
    ss.dependency 'TTThemed'
    ss.dependency 'Masonry'
end

s.subspec 'TTBadgeNumberView' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/TTBadgeNumberView/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/TTBadgeNumberView/**/*.h'
    ss.dependency 'TTThemed'
    ss.dependency 'KVOController'
end

s.subspec 'TTColorAsFollowButton' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/TTColorAsFollowButton/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/TTColorAsFollowButton/**/*.h'
    ss.dependency 'TTThemed'
    ss.dependency 'TTUIWidget/TTAlphaThemedButton'
    ss.dependency 'TTKitchenExtension'
end

s.subspec 'TTNavigationControllerTTBD' do |ss|
    ss.requires_arc =  true
    ss.source_files =  ''
    ss.public_header_files = ''
    ss.dependency 'BDMobileRuntime'
    ss.dependency 'TTRegistry'
    ss.dependency 'TTServiceProtocols'
end

s.subspec 'TTNavigationController' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/TTNavigationController/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/TTNavigationController/**/*.h'
    ss.dependency 'TTBaseLib/TTCategory'
    ss.dependency 'TTBaseLib/TTDeviceHelper'
    ss.dependency 'TTThemed'
    ss.dependency 'KVOController'
    ss.dependency 'TTUIWidget/TTAlphaThemedButton'
    ss.dependency 'TTUIWidget/UIView+CustomTimingFunction'
    ss.dependency 'BDAssert'
    ss.dependency 'TTUIWidget/TTBackButtonView'
end

s.subspec 'TTPageController' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/TTPageController/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/TTPageController/**/*.h'
    ss.dependency 'TTBaseLib/TTCategory'
    ss.dependency 'TTThemed'
    ss.dependency 'Masonry'
end

s.subspec 'TTTagView' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/TTTagView/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/TTTagView/**/*.h'
    ss.dependency 'TTBaseLib/TTDeviceHelper'
    ss.dependency 'TTBaseLib/TTCategory'
    ss.dependency 'TTThemed'
    ss.dependency 'Masonry'
end

s.subspec 'UIView+CustomTimingFunction' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/UIView+CustomTimingFunction/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/UIView+CustomTimingFunction/**/*.h'
end


s.subspec 'ALAssets' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/ALAssets/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/ALAssets/**/*.h'
    ss.dependency 'TTServiceKit'
    ss.dependency 'TTUIWidget/TTThemedAlertControllerProtocol'
    ss.dependency 'TTBaseLib/TTCategory'
    ss.dependency 'TTBaseLib/TTUIResponderHelper'
    ss.dependency 'TTBaseLib/TTDeviceHelper'
    ss.dependency 'TTBaseLib/TTBaseTool'
    ss.dependency 'TTBaseLib/TTSandBoxHelper'
    ss.dependency 'TTThemed'
    ss.dependency 'TTUIWidget/TTIndicatorView'
    ss.dependency 'TTKitchenExtension'
end

s.subspec 'TTAsyncLabel' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/TTAsyncLabel/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/TTAsyncLabel/**/*.h'
    ss.dependency 'TTBaseLib/TTDeviceHelper'
end

s.subspec 'TTIconLabel' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/TTIconLabel/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/TTIconLabel/**/*.h'
    ss.dependency 'TTUIWidget/TTAsyncLabel'
    ss.dependency 'TTBaseLib/TTDeviceHelper'
    ss.dependency 'TTBaseLib/TTCategory'
    ss.dependency 'TTThemed'
    ss.dependency 'SDWebImage'
    ss.dependency 'TTVerifyKit'
end

s.subspec 'SSMotionRender' do |ss|
    ss.requires_arc =   true
    ss.source_files = 'TTUIWidget/Classes/UIWidget/SSMotionRender/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/SSMotionRender/**/*.h'
    ss.dependency 'TTBaseLib/TTUIResponderHelper'
    ss.dependency 'TTThemed'
end

s.subspec 'SaveImageAlertView' do |ss|
    ss.requires_arc =   true
    ss.source_files = 'TTUIWidget/Classes/UIWidget/SaveImageAlertView/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/SaveImageAlertView/**/*.h'
    ss.dependency 'TTUIWidget/SSAlertViewBase'
    ss.dependency 'TTBaseLib/TTDeviceHelper'
end

s.subspec 'TTThemedAlertControllerProtocol' do |ss|
    ss.requires_arc =   true
    ss.source_files = 'TTUIWidget/Classes/UIWidget/TTThemedAlertControllerProtocol/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/TTThemedAlertControllerProtocol/**/*.h'
end

s.subspec 'TTThemedAlertController' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/TTThemedAlertController/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/TTThemedAlertController/**/*.h'
    ss.dependency 'TTUIWidget/TTThemedAlertControllerProtocol'
    ss.dependency 'TTServiceKit'
    ss.dependency 'TTThemed'
    ss.dependency 'TTUIWidget/TTKeyboardListener'
    ss.dependency 'TTBaseLib'
end

s.subspec 'TTKeyboardListener' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/utils/TTKeyboardListener/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/utils/TTKeyboardListener/**/*.h'
    ss.dependency 'TTBaseLib/TTDeviceHelper'
end

s.subspec 'UIViewController+TabBarSnapShot' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/UIViewController+TabBarSnapShot/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/UIViewController+TabBarSnapShot/**/*.h'
    ss.dependency 'TTBaseLib/TTDeviceHelper'
    ss.dependency 'TTThemed'
end

s.subspec 'TTDialogView' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/TTDialogView/**/*.{h,m}'
    ss.resource_bundles = {
        'TTDialogViewResource' => ['TTUIWidget/Assets/TTDialogView.xcassets']
    }
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/TTDialogView/**/*.h'
    ss.dependency 'TTThemed'
    ss.dependency 'TTBaseLib/TTUIResponderHelper'
    ss.dependency 'TTBaseLib/TTCategory'
end

s.subspec 'STLinkLabel' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/STLinkLabel/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/STLinkLabel/**/*.h'
    ss.dependency 'TTThemed'
    ss.dependency 'TTBaseLib/TTCategory'
end

s.subspec 'TTHeaderScrollView' do |ss|
    ss.source_files = 'TTUIWidget/Classes/UIWidget/TTHeaderScrollView/**/*.{h,m}'
    ss.dependency 'TTThemed'
    ss.dependency 'TTBaseLib/TTCategory'
end

s.subspec 'TTBackButtonView' do |ss|
    ss.source_files = 'TTUIWidget/Classes/UIWidget/TTBackButtonView/**/*.{h,m}'
    ss.resource_bundles = {
        'TTBackButtonView' => ['TTUIWidget/Assets/TTBackButtonView.xcassets']
    }
    ss.dependency 'TTThemed'
    ss.dependency 'TTBaseLib/TTCategory'
end

s.subspec 'TTBubbleView' do |ss|
    ss.source_files = 'TTUIWidget/Classes/UIWidget/TTBubbleView/**/*.{h,m}'
    ss.dependency 'TTDialogDirector'
    ss.dependency 'TTThemed'
    ss.dependency 'TTBaseLib/TTCategory'
end

s.subspec 'TTSegmentedControl' do |ss|
    ss.source_files = 'TTUIWidget/Classes/UIWidget/TTSegmentedControl/**/*.{h,m}'
    ss.dependency 'TTThemed'
    ss.dependency 'TTBaseLib/TTCategory'
    ss.dependency 'TTUIWidget/TTBadgeNumberView'
end

s.subspec 'TTSearchBarView' do |ss|
    ss.source_files = 'TTUIWidget/Classes/UIWidget/TTSearchBarView/**/*.{h,m}'
    ss.dependency 'TTThemed'
    ss.dependency 'TTBaseLib/TTDeviceHelper'
    ss.dependency 'TTBaseLib/TTCategory'
end

s.subspec 'TTWrongWordsReportView' do |ss|
    ss.source_files = 'TTUIWidget/Classes/UIWidget/TTWrongWordsReportView/**/*.{h,m}'
    ss.public_header_files = 'TTUIWidget/Classes/UIWidget/TTWrongWordsReportView/**/*.h'
    ss.dependency 'TTKitchen/Core'
    ss.dependency 'TTKitchenExtension'
    ss.dependency 'BDTrackerProtocol'
    ss.dependency 'TTInstallService'
    ss.dependency 'TTThemed'
    ss.dependency 'TTUIWidget/TTAlphaThemedButton'
    ss.dependency 'TTBaseLib/TTBaseTool'
    ss.dependency 'TTBaseLib/TTDeviceHelper'
    ss.dependency 'TTBaseLib/TTCategory'
end

# TODO: Others待拆分
s.subspec 'Others' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTUIWidget/Classes/UIWidget/TTHorizontalStructViews/**/*.{h,m}',
                        'TTUIWidget/Classes/UIWidget/TTModalContainer/**/*.{h,m}',
                        'TTUIWidget/Classes/UIWidget/TTOriginalLogo/**/*.{h,m}',
                        'TTUIWidget/Classes/UIWidget/TTPanelController/**/*.{h,m}',
                        'TTUIWidget/Classes/UIWidget/TTRefresh/**/*.{h,m}',
                        'TTUIWidget/Classes/UIWidget/TTView/**/*.{h,m}',
                        'TTUIWidget/Classes/UIWidget/UILabelCategory/**/*.{h,m}',
                        'TTUIWidget/Classes/UIWidget/UIViewController+ErrorHandler/**/*.{h,m}',
                        'TTUIWidget/Classes/utils/UIViewControllerTrack/**/*.{h,m}'
    ss.public_header_files =    'TTUIWidget/Classes/UIWidget/TTHorizontalStructViews/**/*.h',
                        'TTUIWidget/Classes/UIWidget/TTModalContainer/**/*.h',
                        'TTUIWidget/Classes/UIWidget/TTOriginalLogo/**/*.h',
                        'TTUIWidget/Classes/UIWidget/TTPanelController/**/*.h',
                        'TTUIWidget/Classes/UIWidget/TTRefresh/**/*.h',
                        'TTUIWidget/Classes/UIWidget/TTView/**/*.h',
                        'TTUIWidget/Classes/UIWidget/UILabelCategory/**/*.h',
                        'TTUIWidget/Classes/UIWidget/UIViewController+ErrorHandler/**/*.h',
                        'TTUIWidget/Classes/utils/UIViewControllerTrack/**/*.h'
    ss.dependency 'TTBaseLib'
    ss.dependency 'TTThemed'
    ss.dependency 'TTImage'
    ss.dependency 'TTRoute'
    ss.dependency 'TTVerifyKit'
    ss.dependency 'KVOController'
    ss.dependency 'Masonry'
    ss.dependency 'TTUIWidget/TTBadgeNumberView'
    ss.dependency 'TTUIWidget/TTNavigationController'
    ss.dependency 'TTUIWidget/SSViewControllerBase'
    ss.dependency 'BDALog'
    ss.dependency 'lottie-ios'
    ss.dependency 'ByteDanceKit'
end

s.subspec 'ArticleListNotifyBarView' do |ss|
    ss.source_files = 'TTUIWidget/Classes/UIWidget/ArticleListNotifyBarView/**/*.{h,m}'
    ss.dependency 'TTThemed'
    ss.dependency 'Masonry'
    ss.dependency 'TTUIWidget/Others'
end

s.subspec 'TTLabel' do |ss|
    ss.source_files = 'TTUIWidget/Classes/UIWidget/TTLabel/*.{h,m}'
    ss.dependency 'TTBaseLib/TTCategory'
    ss.dependency 'TTThemed'
end

end
