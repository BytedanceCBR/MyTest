//
//  TTHTSTrackerHelper.m
//  Article
//
//  Created by 王双华 on 2017/5/26.
//
//

#import "TTHTSTrackerHelper.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TSVShortVideoOriginalData.h"

@implementation TTHTSTrackerHelper

+ (void)trackUnInterestButtonClickedWithExploreOrderData:(ExploreOrderedData *)orderedData extraParams:(NSDictionary *)extraParams
{
    [TTTrackerWrapper eventV3:@"dislike_menu_no_reason" params:[self paramsWithOrderedData:orderedData extraParams:extraParams]];
}

+ (void)trackDislikeViewOKBtnClickedWithExploreOrderData:(ExploreOrderedData *)orderedData extraParams:(NSDictionary *)extraParams
{
    [TTTrackerWrapper eventV3:@"rt_dislike" params:[self paramsWithOrderedData:orderedData extraParams:extraParams]];
}

+ (NSDictionary *)paramsWithOrderedData:(ExploreOrderedData *)orderedData extraParams:(NSDictionary *)extraParams
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:extraParams];
    
//    if (orderedData.tsvStoryOriginalData) {
//        if ([orderedData.categoryID isEqualToString:@"__all__"]) {
//            [params setValue:@"more_shortvideo" forKey:@"list_entrance"];
//        } else if ([orderedData.categoryID isEqualToString:@"关注"]) {
//            [params setValue:@"more_shortvideo_guanzhu" forKey:@"list_entrance"];
//        }
//    } else {
        [params setValue:@"list" forKey:@"position"];
        [params setValue:orderedData.shortVideoOriginalData.shortVideo.author.userID forKey:@"user_id"];
        [params setValue:orderedData.shortVideoOriginalData.shortVideo.groupSource forKey:@"group_source"];
        [params setValue:orderedData.uniqueID forKey:@"group_id"];
        [params setValue:orderedData.shortVideoOriginalData.shortVideo.itemID forKey:@"item_id"];
//    }
    
    [params setValue:orderedData.logPb forKey:@"log_pb"];

    return params;
}

@end
