//
//  WDPersonModel.m
//  Forum
//
//  Created by Zhang Leonardo on 15-3-27.
//
//

#import "WDPersonModel.h"
#import "WDDefines.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>

@implementation WDPersonModel

+ (NSMapTable *)userMap
{
    static dispatch_once_t token;
    static NSMapTable * userMapTable;
    dispatch_once(&token, ^{
        userMapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    });
    return userMapTable;
}

+ (WDPersonModel *)genWDPersonModelFromDictionary:(NSDictionary *)userDict
{
    if (!userDict || ![userDict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSString *key = nil;
    if([userDict objectForKey:@"user_id"]) {
        key = [userDict tt_stringValueForKey:@"user_id"];
    } else if ([userDict objectForKey:@"id"]) {
        key = [userDict tt_stringValueForKey:@"id"];
    }
    
    if (isEmptyString(key)) {
        return nil;
    }
    
    WDPersonModel *person = [[self userMap] objectForKey:key];
    if (person) {
        [person updateWithDictionary:userDict];
        return person;
    }
    
    person = [[WDPersonModel alloc] initWithDictionary:userDict];
    [[self userMap] setObject:person forKey:key];
    return person;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if(self) {
        [self updateWithDictionary:dict];
    }
    
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dict
{
    if([dict objectForKey:@"user_id"]) {
        self.userID = [dict tt_stringValueForKey:@"user_id"];
    } else if ([dict objectForKey:@"id"]) {
        self.userID = [dict tt_stringValueForKey:@"id"];
    }
    
    if(!isEmptyString([dict tt_stringValueForKey:@"name"])) {
        self.name = [dict objectForKey:@"name"];
    } else if (!isEmptyString([dict tt_stringValueForKey:@"user_name"])) {
        self.name = [dict objectForKey:@"user_name"];
    }

    if(!isEmptyString([dict tt_stringValueForKey:@"screen_name"])) {
        self.screenName = [dict objectForKey:@"screen_name"];
    }
    
    if(!isEmptyString([dict tt_stringValueForKey:@"avatar_url"])) {
        self.avatarURLString = [dict objectForKey:@"avatar_url"];
    } else if (!isEmptyString([dict tt_stringValueForKey:@"user_profile_image_url"])) {
        self.avatarURLString = dict[@"user_profile_image_url"];
    }

    if (!isEmptyString([dict tt_stringValueForKey:@"user_intro"])) {
        self.userIntro = dict[@"user_intro"];
    }
    
    if([dict objectForKey:@"user_auth_info"]) {
        self.userAuthInfo = [dict tt_stringValueForKey:@"user_auth_info"];
        NSData *data = [self.userAuthInfo dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([dictionary tt_stringValueForKey:@"auth_info"]) {
            self.userIntro = [dictionary tt_stringValueForKey:@"auth_info"];
        }
    }

    if (!isEmptyString([dict tt_stringValueForKey:@"user_decoration"])) {
        self.userDecoration = dict[@"user_decoration"];
    }
    
    if ([dict.allKeys containsObject:@"is_following"]) {
        self.isFollowing = [[dict objectForKey:@"is_following"] intValue];
    }
    if ([dict.allKeys containsObject:@"is_followed"]) {
        self.isFollowed = [[dict objectForKey:@"is_followed"] intValue];
    }
}

+ (WDPersonModel *)genWDPersonModelFromWDUserModel:(WDUserStructModel *)model
{
    if (!model || ![model isKindOfClass:[WDUserStructModel class]]) {
        return nil;
    }
    
    if (isEmptyString(model.user_id)) {
        return nil;
    }
    
    NSString * key = [NSString stringWithFormat:@"%@", model.user_id];
    WDPersonModel *person = [[self userMap] objectForKey:key];
    if (person) {
        [person updatePersonWithWDUserModel:model];
        return person;
    }
    
    person = [[WDPersonModel alloc] initWithStructModel:model];
    [[self userMap] setObject:person forKey:key];
    return person;
}

- (instancetype)initWithStructModel:(WDUserStructModel *)model
{
    if (self = [super init]) {
        if (!isEmptyString(model.user_id)) {
            self.userID = model.user_id;
        }
        [self updatePersonWithWDUserModel:model];
    }
    return self;
}

- (void)updatePersonWithWDUserModel:(WDUserStructModel *)model
{
    if (!model || ![model isKindOfClass:[WDUserStructModel class]] || ![self.userID isEqualToString:model.user_id]) {
        return;
    }
    if (!isEmptyString(model.user_intro)) {
        self.userIntro = model.user_intro;
    }
    if (!isEmptyString(model.uname)) {
        self.name = model.uname;
    }
    if (!isEmptyString(model.user_intro)) {
        self.userIntro = model.user_intro;
    }
    if (!isEmptyString(model.avatar_url)) {
        self.avatarURLString = model.avatar_url;
    }
    if (!isEmptyString(model.user_auth_info)) {
        self.userAuthInfo = model.user_auth_info;
        NSData *data = [self.userAuthInfo dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([dictionary tt_stringValueForKey:@"auth_info"]) {
            self.userIntro = [dictionary tt_stringValueForKey:@"auth_info"];
        }
    }
    if (!isEmptyString(model.user_decoration)) {
        self.userDecoration = model.user_decoration;
    }
    if (!SSIsEmptyArray(model.medals)) {
        self.medals = model.medals;
    }
    if (model.is_following) {
        self.isFollowing = model.is_following.boolValue;
    }
    if (model.is_followed) {
        self.isFollowed = model.is_followed.boolValue;
    }
    if (model.invite_status) {
        self.inviteStatus = [model.invite_status integerValue];
    }
    if (model.total_answer) {
        self.totalAnswerCount = model.total_answer.longLongValue;
    }
    if (model.total_digg) {
        self.totalDiggCount = model.total_digg.longLongValue;
    }
    if (!isEmptyString(model.user_auth_info)) {
        self.userAuthInfo = model.user_auth_info;
    }
    if (model.activity) {
        self.redPack = model.activity.redpack;
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.userID = [aDecoder decodeObjectForKey:@"userID"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.screenName = [aDecoder decodeObjectForKey:@"screenName"];
        self.avatarURLString = [aDecoder decodeObjectForKey:@"avatarURLString"];
        self.userIntro = [aDecoder decodeObjectForKey:@"userIntro"];
        self.userAuthInfo = [aDecoder decodeObjectForKey:@"userAuthInfo"];
        self.userDecoration = [aDecoder decodeObjectForKey:@"userDecoration"];
        self.isFollowing = [[aDecoder decodeObjectForKey:@"isFollowing"] boolValue];
        self.isFollowed = [[aDecoder decodeObjectForKey:@"isFollowed"] boolValue];
        self.inviteStatus = [[aDecoder decodeObjectForKey:@"inviteStatus"] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_userID forKey:@"userID"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_screenName forKey:@"screenName"];
    [aCoder encodeObject:_avatarURLString forKey:@"avatarURLString"];
    [aCoder encodeObject:_userIntro forKey:@"userIntro"];
    [aCoder encodeObject:_userAuthInfo forKey:@"userAuthInfo"];
    [aCoder encodeObject:_userDecoration forKey:@"userDecoration"];
    [aCoder encodeObject:@(_isFollowing) forKey:@"isFollowing"];
    [aCoder encodeObject:@(_isFollowed) forKey:@"isFollowed"];
    [aCoder encodeObject:@(_inviteStatus) forKey:@"inviteStatus"];
}

- (void)setIsFollowing:(BOOL)isFollowing
{
    if (isFollowing == _isFollowing) {
        return;
    }
    
    _isFollowing = isFollowing;
    
    if (isFollowing) {
        self.followerCount++;
    } else if (self.followerCount > 0){
        self.followerCount--;
    }
}

@end

@implementation WDPersonModel (TTFeed)

+ (WDPersonModel *)genWDPersonModelFromWDFeedUserModel:(WDStreamUserStructModel *)model {
    if (!model || ![model isKindOfClass:[WDStreamUserStructModel class]]) {
        return nil;
    }
    WDPersonModel *ttModel = [[WDPersonModel alloc] init];
    ttModel.userID = model.user_id;
    ttModel.name = model.uname;
    ttModel.avatarURLString = model.avatar_url;
    ttModel.userAuthInfo = model.user_auth_info;
    ttModel.userDecoration = model.user_decoration;
    ttModel.isFollowing = model.is_following.boolValue;
    return ttModel;
}

@end

