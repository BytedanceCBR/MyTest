//
//  TTShortVideoHelper.m
//  Article
//
//  Created by 邱鑫玥 on 2017/8/17.
//

#import "TTShortVideoHelper.h"
#import "TTArticleTabBarController.h"
#import "TTArticleCategoryManager.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "HorizontalCard.h"
#import "AWEVideoConstants.h"
#import "TSVShortVideoOriginalData.h"
#import "TSVDownloadManager.h"
#import <TTRoute/TTRoute.h>
#import "TTTabBarProvider.h"
#import "TTTabBarManager.h"
#import "ExploreItemActionManager.h"
#import "ExploreMixListDefine.h"
#import "UIViewAdditions.h"
#import "TTDeviceUIUtils.h"
#import "TTDeviceHelper.h"
#import "TTArticleCellHelper.h"
#import "TTHTSTrackerHelper.h"
#import "TTFeedDislikeView.h"
#import "TTTabBarProvider.h"
#import "TTTabBarManager.h"
#import "ExploreOrderedData+TTAd.h"

static NSString * const kTSVOpenTabHost = @"ugc_video_tab";
static NSString * const kTSVOpenDetailHost = @"ugc_video_recommend";
static NSString * const kTSVOpenCategoryHost = @"ugc_video_category";
static NSString * const kTSVDownloadHost = @"ugc_video_download";

@implementation TTShortVideoHelper

#pragma mark - Tab
+ (BOOL)canOpenShortVideoTab
{
    return [TTTabBarProvider isHTSTabOnTabBar];
}

+ (void)openShortVideoTab
{
    if (![self canOpenShortVideoTab]) {
        return;
    }
        
    [[NSNotificationCenter defaultCenter] postNotificationName:TTArticleTabBarControllerChangeSelectedIndexNotification object:nil userInfo:@{@"tag":kTTTabHTSTabKey}];
}

+ (BOOL)canOpenShortVideoCategory
{
    return [TTArticleCategoryManager categoryModelByCategoryID:kTTUGCVideoCategoryID] != nil;
}

+ (void)openShortVideoCategory
{
    if (![self canOpenShortVideoCategory]) {
        return;
    }
    
    TTCategory *shortVideoCategory = [TTArticleCategoryManager categoryModelByCategoryID:kTTUGCVideoCategoryID];
    if (!shortVideoCategory.subscribed) {
        [[TTArticleCategoryManager sharedManager] subscribe:shortVideoCategory];
        [[TTArticleCategoryManager sharedManager] changeSubscribe:shortVideoCategory toOrderIndex:[TTArticleCategoryManager sharedManager].subScribedCategories.count - 1];
        [[TTArticleCategoryManager sharedManager] save];
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:shortVideoCategory forKey:@"model"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCategoryManagementViewCategorySelectedNotification object:self userInfo:userInfo];
}



#pragma mark - More Button Click
+ (BOOL)shouldHandleClickWithData:(ExploreOrderedData *)orderedData
{
    BOOL shouldHandleClick = NO;
    HorizontalCard *horizontalCard = orderedData.horizontalCard;
    NSString *urlStr = horizontalCard.showMoreModel.urlString;
    if (!isEmptyString(urlStr)) {
        NSURL *url = [TTStringHelper URLWithURLString:urlStr];
        TTRouteParamObj *params = [[TTRoute sharedRoute] routeParamObjWithURL:url];
        NSString *host = params.host;
        if ([host isEqualToString:kTSVOpenTabHost]) {
            shouldHandleClick = YES;
        }
    }
    return shouldHandleClick;
}

#pragma mark - Cell Style
+ (TTHorizontalCardStyle)cardStyleWithData:(ExploreOrderedData *)orderedData
{
    if ([orderedData.horizontalCard isKindOfClass:[HorizontalCard class]]) {
        HorizontalCard *card = orderedData.horizontalCard;
        NSInteger cardStyle = [card.cardLayoutStyle integerValue];
        switch (cardStyle) {
            case 1:
                return TTHorizontalCardStyleOne;
                break;
            case 2:
                return TTHorizontalCardStyleTwo;
                break;
            case 3:
                return TTHorizontalCardStyleThree;
                break;
            case 4:
                return TTHorizontalCardStyleFour;
                break;
            default:
                return TTHorizontalCardStyleTwo;
                break;
        }
    }
    return TTHorizontalCardStyleTwo;
}

+ (TTHorizontalCardContentCellStyle)contentCellStyleWithItemData:(ExploreOrderedData *)itemData
{
    if (itemData.cellCtrls && [itemData.cellCtrls isKindOfClass:[NSDictionary class]]) {
        NSInteger layoutStyle = [itemData.cellCtrls tt_integerValueForKey:@"cell_layout_style"];
        switch (layoutStyle) {
            case 15:
                return TTHorizontalCardContentCellStyle2;
                break;
            case 16:
                return TTHorizontalCardContentCellStyle3;
                break;
            case 17:
                return TTHorizontalCardContentCellStyle4;
                break;
            case 18:
                return TTHorizontalCardContentCellStyle5;
                break;
            case 21:
                return TTHorizontalCardContentCellStyle6;
                break;
            case 22:
                return TTHorizontalCardContentCellStyle7;
                break;
            case 23:
                return TTHorizontalCardContentCellStyle8;
                break;
            default:
                return TTHorizontalCardContentCellStyle1;
                break;
        }
    }
    return TTHorizontalCardContentCellStyle1;
}

