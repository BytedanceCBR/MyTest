//
//  TTRNavi.m
//  Article
//
//  Created by muhuai on 2017/5/21.
//
//

#import "TTRNavi.h"
#import <TTAccountBusiness.h>
#import <TTBaseLib/TTURLUtils.h>
#import <TTRoute/TTRoute.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import <FHEnvContext.h>
#import <TTAccountSDK.h>

@implementation TTRNavi

TTR_PROTECTED_HANDLER(@"TTRNavi.open", @"TTRNavi.openHotsoon")

- (void)closeWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    UIViewController *topVC = [TTUIResponderHelper topViewControllerFor:webview];
    
    //close page回传上一个bVC
    if (controller.navigationController.viewControllers.count >= 2) {
        UIViewController *previousVC = controller.navigationController.viewControllers[controller.navigationController.viewControllers.count - 2];
        NSMutableDictionary * resultDict = [NSMutableDictionary new];
        [resultDict setValue:param forKey:@"data"];
        if ([previousVC respondsToSelector:@selector(getOpenPageTagStr)]) {
            NSString *tagStr = [previousVC performSelector:@selector(getOpenPageTagStr) withObject:nil];
            [resultDict setValue:tagStr  forKey:@"tag"];
        }

        if ([previousVC respondsToSelector:@selector(setupCloseCallBackPreviousVC:)]) {
            [previousVC performSelector:@selector(setupCloseCallBackPreviousVC:) withObject:resultDict];
        }
    }

    
//    for (int i = 0; i < controller.navigationController.viewControllers.count; i++) {
//
//    }

    __block __strong __typeof(webview)strongWebview = webview;
        if(topVC.navigationController) {
            [topVC.navigationController popViewControllerAnimated:YES];
            callback(TTRJSBMsgSuccess, @{@"code": @0});
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                strongWebview = nil;
            });
        } else {
            [topVC dismissViewControllerAnimated:YES completion:^{
                callback(TTRJSBMsgSuccess, @{@"code": @0});
                strongWebview = nil;
            }];
        }
    callback(TTRJSBMsgSuccess, @{@"code": @1});
}

- (void)openPageWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller
{
    if ([controller respondsToSelector:@selector(setupOpenPageTagStr:)] && param[@"tag"]) {
        [controller performSelector:@selector(setupOpenPageTagStr:) withObject:param[@"tag"]];
    }
    NSString * urlStr = [param objectForKey:@"route"];
    NSNumber * closeStack = [param objectForKey:@"closeStack"];

    if (!closeStack) {
        closeStack = @(0);
    }
    
    if ([urlStr containsString:@"?"]) {
        urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"&closeStack=%ld",[closeStack integerValue]]];
    }else
    {
        urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"?&closeStack=%ld",[closeStack integerValue]]];
    }
    

    if (!isEmptyString(urlStr)) {
        
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:urlStr]];
        
        if ([closeStack isKindOfClass:[NSNumber class]] && ![closeStack isEqualToNumber:@(0)]) {
            [self setUpVCCloseStack:[closeStack integerValue] andController:controller];
        }
     
        callback(TTRJSBMsgSuccess, @{@"code": @1});
        return;
    }
}

- (void)setUpVCCloseStack:(NSInteger)closeStackCouuntResult andController:(UIViewController *)controller
{
    NSMutableArray *vcStack = [NSMutableArray arrayWithArray:controller.navigationController.viewControllers];
    
    if (closeStackCouuntResult == 0) {
        
    }else
    {
        if (vcStack.count > closeStackCouuntResult + 2) {
            NSInteger retainVCs = vcStack.count - closeStackCouuntResult - 2;
            if (retainVCs <= 0) {
                controller.navigationController.viewControllers = [NSArray arrayWithObjects:vcStack.firstObject,vcStack.lastObject,nil];
            }else
            {
                NSMutableArray *viewControllersArray = [NSMutableArray new];
                [viewControllersArray addObject:vcStack.firstObject];
                
                for (int i = 0; i < retainVCs; i++) {
                    if (vcStack.count > i) {
                        [viewControllersArray addObject:vcStack[i + 1]];
                    }
                }
                [viewControllersArray addObject:vcStack.lastObject];
                controller.navigationController.viewControllers = viewControllersArray;
            }
        }else
        {
            controller.navigationController.viewControllers = [NSArray arrayWithObjects:vcStack.firstObject,vcStack.lastObject,nil];
        }
    }
}

