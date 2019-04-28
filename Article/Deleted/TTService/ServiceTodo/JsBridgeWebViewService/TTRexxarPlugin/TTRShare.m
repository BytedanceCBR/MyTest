//
//  TTRShare.m
//  Article
//
//  Created by muhuai on 2017/5/21.
//
//

#import "TTRShare.h"
#import "TTQQShare.h"
#import "TTActivityShareManager.h"
#import "ExploreFetchEntryManager.h"
#import <TTImage/TTWebImageManager.h>
#import "ArticleShareManager.h"
#import "SSActivityView.h"
#import "TTDetailContainerViewModel.h"
#import "TTDetailModel.h"

#import "TTProfileShareService.h"
#import <TTAccountBusiness.h>
#import <TTRoute/TTRouteDefine.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTImage/TTImageDownloader.h>

#import "AKShareManager.h"

//这不是我写的.... 我只是代码的搬运工..
@interface TTRShare()<SSActivityViewDelegate, TTActivityShareManagerDelegate>
@property (nonatomic, strong) TTActivityShareManager *shareManager;
@property (nonatomic, strong) TTImageDownloader *imageManager;
@property (nonatomic, strong) NSTimer *imageDownloadTimeoutTimer;
@property (nonatomic, assign) TTShareSourceObjectType curShareSourceType;
//@property (nonatomic, strong) NSDictionary *shareData;
@property (nonatomic, strong) SSActivityView *phoneShareView;
@property (nonatomic, strong) TTDetailContainerViewModel *detailModel;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *mediaID;
@property (nonatomic, copy) TTRJSBResponse callback;
@end

@implementation TTRShare
+ (TTRJSBInstanceType)instanceType {
    return TTRJSBInstanceTypeWebView;
}

- (void)dealloc {
    
}

- (void)shareWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *platform = [param objectForKey:@"platform"];
    if(([platform isEqualToString:@"qzone"] || [platform isEqualToString:@"qq"]) && ![[TTQQShare sharedQQShare] isAvailable]) {
        TTIndicatorView *indicateView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"你未安装QQ" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] dismissHandler:nil];
        indicateView.autoDismiss = YES;
        [indicateView showFromParentView:[UIApplication sharedApplication].delegate.window];
        callback(TTRJSBMsgFailed, @{@"code": @0});
        return;
    }
    
    /* added for AK
     文本分享：{
     channel,
     platform,
     text,
     }
     链接分享：{
     channel,
     platform,
     title,
     desc,
     image: 'http://s2.pstatp.com/site_new/promotion/landing_page/img/youliao_2074932463ecab05635cd860c3154ba4.png',
     url,
     }
     */
    NSString *text = [param tt_stringValueForKey:@"text"];
    if (isEmptyString(text)) {
        [self startShareWithData:param];
    } else {
        [self startShareTextWithData:param];
    }
    
    if ([SSCommonLogic enableWXShareCallback]) {
        self.callback = callback;
    } else {
        //走原逻辑 直接回调
        callback(TTRJSBMsgSuccess, @{@"code": @1});
    }
    return;
}

- (void)sharePGCWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *pgcID = [NSString stringWithFormat:@"%@", [param objectForKey:@"id"]];
    self.mediaID = pgcID;
    if(isEmptyString(pgcID)) {
        callback(TTRJSBMsgParamError, @{@"code": @NO});
    }
    else
    {
        self.callback = callback;
        [[ExploreFetchEntryManager sharedManager] fetchEntryByMediaID:pgcID finishBlock:^(ExploreEntry *entry, NSError *error) {
            if(error) {
                callback(TTRJSBMsgFailed,@{@"code": @NO});
                return;
            }
            else
            {
                UIImage *image = [TTWebImageManager imageForURLString:entry.imageURLString];
                if(image)
                {
                    [self shareWithExploreEntry:entry];
                }
                else
                {
                    
                    [self.imageManager cancelAll];
                    __weak typeof(self) wself = self;
                    [self.imageManager downloadImageWithURL:entry.imageURLString options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
                        __strong typeof(wself) self = wself;
                        [self shareWithExploreEntry:entry];
                    }];
                    
                }
            }
        }];
        
        [self shareWithmediaID:pgcID callback:callback];
    }
}

