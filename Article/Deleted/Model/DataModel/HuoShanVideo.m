//
//  HuoShanVideo.m
//  Article
//
//  Created by 王双华 on 2017/4/14.
//
//

#import "HuoShanVideo.h"
#import "TTImageInfosModel.h"
#import "FriendDataManager.h"
#import "TTBlockManager.h"

@implementation HuoShanVideo

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = [[super persistentProperties] arrayByAddingObjectsFromArray:@[
                       @"originalDict",
                       @"text",
                       @"location",
                       @"openURL",
                       @"openHotsoonURL",
                       @"userInfo",
                       @"videoDetailInfo",
                       @"filterWords",
                       @"rid",
                       ]];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[super keyMapping]];
        [dict addEntriesFromDictionary:@{
                                         @"originalDict":@"original_dict",
                                         @"openURL":@"open_url",
                                         @"openHotsoonURL":@"open_hotsoon_url",
                                         @"userInfo":@"user_info",
                                         @"videoDetailInfo":@"video_detail_info",
                                         @"filterWords":@"filter_words"
                                         }];
        properties = [dict copy];
    }
    return properties;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addObserveNotification];
    }
    return self;
}

- (void)dealloc {
    [self removeObserveNotification];
}

#pragma make - Notification
- (void)addObserveNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followNotification:) name:RelationActionSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockNotification:) name:kHasBlockedUnblockedUserNotification object:nil];
}

- (void)removeObserveNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)followNotification:(NSNotification *)notify
{
    NSString * userID = notify.userInfo[kRelationActionSuccessNotificationUserIDKey];
    NSString * userIDOfSelf = [self.userInfo tt_stringValueForKey:@"user_id"];
    if (!isEmptyString(userID) && [userID isEqualToString:userIDOfSelf]) {
        NSInteger actionType = [(NSNumber *)notify.userInfo[kRelationActionSuccessNotificationActionTypeKey] integerValue];
        if (actionType == FriendActionTypeFollow) {
            [self updateFollowed:YES];
        }else if (actionType == FriendActionTypeUnfollow) {
            [self updateFollowed:NO];
        }
        [self save];
    }
}

- (void)blockNotification:(NSNotification *)notify
{
    NSString * userID = notify.userInfo[kBlockedUnblockedUserIDKey];
    NSString * userIDOfSelf = [self.userInfo tt_stringValueForKey:@"user_id"];
    if (!isEmptyString(userID) && [userID isEqualToString:userIDOfSelf]) {
        BOOL isBlocking = [notify.userInfo[kIsBlockingKey] boolValue];
        if (isBlocking) {
            [self updateFollowed:NO];
        }
        [self save];
    }
}

- (void)updateFollowed:(BOOL)followed
{
    [self updateOriginalDictWithFollowed:followed];
    if([[self userInfo] objectForKey:@"follow"]){
        NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
        [mutDict setValue:@(followed) forKey:@"follow"];
        self.userInfo = [mutDict copy];
    }
    [self save];
}

- (void)updateOriginalDictWithFollowed:(BOOL)followed
{
    if ([[self originalDict] objectForKey:@"user_info"]) {
        NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithDictionary:self.originalDict];
        NSMutableDictionary *userInfo = [[mutDict tt_dictionaryValueForKey:@"user_info"] mutableCopy];
        [userInfo setValue:@(followed) forKey:@"follow"];
        [mutDict setValue:userInfo forKey:@"user_info"];
        self.originalDict = [mutDict copy];
    }
    [self save];
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    [super updateWithDictionary:dictionary];
    
    if ([dictionary objectForKey:@"original_dict"]) {
        self.originalDict = [dictionary tt_dictionaryValueForKey:@"original_dict"];
    }
    
    if ([dictionary objectForKey:@"user_info"]) {
        self.userInfo = [dictionary tt_dictionaryValueForKey:@"user_info"];
    }
    
    if ([dictionary objectForKey:@"video_detail_info"]) {
        self.videoDetailInfo = [dictionary tt_dictionaryValueForKey:@"video_detail_info"];
    }
    
    // 不喜欢的理由
    if ([dictionary objectForKey:@"filter_words"]) {
        self.filterWords = [dictionary tt_arrayValueForKey:@"filter_words"];
    }
}

- (nullable TTImageInfosModel *)coverImageModel
{
    NSDictionary *info = [self.videoDetailInfo tt_dictionaryValueForKey:@"detail_video_large_image"];
    if (!info || [info count] == 0) {
        return nil;
    }
    TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:info];
    model.imageType = TTImageTypeLarge;
    return model;
}

@end
