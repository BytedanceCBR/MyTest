//
//  TTAppLinkManager.m
//  Article
//
//  Created by muhuai on 16/7/21.
//
//

#import "TTAppLinkManager.h"
#import "SSCommonLogic.h"
#import <TTBaseLib/JSONAdditions.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/TTURLUtils.h>
#import <TTRoute/TTRoute.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import "SSViewControllerBase.h"

NSString *const kAppLinkHost = @"applink";
NSString *const kAppLinkBackFlow = @"/app_back_flow";
NSString *const kAppLinkAdSourceTag = @"ad_source";
NSString *const kAppLinkChannel = @"channel";
NSString *const kAppLinkAdID = @"adid";
NSString *const kAppLinkExtraDic = @"extraDic";
NSString *const kAppLinkBackURLPlaceHolder = @"__back_url__";

@interface TTAppLinkManager()

@property (nonatomic, strong) NSArray<NSString *> *whiteList;

// 广告打开第三方app时，返回主端 需要用到的回调信息
@property (nonatomic, copy) NSString *currentADID;
@property (nonatomic, copy) NSMutableDictionary *linkCompleteBlockDic;

@end

@implementation TTAppLinkManager

+ (instancetype)sharedInstance {
    static TTAppLinkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTAppLinkManager alloc] init];
        manager.whiteList = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"LSApplicationQueriesSchemes"];
    });
    return manager;
}

- (BOOL)containsScheme:(NSString *)scheme {
    return !isEmptyString(scheme) && [self.whiteList containsObject:scheme];
}

- (BOOL)handOpenURL:(NSURL *)url {
    if (!url || isEmptyString(url.scheme) || isEmptyString(url.host)) {
        return NO;
    }
    //清空applinkManager 的 currentADID
    [TTAppLinkManager sharedInstance].currentADID = nil;
    
    if ([[TTSandBoxHelper ssAppScheme] rangeOfString:url.scheme].location != NSNotFound && [url.host isEqualToString:kAppLinkHost]) {
        
        //执行广告回调
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([url.path isEqualToString:kAppLinkBackFlow]) {
                NSDictionary *query = [TTURLUtils queryItemsForURL:url];
                NSString *value = [query stringValueForKey:kAppLinkAdID defaultValue:nil];
                if ([[TTAppLinkManager sharedInstance].linkCompleteBlockDic valueForKey:value]) {
                    TTAppPageCompletionBlock completeBlock = [[TTAppLinkManager sharedInstance].linkCompleteBlockDic valueForKey:value];
                    if (completeBlock) {
                        completeBlock(self);
                    }
                    [[TTAppLinkManager sharedInstance].linkCompleteBlockDic removeObjectForKey:value];
                }
            }
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            if ([url.path isEqualToString:kAppLinkBackFlow]) {
                NSDictionary *query = [TTURLUtils queryItemsForURL:url];
                NSString *event = [query stringValueForKey:kAppLinkAdSourceTag defaultValue:nil];
                NSString *channel = [query stringValueForKey:kAppLinkChannel defaultValue:nil];
                NSString *value = [query stringValueForKey:kAppLinkAdID defaultValue:nil];
                NSString *extraDicStr = [query stringValueForKey:kAppLinkExtraDic defaultValue:nil];
                NSDictionary *extraDic = [extraDicStr tt_JSONValue];
                if ([channel isEqualToString:@"sdk"]) {
                    wrapperTrackEventWithCustomKeys(event, @"sdk_appback", value, nil, extraDic);
                } else if ([channel isEqualToString:@"open_url"]) {
                    wrapperTrackEventWithCustomKeys(event, @"open_url_appback", value, nil, extraDic);
                }
            }
        });
        return YES;
    }
    return NO;
}

