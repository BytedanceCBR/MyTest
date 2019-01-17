//
//  TTAuthorizeLocationObj.m
//  Article
//
//  Created by Chen Hong on 15/4/15.
//
//

#import "TTAuthorizeLocationObj.h"
#import <CoreLocation/CoreLocation.h>
#import "TTTracker.h"
#import "TTSandBoxHelper.h"
//
//#import "TTFetchGuideSettingManager.h"


@import ObjectiveC;
/*
 1、点击取消，弹窗关闭。
 2、点击开启，请求系统定位权限。
 
 **iOS,如之前已关闭权限，点击开启后弹窗提示:
 iOS8以上版本:「开启定位失败，请去设置项允许爱看获取您的位置」，展示「取消/去设置」选项
 iOS8以下版本:「开启定位失败，请去 设置-隐私-定位服务 内开启爱看访问权限」
 */

@interface TTAuthorizeLocationObj ()

//保存下一步要提示的弹窗
@property (nonatomic,strong) TTAuthorizeHintView * hintView;

@end

@implementation TTAuthorizeLocationObj {
    
}

- (void)showAlertAtLocalCategory:(TTThemedAlertActionBlock)completionBlock authCompleteBlock:(TTAuthorizeLocationAuthCompleteBlock)authCompleteBlock sysAuthFlag:(NSInteger)flag {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        if (flag == 0 && authCompleteBlock) {
            TTAuthorizeLocationArrayParamBlock paramBlock = ^(NSArray *placemarks){};
            authCompleteBlock(paramBlock);
            [self updateShowTime];
        }
//        if([TTFetchGuideSettingManager sharedInstance_tt].systemAuthorizationFlag == 0){
//            //连续弹窗
//            [[TTLocationManager sharedManager] regeocodeWithCompletionHandlerAfterAuthorization:^(NSArray *placemarks) {
//                
//                        }];
//            [self updateShowTime];
//        }
        else{
            //自有弹窗
            if([self _isAuthorizeHintEnabled]){
                [self _showCustomAuthorizeHintViewWithCompletionHander:nil authCompleteBlock:authCompleteBlock];
            }
        }
        return;
    }
    
    if (self.authorizeModel.lastTimeShowLocation == 0) {
        [self updateShowTime];
        return;
    }
    
    if (![self isEnabled])
        return;
    
    if (self.authorizeModel.showLocationTimesLocalCategory >= self.authorizeModel.showLocationMaxTimesLocalCategory)
        return;
    
    self.authorizeModel.showLocationTimesLocalCategory += 1;

    [self updateShowTime];
    
    if (status == kCLAuthorizationStatusDenied) {
        BOOL canOpenSettings = &UIApplicationOpenSettingsURLString != NULL;
        
        if (canOpenSettings) {
            ttTrackEvent(@"pop", @"locate_local_limit_choose");
        } else {
            ttTrackEvent(@"pop", @"locate_local_limit_show");
        }
        
        NSString *message = canOpenSettings ? @"智能推荐当前城市资讯，去设置中允许幸福里定位" : @"智能推荐当前城市资讯，请去 设置-隐私-定位服务 内开启幸福里访问权限";
        NSString *okBtnTitle = canOpenSettings ? @"去设置" : @"我知道了";
        
        _hintView = [self authorizeHintViewWithTitle:@"开启定位" message:message imageName:@"img_popup_locate" okButtonTitle:okBtnTitle okBlock:^{
            if (canOpenSettings) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
                ttTrackEvent(@"pop", @"locate_local_limit_set");
            }
            [[TTGuideDispatchManager sharedInstance_tt] removeGuideViewItem:self];
        } cancelBlock:^{
            if (canOpenSettings) {
                ttTrackEvent(@"pop", @"locate_local_limit_cancel");
            }
            [[TTGuideDispatchManager sharedInstance_tt] removeGuideViewItem:self];
        }];
        [[TTGuideDispatchManager sharedInstance_tt] addGuideViewItem:self withContext:nil];
    }
}

