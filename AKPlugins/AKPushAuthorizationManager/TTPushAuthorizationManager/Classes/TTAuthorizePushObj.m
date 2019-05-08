//
//  TTAuthorizePushObj.m
//  Article
//
//  Created by Chen Hong on 15/4/15.
//
//

#import "TTAuthorizePushObj.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import "TTURLDomainHelper.h"
#import "NSDictionary+TTAdditions.h"
#import "TTPushGuideSettings.h"
#import "TTThemeConst.h"
#import "TTThemeManager.h"
#import "TTTracker.h"

@import ObjectiveC;

/*
 1、点击取消，弹窗关闭。
 2、点击开启，开启推送权限。（iOS直接请求权限）
 
 
 距上次同类弹窗时间i天。
 最多弹j次。
 和其他类型弹窗间隔c天。
 
 **iOS，如之前已关闭权限，点击开启后弹窗提示：
 iOS8以上版本：「开启推送失败，请去设置项允许爱看推送通知」，展示「取消/去设置」选项
 iOS8以下版本：「开启推送失败，请去 设置-通知 内开启爱看访问权限」
 */

@interface TTAuthorizePushObj()

//保存下一步要提示的弹窗
@property (nonatomic,strong) TTAuthorizeHintView *hintView;

@end

@implementation TTAuthorizePushObj {
    
}

- (TTAuthorizeHintView *)authorizeHintViewWithTitle:(NSString *)title
                                            message:(NSString *)message
                                              image:(id)imageObject
                                      okButtonTitle:(NSString *)okButtonTitle
                                            okBlock:(void (^)())okBlock
                                        cancelBlock:(void (^)())cancelBlock
{
    return [[TTAuthorizeHintView alloc] initAuthorizeHintWithTitle:title message:message image:imageObject confirmBtnTitle:okButtonTitle animated:YES completed:^(TTAuthorizeHintCompleteType type) {
        
        if (type == TTAuthorizeHintCompleteTypeDone){
            if(okBlock){
                okBlock();
            }
        }
        else {
            if(cancelBlock){
                cancelBlock();
            }
        }
    }];
}

- (NSString *)pushSettingURL {
    NSString *domain = [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
    return [NSString stringWithFormat:@"%@/hint_info/open_push_settings/v1", domain];
}

- (void)showAlertAtActionFeedRefreshWithCompletion:(dispatch_block_t)completionHandler sysAuthFlag:(NSInteger)flag {
    void (^pushAuthorizeSettingBlock)() = ^{
        // 更新显示次数
        [self updatePushShowTimes];
        
        // 更新时间
        [self updateShowTime];
        
        //        [[TTNetworkManager shareInstance] requestForJSONWithURL:[self pushSettingURL] params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        //           if (!error && [jsonObj objectForKey:@"data"]) {
        //               NSDictionary *data = [jsonObj dictionaryValueForKey:@"data" defalutValue:nil];
        //               if ([data isKindOfClass:[NSDictionary class]]) {
        //                   NSString *desc = [data stringValueForKey:@"desc" defaultValue:nil];
        //                   if (!isEmptyString(desc)) {
        //                       self.authorizeModel.showPushHintText = desc;
        //                   }
        //               }
        //           }
        
        BOOL canOpenSettings = &UIApplicationOpenSettingsURLString != NULL;
        
        if (canOpenSettings) {
            ttTrackEvent(@"pop", @"push_feed_limit_choose");
        } else {
            ttTrackEvent(@"pop", @"push_feed_limit_show");
        }
        
        TTPushGuideDialogCategory category = [self.class categoryOfFiringPushGuideDlg:self.authorizeModel.pushFireReason];
        TTPushGuideSettingsModel *alertModel = [TTPushGuideSettings pushGuideDialogModelOfCategory:category];
        NSString *titleString = alertModel.titleString;
        NSString *defaultMessage = canOpenSettings ? @"第一时间获取重大新闻，去设置中允许幸福里通知" : @"第一时间获取重大新闻，请去 设置-通知 内开启幸福里访问权限";
        NSString *message = alertModel.subtitleString ? : defaultMessage;
        NSString *okBtnTitle = canOpenSettings ? (alertModel.buttonTextString ? : @"去设置") : @"我知道了";
        
        id imageObject = ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeNight) ? (alertModel.nightImage ? : alertModel.nightImageURLString) : (alertModel.image ? : alertModel.imageURLString);
        _hintView = [self authorizeHintViewWithTitle:titleString message:message image:imageObject okButtonTitle:okBtnTitle okBlock:^{
            if (canOpenSettings) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
                
                ttTrackEvent(@"pop", @"push_feed_limit_set");
            }
            
            // 显示引导弹窗埋点
            if (TTPushNoteGuideFireReasonNone != self.authorizeModel.pushFireReason) {
                [TTTracker eventV3:@"push_guide" params:@{@"click_push_guide_dialog": @(1)}];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BOOL isAPNSEnabled = NO;
                
                if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
                    isAPNSEnabled = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
                } else {
                    isAPNSEnabled = ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone);
                }
                [TTTracker eventV3:@"push_guide" params:@{@"click_push_guide_dialog": @(1), @"notificationStatus": isAPNSEnabled ? @(1) : @(0)}];
            });
            
            [[TTGuideDispatchManager sharedInstance_tt] removeGuideViewItem:self];
            
            self.authorizeModel.pushFireReason = TTPushNoteGuideFireReasonNone;
        } cancelBlock:^{
            
            if (canOpenSettings) {
                ttTrackEvent(@"pop", @"push_feed_limit_cancel");
            }
            
            // 显示引导弹窗埋点
            if (TTPushNoteGuideFireReasonNone != self.authorizeModel.pushFireReason) {
                [TTTracker eventV3:@"push_guide" params:@{@"click_push_guide_dialog": @(3)}];
            }
            
            [[TTGuideDispatchManager sharedInstance_tt] removeGuideViewItem:self];
            
            self.authorizeModel.pushFireReason = TTPushNoteGuideFireReasonNone;
        }];
        
        [[TTGuideDispatchManager sharedInstance_tt] addGuideViewItem:self withContext:nil];
        
        //        }];
    };
    
    
    if (flag == 0) {
        if ([self isEnabled]) {
            pushAuthorizeSettingBlock();
        }
    } else {
        if (!self.authorizeModel.isPushAuthorizeDetermined) {
            if ([self _isAuthorizeHintEnabled]) {
                [self _showCustomAuthorizeHintViewWithCompletionHandler:completionHandler];
            }
        } else {
            if ([self isEnabled]) {
                pushAuthorizeSettingBlock();
            }
        }
    }
}

