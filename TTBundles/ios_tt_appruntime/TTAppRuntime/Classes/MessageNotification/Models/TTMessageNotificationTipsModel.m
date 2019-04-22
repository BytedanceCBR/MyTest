//
//  TTMessageNotificationTipsModel.m
//  Article
//
//  Created by lizhuoli on 17/3/23.
//
//

#import "TTMessageNotificationTipsModel.h"

@implementation TTMessageNotificationTipsModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"action_type": @"actionType",
                                                       @"last_image_url": @"lastImageUrl",
                                                       @"follow_channel_tips": @"followChannelTips"
                                                       }];
}

@end

@implementation TTMessageNotificationTipsImportantModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"user_name": @"userName",
                                                       @"thumb_url": @"thumbUrl",
                                                       @"user_auth_info": @"userAuthInfo",
                                                       @"display_time": @"displayTime",
                                                       @"openurl": @"openUrl",
                                                       @"msg_id":@"msgID",
                                                       @"user_decoration":@"userDecoration",
                                                       @"only_bubble": @"onlyBubble"
                                                       }];
}

- (instancetype)init{
    if(self = [super init]){
        _hasShown = @(0);
    }
    return self;
}

@end
