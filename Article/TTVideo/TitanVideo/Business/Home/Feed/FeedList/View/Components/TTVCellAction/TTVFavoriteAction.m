//
//  TTVFavoriteAction.m
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//

#import "TTVFavoriteAction.h"
#import "ExploreItemActionManager.h"
#import "TTIndicatorView.h"
#import "TTVideoArticleService+Action.h"
#import "TTVFeedItem+Extension.h"
#import "Article.h"
#import <libextobjc/extobjc.h>
#import "TTMessageCenter.h"
#import "TTVFeedUserOpDataSyncMessage.h"

@implementation TTVFavoriteActionEntity


@end

@interface TTVFavoriteAction ()
@property (nonatomic ,strong)ExploreItemActionManager *itemActionManager;
@end

@implementation TTVFavoriteAction
@dynamic entity;


- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity
{
    self = [super initWithEntity:entity];
    if (self) {
        self.type = TTActivityTypeFavorite;
    }
    return self;
}

- (TTVideoArticleService *)articleService
{
    TTVideoArticleService *service = [[TTServiceCenter sharedInstance] getService:[TTVideoArticleService class]];
    return service;
}

- (TTVideoArticleActionItem *)actionItemWithUserInfo:(NSDictionary *)dic adId:(NSString *)adId
{
    TTVideoArticleActionItem *item = [[TTVideoArticleActionItem alloc] init];
    item.groupId = [NSString stringWithFormat:@"%@",[dic valueForKey:@"group_id"]];
    item.adId = [NSString stringWithFormat:@"%@",adId];
    item.buryCount = @([NSString stringWithFormat:@"%@",[dic valueForKey:@"bury_count"]].longLongValue);
    item.diggCount = @([NSString stringWithFormat:@"%@",[dic valueForKey:@"digg_count"]].longLongValue);
    item.commentCount = @([NSString stringWithFormat:@"%@",[dic valueForKey:@"comment_count"]].longLongValue);
    item.repinCount = @([NSString stringWithFormat:@"%@",[dic valueForKey:@"repin_count"]].longLongValue);
    return item;
}

- (void)olDFavorite
{
    NSString *group_id = self.entity.groupId;
    NSString *item_id = self.entity.itemId;
    NSString *category_id = self.entity.categoryId;
    NSNumber *aggrType = self.entity.aggrType;
    NSString *ad_id = self.entity.adId;
    BOOL userRepined = [self userRepined];

    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    NSString *unique_id = group_id ? group_id : ad_id;
    NSMutableDictionary * eventContext = [[NSMutableDictionary alloc] init];
    [eventContext setValue:unique_id forKey:@"group_id"];
    [eventContext setValue:item_id forKey:@"item_id"];
    NSString * screenName = category_id ? [NSString stringWithFormat:@"channel_%@", category_id] : nil;

    TTGroupModel *model = [[TTGroupModel alloc] initWithGroupID:group_id itemID:item_id impressionID:nil aggrType:aggrType.integerValue];

    if (userRepined) {
        @weakify(self);
        [self.itemActionManager favoriteForGroupModel:model adID:@(ad_id.longLongValue) isFavorite:!userRepined finishBlock:^(NSDictionary *userInfo, NSError *error) {
            @strongify(self);
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedCollectChanged:uniqueIDStr:), ttv_message_feedCollectChanged:NO uniqueIDStr:unique_id);
            if ([userInfo isKindOfClass:[NSDictionary class]]) {
                [[self articleService] updateUnrepinWithActionItem:[self actionItemWithUserInfo:userInfo adId:ad_id]];
            }
        }];
        
        if (self.favoriteActionDone) {
            self.favoriteActionDone(NO);
        }

    }
    else {
        @weakify(self);
        [self.itemActionManager favoriteForGroupModel:model adID:@(ad_id.longLongValue) isFavorite:!userRepined finishBlock:^(id userInfo, NSError *error) {
            @strongify(self);
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedCollectChanged:uniqueIDStr:), ttv_message_feedCollectChanged:YES uniqueIDStr:unique_id);
            [[self articleService] updateRepinWithActionItem:[self actionItemWithUserInfo:userInfo adId:ad_id]];
        }];
        
        if (self.favoriteActionDone) {
            self.favoriteActionDone(YES);
        }

}

}
- (BOOL)userRepined
{
    BOOL userRepined = self.entity.userRepined;
    if ([self.entity.cellEntity isKindOfClass:[TTVFeedItem class]]) {
        TTVFeedItem *item = (TTVFeedItem *)self.entity.cellEntity;
        userRepined = [item article].userRepin;
    }
    return userRepined;
}

