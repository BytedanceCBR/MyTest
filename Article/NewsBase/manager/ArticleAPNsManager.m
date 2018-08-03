//
//  ArticleAPNsManager.m
//  Article
//
//  Created by Kimimaro on 13-4-3.
//
//

#import "ArticleAPNsManager.h"
#import "TTRoute.h"
#import "AppAlertManager.h"
#import "TTDeviceHelper.h"

/*
 iOS 头条2.5版本及以前版本的apns逻辑如下：
 
 通过 push apn 推送，推送内容包含：
 
 t：1，通知类型，1表示动态消息类型通知
 text：通知内容 ，如：xxx关注了你
 p：跳转页面（int值），如：1
 uid：userid（int值），只在跳好有profile页面用到
 
 跳转页面如下：
 1：好友粉丝
 2：好友动态
 3：添加好友
 4：好友profile
 */

typedef enum {
    SSAPNsTypeRelation = 1,
    SSAPNsTypeAction = 2,
    SSAPNsTypeCustom = 99
} SSAPNsType;

typedef enum {
    SSAPNsRelationRelation      = 1,
    SSAPNsRelationUpdate        = 2,
    SSAPNsRelationSuggestUsers  = 3,
    SSAPNsRelationProfile       = 4
} SSAPNsRelation;

typedef enum {
    SSAPNsActionAccountNotification = 5
} SSAPNsAction;


@implementation ArticleAPNsManager

static ArticleAPNsManager *_sharedManager = nil;
+ (APNsManager *)sharedManager
{
    @synchronized(self) {
        if (!_sharedManager) {
            _sharedManager = [[ArticleAPNsManager alloc] init];
        }
    }
    
    return _sharedManager;
}

- (BOOL)tryForOldAPNsLogical:(NSDictionary *)userInfo
{
    BOOL isOldLogical = NO;
    
    if ([[userInfo allKeys] containsObject:@"t"]) {
        isOldLogical = YES;
        
        if (![TTDeviceHelper isPadDevice]) {
            
            NSString *toUserID = [userInfo objectForKey:@"tuid"];
            SSAPNsType type = (SSAPNsType)[[userInfo objectForKey:@"t"] integerValue];
            switch (type) {
                case SSAPNsTypeRelation:
                {
                    SSAPNsRelation relationType = (SSAPNsRelation)[[userInfo objectForKey:@"p"] integerValue];
                    if (_delegate && [_delegate respondsToSelector:@selector(apnsManager:canPresentViewControllerToUserID:)]) {
                        if ([_delegate apnsManager:self canPresentViewControllerToUserID:toUserID]) {
                            
                            switch (relationType) {
                                case SSAPNsRelationProfile:
                                case SSAPNsRelationUpdate:
                                {
                                    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"profile"] userInfo:TTRouteUserInfoWithDict(@{@"uid" : [userInfo objectForKey:@"uid"]})];
                                    wrapperTrackEvent(@"apn", @"user_info");
                                }
                                    break;
                                case SSAPNsRelationRelation:
                                {
                                    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"relation/follower"]];
                                    wrapperTrackEvent(@"apn", @"user_follower");
                                }
                                    break;
                                case SSAPNsRelationSuggestUsers:
                                {
                                    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"relation/add_friend"]];
                                    wrapperTrackEvent(@"apn", @"user_info");
                                }
                                    break;
                                default:
                                    break;
                            }
                        }
                    }
                }
                    break;
                case SSAPNsTypeAction:
                {
                    SSAPNsAction actionType = (SSAPNsAction)[[userInfo objectForKey:@"p"] integerValue];
                    if (_delegate && [_delegate respondsToSelector:@selector(apnsManager:canPresentViewControllerToUserID:)]) {
                        if ([_delegate apnsManager:self canPresentViewControllerToUserID:toUserID]) {
                            
                            switch (actionType) {
                                case SSAPNsActionAccountNotification:
                                {
                                    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"notification"]];
                                    wrapperTrackEvent(@"apn", @"comment");
                                }
                                    break;
                                    
                                default:
                                    break;
                            }
                        }
                    }
                }
                    break;
                case SSAPNsTypeCustom:
                {
                    NSString * pStr = [userInfo objectForKey:@"p"];
                    if (_delegate && [_delegate respondsToSelector:@selector(apnsManager:customAction:)]) {
                        [_delegate apnsManager:self customAction:pStr];
                    }
                }
                    break;
                default:
                    break;
            }
        }
    }
    else if ([[userInfo allKeys] containsObject:@"id"]) {
        isOldLogical = YES;
        
        [self sendTrackEvent:@"apn" lable:@"notice" value:[userInfo objectForKey:@"id"]];
        if (_delegate && [_delegate respondsToSelector:@selector(apnsManager:handleUserInfoContainsID:)]) {
            [_delegate apnsManager:self handleUserInfoContainsID:[userInfo objectForKey:@"id"]];
        }
    }
    
    return isOldLogical;
}

- (void)dealWithOpenURL:(NSString **)openURL
{
    [super dealWithOpenURL:openURL];
    
    TTRouteParamObj *paramsObj = [[TTRoute sharedRoute] routeParamObjWithURL:[NSURL URLWithString:*openURL]];
    if (!isEmptyString(paramsObj.host)) {
        NSString *pageName = paramsObj.host;
        if ([pageName isEqualToString:@"detail"] ||
            [pageName isEqualToString:@"new_detail"]) {
            *openURL = [NSString stringWithFormat:@"%@&gd_label=%@", *openURL, kArticleDetailFromAPNsKey];
        }
    }
}

- (void)trackWithPageName:(NSString *)pageName params:(NSDictionary *)params
{
    // 为了兼容头条之前的统计事件，根据页面优先处理这些page，其他情况下发送event:apn, label:{pageName}
    if ([pageName isEqualToString:@"profile"] || [pageName isEqualToString:@"add_friend"]) {
        wrapperTrackEvent(@"apn", @"user_info");
    }
    else if ([pageName isEqualToString:@"relation/follower"]) {
        wrapperTrackEvent(@"apn", @"user_follower");
    }
    else if ([pageName isEqualToString:@"notification"]) {
        if ([params.allKeys containsObject:@"source"]) {
            wrapperTrackEvent(@"apn", [params objectForKey:@"source"]);
        }
        else {
            wrapperTrackEvent(@"apn", @"comment");
        }
    }
    else if ([pageName isEqualToString:@"detail"]) {
        [self sendTrackEvent:@"apn" lable:@"notice" value:[params objectForKey:@"groupid"]];
    }
    else {
        wrapperTrackEvent(@"apn", pageName);
    }
}

@end
