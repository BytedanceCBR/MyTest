//
//  SSAPNsAlertManager.m
//  Article
//
//  Created by Zhang Leonardo on 13-12-26.
//
//

#import "SSAPNsAlertManager.h"
#import <TTRoute.h>
#import <TTThemedAlertController.h>
#import <TTStringHelper.h>

#import "ExploreMovieView.h"
#import "Article.h"
#import "TTProjectLogicManager.h"
#import "TTPushAlertManager.h"
#import "TouTiaoPushSDK.h"
//#import "TTSFShareManager.h"
#import "TTAPNsRouting.h"
#import "TTPushResourceMgr.h"
#import "TTArticleTabBarController.h"
#import "TTAccountManager.h"
#import "FHHouseBridgeManager.h"
#import <FHLocManager.h>

#define kApnsAlertManagerCouldShowAlertViewKey @"kApnsAlertManagerCouldShowAlertViewKey"

#define kCouldShowActivePushAlertKey @"kCouldShowActivityPushAlertKey"

static SSAPNsAlertManager *s_manager;

@interface SSAPNsAlertManager()

@end

@implementation SSAPNsAlertManager

+ (SSAPNsAlertManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[SSAPNsAlertManager alloc] init];
    });
    return s_manager;
}

+ (void)setCouldShowAPNsAlert:(BOOL)could
{
    [[NSUserDefaults standardUserDefaults] setObject:@(could) forKey:kApnsAlertManagerCouldShowAlertViewKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)couldShowAPNsAlert
{
    NSNumber *could = [[NSUserDefaults standardUserDefaults] objectForKey:kApnsAlertManagerCouldShowAlertViewKey];
    if (could == nil) {
        return YES;
    }
    return [could boolValue];
}

+ (void)setCouldShowActivePushAlert:(BOOL)could
{
    [[NSUserDefaults standardUserDefaults] setObject:@(could) forKey:kCouldShowActivePushAlertKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)couldShowActivePushAlert
{
    NSNumber *result = [[NSUserDefaults standardUserDefaults] objectForKey:kCouldShowActivePushAlertKey];
    if (result == nil) {
        return YES;
    }
    return [result boolValue];
}

#pragma mark - public

static NSString * const kTTAPNsImportanceKey = @"important";

- (void)showRemoteNotificationNewAlert:(NSDictionary *)dict
{
    NSString *title = [dict tt_stringValueForKey:kSSAPNsAlertManagerTitleKey];
    NSNumber *gid = @([dict tt_longlongValueForKey:kSSAPNsAlertManagerOldApnsTypeIDKey]);
    NSString *rid = [dict tt_stringValueForKey:kSSAPNsAlertManagerRidKey];
    NSString *postBack = [dict tt_stringValueForKey:@"post_back"];
    NSString *schemaString = [dict tt_stringValueForKey:kSSAPNsAlertManagerSchemaKey];
    
    if ([gid longLongValue] != 0 && isEmptyString(schemaString)) {
        schemaString = [NSString stringWithFormat:@"sslocal://detail?groupid=%@&gd_label=click_news_alert", gid];
    }
    
    if (!([[[TTStringHelper URLWithURLString:schemaString] host] isEqualToString:@"detail"] ||
          [[[TTStringHelper URLWithURLString:schemaString] host] isEqualToString:@"fantasy"] ||
          [[[TTStringHelper URLWithURLString:schemaString] host] isEqualToString:@"wenda_detail"] ||
          [[[TTStringHelper URLWithURLString:schemaString] host] isEqualToString:@"awemevideo"])) {
        return;
    }
    
    if (![SSAPNsAlertManager couldShowActivePushAlert]) {
        return;
    }
    
    BOOL hasRead = [self _hasReadOfArticle:schemaString];
    
    if (!hasRead) {
        NSString *titleString  = NSLocalizedString(@"实时推送", nil);
        NSString *detailString = title;
        NSString *attachmentURLString = [dict tt_stringValueForKey:kSSAPNsAlertManagerAttachmentKey];
        NSString *importanceString    = [dict tt_stringValueForKey:kSSAPNsAlertManagerImportanceKey];
        
        [TTPushResourceMgr downloadImageWithURLString:attachmentURLString completion:^(UIImage *image, BOOL success) {
            
            TTPushAlertModel *alertModel = [TTPushAlertModel modelWithTitle:titleString detail:detailString images:nil];
            alertModel.images = image ? @[image] : nil;
            alertModel.schemaString = schemaString;
            alertModel.gidString = gid;
            alertModel.ridString = rid;
            
            void (^TTAPNsTakeALookActionBlock)() = ^(TTPushAlertModel *alertModel) {
                //推送过来 如果是弹框打开的 把click_apn 改成click_news_alert
                NSMutableString *schemaReplaceString = [schemaString mutableCopy];
                if ([schemaReplaceString rangeOfString:@"gd_label"].location != NSNotFound) {
                    [schemaReplaceString replaceOccurrencesOfString:@"click_apn" withString:@"click_news_alert" options:NSLiteralSearch range:NSMakeRange(0, schemaReplaceString.length)];
                }
                
                if ([[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:schemaReplaceString]]) {
                    // [ExploreMovieView removeAllExploreMovieView]; 全屏不显示推送了
                    //有可能当前有视频全屏，等视频完全退出后再打开推送来的文章
                    //在旧的navigation架构下，使用的是pushViewController:animated:方法，如果push的时候，还有presentedViewController在上面的话，UIKit会两次调用pushViewController:方法，而后一次由于TTNavigationController做了保护，而无法完成push操作
                    //所以用让openURL操作慢0.1s，确保视频已经完全退出
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        NSURL *openURL = [TTStringHelper URLWithURLString:schemaReplaceString];

                        TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:openURL];
                        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
                        [params setValue:rid  == nil ? @"be_null" : rid forKey:@"rule_id"];
                        [params setValue:@"alert" forKey:@"click_position"];
                        [params setValue:postBack == nil ? @"be_null" : postBack forKey:@"post_back"];
                        if ([paramObj.queryParams.allKeys containsObject:@"groupid"]) {
                            NSString* value = [paramObj.queryParams objectForKey:@"groupid"];
                            if (value != nil) {
                                [params setValue:value forKey:@"group_id"];
                            } else {
                                [params setValue:@"be_null" forKey:@"group_id"];
                            }
                        }
                        if ([paramObj.queryParams.allKeys containsObject:@"group_id"]) {
                            NSString* value = [paramObj.queryParams objectForKey:@"group_id"];
                            if (value != nil) {
                                [params setValue:value forKey:@"group_id"];
                            } else {
                                [params setValue:@"be_null" forKey:@"group_id"];
                            }
                        }
                        params[@"event_type"] = @"house_app2c_v2";
                        [TTTracker eventV3:@"push_click" params:params];

                        [[TTRoute sharedRoute] openURLByPushViewController:openURL];
                    });
                }
                wrapperTrackEventWithCustomKeys(@"apn", @"news_alert_view", rid, nil, nil);
            };
            
            if ([importanceString isKindOfClass:[NSString class]] && [importanceString isEqualToString:kTTAPNsImportanceKey]) {
                // Importance弹窗样式，下载失败不显示图片
                id<TTPushAlertViewProtocol> pushAlert = [TTPushAlertManager showPushAlertViewWithModel:alertModel urgency:TTPushAlertImportance didTapBlock:^(NSInteger hideReason) {
                    if (TTStrongAlertHideTypeTapCancel == hideReason) {
                        [TTTrackerWrapper eventV3:@"apn" params:@{@"news_alert_close": @(1)}];
                    } else if (TTStrongAlertHideTypeTapOk == hideReason ||
                               TTStrongAlertHideTypeTapContent == hideReason) {
                        if (TTAPNsTakeALookActionBlock) {
                            TTAPNsTakeALookActionBlock(alertModel);
                        }
                        
                        [TTTrackerWrapper eventV3:@"apn" params:@{@"news_alert_click": @(1)}];
                        //AB测旧埋点不能丢
                        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                            wrapperTrackEventWithCustomKeys(@"apn", @"news_alert_view", rid, nil, nil);
                        }
                        //pushsdk 新增v3埋点
                        [TouTiaoPushSDK trackerWithRuleId:rid clickPosition:@"alert" postBack:postBack];
                    }
                } willHideBlock:nil didHideBlock:nil];
                
                if (pushAlert) {
                    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
                    [params setValue:@(1) forKey:@"news_alert_show"];
                    [params setValue:schemaString forKey:@"schema"];
                    [params setValue:gid forKey:@"gid"];
                    [params setValue:rid forKey:@"rid"];
                    [TTTrackerWrapper eventV3:@"apn" params:params];
                }
            } else {
                // Unimportance弹窗样式，下载失败不显示图片
                id<TTPushAlertViewProtocol> pushAlert = [TTPushAlertManager showPushAlertViewWithModel:alertModel urgency:TTPushAlertUnimportance didTapBlock:nil willHideBlock:nil didHideBlock:^(NSInteger hideReason) {
                    
                    if (hideReason == TTWeakPushAlertHideTypeAutoDismiss) {
                        [TTTrackerWrapper eventV3:@"apn" params:@{@"news_alert_auto_dismiss": @(2)}];
                    } else if (hideReason == TTWeakPushAlertHideTypeTapClose) {
                        [TTTrackerWrapper eventV3:@"apn" params:@{@"news_alert_close": @(2)}];
                    } else if (hideReason == TTWeakPushAlertHideTypePanClose) {
                        [TTTrackerWrapper eventV3:@"apn" params:@{@"news_alert_pan_dismiss": @(2)}];
                    } else if (hideReason == TTWeakPushAlertHideTypeOpenContent) {
                        if (TTAPNsTakeALookActionBlock) {
                            TTAPNsTakeALookActionBlock(alertModel);
                        }
                        
                        [TTTrackerWrapper eventV3:@"apn" params:@{@"news_alert_click": @(2)}];
                        
                        //AB测旧埋点不能丢
                        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                            wrapperTrackEventWithCustomKeys(@"apn", @"news_alert_view", rid, nil, nil);
                        }

                    }
                }];
                
                if (pushAlert) {
                    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
                    [params setValue:@(2) forKey:@"news_alert_show"];
                    [params setValue:schemaString forKey:@"schema"];
                    [params setValue:gid forKey:@"gid"];
                    [params setValue:rid forKey:@"rid"];
                    [TTTrackerWrapper eventV3:@"apn" params:params];
                }
            }
        }];
    }
}

