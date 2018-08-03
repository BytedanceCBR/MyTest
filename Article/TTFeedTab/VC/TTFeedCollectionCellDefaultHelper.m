//
//  TTFeedCollectionCellDefaultHelper.m
//  Article
//
//  Created by Chen Hong on 2017/4/9.
//
//

#import "TTFeedCollectionCellDefaultHelper.h"
#import "TTFeedCollectionNewsListCell.h"
#import "TTFeedCollectionWebListCell.h"
//#import "TTFeedCollectionSubListCell.h"
//#import "TTFeedCollectionWenDaListCell.h"
//#import "TTFeedCollectionFollowListCell.h"
#import "TTFeedCollectionHTSListCell.h"

#import "TTCategory.h"

@implementation TTFeedCollectionCellDefaultHelper

+ (nullable Class<TTFeedCollectionCell>)cellClassFromFeedCategory:(nonnull id<TTFeedCategory>)feedCategory
{
    switch (feedCategory.listDataType) {
        case TTFeedListDataTypeArticle:
        case TTFeedListDataTypeEssay:
        case TTFeedListDataTypeImage:
            if ([feedCategory.categoryID isEqualToString:kTTUGCVideoCategoryID] || [feedCategory.categoryID isEqualToString:@"ugc_video_fake"]) {
                return [TTFeedCollectionHTSListCell class]; // 火山小视频频道 和小视频测试频道
            }
//            else if ([feedCategory.categoryID isEqualToString:@"question_and_answer"]) {
//                return [TTFeedCollectionWenDaListCell class]; // 问答频道
//            }
//            else if ([feedCategory.categoryID isEqualToString:kTTFollowCategoryID]){
//                return [TTFeedCollectionFollowListCell class]; //关注频道
//            }
            else {
                return [TTFeedCollectionNewsListCell class]; // 普通频道
            }
            break;
            
        case TTFeedListDataTypeWeb:
            return [TTFeedCollectionWebListCell class]; // Web频道
        case TTFeedListDataTypeShortVideo:
            return [TTFeedCollectionHTSListCell class]; // 火山小视频频道
        default:
            break;
    }
    
    return [TTFeedCollectionNewsListCell class];
}

+ (NSArray<Class<TTFeedCollectionCell>> *)supportedCellClasses
{
    return @[
             [TTFeedCollectionNewsListCell class],
             [TTFeedCollectionNewsListCell class],
             [TTFeedCollectionWebListCell class],
//             [TTFeedCollectionSubListCell class],
//             [TTFeedCollectionWenDaListCell class],
//             [TTFeedCollectionFollowListCell class],
             [TTFeedCollectionHTSListCell class],
             ];
}

@end