+ (NSString *)_backURLWithSourceTag:(NSString *)tag channel:(NSString *)channel value:(NSString *)value extraDic:(NSDictionary *)extradic {
    if (isEmptyString(tag) || isEmptyString(channel) || isEmptyString(value)) {
        
        return [TTSandBoxHelper ssAppScheme];
    }
    NSMutableDictionary *queryItems = [[NSMutableDictionary alloc] initWithDictionary:@{kAppLinkAdSourceTag: tag,
                                                                                        kAppLinkChannel: channel,
                                                                                        kAppLinkAdID: value}];
    [queryItems setValue:[extradic tt_JSONRepresentation] forKey:kAppLinkExtraDic];
    NSURL *backURL = [TTURLUtils URLWithString:[[TTSandBoxHelper ssAppScheme] stringByAppendingFormat:@"%@%@", kAppLinkHost, kAppLinkBackFlow] queryItems:queryItems];
    return backURL.absoluteString;
}

+ (NSString *)escapesBackURL:(NSString *)sourceTag value:(NSString *)value extraDic:(NSDictionary *)extraDic {
    return  [TTURLUtils queryItemAddingPercentEscapes:[self _backURLWithSourceTag:sourceTag channel:@"open_url" value:value extraDic:extraDic]];
}

- (void)linkCompleleBlockDicSetValue:(id)value forKey:(NSString *)key{
    if (!_linkCompleteBlockDic) {
        _linkCompleteBlockDic = [NSMutableDictionary dictionary];
    }
    [_linkCompleteBlockDic setValue:value forKey:key];
}
@end

@implementation TTAppLinkManager (AD)

+ (BOOL)dealWithWebURL:(NSString *)webURLStr openURL:(NSString *)openURLStr sourceTag:(NSString *)sourceTag value:(NSString *)value extraDic:(NSDictionary *)extraDic {
    if (isEmptyString(webURLStr) && isEmptyString(openURLStr)) {
        return NO;
    }
    if (value && [extraDic valueForKey:value]) {
        [TTAppLinkManager sharedInstance].currentADID = value;
        NSMutableDictionary *extraMutDic = [[NSMutableDictionary alloc] initWithDictionary:extraDic];
        [[TTAppLinkManager sharedInstance] linkCompleleBlockDicSetValue:extraMutDic[value] forKey:value];
        [extraMutDic removeObjectForKey:value];
        extraDic = [extraMutDic copy];
    }
    NSString *escapesBackURL = [TTURLUtils queryItemAddingPercentEscapes:[self _backURLWithSourceTag:sourceTag channel:@"open_url" value:value extraDic:extraDic]];
    NSURL *webURL = [NSURL URLWithString:webURLStr];
    NSURL *openURL = [NSURL URLWithString:[openURLStr stringByReplacingOccurrencesOfString:kAppLinkBackURLPlaceHolder withString:escapesBackURL]];
    
    //🐶东和淘宝走SDK,所以只需weburl
    BOOL result = NO;
    
    if (!result) {
        result = [self _dealCommonWithOpenURL:openURL sourceTag:sourceTag value:value extrDic:extraDic];
    }
    
    //如果result是否，则说明没有通过第三方SDK打开，移除回调 和 currentADID
    if (!result) {
        if ([[TTAppLinkManager sharedInstance].linkCompleteBlockDic valueForKey:value]) {
            [[TTAppLinkManager sharedInstance].linkCompleteBlockDic removeObjectForKey:value];
        }
        [TTAppLinkManager sharedInstance].currentADID = nil;
    }
    
    return result;
}

+ (BOOL)_dealCommonWithOpenURL:(NSURL *)openURL sourceTag:(NSString *)sourceTag value:(NSString *)value extrDic:(NSDictionary *)extraDic {
    //如果自身app可以处理 向上抛
    if (!openURL || [[TTRoute sharedRoute] canOpenURL:openURL]) {
        return NO;
    }
    BOOL result = [[UIApplication sharedApplication] openURL:openURL];
    if (result) {
        wrapperTrackEventWithCustomKeys(sourceTag, @"open_url_app", value, nil, extraDic);
    }
    return result;
}

@end
