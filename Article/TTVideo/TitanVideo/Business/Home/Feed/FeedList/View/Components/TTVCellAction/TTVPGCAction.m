//
//  TTVPGCAction.m
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//

#import "TTVPGCAction.h"
#import "ExploreEntryManager.h"
#import "TTIndicatorView.h"
#import "TTFollowNotifyServer.h"
#import "TTVideoUserInfoService.h"
#import "TTVideoApiModel.h"
#import "ExploreEntry.h"

@implementation TTVPGCActionEntity


@end

@interface TTVPGCAction ()
@end

@implementation TTVPGCAction
@dynamic entity;


- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity
{
    self = [super initWithEntity:entity];
    if (self) {
        self.type = TTActivityTypePGC;
    }
    return self;
}

- (NSDictionary *)extraValueDic {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (self.entity.groupId > 0) {
        [dic setValue:self.entity.groupId forKey:@"group_id"];
    }
    if (!isEmptyString(self.entity.categoryId)) {
        [dic setValue:self.entity.categoryId forKey:@"category_id"];
    }
    if (self.entity.refer) {
        [dic setObject:[NSNumber numberWithUnsignedInteger:self.entity.refer] forKey:@"location"];
    }
    [dic setObject:@1 forKey:@"gtype"];
    return dic;
}

- (TTVideoUserInfoService *)userInfoService
{
    TTVideoUserInfoService *service = [[TTServiceCenter sharedInstance] getService:[TTVideoUserInfoService class]];
    return service;
}

//订阅
- (void)subscribArticle:(NSString *)entryID
{
    ExploreEntry *entry ;
    NSArray *entries = [[ExploreEntryManager sharedManager] entryForEntryIDs:@[entryID]];

    if(entries.count > 0)
    {
        entry = entries[0];
    }
    else {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:entryID forKey:@"id"];
        [dic setValue:@1 forKey:@"type"];
        [dic setValue:@0 forKey:@"subscribed"];
        [dic setValue:[NSNumber numberWithInteger:entryID.integerValue] forKey:@"media_id"];
        [dic setValue:entryID forKey:@"entry_id"];

        entry = [[ExploreEntryManager sharedManager] insertExploreEntry:dic save:YES];
    }


    @weakify(self);
    [[ExploreEntryManager sharedManager] exploreEntry:entry
                                   changeToSubscribed:YES
                                               notify:YES
                                    notifyFinishBlock:^(ExploreEntry * _Nullable entry, NSError * _Nullable error) {
                                        @strongify(self);
                                        //失败提示
                                        if (error) {
                                            NSString *msgFail = [NSString stringWithFormat:@"%@失败",@"关注"];
                                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                                                      indicatorText:msgFail
                                                                     indicatorImage:nil
                                                                        autoDismiss:YES
                                                                     dismissHandler:nil];
                                            return ;
                                        }
                                        if (!isEmptyString(entryID)) {
                                            [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:entryID
                                                                                             actionType:TTFollowActionTypeFollow
                                                                                               itemType:TTFollowItemTypeDefault
                                                                                               userInfo:nil];

                                            TTVUserInfo *info = [[TTVUserInfo alloc] init];
                                            info.userId = entry.userID.longLongValue;
                                            info.name = entry.name;
                                            info.follow = entry.subscribed;
                                            info.followersCount = entry.subscribedCount.longLongValue;
                                            info.userAuthInfo = entry.authInfo;
                                            [[self userInfoService] updateUserInfo:info];
                                        }

                                        //订阅成功
                                        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"将增加推荐此头条号内容", nil) indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                                    }];

}


//取消订阅
- (void)cancelSubscribArticle:(NSString *)entryID
{

    ExploreEntry *entry ;
    NSArray *entries = [[ExploreEntryManager sharedManager] entryForEntryIDs:@[entryID]];

    if(entries.count > 0)
    {
        entry = entries[0];
    }
    else {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:entryID forKey:@"id"];
        [dic setValue:@1 forKey:@"type"];
        [dic setValue:@1 forKey:@"subscribed"];
        [dic setValue:[NSNumber numberWithInteger:entryID.integerValue] forKey:@"media_id"];
        [dic setValue:entryID forKey:@"entry_id"];

        entry = [[ExploreEntryManager sharedManager] insertExploreEntry:dic save:YES];
    }


    @weakify(self);
    [[ExploreEntryManager sharedManager] exploreEntry:entry
                                   changeToSubscribed:NO
                                               notify:YES
                                    notifyFinishBlock:^(ExploreEntry * _Nullable entry, NSError * _Nullable error) {
                                        @strongify(self);

                                        //失败提示
                                        if (error) {
                                            NSString *msgFail = [NSString stringWithFormat:@"取消%@失败",@"关注"];

                                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                                                      indicatorText:msgFail
                                                                     indicatorImage:nil
                                                                        autoDismiss:YES
                                                                     dismissHandler:nil];

                                            return ;
                                        }

                                        NSString *msgSuccess = [NSString stringWithFormat:@"已取消%@",@"关注"];
                                        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                                                  indicatorText:msgSuccess
                                                                 indicatorImage:nil
                                                                    autoDismiss:YES
                                                                 dismissHandler:nil];
                                        if (!isEmptyString(entryID)) {
                                            [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:entryID
                                                                                             actionType:TTFollowActionTypeUnfollow
                                                                                               itemType:TTFollowItemTypeDefault
                                                                                               userInfo:nil];
                                            TTVUserInfo *info = [[TTVUserInfo alloc] init];
                                            info.userId = entry.userID.longLongValue;
                                            info.name = entry.name;
                                            info.follow = entry.subscribed;
                                            info.followersCount = entry.subscribedCount.longLongValue;
                                            info.userAuthInfo = entry.authInfo;
                                            [[self userInfoService] updateUserInfo:info];

                                        }
                                    }];
}


- (void)execute:(TTActivityType)type
{
    if (type != self.type) {
        return;
    }
    //关注通知
    if (isEmptyString(self.entity.userId)) {
        return;
    }

    if (self.entity.isSubscribe) {
        [self cancelSubscribArticle:self.entity.userId];
        wrapperTrackEventWithCustomKeys(@"list_share", @"unconcern",self.entity.groupId, nil, [self extraValueDic]);
    }
    else {
//        if ([TTFirstConcernManager firstTimeGuideEnabled]) {
//            TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//            [manager showFirstConcernAlertViewWithDismissBlock:nil];
//        }
        wrapperTrackEventWithCustomKeys(@"list_share", @"concern", self.entity.groupId, nil, [self extraValueDic]);
        [self subscribArticle:self.entity.userId];
    }
    //统计
    wrapperTrackEvent(@"xiangping", @"video_list_pgc_button");
    NSMutableDictionary * eventContext = [[NSMutableDictionary alloc] init];
    [eventContext setValue:self.entity.groupId forKey:@"group_id"];
    [eventContext setValue:self.entity.itemId forKey:@"item_id"];
    [eventContext setValue:self.entity.userId forKey:@"media_id"];
    NSString * screenName = [NSString stringWithFormat:@"channel_%@", self.entity.categoryId];
//    [TTLogManager logEvent:@"click_feed_pgc" context:eventContext screenName:screenName];

}

@end
