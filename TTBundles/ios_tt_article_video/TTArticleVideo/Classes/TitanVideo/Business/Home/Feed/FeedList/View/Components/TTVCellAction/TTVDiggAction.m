//
//  TTVDiggAction.m
//  self.entity
//
//  Created by panxiang on 2017/4/11.
//
//

#import "TTVDiggAction.h"
#import "ExploreItemActionManager.h"
#import "TTIndicatorView.h"
#import "TTVideoArticleService+Action.h"
#import "TTVideoArticleServiceMessage.h"
#import <libextobjc/extobjc.h>
#import "TTMessageCenter.h"
#import "TTVFeedUserOpDataSyncMessage.h"
#import "TTVBuryAction.h"

@implementation TTVDiggActionEntity

@end

@interface TTVDiggAction ()
@end

@implementation TTVDiggAction
@dynamic entity;


- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity
{
    self = [super initWithEntity:entity];
    if (self) {
        self.type = TTActivityTypeDigUp;
    }
    return self;
}

- (void)execute:(TTActivityType)type
{
    if (type != self.type) {
        return;
    }
    if ([self.entity.userDigg boolValue]) {
        //取消赞
        if (self.diggActionDone)
        {
            self.diggActionDone(NO);
        }
        TTVideoArticleService *service = [[TTServiceCenter sharedInstance] getService:[TTVideoArticleService class]];
        
        TTVideoDiggBuryParameter *parameter = [[TTVideoDiggBuryParameter alloc] init];
        parameter.aggr_type = self.entity.aggrType;
        parameter.item_id = self.entity.itemId;
        parameter.group_id = self.entity.groupId;
        parameter.ad_id = self.entity.adId;
        NSString *unique_id = self.entity.groupId ? self.entity.groupId : self.entity.adId;
        @weakify(self);
        [service cancelDigg:parameter completion:^(TT2DataItemActionResponseModel *response, NSError *error) {
            @strongify(self);
            if (error) {
                return;
            }
            self.entity.userDigg = @(NO);
            self.buryAction.entity.userDigg = @(NO);
            int diggCount = [self.entity.diggCount intValue] - 1;
            self.entity.diggCount = @(diggCount);
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggChanged:uniqueIDStr:), ttv_message_feedDiggChanged:[self.entity.userDigg boolValue] uniqueIDStr:unique_id);
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggCountChanged:uniqueIDStr:), ttv_message_feedDiggCountChanged:diggCount uniqueIDStr:unique_id);
        }];

    }
    else if (![self.entity.userBury boolValue]){
        if (self.diggActionDone)
        {
            self.diggActionDone(YES);
        }
        TTVideoArticleService *service = [[TTServiceCenter sharedInstance] getService:[TTVideoArticleService class]];

        TTVideoDiggBuryParameter *parameter = [[TTVideoDiggBuryParameter alloc] init];
        parameter.aggr_type = self.entity.aggrType;
        parameter.item_id = self.entity.itemId;
        parameter.group_id = self.entity.groupId;
        parameter.ad_id = self.entity.adId;
        NSString *unique_id = self.entity.groupId ? self.entity.groupId : self.entity.adId;
        @weakify(self);
        [service digg:parameter completion:^(TT2DataItemActionResponseModel *response, NSError *error) {
            @strongify(self);
            if (error) {
                return;
            }
            self.entity.userDigg = @(YES);
            self.buryAction.entity.userDigg = @(YES);
            int diggCount = [self.entity.diggCount intValue] + 1;
            self.entity.diggCount = @(diggCount);
           SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggChanged:uniqueIDStr:), ttv_message_feedDiggChanged:YES uniqueIDStr:unique_id);
           SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggCountChanged:uniqueIDStr:), ttv_message_feedDiggCountChanged:diggCount uniqueIDStr:unique_id);
        }];
        //        [_itemActionManager sendActionForOriginalData:self.entity adID:nil actionType:DetailActionTypeDig finishBlock:^(id userInfo, NSError *error) {
        //        }];
//        wrapperTrackEvent(@"xiangping", @"video_list_digg");
    }
}

- (void)message_updateDiggBuryCountWithArticle:(TTVVideoArticle *)article
{

}

@end