- (void)openWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSMutableString * openURL = nil;
    NSString * type = [param objectForKey:@"type"];
    if ([type isEqualToString:@"detail"]) {
        NSString * groupID = [[param objectForKey:@"args"] objectForKey:@"groupid"];
        if ([groupID longLongValue] != 0) {
            openURL = [NSMutableString stringWithFormat:@"sslocal://detail?groupid=%@", groupID];
            NSString * gdLabel = [[param objectForKey:@"args"] objectForKey:@"gd_label"];
            if (!isEmptyString(gdLabel)) {
                [openURL appendFormat:@"&gd_label=%@", gdLabel];
            }
            id itemID = [[param objectForKey:@"args"] objectForKey:@"item_id"];
            if (itemID) {
                [openURL appendFormat:@"&item_id=%@", itemID];
                id aggrType = [[param objectForKey:@"args"] objectForKey:@"aggr_type"];
                if (aggrType) {
                    [openURL appendFormat:@"&aggr_type=%@", aggrType];
                }
            }
        }
    }
    else if([type isEqualToString:@"webview"]) {
        NSString * urlStr = [[param objectForKey:@"args"] objectForKey:@"url"];
        if (!isEmptyString(urlStr)) {
            openURL = [NSMutableString stringWithFormat:@"sslocal://webview?url=%@", urlStr];
            BOOL rotate = [[[param objectForKey:@"args"] objectForKey:@"rotate"] boolValue];
            if (rotate) {
                [openURL appendString:@"&supportRotate=1"];
            }
        }
    }
    else if([type isEqualToString:@"media_account"]) {
        NSString * entryID = [[param objectForKey:@"args"] objectForKey:@"entry_id"];
        if ([entryID longLongValue] != 0) {
            openURL = [NSMutableString stringWithFormat:@"sslocal://media_account?mediaID=%@", entryID];
        }
    }
    else if([type isEqualToString:@"profile"]) {
        NSString * uid = [[param objectForKey:@"args"] objectForKey:@"uid"];
        if ([uid longLongValue] != 0) {
            openURL = [NSMutableString stringWithFormat:@"sslocal://profile?uid=%@", uid];
        }
    }
    else if([type isEqualToString:@"feedback"] && ![TTDeviceHelper isPadDevice]) {
        openURL = [NSMutableString stringWithString:@"sslocal://feedback"];;
    }
    else if([type isEqualToString:@"home/news"]) {
        // 切到tab
        NSString *tabKey = [[param objectForKey:@"args"] objectForKey:@"default_tab"];
        if (isEmptyString(tabKey)) {
            tabKey = @"tab_stream";
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TTArticleTabBarControllerChangeSelectedIndexNotification" object:nil userInfo:@{@"tag":tabKey}];
    }
    
    if (!isEmptyString(openURL)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openURL]];
        callback(TTRJSBMsgSuccess, @{@"code": @1});
        return;
    }
    
    callback(TTRJSBMsgParamError, @{@"code": @0});
}

- (void)openHotsoonWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *type = [param tt_stringValueForKey:@"type"];
    NSString *schema = nil;
    
    // 打开直播间
    if ([type isEqualToString:@"room"]) {
        schema = @"sslocal://huoshan";
    }
    // 充值
    else if ([type isEqualToString:@"charge"]) {
        if ([TTAccountManager isLogin]) {
            schema = @"sslocal://huoshancharge";
        } else {
            schema = @"sslocal://login";
        }
    }
    
    if (!isEmptyString(schema)) {
        NSDictionary *args = [param tt_dictionaryValueForKey:@"args"];
        NSURL *url = [TTURLUtils URLWithString:schema queryItems:args];
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            [[TTRoute sharedRoute] openURLByPushViewController:url];
            callback(TTRJSBMsgSuccess, @{@"code": @1});
            return;
        }
    }
    
    callback(TTRJSBMsgFailed, @{@"code": @0});
}

- (void)openAppWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *urlStr = [param tt_stringValueForKey:@"url"];
    if (isEmptyString(urlStr)) {
        TTR_CALLBACK_WITH_MSG(TTRJSBMsgParamError, @"url为空")
        return;
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    if (!url) {
        TTR_CALLBACK_WITH_MSG(TTRJSBMsgParamError, @"url不合法")
        return;
    }
    BOOL success = [[UIApplication sharedApplication] openURL:url];
    if (success) {
        TTR_CALLBACK_SUCCESS
        return;
    } else {
        TTR_CALLBACK_WITH_MSG(TTRJSBMsgFailed, @"请检查scheme是否正确, 或者找客户端开scheme白名单")
        return;
    }
}

// 禁用滑动返回
- (void)disableDragBackWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    BOOL disable = [param tt_boolValueForKey:@"disable"];
    controller.ttDisableDragBack = disable;
    TTR_CALLBACK_SUCCESS
}

- (void)handleNavBackWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller
{
    NSNumber *numberH5 = param[@"h5"];
    NSNumber *numberShowClose = param[@"showClose"];

    BOOL isWebControl = NO;
    if ([numberH5 respondsToSelector:@selector(boolValue)]) {
        isWebControl = [numberH5 boolValue];
    }
    
    BOOL isShowCloseBtn= YES;
    if ([numberShowClose respondsToSelector:@selector(boolValue)]) {
        isShowCloseBtn = [numberShowClose boolValue];
    }
    
    if ([controller respondsToSelector:@selector(setUpBackBtnControlForWeb:)]) {
        [controller performSelector:@selector(setUpBackBtnControlForWeb:) withObject:@(isWebControl)];
    }
    if ([controller respondsToSelector:@selector(setUpCloseBtnControlForWeb:)]) {
        [controller performSelector:@selector(setUpCloseBtnControlForWeb:) withObject:@(isShowCloseBtn)];
    }
    
//    controller.ttDisableDragBack = NO;
}

- (void)setNativeTitleWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller
{
    if(param[@"title"]){
        NSString *title = param[@"title"];
        if ([controller respondsToSelector:@selector(setTitleText:)]) {
            [controller performSelector:@selector(setTitleText:) withObject:title];
        }
    }
}

- (void)setNativeDividerVisibleWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller
{
    if(param[@"isVisible"]){
        BOOL isVisible = [param[@"isVisible"] boolValue];
        controller.ttNeedHideBottomLine = !isVisible;
    }
}

- (void)onAccountCancellationSuccessWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller
{
    NSString *cityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    
    if ([cityId isKindOfClass:[NSString class]] && cityId.length > 0) {
        NSString *url = [NSString stringWithFormat:@"fschema://fhomepage?city_id=%@",cityId];
        // 退出登录
        [TTAccount logout:^(BOOL success, NSError * _Nullable error) {
            
        }];
        [FHEnvContext openLogoutSuccessURL:url completion:^(BOOL isSuccess) {
        
        }];
    }
}

@end
