//
//  WDMonitorManager.m
//  Article
//
//  Created by xuzichao on 2016/11/8.
//
//

#import "WDMonitorManager.h"
#import "WDDefines.h"

NSString * const kWDErrorDomain  = @"WDPostErrorDomain";
NSString * const kWDErrorTipsKey = @"WDErrorTipsKey";
NSString * const kWDErrorCodeKey = @"WDErrorCodeKey";

NSString * const WDAnswerPastLengthKey = @"PasteLength";
NSString * const WDAnswerQualifyPasteService = @"wenda_answer_qualify_paste";

//核心提交服务

NSString * const WDPostQuestionService = @"wenda_post_question_network";
NSString * const WDPostAnswerService = @"wenda_post_answer_network";

//图片提交
NSString * const WDQuestionImageUploadService = @"wenda_postquestion_image_upload";
NSString * const WDAnswerImageUploadService = @"wenda_postanswer_image_upload";

//Feed
NSString * const WDFeedRefreshService = @"wenda_feed_refresh_network";
NSString * const WDFeedLoadMoreService = @"wenda_feed_loadmore_network";

NSString * const WDFeedRefreshTimeService = @"wenda_feed_refresh_time";  // not OK for now
NSString * const WDFeedLoadMoreTimeService = @"wenda_feed_loadmore_time";


//列表页
NSString * const WDListRefreshService = @"wenda_list_refresh_network";
NSString * const WDListLoadMoreService = @"wenda_list_loadmore_network";

NSString * const WDListRefreshTimeService = @"wenda_list_refresh_time";
NSString * const WDListLoadMoreTimeService = @"wenda_list_loadmore_time";

NSString * const WDListErrorPageStayService = @"wenda_list_error_page_stay";

//详情页
NSString * const WDDetailCDNService = @"wenda_detail_cdn_network";
NSString * const WDDetailInfoService = @"wenda_detail_info_network";
NSString * const WDDetailCommentService = @"wenda_detail_comment_network";

NSString * const WDDetailCDNTimeService = @"wenda_detail_cdntime_network";

NSString * const WDDetailDomReadyTimeService = @"wenda_detail_domready_time";
NSString * const WDDetailInfoTimeService = @"wenda_detail_info_time";
NSString * const WDDetailCommentTimeService = @"wenda_detail_comment_time";

NSString * const WDDetailErrorPageStayService = @"wenda_detail_error_page_stay";
NSString * const WDDetailContentNullService = @"wenda_null_content_count";

@implementation WDMonitorManager

+ (NSString *)userId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"SNS_USER_ID"];
}

+ (NSDictionary *)extraDicWithError:(NSError *)error
{
    return [self extraDicWithInfo:nil error:error];
}

+ (NSDictionary *)extraDicWithInfo:(NSDictionary *)dict error:(NSError *)error
{
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] initWithDictionary:dict];
    
    [extra addEntriesFromDictionary:[self extraDataWithError:error]];
    
    return [extra copy];
}

+ (NSDictionary *)extraDicWithQuestionId:(NSString *)qId error:(NSError *)error
{
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];

    if (!isEmptyString(qId)) {
        [extra setValue:qId forKey:@"qid"];
    }
    
    [extra addEntriesFromDictionary:[self extraDataWithError:error]];
    
    return [extra copy];
}

+ (NSDictionary *)extraDicWithAnswerId:(NSString *)answId error:(NSError *)error
{
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];

    if (!isEmptyString(answId)) {
        [extra setValue:answId forKey:@"ansid"];
    }
    
    [extra addEntriesFromDictionary:[self extraDataWithError:error]];
    
    return [extra copy];
}

+ (NSDictionary *)extraDataWithError:(NSError *)error
{
    NSMutableDictionary *extraDict = @{}.mutableCopy;
    [extraDict setValue:@(error.code) forKey:@"err_code"];
    
    //业务错误Code
    NSNumber *code = [error.userInfo objectForKey:kWDErrorCodeKey];
    if (code) {
        [extraDict setValue:code forKey:kWDErrorCodeKey];
    }
    
    //业务错误Desc
    NSString *tips = [error.userInfo tt_stringValueForKey:kWDErrorTipsKey];
    if (isEmptyString(tips)) {
        tips = error.localizedDescription;
    }
    [extraDict setValue:tips forKey:@"err_des"];
    
    return [extraDict copy];
}

@end
