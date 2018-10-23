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

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                      @"create_time": @"createTime",
                                                      @"id": @"ID",
                                                      @"type": @"actionType",
                                                       }];
}

- (instancetype)init{
    if(self = [super init]){
        self.cachedHeight = @(0);
        self.hasFollowed = @(0);
        self.hasBeFollowed = @(0);
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[TTMessageNotificationModel class]]) {
        return NO;
    }
    
    TTMessageNotificationModel *other = (TTMessageNotificationModel *)object;
    BOOL equal = IsEqualNumber(self.cursor, other.cursor);
    
    return equal;
}

- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.cursor hash];
    
    return result;
}

@end

@implementation TTMessageNotificationIconModel

@end

@implementation TTMessageNotificationUserModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"user_id": @"userID",
                                                       @"screen_name": @"screenName",
                                                       @"avatar_url": @"avatarUrl",
                                                       @"user_auth_info": @"userAuthInfo",
                                                       @"contact_info": @"contactInfo",
                                                       @"relation_info": @"relationInfo",
                                                       @"user_decoration": @"userDecoration"
                                                       }];
}

@end

@implementation TTMessageNotificationWDProfitModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"icon_day_url": @"iconDayUrl",
                                                       @"icon_night_url": @"iconNightUrl",
                                                       @"text": @"text",
                                                       @"amount" : @"amount"
                                                       }];
}

@end

@implementation TTMessageNotificationContentModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                      @"body_text": @"bodyText",
                                                      @"body_url": @"bodyUrl",
                                                      @"ref_text": @"refText",
                                                      @"ref_thumb_url": @"refThumbUrl",
                                                      @"multi_text": @"multiText",
                                                      @"multi_url": @"multiUrl",
                                                      @"action_text": @"actionText",
                                                      @"goto_text": @"gotoText",
                                                      @"goto_thumb_url" : @"gotoThumbUrl",
                                                      @"goto_url" :@"gotoUrl",
                                                      @"ref_image_type" : @"refImageType",
                                                      @"filter_words" : @"filterWords"
                                                      }];
}

@end

@implementation TTMessageNotificationResponseModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                      @"msg_list": @"msgList",
                                                      @"has_more": @"hasMore",
                                                      @"read_cursor": @"readCursor",
                                                      @"min_cursor": @"minCursor"
                                                       }];
}

- (void)setMsgListWithNSArray:(NSArray *)msgList
{
    NSMutableArray *mutArr = [NSMutableArray array];
    
    for (NSDictionary *msgDict in msgList) {
        if ([msgDict isKindOfClass:[NSDictionary class]]) {
            NSError *error;
            TTMessageNotificationModel *msgModel = [[TTMessageNotificationModel alloc] initWithDictionary:msgDict error:&error];
            
            if (msgModel) {
                [mutArr addObject:msgModel];
            } else {
                NSMutableDictionary *extraParams = [NSMutableDictionary dictionary];
                
                [extraParams setValue:[msgDict objectForKey:@"style"] forKey:@"style"];
                [extraParams setValue:@(error.code) forKey:@"err_code"];
                [extraParams setValue:error.localizedDescription forKey:@"err_des"];
                
                [[TTMonitor shareManager] trackService:@"tt_message_monitor_model_error" status:1 extra:[extraParams copy]];
            }
        }
    }
    
    self.msgList = [mutArr copy];
}

@end
