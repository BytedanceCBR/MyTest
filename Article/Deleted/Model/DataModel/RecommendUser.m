//
//  RecommendUser.m
//  Article
//
//  Created by 王双华 on 16/11/30.
//
//

#import "RecommendUser.h"
#import "TTFollowNotifyServer.h"
#import "TTRecommendModel.h"
#import "FriendDataManager.h"
#import "TTBlockManager.h"

@interface RecommendUser ()

@property (nonatomic, retain) NSArray *userListModels;

@end

@implementation RecommendUser
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
                       @"userList",
                       @"cellID",
                       ];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{
                       @"cellID":@"cell_id",
                       @"showMore":@"show_more",
                       @"showMoreJumpURL":@"show_more_jump_url",
                       };
    }
    return properties;
}

- (void)updateWithDictionary:(NSDictionary *)dataDict
{
    if (!self.managedObjectContext) return;
    
    [super updateWithDictionary:dataDict];
    
    self.userList = [dataDict tt_arrayValueForKey:@"user_list"];
}

- (NSArray *)userListModels
{
    if (![self.userList isKindOfClass:[NSArray class]] || [self.userList count] == 0) {
        return nil;
    }
    NSMutableArray *ary = [NSMutableArray arrayWithCapacity:10];
    
    int index = 0;
    for (NSDictionary *dict in self.userList) {
        TTRecommendModel *model = [[TTRecommendModel alloc] initWithUserInfoDict:dict];
        if (model) {
            [ary addObject:model];
            index ++;
        }
    }
    _userListModels = ary;
    
    return _userListModels;
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
        for (TTRecommendModel *model in self.userListModels) {
            if (model && [userID isEqualToString:model.userID]) {
                model.isFollowing = follow;
                if (index < self.userList.count) {
                    [self setIsFollowed:follow index:index];
                }
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
        for (TTRecommendModel *model in self.userListModels) {
            if (model && [userID isEqualToString:model.userID]) {
                if (index < self.userList.count) {
                    [self setIsFollowed:NO index:index];
                }
            }
            index ++;
        }
    }
}

- (void)setIsFollowed:(BOOL)isFollowed index:(NSUInteger)index
{
    if ([self.userList count] > 0) {
        NSMutableArray *mutList = [NSMutableArray arrayWithCapacity:10];
        int indexInArray = 0;
        for (id dict in self.userList) {
            if (![dict isKindOfClass:[NSDictionary class]]) {
                return;
            }
            NSMutableDictionary *mutDict = nil;
            if ([dict isKindOfClass:[NSDictionary class]] && [(NSDictionary *)dict count] > 0) {
                mutDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                if (index == indexInArray) {
                    [mutDict setValue:@(isFollowed) forKey:@"follow"];
                }
                [mutList addObject:mutDict];
            }
            indexInArray ++;
        }
        self.userList = mutList;
        [self save];
    }
}

@end

