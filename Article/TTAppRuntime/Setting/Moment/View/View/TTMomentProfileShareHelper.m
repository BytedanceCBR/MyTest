//
//  TTMomentProfileShareHelper.m
//  Article
//
//  Created by muhuai on 2017/6/6.
//
//

#import "TTMomentProfileShareHelper.h"
#import "TTProfileShareService.h"
#import <TTAccountBusiness.h>
#import "TTActivityShareManager.h"
#import "ArticleShareManager.h"
#import "SSActivityView.h"

#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTImage/TTWebImageManager.h>
#import <SDWebImage/SDWebImageManager.h>

//我就没见过这么脏的代码
@interface TTMomentProfileShareHelper ()<SSActivityViewDelegate>

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *mediaID;
@property (nonatomic, strong) SDWebImageManager *imageManager;
@property (nonatomic, assign) TTShareSourceObjectType curShareSourceType;
@property (nonatomic, strong) SSActivityView *phoneShareView;
@property (nonatomic, strong) TTActivityShareManager *shareManager;
@end

@implementation TTMomentProfileShareHelper

- (void)shareWithUserID:(NSString *)uid {
    if (isEmptyString(self.userID)) {
        self.userID = uid;
    }
    NSDictionary *shareObject = [TTProfileShareService shareObjectForUID:uid];
    if(!shareObject) {
        return;
    } else {
        if (!self.imageManager) {
            self.imageManager = [[TTWebImageManager alloc] init];
        } else {
            [self.imageManager cancelAll];
        }
        
        __weak typeof(self) wself = self;
        void (^TTProfileShareBlock)() = ^() {
            __strong typeof(wself) sself = wself;
            
            BOOL isAccountUser = [[TTAccountManager sharedManager] isAccountUserOfUID:uid];
            NSArray *activityItems = [ArticleShareManager shareActivityManager:sself.shareManager profileShareObject:shareObject isAccountUser:isAccountUser];
            sself.curShareSourceType = TTShareSourceObjectTypeProfile;
            sself.phoneShareView = [[SSActivityView alloc] init];
            sself.phoneShareView.activityItems = activityItems;
            sself.phoneShareView.delegate = sself;
            
            [sself.phoneShareView showOnViewController:[TTUIResponderHelper mainWindowRootViewController]];
        };
        
        if ([TTWebImageManager cachedImageExistsForKey:[shareObject valueForKey:@"avatar_url"]]) {
            if (TTProfileShareBlock) TTProfileShareBlock();
        } else {
            [[TTWebImageManager shareManger] downloadImageWithURL:[shareObject valueForKey:@"avatar_url"] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
                if (TTProfileShareBlock) TTProfileShareBlock();
            }];
        }
    }
}

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    if (view == _phoneShareView) {
        if (self.curShareSourceType == TTShareSourceObjectTypeProfile) {
            if (itemType == TTActivityTypeNightMode){
                BOOL isDayMode = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay);
                NSString *eventID = nil;
                if (isDayMode){
                    [[TTThemeManager sharedInstance_tt] switchThemeModeto:TTThemeModeNight];
                    eventID = @"click_to_night";
                }
                else{
                    [[TTThemeManager sharedInstance_tt] switchThemeModeto:TTThemeModeDay];
                    eventID = @"click_to_day";
                }
                wrapperTrackEvent(@"profile", eventID);
                
                //做一个假的动画效果 让夜间渐变
                UIView *imageScreenshot = [[TTUIResponderHelper mainWindow] snapshotViewAfterScreenUpdates:NO];
                [[TTUIResponderHelper mainWindow] addSubview:imageScreenshot];
                [UIView animateWithDuration:0.5f animations:^{
                    imageScreenshot.alpha = 0;
                } completion:^(BOOL finished) {
                    [imageScreenshot removeFromSuperview];
                }];
            }
            else if (itemType == TTActivityTypeFontSetting){
                [self.phoneShareView fontSettingPressed];
            }
            else { // Share
                [[self shareManager] performActivityActionByType:itemType inViewController:[TTUIResponderHelper topNavigationControllerFor:nil] sourceObjectType:self.curShareSourceType uniqueId:self.userID adID:nil platform:TTSharePlatformTypeOfMain groupFlags:nil];
                self.phoneShareView = nil;
                
                NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:self.curShareSourceType];
                NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
                if (itemType == TTActivityTypeNone) {
                    tag = @"profile";
                }
                
                NSDictionary *profileDict = [TTProfileShareService shareObjectForUID:self.userID];
                
                NSString *mediaID = [profileDict tt_stringValueForKey:@"media_id"];
                if (!isEmptyString(mediaID) && ![mediaID isEqualToString:@"0"]) {
                    self.mediaID = mediaID;
                }
                
                //ugly code 个人主页的取消分享需要单独修改label
                if ([tag isEqualToString:@"profile"] && [label isEqualToString:@"share_cancel_button"]) {
                    label = @"profile_more_close";
                }
                
                [TTTrackerWrapper event:tag label:label value:self.mediaID extValue:self.userID extValue2:nil];
            }
        }
    }
}

- (TTActivityShareManager*)shareManager
{
    @synchronized(self)
    {
        if(!_shareManager)
        {
            _shareManager = [[TTActivityShareManager alloc] init];
        }
        
        return _shareManager;
    }
}
@end
