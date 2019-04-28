//
//  RecommendUserCardsData.m
//  Article
//
//  Created by 王双华 on 16/11/30.
//
//

#import "RecommendUserCardsData.h"
#import "TTFollowNotifyServer.h"
#import "TTRecommendModel.h"
#import "FriendDataManager.h"
#import "TTBlockManager.h"
#import "FRApiModel.h"

@interface RecommendUserCardsData ()

@end

@implementation RecommendUserCardsData
@synthesize userCardModels = _userCardModels;

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"uniqueID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"uniqueID",
                       @"title",
                       @"showMore",
                       @"showMoreJumpURL",
                       @"userCards",
                       @"hasMore",
                       ];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    return @{};
}

- (void)updateWithDictionary:(NSDictionary *)dataDict
{
    if (!self.managedObjectContext) return;
    
    [super updateWithDictionary:dataDict];
    
    NSDictionary* rawData = [dataDict tt_dictionaryValueForKey:@"raw_data"];
    if (rawData != nil) {
        
        self.title = [rawData tt_stringValueForKey:@"title"];
        self.showMore = [rawData tt_stringValueForKey:@"show_more"];
        self.showMoreJumpURL = [rawData tt_stringValueForKey:@"show_more_jump_url"];
        self.hasMore = [rawData tt_boolValueForKey:@"has_more"];
        
        self.userCards = [rawData tt_arrayValueForKey:@"user_cards"];
    }
    
    NSMutableArray *ary = [NSMutableArray arrayWithCapacity:10];
    int index = 0;
    for (NSDictionary *dict in self.userCards) {
        NSError* error;
        FRRecommendCardStructModel *model = [[FRRecommendCardStructModel alloc] initWithDictionary:dict error:&error];
        if (!error && model) {
            [ary addObject:model];
            index ++;
        }
    }
    self.userCardModels = ary;
}

- (NSArray *)userCardModels
{
    if ([_userCardModels isKindOfClass:[NSArray class]] && [_userCardModels count] > 0) {
        return _userCardModels;
    }
    if (![self.userCards isKindOfClass:[NSArray class]] || [self.userCards count] == 0) {
        return nil;
    }
    NSMutableArray *ary = [NSMutableArray arrayWithCapacity:10];
    int index = 0;
    for (NSDictionary *dict in self.userCards) {
        NSError* error;
        FRRecommendCardStructModel *model = [[FRRecommendCardStructModel alloc] initWithDictionary:dict error:&error];
        if (!error && model) {
            [ary addObject:model];
            index ++;
        }
    }
    _userCardModels = ary;
    
    return _userCardModels;
}

- (void)setUserCardModels:(NSArray<FRRecommendCardStructModel *> *)userCardModels {
    if (_userCardModels == userCardModels) {
        return;
    }
    _userCardModels = userCardModels;
    
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:userCardModels.count];
    for (FRRecommendCardStructModel* model in userCardModels) {
        [array addObject:[model toDictionary]];
    }
    self.userCards = array;
    [self save];
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
    if (!isEmptyString(userID)) {
        NSInteger actionType = [(NSNumber *)notify.userInfo[kRelationActionSuccessNotificationActionTypeKey] integerValue];
        BOOL follow = actionType == FriendActionTypeFollow;
        int index = 0;
        for (FRRecommendCardStructModel *model in self.userCardModels) {
            if (model && [userID isEqualToString:model.user.info.user_id]) {
                [self setIsFollowed:follow index:index];
            }
            index ++;
        }
    }
}

- (void)blockNotification:(NSNotification *)notify
{
    NSString * userID = notify.userInfo[kBlockedUnblockedUserIDKey];
    BOOL isBlocking = [notify.userInfo[kIsBlockingKey] boolValue];
    if (!isEmptyString(userID) && isBlocking) {
        int index = 0;
        for (FRRecommendCardStructModel *model in self.userCardModels) {
            if (model && [userID isEqualToString:model.user.info.user_id]) {
                [self setIsFollowed:NO index:index];
            }
            index ++;
        }
    }
}

- (void)setIsFollowed:(BOOL)isFollowed index:(NSUInteger)index
{
    if ([self.userCards count] > index) {
        FRRecommendCardStructModel *model = self.userCardModels[index];
        model.user.relation.is_following = @(isFollowed);
        if (isFollowed && model.activity.redpack) {
            //该推人卡片的人已经被关注，清空关联的红包
            model.activity.redpack = nil;
        }
        
        NSMutableArray* array = [NSMutableArray arrayWithCapacity:self.userCardModels.count];
        for (FRRecommendCardStructModel* model in self.userCardModels) {
            [array addObject:[model toDictionary]];
        }
        self.userCards = array;
        [self save];
    }
}

@end