- (BOOL)isEnabled {
    // 仅对未开启推送的用户生效。
    BOOL isAPNSEnabled = NO;
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        isAPNSEnabled = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    } else {
        isAPNSEnabled = ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone);
    }
    
    if (isAPNSEnabled) {
        return NO;
    }
    
    if (self.authorizeModel.pushFireReason == TTPushNoteGuideFireReasonNone) {
        return NO;
    }
    
    // 最多弹窗次数
    if (self.authorizeModel.showPushTimes >= self.authorizeModel.showPushMaxTimes) {
        return NO;
    }
    
    // 距上次同类弹窗时间k天
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = now - self.authorizeModel.lastTimeShowPush;
    if ((interval / (24 * 60 * 60)) < self.authorizeModel.showPushTimeInterval) {
        return NO;
    }
    
    // 和其他类型弹窗间隔c天
    interval = now - [self.authorizeModel maxLastTimeExcept:self.authorizeModel.lastTimeShowPush];
    if ((interval / (24 * 60 * 60)) < self.authorizeModel.showAlertInterval) {
        return NO;
    }
    
    // 图片下载成功，下载失败不显示
    TTPushGuideDialogCategory category = [self.class categoryOfFiringPushGuideDlg:self.authorizeModel.pushFireReason];
    if (![TTPushGuideSettings imageHasDownloadedOfCategory:category] || ![TTPushGuideSettings nightImageHasDownloadedOfCategory:category]) {
        return NO;
    }
    
    NSInteger maxShowCategoryTimes = [TTPushGuideSettings maxShowTimesOfCategory:category];
    switch (category) {
        case TTPushGuideDialogCategoryReadTopArticle: {
            if (self.authorizeModel.showPushTimesByTopArticle >= maxShowCategoryTimes) {
                return NO;
            }
        }
            break;
        case TTPushGuideDialogCategoryFollow: {
            if (self.authorizeModel.showPushTimesByFollow >= maxShowCategoryTimes) {
                return NO;
            }
        }
            break;
        case TTPushGuideDialogCategoryInteraction: {
            if (self.authorizeModel.showPushTimesByInteraction >= maxShowCategoryTimes) {
                return NO;
            }
        }
            break;
    }
    
    return YES;
}

- (void)updateShowTime {
    self.authorizeModel.lastTimeShowPush = (NSInteger)[[NSDate date] timeIntervalSince1970];
    [self.authorizeModel saveData];
}

- (void)updatePushShowTimes
{
    // 先更新总显示次数
    self.authorizeModel.showPushTimes += 1;
    
    // 然后更新某种类型的条件触发弹窗显示次数
    TTPushGuideDialogCategory category = [self.class categoryOfFiringPushGuideDlg:self.authorizeModel.pushFireReason];
    switch (category) {
        case TTPushGuideDialogCategoryReadTopArticle: {
            self.authorizeModel.showPushTimesByTopArticle++;
        }
            break;
        case TTPushGuideDialogCategoryFollow: {
            self.authorizeModel.showPushTimesByFollow++;
        }
            break;
        case TTPushGuideDialogCategoryInteraction: {
            self.authorizeModel.showPushTimesByInteraction++;
        }
            break;
    }
    [self.authorizeModel saveData];
}

