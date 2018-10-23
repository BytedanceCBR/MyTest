//
//  TTDetailWebViewContainerDefine.h
//  Pods
//
//  Created by muhuai on 2017/4/27.
//
//

#import <Foundation/Foundation.h>

//文章详情页浮层类型
typedef NS_ENUM(NSInteger, TTDetailNatantStyle)
{
    TTDetailNatantStyleDisabled,      //禁止浮层
    TTDetailNatantStyleInsert,       //点击或临界值拖拽调起
    TTDetailNatantStyleAppend,       //随手平滑滚出+点击调起
    TTDetailNatantStyleOnlyClick,    //点击调起
};

/**
 *  footer view 的显示状态
 */
typedef NS_ENUM(NSUInteger, TTDetailWebViewFooterStatus)
{
    TTDetailWebViewFooterStatusNoDisplay, //没有显示
    TTDetailWebViewFooterStatusDisplayHalf,//显示了一半
    TTDetailWebViewFooterStatusDisplayTotal,//完整显示, 此种显示是用户手动滑动到底部显示的
    TTDetailWebViewFooterStatusDisplayNotManual,//完整显示，此种显示不是用户手动滑动到底部显示的
};

typedef enum JSMetaInsertImageType {
    JSMetaInsertImageTypeNone,      //kJsMetaImageNoneKey
    JSMetaInsertImageTypeOrigin,    //kJsMetaImageOriginKey
    JSMetaInsertImageTypeThumb      //kJsMetaImageThumbKey
}JSMetaInsertImageType;

#define kJsMetaImageOriginKey       @"origin"
#define kJsMetaImageThumbKey        @"thumb"
#define kJsMetaImageNoneKey         @"none"
#define kJsMetaImageAllKey          @"all"
#define kShowOriginImageHost        @"origin_image"         //单张显示大图
#define kShowFullImageHost          @"full_image"           //进入图片浏览页面
#define kCacheSizeForAllTypeThumb   @"thumb"

#define kLocalSDKDetailSCheme               @"localsdk://detail"    //兼容较早相关阅读代码
#define kMediaAccountProfileHost            @"media_account"        //PGC profile
#define kShowOriginImageHost                @"origin_image"         //单张显示大图
#define kShowFullImageHost                  @"full_image"           //进入图片浏览页面
#define kWebViewShowThumbImage              @"thumb_image"          //非wifi下加载缩略图
#define kWebViewCancelimageDownload         @"cancel_image"         //用户取消下载
#define kUserProfile                        @"user_profile"         //用户主页
#define kWebViewUserClickLoadOriginImg      @"toggle_image"         //用户点击显示原图，//一键切换大图 按钮
#define kClickSource                        @"click_source"         //来源
#define kDomReady                           @"domReady"             //domReady事件

#define kBytedanceScheme                    @"bytedance"
#define kSNSSDKScheme                       @"snssdk35"
#define kDownloadAppHost                    @"download_app"
#define kCustomOpenHost                     @"custom_open"
#define kTrackURLHost                       @"track_url"
#define kCustomEventHost                    @"custom_event"
#define kKeyWordsHost                       @"keywords"
#define kArticleImpression                  @"article_impression"
#define kClientEscapeTranscodeError         @"transcode_error"      //客户端转码失败
#define kClientEscapeOpenInWebViewHost      @"open_origin_url"      //客户端转码
#define kMediaLike                          @"media_like"
#define kMediaUnlike                        @"media_unlike"