// 前台收到推送
- (void)showRemoteNotificationAlert:(NSDictionary *)dict
{
    // 处理注册到push路由的业务逻辑，如果能处理则处理后return
    if ([TTAPNsRouting handlePushMsg:dict]) {
        return;
    }
    
    NSString *schemaString = [dict tt_stringValueForKey:kSSAPNsAlertManagerSchemaKey];
    
    // 暂时兼容的逻辑，如果是detail，走原有弹窗逻辑；否则透传给路由处理
    NSLog(@"%@", [[TTStringHelper URLWithURLString:schemaString] host]);
    if ([[[TTStringHelper URLWithURLString:schemaString] host] isEqualToString:@"detail"] ||
        [[[TTStringHelper URLWithURLString:schemaString] host] isEqualToString:@"wenda_detail"] ||
        [[[TTStringHelper URLWithURLString:schemaString] host] isEqualToString:@"awemevideo"]) {
        if ([TTPushAlertManager newAlertEnabled]) {
            [self showRemoteNotificationNewAlert:dict];
            return;
        }
        
        NSString *importanceString = [dict tt_stringValueForKey:kSSAPNsAlertManagerImportanceKey];
        if (importanceString && ![importanceString isEqualToString:kTTAPNsImportanceKey]) {
            return;
        }
        
        NSString *title = [dict tt_stringValueForKey:kSSAPNsAlertManagerTitleKey];
        NSNumber *gid = @([dict tt_longlongValueForKey:kSSAPNsAlertManagerOldApnsTypeIDKey]);
        NSString *rid = [dict tt_stringValueForKey:kSSAPNsAlertManagerRidKey];
//        NSString *schemaString = [dict tt_stringValueForKey:kSSAPNsAlertManagerSchemaKey];
        NSString *postBack = [dict tt_stringValueForKey:@"post_back"];
        
        if ([gid longLongValue] != 0 && isEmptyString(schemaString)) {
            schemaString = [NSString stringWithFormat:@"sslocal://detail?groupid=%@&gd_label=click_news_alert", gid];
        }
        
        if (isEmptyString(title) || isEmptyString(schemaString)) {
            return;
        }
        
        if (![SSAPNsAlertManager couldShowActivePushAlert]) {
            return;
        }
        
        BOOL hasRead = [self _hasReadOfArticle:schemaString];
        
        if (!hasRead) {
            TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"实时推送", nil) message:title preferredType:TTThemedAlertControllerTypeAlert];
            [alert addActionWithTitle:NSLocalizedString(@"忽略", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
                wrapperTrackEvent(@"apn", @"news_alert_close");
            }];
            [alert addActionWithTitle:NSLocalizedString(@"立即查看", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                //推送过来 如果是弹框打开的 把click_apn 改成click_news_alert
                NSMutableString *schemaReplaceStr = [schemaString mutableCopy];
                if ([schemaReplaceStr rangeOfString:@"gd_label"].location != NSNotFound) {
                    [schemaReplaceStr replaceOccurrencesOfString:@"click_apn" withString:@"click_news_alert" options:NSLiteralSearch range:NSMakeRange(0, schemaReplaceStr.length)];
                    
                }
                if ([[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:schemaReplaceStr]]) {
                    // [ExploreMovieView removeAllExploreMovieView]; 全屏不显示推送了
                    //有可能当前有视频全屏，等视频完全退出后再打开推送来的文章
                    //在旧的navigation架构下，使用的是pushViewController:animated:方法，如果push的时候，还有presentedViewController在上面的话，UIKit会两次调用pushViewController:方法，而后一次由于TTNavigationController做了保护，而无法完成push操作
                    //所以用让openURL操作慢0.1s，确保视频已经完全退出
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        NSURL *openURL = [TTStringHelper URLWithURLString:schemaReplaceStr];
                        [[TTRoute sharedRoute] openURLByPushViewController:openURL];
                    });
                }
                if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                    wrapperTrackEventWithCustomKeys(@"apn", @"news_alert_view", rid, nil, nil);
                }
                
                //V3埋点
                // NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
                // [params setValue:rid forKey:@"rule_id"];
                // [params setValue:@"alert" forKey:@"click_position"];
                // [TTTrackerWrapper eventV3:@"push_click" params:[params copy] isDoubleSending:YES];
                [TouTiaoPushSDK trackerWithRuleId:rid clickPosition:@"alert" postBack:postBack];
            }];
            [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
            wrapperTrackEvent(@"apn", @"news_alert_show");
        }
    }
