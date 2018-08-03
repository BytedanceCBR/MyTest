//
//  MomentsRecommendUserData.m
//  Article
//
//  Created by Jiyee Sheng on 7/13/17.
//
//

#import "MomentsRecommendUserData.h"
#import "TTBlockManager.h"
#import "FRApiModel.h"


@implementation MomentsRecommendUserData
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
            @"friend",
            @"follows",
        ];
    }

    return properties;
}

+ (NSDictionary *)keyMapping {
    return @{};
}

- (void)updateWithDictionary:(NSDictionary *)dataDict {
    if (!self.managedObjectContext) return;

    [super updateWithDictionary:dataDict];

    NSDictionary *rawData = [dataDict tt_dictionaryValueForKey:@"raw_data"];
    if (rawData != nil) {
        self.title = [rawData tt_stringValueForKey:@"title"];
        self.friend = [rawData tt_dictionaryValueForKey:@"friend"];
        self.follows = [rawData tt_arrayValueForKey:@"follows"];
    }

    NSError *error;
    FRCommonUserStructModel *model = [[FRCommonUserStructModel alloc] initWithDictionary:self.friend error:&error];
    if (!error && model) {
        self.friendUserModel = model;
    }

    NSMutableArray *models = [NSMutableArray arrayWithCapacity:self.follows.count];
    for (NSDictionary *dict in self.follows) {
        NSDictionary *followedUser = [dict tt_dictionaryValueForKey:@"followed_user"];
        NSError *error;
        FRMomentsRecommendUserStructModel *model = [[FRMomentsRecommendUserStructModel alloc] initWithDictionary:followedUser error:&error];
        if (!error && model) {
            [models addObject:model];
        }
    }

    self.userCardModels = models;
}

- (FRCommonUserStructModel *)friendUserModel {
    if ([_friendUserModel isKindOfClass:[FRCommonUserStructModel class]]) {
        return _friendUserModel;
    }

    if (!self.friend) {
        return nil;
    }

    NSError *error;
    FRCommonUserStructModel *model = [[FRCommonUserStructModel alloc] initWithDictionary:self.friend error:&error];
    if (!error && model) {
        _friendUserModel = model;
        return _friendUserModel;
    }

    return nil;
}

- (NSArray<FRMomentsRecommendUserStructModel *> *)userCardModels {
    if ([_userCardModels isKindOfClass:[NSArray class]] && [_userCardModels count] > 0) {
        return _userCardModels;
    }

    if (![self.follows isKindOfClass:[NSArray class]] || [self.follows count] == 0) {
        return nil;
    }

    NSMutableArray *models = [NSMutableArray arrayWithCapacity:self.follows.count];
    for (NSDictionary *dict in self.follows) {
        NSDictionary *followedUser = [dict tt_dictionaryValueForKey:@"followed_user"];
        NSError *error;
        FRMomentsRecommendUserStructModel *model = [[FRMomentsRecommendUserStructModel alloc] initWithDictionary:followedUser error:&error];
        if (!error && model) {
            [models addObject:model];
        }
    }

    _userCardModels = models;

    return _userCardModels;
}

- (void)setUserCardModels:(NSArray<FRMomentsRecommendUserStructModel *> *)userCardModels {
    if (_userCardModels == userCardModels) {
        return;
    }

    _userCardModels = userCardModels;

    NSMutableArray *models = [NSMutableArray arrayWithCapacity:userCardModels.count];
    for (FRMomentsRecommendUserStructModel *model in userCardModels) {
        if (model.toDictionary) {
            [models addObject:@{@"followed_user": [model toDictionary]}];
        }
    }
    self.follows = models;
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

#pragma mark - Notification

- (void)addObserveNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockNotification:) name:kHasBlockedUnblockedUserNotification object:nil];
}

- (void)removeObserveNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)blockNotification:(NSNotification *)notify {
    NSString *userID = notify.userInfo[kBlockedUnblockedUserIDKey];
    BOOL isBlocking = [notify.userInfo[kIsBlockingKey] boolValue];
    if (!isEmptyString(userID) && isBlocking) {
        NSUInteger index = 0;
        for (FRMomentsRecommendUserStructModel *model in self.userCardModels) {
            if (model && [userID isEqualToString:model.user.info.user_id]) {
                [self setFollowing:NO atIndex:index];
            }
            index++;
        }
    }
}

- (void)setFollowing:(BOOL)following atIndex:(NSUInteger)index {
    if ([self.follows count] > index) {
        FRMomentsRecommendUserStructModel *userModel = self.userCardModels[index];
        userModel.user.relation.is_following = @(following);

        NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.userCardModels.count];
        for (FRMomentsRecommendUserStructModel *model in self.userCardModels) {
            NSDictionary *dictionary = [model toDictionary];
            if (dictionary) {
                [array addObject:@{@"followed_user": dictionary}];
            }
        }
        self.follows = array;
        [self save];
    }
}

@end
