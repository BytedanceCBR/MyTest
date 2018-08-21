//
//  WDMonitorManager.h
//  Article
//
//  Created by xuzichao on 2016/11/8.
//
//

#import "TTMonitor.h"

extern NSString * const kWDErrorDomain;
extern NSString * const kWDErrorTipsKey;
extern NSString * const kWDErrorCodeKey;

#pragma mark - 网络请求状态

typedef NS_ENUM(NSUInteger, WDRequestNetworkStatus) {
    WDRequestNetworkStatusCompleted, //成功
    WDRequestNetworkStatusFailed , //失败
    WDRequestNetworkStatusBusinessError, //服务端业务失败，是否统计看具体业务
};

extern NSString * const WDAnswerPastLengthKey;
extern NSString * const WDAnswerQualifyPasteService;

#pragma mark - 核心提交服务

extern NSString * const WDPostQuestionService;
extern NSString * const WDPostAnswerService;

#pragma mark - 图片上传服务，记状态

extern NSString * const WDQuestionImageUploadService;//提问时候图片上传
extern NSString * const WDAnswerImageUploadService;//回答时候的图片上传

#pragma mark - 问答频道首页

extern NSString * const WDFeedRefreshService;
extern NSString * const WDFeedLoadMoreService;

extern NSString * const WDFeedRefreshTimeService;
extern NSString * const WDFeedLoadMoreTimeService;

#pragma mark - 问答回答列表接口

extern NSString * const WDListRefreshService;
extern NSString * const WDListLoadMoreService;

extern NSString * const WDListRefreshTimeService;
extern NSString * const WDListLoadMoreTimeService;

extern NSString * const WDListErrorPageStayService; //列表页stay_page错误

#pragma mark - 问答回答详情接口

extern NSString * const WDDetailCDNService;
extern NSString * const WDDetailInfoService;
extern NSString * const WDDetailCommentService;

extern NSString * const WDDetailCDNTimeService;
extern NSString * const WDDetailDomReadyTimeService; //问答详情页DomReady时长统计
extern NSString * const WDDetailInfoTimeService; //问答详情页Info接口耗时
extern NSString * const WDDetailCommentTimeService; //问答详情页评论接口耗时

extern NSString * const WDDetailErrorPageStayService; //详情页页面时长统计
extern NSString * const WDDetailContentNullService; //详情页内容数据为空的情况


@interface WDMonitorManager : NSObject

+ (NSString *)userId;
+ (NSDictionary *)extraDicWithError:(NSError *)error;
+ (NSDictionary *)extraDicWithInfo:(NSDictionary *)dict error:(NSError *)error;
+ (NSDictionary *)extraDicWithQuestionId:(NSString *)qId error:(NSError *)error;
+ (NSDictionary *)extraDicWithAnswerId:(NSString *)answId error:(NSError *)error;

@end