- (TTAuthorizeHintView *)showAlertWhenLocationChanged:(TTThemedAlertActionBlock)completionBlock authCompleteBlock:(TTAuthorizeLocationAuthCompleteBlock)authCompleteBlock sysAuthFlag:(NSInteger)flag {
    // 判断条件放在外部调用处
    self.authorizeModel.showLocationTimesLocationChanged += 1;
    
    [self updateShowTime];
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        if (flag == 0 && authCompleteBlock) {
            TTAuthorizeLocationArrayParamBlock paramBlock = ^(NSArray *placemarks){};
            authCompleteBlock(paramBlock);
            [self updateShowTime];
        }
//        if([TTFetchGuideSettingManager sharedInstance_tt].systemAuthorizationFlag == 0){
//            //连续弹窗
//            [[TTLocationManager sharedManager] regeocodeWithCompletionHandlerAfterAuthorization:^(NSArray *placemarks) {
//                
//            }];
//            [self updateShowTime];
//        }
        else{
            //自有弹窗
            if([self _isAuthorizeHintEnabled]){
                [self _showCustomAuthorizeHintViewWithCompletionHander:nil authCompleteBlock:authCompleteBlock];
            }
        }
        return nil;
    }
    else if (status == kCLAuthorizationStatusRestricted ||
             status == kCLAuthorizationStatusDenied) {
        BOOL canOpenSettings = &UIApplicationOpenSettingsURLString != NULL;
        
        if (canOpenSettings) {
            ttTrackEvent(@"pop", @"locate_change_city_limit_choose");
        } else {
            ttTrackEvent(@"pop", @"locate_change_city_limit_show");
        }
        
        NSString *message = canOpenSettings ? @"开启定位失败，请去设置项允许幸福里获取您的位置" : @"开启定位失败，请去 设置-隐私-定位服务 内开启幸福里访问权限";
        NSString *okBtnTitle = canOpenSettings ? @"去设置" : @"我知道了";
        
        _hintView = [self authorizeHintViewWithTitle:@"开启定位" message:message imageName:@"img_popup_locate" okButtonTitle:okBtnTitle okBlock:^{
            if (canOpenSettings) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
                ttTrackEvent(@"pop", @"locate_change_city_limit_set");
            }
            if (completionBlock) {
                completionBlock();
            }
            [[TTGuideDispatchManager sharedInstance_tt]removeGuideViewItem:self];
        } cancelBlock:^{
            if (canOpenSettings) {
                ttTrackEvent(@"pop", @"locate_change_city_limit_cancel");
            }
            if (completionBlock) {
                completionBlock();
            }
            [[TTGuideDispatchManager sharedInstance_tt]removeGuideViewItem:self];
        }];
        [[TTGuideDispatchManager sharedInstance_tt]addGuideViewItem:self withContext:nil];
        return _hintView;
    }
    return nil;
}

- (BOOL)isEnabled {
    // 仅对未拒绝定位的用户生效
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status != kCLAuthorizationStatusDenied) {
        return NO;
    }
    
    // 距上次同类弹窗时间k天
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = now - self.authorizeModel.lastTimeShowLocation;
    if (interval < self.authorizeModel.showLocationTimeInterval) {
        return NO;
    }
    
    // 和其他类型弹窗间隔c天
    interval = now - [self.authorizeModel maxLastTimeExcept:self.authorizeModel.lastTimeShowLocation];
    if (interval < self.authorizeModel.showAlertInterval) {
        return NO;
    }
    
    return YES;
}

- (void)updateShowTime {
    self.authorizeModel.lastTimeShowLocation = (NSInteger)[[NSDate date] timeIntervalSince1970];
    [self.authorizeModel saveData];
}

- (void)updateFirstShowTimeIfNeeded {
    // 忽略首次
    if (self.authorizeModel.lastTimeShowLocation == 0) {
        [self updateShowTime];
        return;
    }
}