//    else if ([[[TTStringHelper URLWithURLString:schemaString] host] isEqualToString:@"xigua_live"]){
//        //产品说暂时不出push弹窗
//        return ;
//    }
    else if ([[self class] isF100PushUrl:[[TTStringHelper URLWithURLString:schemaString] host]]) {
        [[self class] showF100PushNotificationInAppAlert:dict];
    }
//    else if ([[[TTStringHelper URLWithURLString:schemaString] host] isEqualToString:@"fantasy"]) {
////        if ([TTPushAlertManager newAlertEnabled]) {
////            [self showRemoteNotificationNewAlert:dict];
////        }
//    }
    else {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSURL *openURL = [TTStringHelper URLWithURLString:schemaString];
//            // 此处为前台收到推送
//            // 优先处理春节活动, 过滤春节活动黑名单的推送scheme
//            // 其他推送默认不在前台做任何处理。需要的要添加else if处理分支
//            if (![self.class inRemoteNotificationOnAppActiveSFBlackList:openURL]) {
////                if (![TTSFShareManager openRemoteNotificationWithURL:openURL]) {
////                    [[TTRoute sharedRoute] openURLByPushViewController:openURL];
////                }
////                [TTSFShareManager openRemoteNotificationWithURL:openURL];
//            }
//        });
    }
    return;
}

