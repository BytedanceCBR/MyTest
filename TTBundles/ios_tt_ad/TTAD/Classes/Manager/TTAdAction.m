//
//  TTAdAction.m
//  Article
//
//  Created by yin on 2017/7/27.
//
//

#import "TTAdAction.h"
#import "TTAppLinkManager.h"
#import "TTRoute.h"
#import "TTUIResponderHelper.h"
#import "TTAdAppDownloadManager.h"
#import "TTAdCallManager.h"
#import "TTIndicatorView.h"
#import "TTAdMonitorManager.h"
#import "TTURLUtils.h"
#import "TTAdDetailActionModel.h"
@implementation TTAdAction

+ (BOOL)handleDownloadApp:(id<TTAd, TTAdAppAction>)model
{
    return [TTAdAppDownloadManager downloadApp:model];
}

+ (BOOL)handleCallActionModel:(id<TTAdPhoneAction>)model
{
    return [TTAdCallManager callWithModel:model];
}

+ (BOOL)handleFormActionModel:(id<TTAdFormAction>)model fromSource:(TTAdApointFromSource)fromSource completeBlock:(TTAdApointCompleteBlock)block{

    return [[TTAdFormHandler sharedInstance] handleFormModel:model fromSource:fromSource completeBlock:block];
}

+ (BOOL)handleDetailActionModel:(id<TTAdDetailAction, TTAd>)model sourceTag:(NSString *)tag
{
    return [self handleDetailActionModel:model sourceTag:tag completeBlock:nil];
}

+ (BOOL)handleDetailActionModel:(id<TTAdDetailAction,TTAd>)model sourceTag:(NSString *)tag completeBlock:(TTAppPageCompletionBlock)completeBlock
{
    if (![model conformsToProtocol:@protocol(TTAdDetailAction)]) {
        return NO;
    }
    if (isEmptyString(model.web_url) && isEmptyString(model.open_url)) {
        return NO;
    }
    NSMutableDictionary *applinkTrackDic = [NSMutableDictionary dictionary];
    [applinkTrackDic setValue:model.log_extra forKey:@"log_extra"];
    if (completeBlock) {
        NSString *adCompleteBlockKey = [NSString stringWithFormat:@"%@",model.ad_id];
        [applinkTrackDic setValue:[completeBlock copy] forKey:adCompleteBlockKey];
    }
    BOOL canOpenApp = [TTAppLinkManager dealWithWebURL:model.web_url openURL:model.open_url sourceTag:tag value:model.ad_id extraDic:applinkTrackDic];
    if (!canOpenApp && !isEmptyString(model.open_url)) {
        NSURL *url = [NSURL URLWithString:model.open_url];
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            NSMutableDictionary* paramDict = [NSMutableDictionary dictionary];
            [paramDict setValue:model.log_extra forKey:@"log_extra"];
            [paramDict setValue:model.ad_id forKey:@"ad_id"];
            if (completeBlock) {
                paramDict[@"completion_block"] = [completeBlock copy];
            }
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(paramDict)];
            canOpenApp = YES;
        }
    }
    
    if (!canOpenApp && !isEmptyString(model.web_url)) {
        NSMutableString *webUrlString = [NSMutableString stringWithString:model.web_url];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:webUrlString forKey:@"url"];
        [params setValue:model.web_title forKey:@"title"];
        [params setValue:model.ad_id forKey:@"ad_id"];
        [params setValue:model.log_extra forKey:@"log_extra"];
        if (completeBlock) {
            params[@"completion_block"] = [completeBlock copy];
        }
        NSURL *schema = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:@{ @"url" : webUrlString}];
        if ([[TTRoute sharedRoute] canOpenURL:schema]) {
            [[TTRoute sharedRoute] openURLByPushViewController:schema userInfo:TTRouteUserInfoWithDict(params)];
        }
        canOpenApp = YES;
    }
    return canOpenApp;
}

+ (BOOL)handleWebActionModel:(id<TTAdDetailAction,TTAd>)model
{
    if (isEmptyString(model.web_url)) {
        return NO;
    }
    NSMutableString *webUrlString = [NSMutableString stringWithString:model.web_url];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:webUrlString forKey:@"url"];
    [params setValue:model.web_title forKey:@"title"];
    [params setValue:model.ad_id forKey:@"ad_id"];
    [params setValue:model.log_extra forKey:@"log_extra"];
    if ([model isKindOfClass:[TTAdDetailActionModel class]]) {
        [params addEntriesFromDictionary:((TTAdDetailActionModel *)model).extraDict];
    }
    NSURL *schema = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:@{ @"url" : webUrlString}];
    if ([[TTRoute sharedRoute] canOpenURL:schema]) {
        [[TTRoute sharedRoute] openURLByPushViewController:schema userInfo:TTRouteUserInfoWithDict(params)];
        return YES;
    }
    return NO;
}

@end
