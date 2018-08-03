//
//  SSShareMessageManager.m
//  Article
//
//  Created by Zhang Leonardo on 13-9-22.
//
//

#import "SSShareMessageManager.h"
#import "CommonURLSetting.h"
#import "TTThirdPartyAccountsHeader.h"
//#import "TTPlatformShareMessageBase.h"
#import "TTBaseMacro.h"
#import <TTNetworkManager/TTNetworkManager.h>

@implementation SSShareMessageManager

static SSShareMessageManager * sManager;

+ (id)shareManager
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sManager = [[SSShareMessageManager alloc] init];
    });
    
    return sManager;
}

- (void)dealloc
{
}

- (void)shareMessageWithGroupModel:(TTGroupModel *)groupModel shareText:(NSString *)text platformKey:(NSString *)platform adID:(NSString *)adID sourceType:(TTShareSourceObjectType)source platform:(TTSharePlatformType)platformType shareUrl:(NSString *)shareUrl shareImageUrl:(NSString *)shareImageUrl{
    
    if (isEmptyString(groupModel.groupID) &&
        (source != TTShareSourceObjectTypeWap && source != TTShareSourceObjectTypeProfile)) {
        return;
    }
    
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    [condition setValue:groupModel.groupID forKey:@"group_id"];
    [condition setValue:groupModel.itemID forKey:@"item_id"];
    [condition setValue:@(groupModel.aggrType) forKey:@"aggr_type"];
    [condition setValue:text forKey:@"text"];
    [condition setValue:platform forKey:@"platform"];
    
    if ([adID longLongValue] != 0) {
        [condition setValue:adID forKey:@"ad_id"];
    }
    
    NSString *utmSource = platform;
    if ([platform isEqualToString:PLATFORM_SINA_WEIBO]) {
        utmSource = @"sinaweibo";
    } else if ([platform isEqualToString:PLATFORM_QQ_WEIBO]) {
        utmSource = @"txweibo";
    } else if ([platform isEqualToString:PLATFORM_RENREN_SNS]) {
        utmSource = @"renren";
    }
    if ([platform isEqualToString:@"weixin"] || [platform isEqualToString:@"weixin_moments"]) {
        condition[@"wxshare_count"] = @1;
    }
    [condition setValue:utmSource forKey:@"utm_source"];
    [condition setValue:@"toutiao_ios" forKey:@"utm_medium"];
    [condition setValue:@"client_share" forKey:@"utm_campaign"];
    if (platformType == TTSharePlatformTypeOfHTSLivePlugin) {
        [condition setValue:@(7) forKey:@"share_type"];
    }
    if (source == TTShareSourceObjectTypeWap ||
        source == TTShareSourceObjectTypeProfile ||
        source == TTShareSourceObjectTypeHTSVideo) {
        [condition setValue:@(5) forKey:@"share_type"];
        [condition setValue:shareUrl forKey:@"url"];
        [condition setValue:shareImageUrl forKey:@"image_url"];
    }
    
    NSString *gID = groupModel.groupID;
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting shareMessageURLString] params:condition method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSMutableDictionary * responseUserInfo = [NSMutableDictionary dictionaryWithCapacity:10];
        
        [responseUserInfo setValue:error forKey:@"error"];
        [responseUserInfo setValue:gID forKey:@"group_id"];
        [responseUserInfo setValue:platform forKey:@"platform"];
        if (!isEmptyString(adID)) {
            [responseUserInfo setValue:adID forKey:@"ad_id"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kShareMessageFinishedNotification object:nil userInfo:responseUserInfo];
    }];
}

#pragma mark - Public

- (void)shareMessageWithGroupModel:(TTGroupModel *)groupModel shareText:(NSString *)text platformKey:(NSString *)platform adID:(NSString *)adID sourceType:(TTShareSourceObjectType)source
{
    [self shareMessageWithGroupModel:groupModel shareText:text platformKey:platform adID:adID sourceType:(TTShareSourceObjectType)source platform:TTSharePlatformTypeOfMain shareUrl:nil shareImageUrl:nil];
}