+ (BOOL)isF100PushUrl:(NSString*) host {
    return [@"old_house_detail" isEqualToString:host] ||
    [@"neighborhood_detail" isEqualToString:host] ||
    [@"new_house_detail" isEqualToString:host] ||
    [@"floor_plan_detail" isEqualToString:host] ||
    [@"message_detail_list" isEqualToString:host] ||
    [@"message_system_list" isEqualToString:host] ||
    [@"house_list" isEqualToString:host] ||
    [@"rent_detail" isEqualToString:host] ||
    [@"renthouse_main" isEqualToString:host] ||
    [@"mapfind_house" isEqualToString:host] ||
    [@"mapfind_rent" isEqualToString:host] ||
    [@"rent_main" isEqualToString:host] ||
    [@"webview" isEqualToString:host] ||
    [@"realtor_detail" isEqualToString:host] ||
    [@"main" isEqualToString:host];
}

+ (void)showF100PushNotificationInAppAlert:(NSDictionary *)dict {
    NSString* title = @"幸福里";
    NSString* content = [dict tt_stringValueForKey:kSSAPNsAlertManagerTitleKey];
    NSString *schemaString = [dict tt_stringValueForKey:kSSAPNsAlertManagerSchemaKey];

    TTPushAlertModel *alertModel = [TTPushAlertModel modelWithTitle:title detail:content images:nil];
    alertModel.images = nil;
    alertModel.schemaString = schemaString;
    // Unimportance弹窗样式，下载失败不显示图片
    //    id<TTPushAlertViewProtocol> pushAlert =
    [TTPushAlertManager showPushAlertViewWithModel:alertModel urgency:TTPushAlertUnimportance didTapBlock:^(NSInteger hideReason) {



        //有可能当前有视频全屏，等视频完全退出后再打开推送来的文章
        //在旧的navigation架构下，使用的是pushViewController:animated:方法，如果push的时候，还有presentedViewController在上面的话，UIKit会两次调用pushViewController:方法，而后一次由于TTNavigationController做了保护，而无法完成push操作
        //所以用让openURL操作慢0.1s，确保视频已经完全退出
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSURL *openURL = [TTStringHelper URLWithURLString:schemaString];

            TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:openURL];
            //V3埋点
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setValue:@"be_null" forKey:@"rule_id"];
            [param setValue:@"alert" forKey:@"click_position"];
            [param setValue:@"be_null" forKey:@"post_back"];
            if ([paramObj.queryParams.allKeys containsObject:@"groupid"]) {
                NSString* value = [paramObj.queryParams objectForKey:@"groupid"];
                if (value != nil) {
                    [param setValue:value forKey:@"group_id"];
                } else {
                    [param setValue:@"be_null" forKey:@"group_id"];
                }
            }
            if ([paramObj.queryParams.allKeys containsObject:@"group_id"]) {
                NSString* value = [paramObj.queryParams objectForKey:@"group_id"];
                if (value != nil) {
                    [param setValue:value forKey:@"group_id"];
                } else {
                    [param setValue:@"be_null" forKey:@"group_id"];
                }
            }
            if ([[self class] f100ContentHasGroupId:paramObj.allParams]) {
                [param setValue:[[self class] f100ContentGroupId:paramObj.allParams] forKey:@"group_id"];
            }
            param[@"event_type"] = @"house_app2c_v2";
            param[@"post_back"] = @"be_null";

            [TTTracker eventV3:@"push_click" params:param];

//            NSURL *handledOpenURL = [TTStringHelper URLWithURLString:openURL];
            if ([[openURL host] isEqualToString:@"main"]) {
                TTRouteParamObj* obj = [[TTRoute sharedRoute] routeParamObjWithURL:openURL];
                NSDictionary* params = [obj queryParams];
                if (params != nil) {
                    NSString* target = params[@"select_tab"];
                    if (target != nil && target.length > 0) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:TTArticleTabBarControllerChangeSelectedIndexNotification object:nil userInfo:@{@"tag": target}];
                    } else {
                        NSAssert(false, @"推送消息的tag为空");
                    }
                }
            } else {
                [FHLocManager sharedInstance].isShowHomeViewController = NO;
                // push对消息特殊处理
//                if ([[openURL host] isEqualToString:@"message_detail_list"]) {
////                    if (![TTAccountManager isLogin]) {
////                        [TTAccountLoginManager showAlertFLoginVCWithParams:nil completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
////                            if (type == TTAccountAlertCompletionEventTypeDone) {
////                                //登录成功 走发送逻辑
////                                if ([TTAccountManager isLogin]) {
////                                    [[EnvContext shared] setTraceValueWithValue:@"push" key:@"origin_from"];
////                                    [[TTRoute sharedRoute] openURLByPushViewController:openURL];
////                                }
////                            }
////                        }];
////                    } else
////                    {
//                        [[EnvContext shared] setTraceValueWithValue:@"push" key:@"origin_from"];
//                        [[TTRoute sharedRoute] openURLByPushViewController:openURL];
////                    }
//
//                    return;
//                }
                NSDictionary* info = @{@"isFromPush": @(1),
                                       @"tracer":@{@"enter_from": @"push",
                                                   @"element_from": @"be_null",
                                                   @"rank": @"be_null",
                                                   @"card_type": @"be_null",
                                                   @"origin_from": @"push",
                                                   @"origin_search_id": @"be_null"
//                                                   @"group_id": paramObj.allParams[@"group_id"],
                                                   }};
                id<FHHouseEnvContextBridge> envBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
                [envBridge setTraceValue:@"push" forKey:@"origin_from"];
                [envBridge setTraceValue:@"be_null" forKey:@"origin_search_id"];
                
                TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
                [[TTRoute sharedRoute] openURLByPushViewController:openURL userInfo:userInfo];
            }
            
        });
    } willHideBlock:nil didHideBlock:^(NSInteger hideReason) {

    }];
}

