#
# Be sure to run `pod lib lint TTShare.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTShare'
  s.version          = '0.3.3'
  s.summary          = '头条分享库'
  s.description      = <<-DESC
                        头条分享库。
                        封装第三方分享SDK，提供一致的分享接口。
                       DESC
  s.homepage         = 'https://code.byted.org/TTIOS/tt_pods_share'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '王霖' => 'wanglin.02@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/tt_pods_share.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'

#----------------注册入口封装----------------
  s.subspec "TTShareService" do |ss|
    ss.source_files = 'TTShareService'
    ss.public_header_files = 'TTShareService/TTShareApiConfig.h',
                             'TTShareService/TTShareActivity.h'

    ss.dependency 'TTShare/TTShareBusiness'
    ss.dependency 'TTShare/TTShareBasic'
  end
#----------------分享业务库----------------
  s.subspec "TTShareBusiness" do |ss|
    ss.subspec "TTShareQQBusiness" do |sss|
        sss.source_files = 'TTShareBusiness/TTShareQQ'
        sss.resources  = 'TTShareBusiness/TTShareQQ/TTShareQQ.xcassets'

        sss.dependency 'TTShare/TTShareBusiness/TTActivity'
        sss.dependency 'TTShare/TTShareBasic/TTQQShare'
    end

    ss.subspec "TTShareWeChatBusiness" do |sss|
        sss.source_files = 'TTShareBusiness/TTShareWeChat'
        sss.resources  = 'TTShareBusiness/TTShareWeChat/TTShareWeChat.xcassets'

        sss.dependency 'TTShare/TTShareBusiness/TTActivity'
        sss.dependency 'TTShare/TTShareBasic/TTWeChatShare'
    end

    ss.subspec "TTShareWeiboBusiness" do |sss|
        sss.source_files = 'TTShareBusiness/TTShareWeibo'
        sss.resources  = 'TTShareBusiness/TTShareWeibo/TTShareWeibo.xcassets'

        sss.dependency 'TTShare/TTShareBusiness/TTActivity'
        sss.dependency 'TTShare/TTShareBasic/TTWeiboShare'
    end

    ss.subspec "TTShareAliBusiness" do |sss|
        sss.source_files = 'TTShareBusiness/TTShareZhiFuBao'
        sss.resources = 'TTShareBusiness/TTShareZhiFuBao/TTShareZhiFuBao.xcassets'

        sss.dependency 'TTShare/TTShareBusiness/TTActivity'
        sss.dependency 'TTShare/TTShareBasic/TTAliShare'
    end

    ss.subspec "TTShareEmailBusiness" do |sss|
        sss.source_files = 'TTShareBusiness/TTShareEmail'
        sss.resources  = 'TTShareBusiness/TTShareEmail/TTShareEmail.xcassets'

        sss.dependency 'TTShare/TTShareBusiness/TTActivity'
    end

    ss.subspec "TTShareSMSBusiness" do |sss|
        sss.source_files = 'TTShareBusiness/TTShareSMS'
        sss.resources  = 'TTShareBusiness/TTShareSMS/TTShareSMS.xcassets'

        sss.dependency 'TTShare/TTShareBusiness/TTActivity'
    end

    ss.subspec "TTShareDingTalkBusiness" do |sss|
        sss.source_files = 'TTShareBusiness/TTShareDingTalk'
        sss.resources  = 'TTShareBusiness/TTShareDingTalk/TTShareDingTalk.xcassets'

        sss.dependency 'TTShare/TTShareBusiness/TTActivity'
        sss.dependency 'TTShare/TTShareBasic/TTDingTalkShare'
    end

    ss.subspec "TTShareCopyBusiness" do |sss|
        sss.source_files = 'TTShareBusiness/TTShareCopy'
        sss.resources  = 'TTShareBusiness/TTShareCopy/TTShareCopy.xcassets'

        sss.dependency 'TTShare/TTShareBusiness/TTActivity'
    end

    ss.subspec "TTShareSystemBusiness" do |sss|
        sss.source_files = 'TTShareBusiness/TTShareSystem'
        sss.resources  = 'TTShareBusiness/TTShareSystem/TTShareSystem.xcassets'

        sss.dependency 'TTShare/TTShareBusiness/TTActivity'
    end

    ss.subspec "TTActivity" do |sss|
        sss.source_files = 'TTShareBusiness/TTShareProtocol',
                           'TTShareBusiness/TTShareManager',
                           'TTShareBusiness/TTShareUtil',
                           'TTShareBusiness/TTShareAdapterService'
        sss.public_header_files = 'TTShareBusiness/TTShareAdapterService/TTShareAdapterSetting.h',
                                  'TTShareBusiness/TTShareProtocol/*.{h}',
                                  'TTShareBusiness/TTShareManager/*.{h}'
    end
  end

#----------------分享基础库----------------
  s.subspec "TTShareBasic" do |ss|
    ss.source_files = 'TTShareBasic/Util/**/*.{h,m}'
    #QQ分享
    ss.subspec "TTQQShare" do |sss|
        sss.source_files = 'TTShareBasic/QQShare/**/*.{h,m}'
        #sss.dependency 'TTThirdPartySDKs/QQSDK'
    end
    #微信分享
    ss.subspec "TTWeChatShare" do |sss|
        sss.source_files = 'TTShareBasic/WeChatShare/**/*.{h,m}'
        #sss.dependency 'TTThirdPartySDKs/WeChatSDK'
    end
    #微博分享
    ss.subspec "TTWeiboShare" do |sss|
        sss.source_files = 'TTShareBasic/WeiboShare/**/*.{h,m}'
        #sss.dependency 'TTThirdPartySDKs/WeiboSDK'
    end
    #支付宝分享
    ss.subspec "TTAliShare" do |sss|
        sss.source_files = 'TTShareBasic/AliShare/**/*.{h,m}'
        #sss.dependency 'TTThirdPartySDKs/AliShareSDK'
    end
    #钉钉分享
    ss.subspec "TTDingTalkShare" do |sss|
        sss.source_files = 'TTShareBasic/DingTalkShare/**/*.{h,m}'
        #sss.dependency 'TTThirdPartySDKs/DingDingSDK'
    end
    #邮件分享
    ss.subspec "TTMailShare" do |sss|
        sss.source_files = 'TTShareBasic/MailShare/**/*.{h,m}'
        #sss.frameworks = 'MessageUI'
    end
    #短信分享
    ss.subspec "TTMessageShare" do |sss|
        sss.source_files = 'TTShareBasic/MessageShare/**/*.{h,m}'
        #sss.frameworks = 'MessageUI'
    end
  end

end