- (void)sharePanelWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *ID = [NSString stringWithFormat:@"%@", [param objectForKey:@"id"]];
    NSString *type = [param objectForKey:@"type"];
    
    // 视频专题
    if ([type isEqualToString:@"video_subject"] && ID) {
        self.mediaID = ID;
        self.detailModel = [[TTDetailContainerViewModel alloc] initWithRouteParamObj:TTRouteParamObjWithDict(@{@"groupid" : ID})];
        __weak typeof(self) wself = self;
        [self.detailModel fetchContentFromRemoteIfNeededWithComplete:^(ExploreDetailManagerFetchResultType type) {
            __strong typeof(wself) self = wself;
            [self shareWithArticle:self.detailModel.detailModel.article];
        }];
    }
    // 媒体主页
    else if ([type isEqualToString:@"media_profile"]) {
        self.mediaID = ID;
        [self shareWithmediaID:ID callback:callback];
    }
    // 个人动态(个人主页)
    else if ([type isEqualToString:@"update"]) {
        self.userID = ID;
        [self shareWithUserID:ID callback:callback];
    }
}

- (void)systemShareWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    
    //    self.shareData = param;
    //    callback(TTRJSBMsgSuccess, @{@"code": @1});
    NSAssert(NO, @"systenShare已废弃");
    return;
}

- (void)startShareTextWithData:(NSDictionary *)data
{
    NSString *text = [data tt_stringValueForKey:@"text"];
    NSString *platform = [data tt_stringValueForKey:@"platform"];
    
    [[AKShareManager sharedManager] shareToPlatform:AKSharePlatformWithString(platform) contentType:AKShareContentTypeText text:text title:nil description:nil webPageURL:nil thumbImage:nil thumbImageURL:nil image:nil videoURL:nil extra:nil completionBlock:nil];
}

- (void)startShareWithData:(NSDictionary*)data
{
    // download image first
    NSDictionary *replacedData = data;
    NSString *imageURLString = [replacedData objectForKey:@"image"];
    
    if(!isEmptyString(imageURLString))
    {
        [self shareManager].shareImage = [TTWebImageManager imageForURLString:imageURLString];
        
        if([self shareManager].shareImage)
        {
            [self shareWithImage:[self shareManager].shareImage data:replacedData];
        }
        else
        {
            [self.imageManager cancelAll];
            
            __weak __typeof(self)weakSelf = self;
            
            [self.imageManager downloadImageWithURL:imageURLString options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
                __strong __typeof(weakSelf)sself = weakSelf;
                if (image) {
                    [sself.imageDownloadTimeoutTimer invalidate];
                    [sself shareWithImage:image data:replacedData];
                } else {
                    [sself.imageDownloadTimeoutTimer invalidate];
                    [sself shareWithImage:[sself.class defaultIconImg] data:replacedData];
                }
            }];
            
            [_imageDownloadTimeoutTimer invalidate];
            self.imageDownloadTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:3.f target:self selector:@selector(timeoutTimer:) userInfo:replacedData repeats:NO];
        }
    }
    else
    {
        [self shareWithImage:[self.class defaultIconImg] data:replacedData];
    }
}

