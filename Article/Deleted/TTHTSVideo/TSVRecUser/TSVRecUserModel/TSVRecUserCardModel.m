//
//  TSVRecUserCardModel.m
//  Article
//
//  Created by 王双华 on 2017/9/27.
//

#import "TSVRecUserCardModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TSVRecUserCardOriginalData.h"
#import "TTFollowManager.h"
#import "TTBlockManager.h"
#import "TTBaseMacro.h"
#import "TSVRecUserSinglePersonModel.h"

@implementation TSVRecUserCardModel

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err
{
    self = [super initWithDictionary:dict error:err];
    if (self) {
        [[[[NSNotificationCenter defaultCenter]
           rac_addObserverForName:RelationActionSuccessNotification object:nil]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(NSNotification *notification) {
             NSString *userID = notification.userInfo[kRelationActionSuccessNotificationUserIDKey];
             for (TSVRecUserSinglePersonModel *singlePersonModel in self.userList) {
                 NSString *userIDOfThisModel = singlePersonModel.user.userID;
                 if (!isEmptyString(userID) && [userID isEqualToString:userIDOfThisModel]) {
                     FriendActionType actionType = (FriendActionType)[(NSNumber *)notification.userInfo[kRelationActionSuccessNotificationActionTypeKey] integerValue];
                     if (actionType == FriendActionTypeFollow) {
                         singlePersonModel.user.isFollowing = YES;
                         [self save];
                     } else if (actionType == FriendActionTypeUnfollow) {
                         singlePersonModel.user.isFollowing = NO;
                         [self save];
                     }
                 }
             }
         }];
        
        [[[[NSNotificationCenter defaultCenter]
           rac_addObserverForName:kHasBlockedUnblockedUserNotification object:nil]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(NSNotification *notification) {
             NSString *userID = notification.userInfo[kBlockedUnblockedUserIDKey];
             for (TSVRecUserSinglePersonModel *singlePersonModel in self.userList) {
                 NSString *userIDOfThisModel = singlePersonModel.user.userID;
                 if (!isEmptyString(userID) && [userID isEqualToString:userIDOfThisModel]) {
                     BOOL isBlocking = [notification.userInfo[kIsBlockingKey] boolValue];
                     if (isBlocking) {
                         singlePersonModel.user.isFollowing = NO;
                         [self save];
                     }
                 }
             }
         }];
    }
    return self;
}

+ (JSONKeyMapper *)keyMapper
{
    TSVRecUserCardModel *model;
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"log_pb": @keypath(model, logPb),
                                                       @"raw_data.id": @keypath(model, cardID),
                                                       @"raw_data.title": @keypath(model, title),
                                                       @"raw_data.user_cards": @keypath(model, userList),
                                                       }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (void)save
{
    if (self.tsvRecUserCardOriginalData) {
        self.tsvRecUserCardOriginalData.originalDict = [self toDictionary];
        [self.tsvRecUserCardOriginalData save];
    }
}

@end