#pragma mark - More Button Click

+ (void)handleClickWithData:(ExploreOrderedData *)orderedData;
{
    HorizontalCard *horizontalCard = orderedData.horizontalCard;
    NSString *urlStr = horizontalCard.showMoreModel.urlString;
    NSString *groupSource = [self groupSourceForDownloadWithHorizontalCard:horizontalCard];
    NSURL *url = [TTStringHelper URLWithURLString:urlStr];
    TTRouteParamObj *params = [[TTRoute sharedRoute] routeParamObjWithURL:url];
    NSString *host = params.host;

    if ([host isEqualToString:kTSVDownloadHost] && [TSVDownloadManager shouldDownloadAppForGroupSource:groupSource]) {
        
        if ([TSVDownloadManager shouldDownloadAppForGroupSource:groupSource]) {
            [TSVDownloadManager downloadAppForGroupSource:groupSource urlDict:@{
                                                                                HotsoonGroupSource : @"http://d.huoshanzhibo.com/SCJa/",
                                                                                AwemeGroupSource : @"https://d.douyin.com/A88w/"
                                                                                }];
            [self sendClickEventWithEventName:@"shortvideo_app_download_feed_click" groupSource:groupSource orderedData:orderedData];
        } else {
            [TSVDownloadManager openAppForGroupSource:groupSource];
        }
        
    } else {
        
        if ([host isEqualToString:kTSVDownloadHost]) {
            host = params.queryParams[@"download_show_more_url"];
        }
        
        if ([host isEqualToString:kTSVOpenTabHost]) {
            [self openShortVideoTab];
        } else if ([host isEqualToString:kTSVOpenDetailHost]) {
            url = [TTStringHelper URLWithURLString:[NSString stringWithFormat:@"%@load_more=2&enter_from=%@&category_name=%@",urlStr, [self enterFromData:orderedData], kTTUGCVideoCategoryID]];
            if ([[TTRoute sharedRoute] canOpenURL:url]) {
                [[TTRoute sharedRoute] openURLByPushViewController:url];
            }
        } else if ([host isEqualToString:kTSVOpenCategoryHost]) {
            [self openShortVideoCategory];
        } else {
            if ([[TTRoute sharedRoute] canOpenURL:url]) {
                [[TTRoute sharedRoute] openURLByPushViewController:url];
            }
        }
        [self sendClickEventWithEventName:@"click_more_shortvideo" groupSource:nil orderedData:orderedData];
    }
}

+ (NSString *)groupSourceForDownloadWithHorizontalCard:(HorizontalCard *)horizontalCard
{
    NSArray *items = [horizontalCard allCardItems];
    
    if (items.count >= 2) {
        ExploreOrderedData *data0 = (ExploreOrderedData *)items[0];
        ExploreOrderedData *data1 = (ExploreOrderedData *)items[1];
        
        if ([data0.shortVideoOriginalData.shortVideo.groupSource isEqualToString:AwemeGroupSource] && [data1.shortVideoOriginalData.shortVideo.groupSource isEqualToString:AwemeGroupSource]) {
            return AwemeGroupSource;
        } else if ([data0.shortVideoOriginalData.shortVideo.groupSource isEqualToString:HotsoonGroupSource] || [data1.shortVideoOriginalData.shortVideo.groupSource isEqualToString:HotsoonGroupSource]) {
            return HotsoonGroupSource;
        }
    }
    return ToutiaoGroupSource;
}

#pragma mark - 埋点

+ (void)sendClickEventWithEventName:(NSString *)eventName groupSource:(NSString *)groupSource orderedData:(ExploreOrderedData *)orderedData;
{
    HorizontalCard *horizontalCard = orderedData.horizontalCard;
    
    NSMutableDictionary *logParams = [[NSMutableDictionary alloc] initWithDictionary : @{
                                                                                         @"card_id" : [NSString stringWithFormat:@"%lld",horizontalCard.uniqueID],
                                                                                         @"category_name" : orderedData.categoryID ?: @"",
                                                                                         @"enter_from" : [[self class] enterFromData:orderedData],
                                                                                         @"position" : @"list"
                                                                                         }];
    [logParams setValue:groupSource forKey:@"group_source"];
    
    [TTTrackerWrapper eventV3:eventName params:logParams];
}

+ (NSString *)enterFromData:(ExploreOrderedData *)orderedData
{
    if ([orderedData.categoryID isEqualToString:@"__all__"]) {
        return @"click_headline";
    } else {
        return @"click_category";
    }
}

