//
//  RecommendRedpacketData.m
//  Article
//
//  Created by lipeilun on 2017/10/23.
//

#import "RecommendRedpacketData.h"

@implementation RecommendRedpacketData
@synthesize userDataList = _userDataList;

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
            @"centerText",
            @"buttonText",
            @"userCards",
            @"isAuth",
            @"numberOfAvatars",
            @"numberOfUsersSelected",
            @"hasRedPacket",
            @"relationType",
            @"friendsListInfo",
            @"redpacketInfo",
            @"state",
            @"showMoreTitle",
            @"showMoreText",
            @"showMoreJumpURL",
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
        self.centerText = [rawData tt_stringValueForKey:@"center_text"];
        self.buttonText = [rawData tt_stringValueForKey:@"button_text"];
        self.userCards = [rawData tt_arrayValueForKey:@"user_cards"];
        self.isAuth = [rawData tt_boolValueForKey:@"is_auth"];
        self.numberOfAvatars = [rawData tt_integerValueForKey:@"avatar_count"];
        self.numberOfUsersSelected = [rawData tt_integerValueForKey:@"selected_cnt"];
        self.hasRedPacket = [rawData tt_boolValueForKey:@"has_redpack"];
        self.relationType = [rawData tt_integerValueForKey:@"rel_type"];
        self.friendsListInfo = [rawData tt_dictionaryValueForKey:@"friends_list_info"];
        self.redpacketInfo = [rawData tt_dictionaryValueForKey:@"redpack_info"];

        // 重置自定义属性
        self.state = (RecommendRedpacketCardState) [rawData tt_integerValueForKey:@"state"];
        self.showMoreTitle = [rawData tt_stringValueForKey:@"showMoreTitle"];
        self.showMoreText = [rawData tt_stringValueForKey:@"showMoreText"];
        self.showMoreJumpURL = [rawData tt_stringValueForKey:@"showMoreJumpURL"];
        _userDataList = nil;
    }
}

- (NSString *)relationTypeValue {
    if (self.relationType == 1) {
        return @"real_friends";
    } else if (self.relationType == 2) {
        return @"stars";
    }

    return nil;
}

- (NSArray<FRRecommendUserLargeCardStructModel *> *)userDataList {
    if ([_userDataList isKindOfClass:[NSArray class]] && [_userDataList count] > 0) {
        return _userDataList;
    }
    
    if (![self.userCards isKindOfClass:[NSArray class]] || [self.userCards count] == 0) {
        return nil;
    }

    NSInteger index = 0;
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary *dict in self.userCards) {
        NSError *error;
        FRRecommendUserLargeCardStructModel *model = [[FRRecommendUserLargeCardStructModel alloc] initWithDictionary:dict error:&error];
        if (!error && model) {
            if (index < self.numberOfUsersSelected) {
                model.selected = @(YES); //初始化的时候，设置成选中
                index ++;
            }
            [models addObject:model];
        }
    }
    self.userDataList = models;
    
    return _userDataList;
}

- (void)setUserDataList:(NSArray<FRRecommendUserLargeCardStructModel *> *)userDataList {
    if (_userDataList == userDataList) {
        return;
    }
    
    _userDataList = userDataList;
    
    NSMutableArray *models = [NSMutableArray array];
    for (FRRecommendUserLargeCardStructModel *model in userDataList) {
        [models addObject:[model toDictionary]];
    }
    self.userCards = models;
    [self save];
}

- (void)setCardState:(RecommendRedpacketCardState)state {
    self.state = state;

    [self save];
}

- (void)setShowMoreTitle:(NSString *)showMoreTitle showMoreText:(NSString *)showMoreText showMoreJumpURL:(NSString *)showMoreJumpURL {
    self.showMoreTitle = showMoreTitle;
    self.showMoreText = showMoreText;
    self.showMoreJumpURL = showMoreJumpURL;

    [self save];
}

@end

