- (void)shareWithImage:(UIImage*)image data:(NSDictionary*)data
{
    NSString *platform = [self sharedPlatformForData:data];
    NSString *title = [data objectForKey:@"title"];;
    NSString *content = [data objectForKey:@"desc"];
    NSString *shareURLString = [data objectForKey:@"url"];
    NSString *repostSchema = [data objectForKey:@"repost_schema"];
    
    
    [[self shareManager] clearCondition];
    
    [self shareManager].shareImage = image;
    
    [self shareManager].hasImg = image == nil ? NO : YES;
    
    [self shareManager].shareURL = shareURLString;
    
    [self shareManager].delegate = self;
    
    UIViewController *topVC = self.engine.ttr_sourceController;
    
    if([platform isEqualToString:@"qzone"])
    {
        [self shareManager].qqZoneTitleText = title;
        [self shareManager].qqZoneText = content;
        [self shareManager].qqShareTitleText = title;
        [[self shareManager] performActivityActionByType:TTActivityTypeQQZone inViewController:topVC sourceObjectType:self.curShareSourceType];
        
    }
    else if([platform isEqualToString:@"weixin"])
    {
        [self shareManager].weixinTitleText = title;
        [self shareManager].weixinText = content;
        [[self shareManager] performActivityActionByType:TTActivityTypeWeixinShare inViewController:topVC sourceObjectType:self.curShareSourceType uniqueId:self.userID];
    }
    else if([platform isEqualToString:@"weixin_moments"])
    {
        [self shareManager].weixinMomentText = title;
        [[self shareManager] performActivityActionByType:TTActivityTypeWeixinMoment inViewController:topVC sourceObjectType:self.curShareSourceType];
    }
    else if([platform isEqualToString:@"qq"])
    {
        [self shareManager].qqShareText = content;
        [self shareManager].qqShareTitleText = title;
        [[self shareManager] performActivityActionByType:TTActivityTypeQQShare inViewController:topVC sourceObjectType:self.curShareSourceType];
    }else if([platform isEqualToString:@"dingding"]){
        [self shareManager].dingtalkText = content;
        [self shareManager].dingtalkTitleText = title;
        [[self shareManager] performActivityActionByType:TTActivityTypeDingTalk inViewController:topVC sourceObjectType:self.curShareSourceType];
    } else if ([platform isEqualToString:@"weitoutiao"]){
        
        wrapperTrackEventWithCustomKeys(@"wap_share", @"share_weitoutiao", nil, @"public-benefit", nil);
        if (!isEmptyString(repostSchema)) {
            [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:repostSchema] userInfo:nil];
        }
    }
}

- (void)shareWithExploreEntry:(ExploreEntry*)entry
{
    self.curShareSourceType = TTShareSourceObjectTypePGC;
    NSArray * activityItems = [ArticleShareManager shareActivityManager:[self shareManager] exploreEntry:entry];
    self.phoneShareView = [[SSActivityView alloc] init];
    self.phoneShareView.delegate = self;
    self.phoneShareView.activityItems = activityItems;
    //    UIViewController *topVC = [TTUIResponderHelper topViewControllerFor: self.webView];
    [self.phoneShareView showOnViewController:[TTUIResponderHelper mainWindowRootViewController]];
    [self sendPGCShareTrackWithItemType:TTActivityTypeShareButton];
}

- (void)shareWithArticle:(Article *)article
{
    self.curShareSourceType = TTShareSourceObjectTypeArticleTop;
    NSArray * activityItems = [ArticleShareManager shareActivityManager:[self shareManager] setArticleCondition:article adID:nil];
    self.phoneShareView = [[SSActivityView alloc] init];
    [self.phoneShareView refreshCancelButtonTitle:@"取消"];
    self.phoneShareView.delegate = self;
    [self.phoneShareView setActivityItemsWithFakeLayout:activityItems];
    [self.phoneShareView show];
    [self sendVideoSubjectShareTrackWithItemType:TTActivityTypeShareButton];
    self.detailModel = nil;
}

- (void)shareWithUserID:(NSString *)uid callback:(TTRJSBResponse)callback {
    if (isEmptyString(self.userID)) {
        self.userID = uid;
    }
    NSDictionary *shareObject = [TTProfileShareService shareObjectForUID:uid];
    if(!shareObject) {
        callback(TTRJSBMsgFailed, @{@"code": @(NO)});
        return;
    } else {
        [self.imageManager cancelAll];
        
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
        
        [self.imageManager downloadImageWithURL:[shareObject valueForKey:@"avatar_url"] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
            if (TTProfileShareBlock) TTProfileShareBlock();
        }];
    }
}

- (void)shareWithmediaID:(NSString *)mediaID callback:(TTRJSBResponse)callback {
    [[ExploreFetchEntryManager sharedManager] fetchEntryByMediaID:mediaID finishBlock:^(ExploreEntry *entry, NSError *error) {
        if(error) {
            callback(TTRJSBMsgFailed, @{@"code": @NO});
            return;
        } else {
            UIImage *image = [TTWebImageManager imageForURLString:entry.imageURLString];
            if(image) {
                [self shareWithExploreEntry:entry];
            } else {
                
                [self.imageManager cancelAll];
                WeakSelf;
                [self.imageManager downloadImageWithURL:entry.imageURLString options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
                    StrongSelf;
                    [self shareWithExploreEntry:entry];
                }];
            }
        }
    }];
}