- (void)newFavorite
{
    NSString *group_id = self.entity.groupId;
    NSString *item_id = self.entity.itemId;
    NSString *category_id = self.entity.categoryId;
    NSNumber *aggrType = self.entity.aggrType;
    NSString *ad_id = self.entity.adId;
    BOOL userRepined = [self userRepined];
    NSString *unique_id = group_id ? group_id : ad_id;
    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    NSMutableDictionary * eventContext = [[NSMutableDictionary alloc] init];
    [eventContext setValue:group_id forKey:@"group_id"];
    [eventContext setValue:item_id forKey:@"item_id"];
    NSString * screenName = [NSString stringWithFormat:@"channel_%@", category_id];

    TTVideoArticleService *service = [[TTServiceCenter sharedInstance] getService:[TTVideoArticleService class]];
    TTVideoDiggBuryParameter *parameter = [[TTVideoDiggBuryParameter alloc] init];
    parameter.group_id = group_id;
    parameter.item_id = item_id;
    parameter.aggr_type = aggrType;
    parameter.ad_id = ad_id;
    if (userRepined == YES) {

        [service unfavorite:parameter completion:^(TT2DataItemActionResponseModel *response, NSError *error) {
           SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedCollectChanged:uniqueIDStr:), ttv_message_feedCollectChanged:NO uniqueIDStr:unique_id);
        }];
        NSString * tipMsg = NSLocalizedString(@"取消收藏", nil);
        UIImage * image = [UIImage themedImageNamed:@"doneicon_popup_textpage.png"];
        if (!isEmptyString(tipMsg)) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:image autoDismiss:YES dismissHandler:nil];
        }
        wrapperTrackEvent(@"xiangping", @"video_list_unfavorite");
//        [TTLogManager logEvent:@"click_unfavorite" context:eventContext screenName:screenName];

    }
    else {
        [service favorite:parameter completion:^(TT2DataItemActionResponseModel *response, NSError *error) {
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedCollectChanged:uniqueIDStr:), ttv_message_feedCollectChanged:YES uniqueIDStr:unique_id);
        }];
        NSString * tipMsg = NSLocalizedString(@"收藏成功", nil);
        UIImage * image = [UIImage themedImageNamed:@"doneicon_popup_textpage.png"];
        if (!isEmptyString(tipMsg)) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:image autoDismiss:YES dismissHandler:nil];
        }
        wrapperTrackEvent(@"xiangping", @"video_list_favorite");
//        [TTLogManager logEvent:@"click_favorite" context:eventContext screenName:screenName];
    }
}

- (void)execute:(TTActivityType)type
{
    if (type != TTActivityTypeFavorite) {
        return;
    }
    [self olDFavorite];
//    [self newFavorite];
}


@end






@implementation TTVCommodityActionEntity


@end

@interface TTVCommodityAction ()
@end

@implementation TTVCommodityAction
@dynamic entity;


- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity
{
    self = [super initWithEntity:entity];
    if (self) {
        self.type = TTActivityTypeCommodity;
    }
    return self;
}

- (void)execute:(TTActivityType)type
{
    if (type != TTActivityTypeCommodity) {
        return;
    }
}

@end