+(BOOL)f100ContentHasGroupId:(NSDictionary*)userInfo {
    NSArray* allKeys = [userInfo allKeys];
    return [allKeys containsObject:@"neighborhood_id"] ||
    [allKeys containsObject:@"court_id"] ||
    [allKeys containsObject:@"house_id"];
}

+(NSString*)f100ContentGroupId:(NSDictionary*)userInfo {
    NSArray* allKeys = [userInfo allKeys];
    if ([allKeys containsObject:@"neighborhood_id"]) {
        return userInfo[@"neighborhood_id"];
    } else if ([allKeys containsObject:@"court_id"]) {
        return userInfo[@"court_id"];
    } else if ([allKeys containsObject:@"house_id"]) {
        return userInfo[@"house_id"];
    }
    return @"be_null";
}

//+ (BOOL)inRemoteNotificationOnAppActiveSFBlackList:(NSURL *)url
//{
//    TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:url];
//    if ([paramObj hasRouteAction]) {
//        // 先监测是否为route action
//        NSString *actionValue = [paramObj routeActionIdentifier];
//        if ([actionValue isEqualToString:@"activity_tab"]) {
//            return YES;
//        }
//    }
//    
//    return NO;
//}

#pragma mark private

- (BOOL)_hasReadOfArticle:(NSString *)articleSchemaString
{
    //判断推送的文章是否已经读过
    
    BOOL hasRead = NO;
    
    NSURL *schemaURL = [TTStringHelper URLWithURLString:articleSchemaString];
    if ([[TTRoute sharedRoute] canOpenURL:schemaURL]){
        
        TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:schemaURL];
        
        NSString *groupIdString = nil;
        NSString *itemID = nil;
        if (paramObj.queryParams) {
            NSDictionary *paramsKeyDictionary = paramObj.queryParams;
            if ([[paramsKeyDictionary allKeys] containsObject:@"groupid"]) {
                groupIdString = [paramsKeyDictionary objectForKey:@"groupid"];
            }
            itemID = [paramsKeyDictionary objectForKey:@"item_id"];
        }
        
        NSNumber *groupIdNumber = [NSNumber numberWithLongLong:[groupIdString longLongValue]];
        NSNumber *fixedgroupID  = [SSCommonLogic fixNumberTypeGroupID:groupIdNumber];
        NSString *fixedgroupIDString = [NSString stringWithFormat:@"%@", fixedgroupID];
        
        NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:2];
        [query setValue:fixedgroupIDString forKey:@"uniqueID"];
        [query setValue:itemID forKey:@"itemID"];
        NSArray *fetchResult = [Article objectsWithQuery:query];
        if ([fetchResult count] > 0) {
            for (id entity in fetchResult) {
                if ([entity isKindOfClass:[ExploreOriginalData class]]) {
                    ExploreOriginalData *originalData = (ExploreOriginalData *)entity;
                    if ([[originalData hasRead] boolValue]) {
                        hasRead = YES;
                        break;
                    }
                }
            }
        }
    }
    return hasRead;
}

@end