- (void)sendPGCShareTrackWithItemType:(TTActivityType)itemType
{
    NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:TTShareSourceObjectTypePGC];
    NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
    wrapperTrackEventWithCustomKeys(tag, label, _mediaID, nil, nil);
}

- (void)sendVideoSubjectShareTrackWithItemType:(TTActivityType)itemType
{
    NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:TTShareSourceObjectTypeVideoSubject];
    NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
    wrapperTrackEventWithCustomKeys(tag, label, _mediaID, nil, nil);
}

- (void)timeoutTimer:(NSTimer*)timer
{
    //  download image timeout
    NSDictionary *data = [timer userInfo];
    [_imageManager cancelAll];
    [self shareWithImage:[self.class defaultIconImg] data:data];
}

//默认Icon
+ (UIImage *)defaultIconImg
{
    UIImage * img;
    //优先使用share_icon.png分享
    if (!img) {
        img = [UIImage imageNamed:@"share_icon.png"];
    }
    if (!img) {
        img = [UIImage imageNamed:@"Icon.png"];
    }
    return img;
}

- (NSString*)sharedPlatformForData:(NSDictionary*)data
{
    NSString *platform = [data objectForKey:@"platform"];
    if(isEmptyString(platform))
    {
        platform = @"weixin_moments";
    }
    
    return platform;
}

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    if (view == _phoneShareView) {
        if (self.curShareSourceType == TTShareSourceObjectTypePGC) {
            [self shareManager].isShareMedia = YES;
            [[self shareManager] performActivityActionByType:itemType inViewController:self.engine.ttr_sourceController sourceObjectType:self.curShareSourceType uniqueId:self.mediaID];
            self.phoneShareView = nil;
            
            if (self.curShareSourceType == TTShareSourceObjectTypePGC) {
                [self sendPGCShareTrackWithItemType:itemType];
                if(self.callback) {
                    BOOL result = (itemType != TTActivityTypeNone);
                    self.callback(TTRJSBMsgSuccess, @{@"code": @(result)});
                    self.callback = nil;
                }
            } else {
                [self sendVideoSubjectShareTrackWithItemType:itemType];
            }
        } else if (self.curShareSourceType == TTShareSourceObjectTypeProfile) {
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
                [[self shareManager] performActivityActionByType:itemType inViewController:self.engine.ttr_sourceController sourceObjectType:self.curShareSourceType uniqueId:self.userID adID:nil platform:TTSharePlatformTypeOfMain groupFlags:self.detailModel.detailModel.article.groupFlags];
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
        } else {
            [[self shareManager] performActivityActionByType:itemType inViewController:self.engine.ttr_sourceController sourceObjectType:self.curShareSourceType uniqueId:self.userID];
            self.phoneShareView = nil;
            
            if (self.curShareSourceType == TTShareSourceObjectTypePGC) {
                [self sendPGCShareTrackWithItemType:itemType];
                if(self.callback)
                {
                    BOOL result = (itemType != TTActivityTypeNone);
                    self.callback(TTRJSBMsgSuccess, @{@"code": @(result)});
                    self.callback = nil;
                }
            } else {
                [self sendVideoSubjectShareTrackWithItemType:itemType];
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

- (TTImageDownloader *)imageManager {
    if (!_imageManager) {
        _imageManager = [[TTImageDownloader alloc] init];
    }
    return _imageManager;
}

#pragma mark - TTActivityShareManagerDelegate

- (void)activityShareManager:(TTActivityShareManager *)activityShareManager completeWithActivityType:(TTActivityType)activityType error:(NSError *)error {
    if (!self.callback) return;
    if (error != nil) {
        NSDictionary *params = error.userInfo;
        if (!SSIsEmptyDictionary(params)) {
            if ([params objectForKey:@"WXCode"]) {
                int errCode = [params tt_intValueForKey:@"WXCode"];
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
                [params setValue:@(1) forKey:@"code"];
                [params setValue:@(errCode) forKey:@"errorCode"];
                self.callback(TTRJSBMsgSuccess, [params copy]);
            }
        }
    }
}



@end