//应用程序启动后控制是否应该显示自有弹窗
- (void)filterAuthorizeStrategyWithCompletionHandler:(dispatch_block_t)completionHandler sysAuthFlag:(NSInteger)flag {
    if(!self.authorizeModel.isPushAuthorizeDetermined){
        if (flag == 0){
            if(completionHandler){
                completionHandler();
            }
            [self updateShowTime];
        }
        else{
            if([self _isAuthorizeHintEnabled]){
                [self _showCustomAuthorizeHintViewWithCompletionHandler:completionHandler];
            }
        }
    }
    else{
        if(completionHandler){
            completionHandler();
        }
    }
}

//显示自有推送权限弹窗
- (void)_showCustomAuthorizeHintViewWithCompletionHandler:(dispatch_block_t)completionHandler{
    self.authorizeModel.showPushAuthorizeHintTimes += 1;
    self.authorizeModel.lastTimeShowPushAuthorizeHint = [[NSDate date] timeIntervalSince1970];
    [self.authorizeModel saveData];
    __weak typeof(self) wself = self;
    _hintView = [self authorizeHintViewWithTitle:@"开启要闻通知" message:@"允许幸福里获取推送权限，第一时间获知重大新闻" imageName:@"img_popup_notice" okButtonTitle:@"确定" okBlock:^{
        __strong typeof(wself) self = wself;
        ttTrackEvent(@"pop", @"push_permission_guide_confirm");
        if(completionHandler){
            completionHandler();
        }
        [self updateShowTime];
        [[TTGuideDispatchManager sharedInstance_tt]removeGuideViewItem:self];
    } cancelBlock:^{
        ttTrackEvent(@"pop", @"push_permission_guide_cancel");
        [[TTGuideDispatchManager sharedInstance_tt]removeGuideViewItem:self];
    }];
    [[TTGuideDispatchManager sharedInstance_tt] addGuideViewItem:self withContext:nil];
    ttTrackEvent(@"pop", @"push_permission_guide_show");
}

//根据时间和次数判断是否应该显示自有推送权限弹窗
- (BOOL)_isAuthorizeHintEnabled{
    
    // 距上次弹同类自有提示弹窗时间k天
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = now - self.authorizeModel.lastTimeShowPushAuthorizeHint;
    if (interval < self.authorizeModel.showPushTimeInterval) {
        return NO;
    }
    
    // 显示次数不超过最大次数
    if(self.authorizeModel.showPushAuthorizeHintTimes >= self.authorizeModel.showPushMaxTimes){
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
    
    // 显示引导弹窗埋点
    if (TTPushNoteGuideFireReasonNone != self.authorizeModel.pushFireReason) {
        [TTTracker eventV3:@"push_guide" params:@{@"show_guide_dialog": @([self positionForFirePushGuideDlg])}];
    }
}

- (id)context {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setContext:(id)context {
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)positionForFirePushGuideDlg
{
    switch (self.authorizeModel.pushFireReason) {
        case TTPushNoteGuideFireReasonReadTopArticle: {
            return 1;
        }
            break;
        case TTPushNoteGuideFireReasonFollow:
        case TTPushNoteGuideFireReasonWDFollow:
        case TTPushNoteGuideFireReasonUGCFollow:
        case TTPushNoteGuideFireReasonHTSFollow:
        case TTPushNoteGuideFireReasonUserMultiFollows:
        case TTPushNoteGuideFireReasonLiveFollow: {
            return 2;
        }
            break;
        case TTPushNoteGuideFireReasonPublishComment:
        case TTPushNoteGuideFireReasonWDPublishAnswer:
        case TTPushNoteGuideFireReasonWDPublishQuestion:
        case TTPushNoteGuideFireReasonWDPublishComment:
        case TTPushNoteGuideFireReasonUGCPublishComment:
        case TTPushNoteGuideFireReasonUGCPublishCard: /** UGC 发帖 */
        case TTPushNoteGuideFireReasonHTSComment: {
            return 3;
        }
            break;
        default: {
            
        }
            break;
    }
    return 0;
}

+ (TTPushGuideDialogCategory)categoryOfFiringPushGuideDlg:(TTPushNoteGuideFireReason)firedReason
{
    switch (firedReason) {
        case TTPushNoteGuideFireReasonReadTopArticle: {
            return 0;
        }
            break;
        case TTPushNoteGuideFireReasonFollow:
        case TTPushNoteGuideFireReasonWDFollow:
        case TTPushNoteGuideFireReasonUGCFollow:
        case TTPushNoteGuideFireReasonHTSFollow:
        case TTPushNoteGuideFireReasonUserMultiFollows:
        case TTPushNoteGuideFireReasonLiveFollow: {
            return 1;
        }
            break;
        case TTPushNoteGuideFireReasonPublishComment:
        case TTPushNoteGuideFireReasonWDPublishAnswer:
        case TTPushNoteGuideFireReasonWDPublishQuestion:
        case TTPushNoteGuideFireReasonWDPublishComment:
        case TTPushNoteGuideFireReasonUGCPublishComment:
        case TTPushNoteGuideFireReasonUGCPublishCard: /** UGC 发帖 */
        case TTPushNoteGuideFireReasonHTSComment: {
            return 2;
        }
            break;
        default: {
            
        }
            break;
    }
    return 0;
}

@end