//通过非本地频道访问位置服务时
- (void)filterAuthorizeStrategyWithCompletionHandler:(void (^)(NSArray *))completionHandler authCompleteBlock:(TTAuthorizeLocationAuthCompleteBlock)authCompleteBlock sysAuthFlag:(NSInteger)flag {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined){
        if (flag == 0 && authCompleteBlock) {
            authCompleteBlock(completionHandler);
            [self updateShowTime];
        }
//        if ([TTFetchGuideSettingManager sharedInstance_tt].systemAuthorizationFlag == 0) {
//            //连续弹窗
//            [[TTLocationManager sharedManager] regeocodeWithCompletionHandlerAfterAuthorization:completionHandler];
//            [self updateShowTime];
//        }
        else{
            if ([TTSandBoxHelper appLaunchedTimes] >= 2 && [self _isAuthorizeHintEnabled]) {
                //显示自有授权框
                [self _showCustomAuthorizeHintViewWithCompletionHander:completionHandler authCompleteBlock:authCompleteBlock];
            }
            else {
                if(completionHandler){
                    completionHandler(nil);
                }
            }

        }
    }
    else{
        //走原来的流程
        if (authCompleteBlock) {
            authCompleteBlock(completionHandler);
        }
//        [[TTLocationManager sharedManager] regeocodeWithCompletionHandlerAfterAuthorization:completionHandler];
    }
}

//显示自有地理位置权限弹窗
- (void)_showCustomAuthorizeHintViewWithCompletionHander:(void (^)(NSArray *))completionHandler authCompleteBlock:(TTAuthorizeLocationAuthCompleteBlock)authCompleteBlock
{
    self.authorizeModel.lastTimeShowLocationAuthorizeHint = [[NSDate date] timeIntervalSince1970];
    self.authorizeModel.showLocationAuthorizeHintTimes += 1;
    [self.authorizeModel saveData];
    
    __weak typeof(self) wself = self;
    _hintView = [self authorizeHintViewWithTitle:@"开启定位" message:@"允许幸福里获取定位权限，智能推荐当前城市资讯" imageName:@"img_popup_locate" okButtonTitle:@"确定" okBlock:^{
        __strong typeof(wself) self = wself;
        ttTrackEvent(@"pop", @"location_permission_guide_confirm");
        if (authCompleteBlock) {
            authCompleteBlock(completionHandler);
        }
        //[[TTLocationManager sharedManager] regeocodeWithCompletionHandlerAfterAuthorization:completionHandler];
        [self updateShowTime];
        [[TTGuideDispatchManager sharedInstance_tt]removeGuideViewItem:self];
    } cancelBlock:^{
        ttTrackEvent(@"pop", @"location_permission_guide_cancel");
        if (completionHandler) {
            completionHandler(nil);
        }
        [[TTGuideDispatchManager sharedInstance_tt]removeGuideViewItem:self];
    }];
    
    [[TTGuideDispatchManager sharedInstance_tt] addGuideViewItem:self withContext:nil];
    ttTrackEvent(@"pop", @"location_permission_guide_show");
}

//根据时间和次数判断是否应该显示自有地理位置权限弹窗
- (BOOL)_isAuthorizeHintEnabled{
    // 距上次弹同类自有提示弹窗时间k天
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = now - self.authorizeModel.lastTimeShowLocationAuthorizeHint;
    if (interval < self.authorizeModel.showLocationTimeInterval) {
        return NO;
    }
    
    // 显示次数不超过最大次数
    if(self.authorizeModel.showLocationAuthorizeHintTimes >= self.authorizeModel.showLocationMaxTimesLocalCategory){
        return NO;
    }
    
    return YES;
}

#pragma mark -- TTGuideProtocol Method

- (BOOL)shouldDisplay:(id)context {
    return YES;
}

- (void)showWithContext:(id)context {
    [_hintView show];
}

- (id)context {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setContext:(id)context {
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