#pragma mark - Uninterest

+ (void)uninterestFormView:(UIView *)view point:(CGPoint)point withOrderedData:(ExploreOrderedData *)orderedData
{
    if (orderedData.horizontalCard) {
        //  水平卡片
        HorizontalCard *horizontalCard = orderedData.horizontalCard;
        for (ExploreOrderedData *item in horizontalCard.originalCardItems) {
            [TTHTSTrackerHelper trackUnInterestButtonClickedWithExploreOrderData:item extraParams:[self trackParamsDictWithData:orderedData]];
        }
        
        if ([horizontalCard isHorizontalScrollEnabled]) {
            for (NSInteger idx = [horizontalCard.originalCardItems count]; idx < [[horizontalCard allCardItems] count]; idx++) {
                ExploreOrderedData *item = [horizontalCard allCardItems][idx];
                [TTHTSTrackerHelper trackUnInterestButtonClickedWithExploreOrderData:item extraParams:[self trackParamsDictWithData:item]];
            }
        }
    } else {
        //  feed story
        [TTHTSTrackerHelper trackUnInterestButtonClickedWithExploreOrderData:orderedData extraParams:[self trackParamsDictWithData:orderedData]];
    }
    
    [TTFeedDislikeView dismissIfVisible];
    
    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.keywords = orderedData.article.filterWords;
    viewModel.groupID = [NSString stringWithFormat:@"%lld", orderedData.horizontalCard.uniqueID];
    viewModel.logExtra = orderedData.log_extra;
    [dislikeView refreshWithModel:viewModel];
    [dislikeView showAtPoint:point
                    fromView:view
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:view withOrderedData:orderedData];
             }];
}

#pragma mark TTFeedDislikeView

+ (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)dislikeView withOrderedData:(ExploreOrderedData *)orderedData
{
    if (!orderedData) {
        return;
    }
    if (orderedData.horizontalCard) {
        HorizontalCard *horizontalCard = orderedData.horizontalCard;
        //卡片内的内容请求batch_action接口
        for (ExploreOrderedData *item in horizontalCard.originalCardItems) {
            [TTHTSTrackerHelper trackDislikeViewOKBtnClickedWithExploreOrderData:item extraParams:[self trackParamsDictWithData:orderedData]];
            [self sendDislikeActionWithOrderedData:item source:TTDislikeSourceTypeFeed];
        }
        
        if ([horizontalCard isHorizontalScrollEnabled]) {
            for (NSInteger idx = [horizontalCard.originalCardItems count]; idx < [[horizontalCard allCardItems] count]; idx++) {
                ExploreOrderedData *item = [horizontalCard allCardItems][idx];
                [TTHTSTrackerHelper trackDislikeViewOKBtnClickedWithExploreOrderData:item extraParams:[self trackParamsDictWithData:item]];
                [self sendDislikeActionWithOrderedData:item source:TTDislikeSourceTypeFeed];
            }
        }
    } else {
        [TTHTSTrackerHelper trackDislikeViewOKBtnClickedWithExploreOrderData:orderedData extraParams:[self trackParamsDictWithData:orderedData]];
        [self sendDislikeActionWithOrderedData:orderedData source:TTDislikeSourceTypeFeed];
    }
    
    NSArray *filterWords = [dislikeView selectedWords];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setValue:orderedData forKey:kExploreMixListNotInterestItemKey];
    if (filterWords.count > 0) {
        [userInfo setValue:filterWords forKey:kExploreMixListNotInterestWordsKey];
    }
    //卡片的dislike不请求batch_action接口
    [userInfo setValue:@(0) forKey:kExploreMixListShouldSendDislikeKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}

+ (NSDictionary *)trackParamsDictWithData:(ExploreOrderedData *)orderedData
{
    NSString *enter_from;
    NSString *category_name;

//    if (orderedData.tsvStoryOriginalData) {
//        enter_from = @"click_pgc";
//        category_name = @"profile";
//    } else {
        if ([orderedData.categoryID isEqualToString:@"__all__"]) {
            enter_from = @"click_headline";
        } else {
            enter_from = @"click_category";
        }
        category_name = orderedData.categoryID?:@"";
//    }

    return @{
             @"category_name":category_name,
             @"enter_from":enter_from,
             };
}

+ (void)sendDislikeActionWithOrderedData:(ExploreOrderedData *)orderedData source:(TTDislikeSourceType)sourceType
{
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:orderedData.uniqueID itemID:orderedData.itemID impressionID:nil aggrType:1];
    ExploreItemActionManager *itemActionManager = [[ExploreItemActionManager alloc] init];
    [itemActionManager startSendDislikeActionType:DetailActionTypeNewVersionDislike source:sourceType groupModel:groupModel filterWords:nil cardID:nil actionExtra:orderedData.actionExtra adID:nil adExtra:nil widgetID:nil threadID:nil finishBlock:nil];
}

@end
