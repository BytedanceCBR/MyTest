#
# Be sure to run `pod lib lint TOTFactoryConfigurator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'TTUGCFoundation'
    s.version          = '0.1.3'
    s.summary          = 'TTUGCFoundation 用于UGC使用的基础库'

    s.description      = <<-DESC
    TTUGCFoundation 用于UGC使用的基础库
    DESC

    s.homepage         = 'https://code.byted.org/TTIOS/TTUGCFoundation'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'chaisong' => 'chaisong@bytedance.com' }
    s.source           = { :git => 'git@code.byted.org:TTIOS/TTUGCFoundation.git', :tag => s.version.to_s }

    s.ios.deployment_target = '8.0'
    s.compiler_flags = '-Wno-unknown-warning-option'
    s.frameworks = 'UIKit', 'Foundation'
    # s.prefix_header_contents = '#import "TTUGCFoundationPCHHeader.h"'
    # s.default_subspec = 'Core'
    s.resources = 'TTUGCFoundation/Assets/UGCImage.xcassets'

    s.subspec 'RequestMonitor' do |ss|
        ss.requires_arc =   true
        ss.dependency 'TTNetworkManager'
        ss.dependency 'TTMonitor'
        ss.dependency 'TTBaseLib/TTCategory'
        ss.dependency 'TTBaseLib/TTBaseTool'
        ss.dependency 'JSONModel'
        ss.source_files =   'RequestMonitor/Classes/**/*.{h,m}'
        ss.public_header_files = 'RequestMonitor/Classes/**/*.h'
    end

    s.subspec 'TTUGCApiModel' do |ss|
        ss.requires_arc =   true
        ss.dependency 'TTNetworkManager'
        ss.dependency 'JSONModel'
        ss.dependency 'TTPlatformBaseLib/TTURLDomainHelper'
        ss.dependency 'TTPlatformUIModel/TTModel'
        ss.source_files =   'TTUGCApiModel/Classes/*.{h,m}'
        ss.public_header_files = 'TTUGCApiModel/Classes/*.h'
    end

    s.subspec 'TTUGCActionDataService' do |ss|
        ss.requires_arc =   true
        ss.dependency 'TTServiceKit'
        ss.dependency 'TTEntityBase'
        ss.dependency 'libextobjc'
        ss.source_files =   'TTUGCActionDataService/Classes/*.{h,m}'
        ss.public_header_files = 'TTUGCActionDataService/Classes/*.h'
    end

    # s.subspec 'TTKitchen' do |ss|
    #     ss.requires_arc =   true
    #     ss.dependency 'YYCache'
    #     ss.source_files =   'TTKitchen/Classes/*.{h,m}'
    #     ss.public_header_files = 'TTKitchen/Classes/*.h'
    # end

    # s.subspec 'TTCSSUIKit' do |ss|
    #     ss.requires_arc =   true
    #     ss.dependency 'TTThemed'
    #     ss.dependency 'TTBaseLib/TTCategory'
    #     ss.dependency 'TTBaseLib/TTBaseTool'
    #     ss.source_files =   'TTCSSUIKit/Classes/**/*.{h,m}'
    #     ss.resource_bundles = { 'TTCSSUIKit' => ['TTCSSUIKit/Assets/**/*.{css,json}'] }
    #     ss.public_header_files = 'TTCSSUIKit/Classes/**/*.h'
    # end

    s.subspec 'TTUGCRichText' do |ss|
        ss.requires_arc =   true
        ss.source_files =   'TTUGCRichText/Classes/**/*.{h,m}'
        ss.public_header_files = 'TTUGCRichText/Classes/**/*.h'
        ss.resources  = 'TTUGCRichText/Assets/Emoji.xcassets'
        ss.resource_bundles = { 'TTUGCRichText' => ['TTUGCRichText/Assets/**/*.plist'] }
        ss.dependency 'TTUGCFoundation/TTUGCApiModel'
        ss.dependency 'TTThemed'
        ss.dependency 'TTUIWidget'
        ss.dependency 'KVOController'
        ss.dependency 'TTAvatar'
        ss.dependency 'TTBaseLib'
        ss.dependency 'TTNetworkManager'
        ss.dependency 'TTPlatformBaseLib/TTTrackerWrapper'
        ss.dependency 'TTServiceKit'
        ss.dependency 'BDTFactoryConfigurator'
        ss.dependency 'TTPlatformUIModel/HPGrowingTextView'
        ss.dependency 'TTPlatformUIModel/TTModel'
        ss.dependency 'TTPlatformBaseLib/TTURLDomainHelper'
        ss.dependency 'TTPlatformUIModel/TTSeachBarView'
    end

    # s.subspec 'TTUGCComment' do |ss|
    #     ss.requires_arc =   true
    #     ss.dependency 'TTNetworkManager'

    #     ss.dependency 'libextobjc'

    #     ss.dependency 'TTImpression'
    #     ss.dependency 'AKCommentPlugin'        

    #     ss.dependency 'TTNewsAccountBusiness'
    #     ss.dependency 'TTUGCFoundation/TTUGCActionDataService'

    #     ss.dependency 'TTPlatformUIModel/TTActionSheet'
    #     ss.dependency 'TTUGCFoundation/RequestMonitor'
    #     ss.source_files =   'TTUGCComment/Classes/**/*.{h,m}'
    #     ss.public_header_files = 'TTUGCComment/Classes/**/*.h'
    # end

    # s.subspec 'Core' do |core|
    #     core.source_files = 'TTUGCFoundation/Classes/**/*.{h,m}'
    #     core.dependency 'TTUGCFoundation/RequestMonitor'
    #     core.dependency 'TTUGCFoundation/TTUGCActionDataService'
    #     core.dependency 'TTUGCFoundation/TTUGCRichText'
    #     core.dependency 'TTUGCFoundation/TTUGCApiModel'
    #     core.dependency 'TTUGCFoundation/TTUGCComment'
    #     core.dependency 'TTUGCFoundation/TTCSSUIKit'
    #     # core.dependency 'TTUGCFoundation/TTKitchen'
    #     core.dependency 'JSONModel'   
    #     core.dependency 'TTBaseLib'
    #     core.dependency 'FRLogKit'
    #     core.dependency 'TTImage'
    #     core.dependency 'TTImagePreviewAnimateManager'
    #     core.dependency 'Crashlytics'
    #     core.dependency 'TTTracker'
    #     core.dependency 'TTPlatformBaseLib'
    #     core.dependency 'TTPlatformUIModel'
    #     core.dependency 'TTImagePicker'
    #     # s.dependency 'AKShareServicePlugin'
    #     s.dependency 'TTShare/TTShareBasic/TTWeChatShare'
    #     s.dependency 'TTShare/TTShareBasic/TTQQShare'
    #     s.dependency 'TTShare/TTShareBusiness/TTShareWeChatBusiness'
    #     s.dependency 'TTShare/TTShareBusiness/TTShareQQBusiness'
    #     core.dependency 'TTNetworkManager'
    #     core.dependency 'BDTSharedHeaders'
    #     core.dependency 'TTFileUploadClient'
    #     core.dependency 'BDTBasePlayer'
    # end

end

