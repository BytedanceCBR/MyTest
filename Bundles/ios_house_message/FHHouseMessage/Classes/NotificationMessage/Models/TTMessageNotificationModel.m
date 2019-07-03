//
//  TTNotificationModel.m
//  Article
//
//  Created by lizhuoli on 17/3/23.
//
//

#import "TTMessageNotificationModel.h"
#import "TTMonitor.h"

#define IsEqualNumber(x, y) ((!x && !y) || (x && [y isEqualToNumber:x]))

@implementation TTMessageNotificationModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
            @"createTime": @"create_time",
            @"ID": @"id",
            @"actionType": @"type",
            @"logPb": @"log_pb",
    };
    return [[JSONKeyMapper alloc] initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName] ?: keyName;
    }];
}

- (instancetype)init {
    if (self = [super init]) {
        self.cachedHeight = @(0);
        self.hasFollowed = @(0);
        self.hasBeFollowed = @(0);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[TTMessageNotificationModel class]]) {
        return NO;
    }

    TTMessageNotificationModel *other = (TTMessageNotificationModel *) object;
    BOOL equal = IsEqualNumber(self.cursor, other.cursor);

    return equal;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.cursor hash];

    return result;
}

@end

@implementation TTMessageNotificationIconModel

@end

@implementation TTMessageNotificationUserModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
            @"userID": @"user_id",
            @"screenName": @"screen_name",
            @"avatarUrl": @"avatar_url",
            @"userAuthInfo": @"user_auth_info",
            @"contactInfo": @"contact_info",
            @"relationInfo": @"relation_info",
            @"userDecoration": @"user_decoration"
    };
    return [[JSONKeyMapper alloc] initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName] ?: keyName;
    }];
}

@end

@implementation TTMessageNotificationWDProfitModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
            @"iconDayUrl": @"icon_day_url",
            @"iconNightUrl": @"icon_night_url",
            @"text": @"text",
            @"amount": @"amount"
    };
    return [[JSONKeyMapper alloc] initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName] ?: keyName;
    }];
}

@end

@implementation TTMessageNotificationContentModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
            @"bodyText": @"body_text",
            @"bodyUrl": @"body_url",
            @"refText": @"ref_text",
            @"refThumbUrl": @"ref_thumb_url",
            @"multiText": @"multi_text",
            @"multiUrl": @"multi_url",
            @"actionText": @"action_text",
            @"gotoText": @"goto_text",
            @"gotoThumbUrl": @"goto_thumb_url",
            @"gotoUrl": @"goto_url",
            @"refImageType": @"ref_image_type",
            @"filterWords": @"filter_words"
    };
    return [[JSONKeyMapper alloc] initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName] ?: keyName;
    }];
}

@end

@implementation TTMessageNotificationResponseModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
            @"msgList": @"msg_list",
            @"hasMore": @"has_more",
            @"readCursor": @"read_cursor",
            @"minCursor": @"min_cursor"
    };
    return [[JSONKeyMapper alloc] initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName] ?: keyName;
    }];
}
@end

@implementation TTMessageNotificationRespModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end
