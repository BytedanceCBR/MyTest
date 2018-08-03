//
//  RecommendUserLargeCardData.m
//  Article
//
//  Created by Jiyee Sheng on 7/13/17.
//
//

#import "RecommendUserLargeCardData.h"
#import "TTBlockManager.h"

@implementation RecommendUserLargeCardData
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
            @"showMoreText",
            @"showMoreTitle",
            @"showMoreJumpURL",
            @"userCards",
            @"state",
            @"groupRecommendType"
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
        self.showMore = [rawData tt_stringValueForKey:@"show_more"];
        self.showMoreText = [rawData tt_stringValueForKey:@"show_more_text"];
        self.showMoreTitle = [rawData tt_stringValueForKey:@"show_more_title"];
        self.showMoreJumpURL = [rawData tt_stringValueForKey:@"show_more_jump_url"];
        self.groupRecommendType = [rawData tt_longValueForKey:@"group_rec_type"];
        self.userCards = [rawData tt_arrayValueForKey:@"user_cards"];
        self.state = (RecommendUserLargeCardState) [rawData tt_integerValueForKey:@"state"];
    }

    NSMutableArray *models = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary *dict in self.userCards) {
        NSError *error;
        FRRecommendUserLargeCardStructModel *model = [[FRRecommendUserLargeCardStructModel alloc] initWithDictionary:dict error:&error];
        if (!error && model) {
            [models addObject:model];
        }
    }

    self.userCardModels = models;
}

- (NSArray<FRRecommendUserLargeCardStructModel *> *)userCardModels {
    if ([_userCardModels isKindOfClass:[NSArray class]] && [_userCardModels count] > 0) {
        return _userCardModels;
    }

    if (![self.userCards isKindOfClass:[NSArray class]] || [self.userCards count] == 0) {
        return nil;
    }

    NSMutableArray *models = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary *dict in self.userCards) {
        NSError *error;
        FRRecommendUserLargeCardStructModel *model = [[FRRecommendUserLargeCardStructModel alloc] initWithDictionary:dict error:&error];
        if (!error && model) {
            [models addObject:model];
        }
    }
    _userCardModels = models;

    return _userCardModels;
}

- (void)setUserCardModels:(NSArray<FRRecommendUserLargeCardStructModel *> *)userCardModels {
    if (_userCardModels == userCardModels) {
        return;
    }

    _userCardModels = userCardModels;

    NSMutableArray *models = [NSMutableArray arrayWithCapacity:userCardModels.count];
    for (FRRecommendUserLargeCardStructModel *model in userCardModels) {
        [models addObject:[model toDictionary]];
    }
    self.userCards = models;
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
        for (FRRecommendUserLargeCardStructModel *model in self.userCardModels) {
            if (model && [userID isEqualToString:model.user.info.user_id]) {
                [self setFollowed:NO atIndex:index];
            }
            index++;
        }
    }
}

- (void)setSelected:(BOOL)selected atIndex:(NSUInteger)index {
    if ([self.userCards count] > index) {
        FRRecommendUserLargeCardStructModel *model = self.userCardModels[index];
        model.selected = @(selected);

        NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.userCardModels.count];
        for (FRRecommendUserLargeCardStructModel *model in self.userCardModels) {
            [array addObject:[model toDictionary]];
        }
        self.userCards = array;
        [self save];
    }
}

- (void)setFollowed:(BOOL)followed atIndex:(NSUInteger)index {
    if ([self.userCards count] > index) {
        FRRecommendUserLargeCardStructModel *model = self.userCardModels[index];
        model.user.relation.is_following = @(followed);

        NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.userCardModels.count];
        for (FRRecommendUserLargeCardStructModel *model in self.userCardModels) {
            [array addObject:[model toDictionary]];
        }
        self.userCards = array;
        [self save];
    }
}

- (void)setCardState:(RecommendUserLargeCardState)state {
    self.state = state;

    [self save];
}

- (void)setFollowedTitle:(NSString *)title {
    self.showMoreTitle = title;

    [self save];
}

@end
