//
//  SSAppStore.m
//  Article
//
//  Created by Zhang Leonardo on 12-11-30.
//
//

#import "SSAppStore.h"
#import <StoreKit/StoreKit.h>
#import <TTUIWidget/TTIndicatorView.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTThemed/UIImage+TTThemeExtension.h>
#import <TTUIWidget/TTIndicatorView.h>
#import <TTBaselib/TTStringHelper.h>
#import <TTThemed/UIImage+TTThemeExtension.h>
#import <StoreKit/StoreKit.h>
#import <TTBaseLib/TTBaseMacro.h>


NSString * const SKStoreProductViewDidAppearKey = @"SKStoreProductViewDidAppearKey";
NSString * const SKStoreProductViewDidDisappearKey = @"SKStoreProductViewDidDisappearKey";
NSString * const SKStoreProductViewWillDisappearKey = @"SKStoreProductViewWillDisappearKey";

@interface SSAppStore()<SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray* serviceArray;

@end

@implementation SSAppStore

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static SSAppStore * store;
    dispatch_once(&onceToken, ^{
        store = [[SSAppStore alloc] init];
        store.serviceArray = [[NSMutableArray alloc] init];
    });
    return store;
}

- (void)openAppStoreByActionURL:(NSString *)actionURL itunesID:(NSString *)appleID presentController:(UIViewController *)controller
{
    [self openAppStoreByActionURL:actionURL itunesID:appleID presentController:controller appName:@""];
}

- (void)openAppStoreByActionURL:(NSString *)actionURL itunesID:(NSString *)appleID presentController:(UIViewController *)controller appName:(NSString *)appName
{
    appleID = [NSString stringWithFormat:@"%@", appleID];
    if (([appleID length] == 0 && [actionURL length] > 0)) {
        if ([actionURL length] == 0) {
            return;
        }
        NSURL * url = [TTStringHelper URLWithURLString:actionURL];

        [[UIApplication sharedApplication] openURL:url];
    }
    else if([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0f){// IOS 6.0 +
        
        if ([appleID length] > 0 && controller != nil) {
            
            //走下载广告预加载逻辑
            if ([self canBeHacked]) {
                if ([self tt_openAppStoreAppleID:appleID controller:controller] == YES) {
                    return;
                }
            }
            
            SKStoreProductViewController * skController = [[SKStoreProductViewController alloc] init];
            skController.delegate = self;
            NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:appleID, SKStoreProductParameterITunesItemIdentifier, nil];
            [skController loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {

                if (error && error.code != 0) {
                    NSString *message = @"";
                    if (isEmptyString(appName)) {
                        message = NSLocalizedString(@"下载失败, 请稍后重试", nil);
                    }
                    else {
                        message = [NSString stringWithFormat:NSLocalizedString(@"下载%@失败, 请稍后重试", nil), appName];
                    }
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:message indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                } else {
                }
                [self tt_appStoreLoad:result error:error appleId:appleID];
            }];
            
            if ([controller isKindOfClass:[UINavigationController class]]) {
                [controller presentViewController:skController animated:YES completion:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:SKStoreProductViewDidAppearKey object:skController];
                }];
            }
            else if (!controller.navigationController) {
                [controller presentViewController:skController animated:YES completion:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:SKStoreProductViewDidAppearKey object:skController];
                }];
            }
            else {
                [controller.navigationController presentViewController:skController animated:YES completion:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:SKStoreProductViewDidAppearKey object:skController];
                }];
            }
            
        }
    }
}

#pragma mark -- SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SKStoreProductViewWillDisappearKey object:viewController];
    [viewController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SKStoreProductViewDidDisappearKey object:viewController];
        [self tt_appStoreDidDisAppear:viewController];
    }];
}

- (void)tt_appStoreLoad:(BOOL)result error:(NSError *)error appleId:(NSString*)appleId
{
    [self.serviceArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj conformsToProtocol:@protocol(TTAppStoreProtocol)]) {
            if ([obj respondsToSelector:@selector(appStoreLoad:error:appleId:)]) {
                [obj appStoreLoad:result error:error appleId:appleId];
            }
        }
    }];
}

- (void)tt_appStoreDidAppear:(UIViewController *)viewController
{
    [self.serviceArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj conformsToProtocol:@protocol(TTAppStoreProtocol)]) {
            if ([obj respondsToSelector:@selector(appStoreDidAppear:)]) {
                [obj appStoreDidAppear:viewController];
            }
        }
    }];
}

- (void)tt_appStoreDidDisAppear:(UIViewController *)viewController
{
    [self.serviceArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj conformsToProtocol:@protocol(TTAppStoreProtocol)]) {
            if ([obj respondsToSelector:@selector(appStoreDidDisappear:)]) {
                [obj appStoreDidDisappear:viewController];
            }
        }
    }];
}

- (BOOL)tt_openAppStoreAppleID:(NSString*)appleID controller:(UIViewController*)controller
{
    __block BOOL canHack = NO;
    [self.serviceArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj conformsToProtocol:@protocol(TTAppStoreProtocol)]) {
            if ([obj respondsToSelector:@selector(openAppStoreAppleID:controller:)]) {
                canHack = [obj openAppStoreAppleID:appleID controller:controller];
            }
        }
    }];
    return canHack;
}

- (BOOL)canBeHacked
{
    __block BOOL canHack = NO;
    [self.serviceArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj conformsToProtocol:@protocol(TTAppStoreProtocol)]) {
            if ([obj respondsToSelector:@selector(openAppStoreAppleID:controller:)]) {
                canHack = YES;
            }
        }
    }];
    return canHack;
}



- (BOOL)registerService:(id<TTAppStoreProtocol>)service
{
    if (service && [service conformsToProtocol:@protocol(TTAppStoreProtocol)]) {
        [self.serviceArray addObject:service];
        return YES;
    }
    return NO;
}

- (BOOL)unregisterService:(id<TTAppStoreProtocol>)service
{
    if (service && [service conformsToProtocol:@protocol(TTAppStoreProtocol)]) {
        if ([self.serviceArray containsObject:service]) {
            [self.serviceArray removeObject:service];
        }
        return YES;
    }
    return NO;
}


@end
