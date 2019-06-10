//
//  TTVBuryAction.m
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//

#import "TTVBuryAction.h"
#import "ExploreItemActionManager.h"
#import "TTIndicatorView.h"
#import "TTVideoArticleService+Action.h"
#import "TTVideoArticleServiceMessage.h"
#import <libextobjc/extobjc.h>
#import "TTMessageCenter.h"
#import "TTVFeedUserOpDataSyncMessage.h"

@interface TTVBuryAction ()

@end

@implementation TTVBuryAction
@dynamic entity;


- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity
{
    self = [super initWithEntity:entity];
    if (self) {
        self.type = TTActivityTypeDigDown;
    }
    return self;
}

- (void)execute:(TTActivityType)type
{
    if (type != self.type) {
        return;
    }
    if ([self.entity.userBury boolValue]){
        //取消踩
        if (self.buryActionDone)
        {
            self.buryActionDone(NO);
        }
        TTVideoArticleService *service = [[TTServiceCenter sharedInstance] getService:[TTVideoArticleService class]];
        
        TTVideoDiggBuryParameter *parameter = [[TTVideoDiggBuryParameter alloc] init];
        parameter.aggr_type = self.entity.aggrType;
        parameter.item_id = self.entity.itemId;
        parameter.group_id = self.entity.groupId;
        parameter.ad_id = self.entity.adId;
        NSString *unique_id = self.entity.groupId ? self.entity.groupId : self.entity.adId;
        @weakify(self);
        [service cancelBurry:parameter completion:^(TT2DataItemActionResponseModel *response, NSError *error) {
            @strongify(self);
            if (error) {
                return;
            }
            self.entity.userBury = @(NO);
            self.diggAction.entity.userBury = @(NO);
            int buryCount = [self.entity.buryCount intValue] - 1;
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedBuryChanged:uniqueIDStr:), ttv_message_feedBuryChanged:self.entity.userBury.boolValue uniqueIDStr:unique_id);
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedBuryCountChanged:uniqueIDStr:), ttv_message_feedBuryCountChanged:buryCount uniqueIDStr:unique_id);
        }];    }
    else if (![self.entity.userDigg boolValue]){

        if (self.buryActionDone)
        {
            self.buryActionDone(YES);
        }
        TTVideoArticleService *service = [[TTServiceCenter sharedInstance] getService:[TTVideoArticleService class]];

        TTVideoDiggBuryParameter *parameter = [[TTVideoDiggBuryParameter alloc] init];
        parameter.aggr_type = self.entity.aggrType;
        parameter.item_id = self.entity.itemId;
        parameter.group_id = self.entity.groupId;
        parameter.ad_id = self.entity.adId;
        NSString *unique_id = self.entity.groupId ? self.entity.groupId : self.entity.adId;
        @weakify(self);
        [service burry:parameter completion:^(TT2DataItemActionResponseModel *response, NSError *error) {
            @strongify(self);
            if (error) {
                return;
            }
            self.entity.userBury = @(YES);
            self.diggAction.entity.userBury = @(YES);
            int buryCount = [self.entity.buryCount intValue] + 1;
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedBuryChanged:uniqueIDStr:), ttv_message_feedBuryChanged:YES uniqueIDStr:unique_id);
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedBuryCountChanged:uniqueIDStr:), ttv_message_feedBuryCountChanged:buryCount uniqueIDStr:unique_id);
        }];

    }
}

- (void)message_updateDiggBuryCountWithArticle:(TTVVideoArticle *)article
{
    
}

@end
