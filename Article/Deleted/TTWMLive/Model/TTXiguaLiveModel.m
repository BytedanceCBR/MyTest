//
//  TTXiguaLiveModel.m
//  Article
//
//  Created by lipeilun on 2017/11/30.
//

#import "TTXiguaLiveModel.h"

@implementation TTXiguaLiveStreamUrlModel
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.streamId = [dict tt_stringValueForKey:@"stream_id"];
        self.createTime = @([dict tt_longlongValueForKey:@"create_time"]);
        self.flvPullUrl = [dict tt_stringValueForKey:@"flv_pull_url"];
        self.alternatePullUrl = [dict tt_stringValueForKey:@"alternate_pull_url"];
    }
    return self;
}
@end

@implementation TTXiguaLiveLiveInfo
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.roomId = [dict tt_stringValueForKey:@"room_id"];
        self.watchingCount = [dict tt_integerValueForKey:@"watching_count"];
        self.createTime = @([dict tt_longlongValueForKey:@"create_time"]);
        self.streamUrl = [[TTXiguaLiveStreamUrlModel alloc] initWithDictionary:[dict tt_dictionaryValueForKey:@"stream_url"]];
    }
    return self;
}
@end

@implementation TTXiguaLiveUserInfo
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.authorInfo = [dict tt_stringValueForKey:@"author_info"];
        self.mediaId = [dict tt_stringValueForKey:@"media_id"];
        self.name = [dict tt_stringValueForKey:@"name"];
        self.followingCount = [dict tt_integerValueForKey:@"following_count"];
        self.followerCount = [dict tt_integerValueForKey:@"follower_count"];
        self.isFollowing = [dict tt_boolValueForKey:@"follow"];
        self.userVerified = [dict tt_boolValueForKey:@"user_verified"];
        self.descriptionStr = [dict tt_stringValueForKey:@"description"];
        self.verifiedContent = [dict tt_stringValueForKey:@"verified_content"];
        self.ugcPublishMediaId = [dict tt_stringValueForKey:@"ugc_publish_media_id"];
        self.avatarUrl = [dict tt_stringValueForKey:@"avatar_url"];
        self.extendInfo = [dict tt_stringValueForKey:@"extend_info"];
        self.userId = [dict tt_stringValueForKey:@"user_id"];
        self.userAuthInfo = [dict tt_stringValueForKey:@"tt_auth_info"];
    }
    return self;
}
@end

@interface TTXiguaLiveModel()

@end

@implementation TTXiguaLiveModel

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.largeImage = [dict tt_dictionaryValueForKey:@"large_image"];
        self.title = [dict tt_stringValueForKey:@"title"];
        self.liveInfo = [dict tt_dictionaryValueForKey:@"live_info"];
        self.userInfo = [dict tt_dictionaryValueForKey:@"user_info"];
        self.groupSource = [dict tt_stringValueForKey:@"group_source"];
        self.groupId = [dict tt_stringValueForKey:@"group_id"];
    }
    return self;
}

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"uniqueID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = [[super persistentProperties] arrayByAddingObjectsFromArray:@[
                                                                                   @"title",
                                                                                   @"liveInfo",
                                                                                   @"userInfo",
                                                                                   @"largeImage",
                                                                                   @"groupSource",
                                                                                   @"groupId"
                                                                                   ]];
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
        self.largeImage = [rawData tt_dictionaryValueForKey:@"large_image"];
        self.title = [rawData tt_stringValueForKey:@"title"];
        self.liveInfo = [rawData tt_dictionaryValueForKey:@"live_info"];
        self.userInfo = [rawData tt_dictionaryValueForKey:@"user_info"];
        self.groupSource = [rawData tt_stringValueForKey:@"group_source"];
        self.groupId = [rawData tt_stringValueForKey:@"group_id"];
    }
}

#pragma mark - public

- (FRImageInfoModel *)largeImageModel {
    if ([self.largeImage count] == 0 || ![self.largeImage isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return [[FRImageInfoModel alloc] initWithDictionary:self.largeImage];
}


- (TTXiguaLiveLiveInfo *)liveLiveInfoModel {
    if ([self.liveInfo count] == 0 || ![self.liveInfo isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return [[TTXiguaLiveLiveInfo alloc] initWithDictionary:self.liveInfo];
}

- (TTXiguaLiveUserInfo *)liveUserInfoModel {
    if ([self.userInfo count] == 0 || ![self.userInfo isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return [[TTXiguaLiveUserInfo alloc] initWithDictionary:self.userInfo];
}

@end




