- (void)shareMessageWithGroupModel:(TTGroupModel *)groupModel shareText:(NSString *)text platformKey:(NSString *)platform uniqueId:(NSString *)uniqueId adID:(NSString *)adID sourceType:(TTShareSourceObjectType)source platform:(TTSharePlatformType)platformType shareUrl:(NSString *)shareUrl shareImageUrl:(NSString *)shareImageUrl{
    
    switch (platformType) {
        case TTSharePlatformTypeOfMain:
        case TTSharePlatformTypeOfHTSLivePlugin:
            [self shareMessageWithGroupModel:groupModel shareText:text platformKey:platform adID:adID sourceType:(TTShareSourceObjectType)source platform:platformType shareUrl:shareUrl shareImageUrl:shareImageUrl];
            break;
//        case TTSharePlatformTypeOfForumPlugin:{
//
//            TTPlatformShareMessageBase *shareMessageManager = [[NSClassFromString(@"FRShareMessageManager") alloc] init];
//            if (shareMessageManager) {
//                NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
//                [condition setValue:platform forKey:@"forward_to"];
//                [condition setValue:uniqueId forKey:@"forward_id"];
//                [condition setValue:text forKey:@"forward_content"];
//                switch (source) {
//                    case TTShareSourceObjectTypeForum:{
//                        [condition setValue:@"forum" forKey:@"forward_type"];
//                    }
//                        break;
//                    case TTShareSourceObjectTypeFeedForumPost:
//                    case TTShareSourceObjectTypeForumPost:{
//                        [condition setValue:@"thread" forKey:@"forward_type"];
//                    }
//                        break;
//                    case TTShareSourceObjectTypeWendaQuestion: {
//                        [condition setValue:@"wenda_list" forKey:@"forward_type"];
//                    }
//                        break;
//                    case TTShareSourceObjectTypeWendaAnswer: {
//                        [condition setValue:@"wenda_detail" forKey:@"forward_type"];
//                    }
//                        break;
//                    default:
//                        break;
//                }
//
//
//                NSString *utmSource = platform;
//                if ([platform isEqualToString:PLATFORM_SINA_WEIBO]) {
//                    utmSource = @"sinaweibo";
//                } else if ([platform isEqualToString:PLATFORM_QQ_WEIBO]) {
//                    utmSource = @"txweibo";
//                } else if ([platform isEqualToString:PLATFORM_RENREN_SNS]) {
//                    utmSource = @"renren";
//                }
//                if ([platform isEqualToString:@"weixin"] || [platform isEqualToString:@"weixin_moments"]) {
//                    condition[@"wxshare_count"] = @1;
//                }
//                [condition setValue:utmSource forKey:@"utm_source"];
//                [condition setValue:@"toutiao_ios" forKey:@"utm_medium"];
//                [condition setValue:@"client_share" forKey:@"utm_campaign"];
//
//                //WeakSelf;
//                [shareMessageManager shareMessageFromPlatform:TTSharePlatformTypeOfForumPlugin condition:condition withCompletion:^(id response, NSError *error) {
//                    //StrongSelf;
//
//                    NSString * gID = [condition objectForKey:@"group_id"];
//                    NSString * platform = [condition objectForKey:@"platform"];
//                    NSString * adID = [condition objectForKey:@"ad_id"];
//
//                    NSMutableDictionary * responseUserInfo = [NSMutableDictionary dictionaryWithCapacity:10];
//
//                    [responseUserInfo setValue:error forKey:@"error"];
//                    [responseUserInfo setValue:gID forKey:@"group_id"];
//                    [responseUserInfo setValue:platform forKey:@"platform"];
//                    if (!isEmptyString(adID)) {
//                        [responseUserInfo setValue:adID forKey:@"ad_id"];
//                    }
//                    [[NSNotificationCenter defaultCenter] postNotificationName:kShareMessageFinishedNotification object:nil userInfo:responseUserInfo];
//
//                }];
//            }
//            break;
//        }
        default:
            break;
    }
}


@end
