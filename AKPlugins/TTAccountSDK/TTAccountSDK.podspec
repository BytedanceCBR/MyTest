#
#  Be sure to run `pod spec lint TTAccountSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "TTAccountSDK"
  s.version      = "3.0.6"
  s.summary      = "爱看账号系统"
  s.description  = '爱看账号系统'

  s.homepage     = "https://code.byted.org/TTIOS/tt_pods_account"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = "MIT (:type => 'MIT', :file => 'LICENSE')"


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "liuzuopeng" => "liuzuopeng@bytedance.com" }
  # Or just: s.author    = "liuzuopeng"
  # s.authors            = { "liuzuopeng" => "liuzuopeng@bytedance.com" }
  # s.social_media_url   = "http://twitter.com/liuzuopeng"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  # s.platform     = :ios
  # s.platform     = :ios, "5.0"

  #  When using multiple platforms
  s.ios.deployment_target = "7.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source = { :git => "git@code.byted.org:TTIOS/tt_pods_account.git",
               :tag => "#{s.version.to_s}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  # s.source_files  = "Classes/TTAccountSDK.{h,m}"
  # s.exclude_files = "Classes/Exclude"
  # s.public_header_files = "Classes/**/*.h"
  s.resource = "Classes/Resource/TTAccountAssets.bundle"


  # 全局依赖
  s.dependency "TTNetworkManager"
  s.dependency "TTReachability"


  # Frameworks
  s.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'


  # ARC
  s.requires_arc = true


  # Logger
  s.subspec "Logger" do |ss|
    ss.source_files  = "Classes/Logger/**/TTAccountLogger.{h,m,mm}", "Classes/Logger/**/TT*Monitor*.{h,m,mm}"
  end


  # 基本账号
  s.subspec "Account" do |ss|
    ss.source_files  = "Classes/Account/**/*.{h,m,mm}", "Classes/TTAccountSDK.{h,m}"
    ss.exclude_files = "Classes/ThirdPartyAccount"
    ss.private_header_files = "Classes/Account/Private/**/*.{h}"

    ss.dependency "TTAccountSDK/Logger"
  end


  s.subspec "WeChatAccount" do |ss|
    ss.source_files = "Classes/ThirdPartyAccount/Platforms/WechatAccount/**/*.{h,m,mm}"
    ss.dependency "TTAccountSDK/ThirdPartyAccountFoundation"
    ss.dependency "TTThirdPartySDKs/WeChatSDK", "~> 0.0.4"
  end

    # 第三方授权登录账号
  s.subspec "ThirdPartyAccountFoundation" do |ss|
    ss.subspec "PlatformLoginCore" do |ssa|
      ssa.source_files  = "Classes/ThirdPartyAccount/**/*.{h,m,mm}", "Classes/Logger/**/TTAccountAuthLogger.{h,m,mm}"
      ssa.exclude_files = "Classes/ThirdPartyAccount/Platforms/**/*.{h,m,mm}"
      # ssc.resource    = "Classes/ThirdPartyAccount/AccountUIKit/TTAccountAssets.bundle"
      ssa.private_header_files = "Classes/ThirdPartyAccount/Private/**/*.{h}"
    end

    ss.subspec "CustomAuthLoginUI" do |ssa|
      ssa.source_files = "Classes/ThirdPartyAccount/Platforms/AccountAuthUI/**/*.{h,m,mm}"
      ssa.private_header_files = "Classes/ThirdPartyAccount/Platforms/AccountAuthUI/Private/**/*.{h}"
      ssa.dependency "TTAccountSDK/ThirdPartyAccountFoundation/PlatformLoginCore"
    end

    ss.dependency "TTAccountSDK/Account"
  end





  # set default subspec
  s.default_subspecs = 'Account'


end
