//
//  SSWebViewControllerView.m
//  Article
//
//  Created by Zhang Leonardo on 13-8-21.
//
//

#import "SSWebViewControllerView.h"
#import "TTActivityShareManager.h"
#import "SSWebViewUtil.h"
#import <TTNetworkUtilities.h>
#import "TTAdManager.h"

#import "ArticleShareManager.h"
#import "ArticleWebViewToAppStoreManager.h"
#import "SSActivityView.h"
#import "SSWebViewUtil.h"
#import "TTActivityShareManager.h"
#import "TTAdManagerProtocol.h"
//#import "TTToolService.h"
#import "ArticleShareManager.h"
#import <TTUserSettingsManager+FontSettings.h>

#import <TTRoute/TTRoute.h>
#import <TTThemed/SSThemed.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/JSONAdditions.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTRoute/TTRoute.h>
#import <TTServiceKit/TTServiceCenter.h>
#import <TTThemed/SSThemed.h>
#import <TTTracker/TTTrackerProxy.h>
#import <TTUIWidget/TTIndicatorView.h>
#import <TTUIWidget/TTThemedAlertController.h>
#import "TTActivityShareSequenceManager.h"
#import "TTVSettingsConfiguration.h"
#import "SSCommonLogic.h"
#import "TTKitchenHeader.h"

#define toolBarHeight 40.f

const NSInteger SSWebViewMoreActionSheetTag = 1001;
//#define toolBarHeight 0.f

@interface SSWebViewControllerView() <UIActionSheetDelegate,SSActivityViewDelegate, YSWebViewDelegate, UIGestureRecognizerDelegate> {
    /// 这个是为了统计广告落地页的跳转次数。
    NSInteger _jumpCount;
    BOOL _userHasClickLink;
    NSInteger   _clickLinkCount;
}


@property (nonatomic, copy) NSString *mainURLString;//主页URL string

@property (nonatomic, strong) TTActivityShareManager *activityActionManager;
@property (nonatomic, strong) SSActivityView *navMoreShareView;

@property (nonatomic, assign) BOOL recordShouldShowShareAction;
@property (nonatomic, assign) BOOL disableTTUserAgent;
@property (nonatomic, assign) BOOL disableTTReferer;
@property (nonatomic, assign) BOOL disableProgressView;
@property (nonatomic, assign) BOOL moreShareOnly; // 点击右上角三个点菜单，是否直接打开分享板而不需要开启菜单ActionSheet

@property (nonatomic, assign) BOOL shouldInterceptAutoJump; // 广告逻辑 @李玲 拦截第三方跳转
@property (nonatomic, strong) UITapGestureRecognizer *webTapGesture;
@property (nonatomic, assign) NSTimeInterval clickTimeStamp;


@end

@implementation SSWebViewControllerView

- (void)dealloc {
    if (self.ssWebContainer.adID && _jumpCount > 0) {
        // 发送广告落地页面跳转次数的统计
        [self _sendJumpEventWithCount:_jumpCount];
    }
}
- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame baseCondition:nil];
}

- (instancetype)initWithFrame:(CGRect)frame baseCondition:(NSDictionary *)baseCondition
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initBaseCondition:baseCondition];
        
        self.shouldInterceptAutoJump = [SSCommonLogic shouldAutoJumpControlEnabled];
        
        self.isRepostWeitoutiaoFromWeb = NO;
        self.isShowCloseWebBtn = YES;
        
        SSNavigationBar *navigationBar = [[SSNavigationBar alloc] initWithFrame:[self frameForTitleBarView]];
        self.navigationBar = navigationBar;
        
        SSWebViewBackButtonView *backButton = [[SSWebViewBackButtonView alloc] init];
        self.navigationBar.preferredItemWidth = 75;
        [backButton.backButton addTarget:self action:@selector(backWebViewActionFired:) forControlEvents:UIControlEventTouchUpInside];
        [backButton.closeButton addTarget:self action:@selector(backViewControllerActionFired:) forControlEvents:UIControlEventTouchUpInside];
        navigationBar.leftBarView = backButton;
        self.backButtonView = backButton;
        
        /*
        SSThemedButton *rightButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(0, 0, 76, 60);
        [rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 40, 0, -6)];
        rightButton.imageName = @"new_more_titlebar.png";
        rightButton.highlightedImageName = @"new_more_titlebar_press.png";
        [rightButton addTarget:self action:@selector(moreActionFired:) forControlEvents:UIControlEventTouchUpInside];
        navigationBar.rightBarView = rightButton;
         */
        //更多按钮自定义操作
        [self initMoreButtonActions];
        
        self.ssWebContainer = [[SSWebViewContainer alloc] initWithFrame:[self frameForWebViewContainer] baseCondition:baseCondition];
        [_ssWebContainer.ssWebView addDelegate:self];
        [_ssWebContainer setDisableTTUserAgent:_disableTTUserAgent];
        [_ssWebContainer hiddenProgressView:self.disableProgressView];
        [self addSubview:_ssWebContainer];
  
        if ([SSCommonLogic shouldClickJumpControlEnabled]) {
            self.webTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
            self.webTapGesture.delegate = self;
            self.webTapGesture.enabled = NO;
            [self.ssWebContainer.ssWebView addGestureRecognizer:self.webTapGesture];
        }

        [self bringSubviewToFront:self.navigationBar];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)initShareButtonAcition
{
     SSThemedButton *rightButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
     rightButton.frame = CGRectMake(10, 0, 30, 30);
    [rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [rightButton setImage:[UIImage imageNamed:@"ic-navigation-share-dark"] forState:UIControlStateNormal];
     [rightButton addTarget:self action:@selector(shareBtnClick)  forControlEvents:UIControlEventTouchUpInside];
    _navigationBar.rightBarView = rightButton;
}

//从SSWebViewController透传的condition
- (void)initBaseCondition:(NSDictionary *)baseCondition {
    NSDictionary *param = baseCondition;
    if (![param isKindOfClass:[NSDictionary class]]) {
        return;
    }
    self.disableTTUserAgent = !!param[@"disable_tt_ua"];
    self.disableTTReferer = !!param[@"disable_tt_referer"];
    self.disableProgressView = [param tt_boolValueForKey:@"disable_web_progressView"];
    self.moreShareOnly = [param tt_boolValueForKey:@"more_share_only"];
}

- (void)initMoreButtonActions
{
    self.shouldShowRefreshAction = YES;
    self.shouldShowCopyAction = YES;
    self.shouldShowSafariAction = YES;
    self.shouldShowShareAction = YES;
}

- (BOOL)rightButtonDisplayed {
    return !self.navigationBar.rightBarView.hidden;
}


- (void)setRightButtonDisplay:(BOOL)rightButtonDisplayed {
    self.navigationBar.rightBarView.hidden = !rightButtonDisplayed;
}

- (void)setupFShareBtn:(BOOL)isShowBtn
{
    if (isShowBtn) {
        [self initShareButtonAcition];
        self.navigationBar.rightBarView.hidden = NO;
    }
}

- (void)shareBtnClick
{
    [self.ssWebContainer.ssWebView ttr_fireEvent:@"clickShare" data:nil];
}

- (void)getShareInfoFormWap
{
    if (!self.shouldShowShareAction) {
        return;
    }
    //执行js脚本后回调ToutiaoJSBridge.call('shareInfo',xxx),传回来title,desc,image,url
    [self.ssWebContainer.ssWebView stringByEvaluatingJavaScriptFromString:@"(function(){function loadScript(url,callback){var head=document.head,script;script=document.createElement('script');script.async=false;script.type='text/javascript';script.charset='utf-8';script.src=url;head.insertBefore(script,head.firstChild);if(callback){script.addEventListener('load',callback,false)}}function sendMsg(argument){var min_image_size=100;var title='',desc='',icon='',title_ele=document.querySelector('title'),desc_ele=document.querySelector('meta[name=description]');if(title_ele){title=title_ele.innerText}if(desc_ele){desc=desc_ele.content}var imgs=document.querySelectorAll('body img');for(var i=0;i<imgs.length;i++){var img=imgs[i];if(img.naturalWidth>min_image_size&&img.naturalHeight>min_image_size){icon=img.src;break}}window.ToutiaoJSBridge.call('shareInfo',{'title':title,'desc':desc,'image':icon,'url':location.href})}if(!window.ToutiaoJSBridge){var protocol=location.protocol.indexOf('https')>-1?'https://':'http://';loadScript(protocol+'s2.pstatp.com/inapp/toutiao.js',sendMsg)}else{sendMsg()}})();"
        completionHandler:nil];
}

- (void)shareActionSheetFired
{
    [_activityActionManager clearCondition];
    if (!_activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
        self.activityActionManager.forwardToWeitoutiao = self.isRepostWeitoutiaoFromWeb;
        if ([KitchenMgr getBOOL:kKCUGCRepostLinkEnable]) {
            self.activityActionManager.forwardToWeitoutiao = YES;
        }
    }
    NSMutableArray * activityItems = [ArticleShareManager shareActivityManager:_activityActionManager setWapConditionWithTitle:self.shareTitle desc:self.shareDesc url:[self currentURLStr] imageUrl:self.shareImageUrl];
    if (self.navMoreShareView){
        self.navMoreShareView = nil;
    }
    self.navMoreShareView = [[SSActivityView alloc] init];
    [self.navMoreShareView refreshCancelButtonTitle:@"取消"];
    self.navMoreShareView.delegate = self;
    [self.navMoreShareView setActivityItemsWithFakeLayout:activityItems];
    if (!isEmptyString(self.ssWebContainer.adID)) {
        id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
        [adManagerInstance share_showInAdPage:self.ssWebContainer.adID groupId:@"0"];
    }
    [self.navMoreShareView show];
    NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:TTShareSourceObjectTypeWap];
    NSString *label = @"share_button";
    NSDictionary *extraDict;
    if (self.ssWebContainer.gdExtJsonDict) {
        tag = [self.ssWebContainer.gdExtJsonDict valueForKey:@"source"];
        extraDict = self.ssWebContainer.gdExtJsonDict;
    }
    wrapperTrackEventWithCustomKeys(tag, label, nil, nil, extraDict);
}

- (BOOL)clickJumpRecognized
{
    if ([self.ssWebContainer.adID longLongValue] == 0 || ![SSCommonLogic shouldClickJumpControlEnabled]) {
        return NO;
    }
    NSTimeInterval interval = fabs([[NSDate date] timeIntervalSince1970] - self.clickTimeStamp) * 1000;
    return interval <= [SSCommonLogic clickJumpTimeInterval];
}

#pragma mark - GestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)handleTapGesture:(UIGestureRecognizer *)recognizer
{
    self.clickTimeStamp = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - SSActivityViewDelegate
- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    if (view == self.navMoreShareView) {
        
        if (itemType == TTActivityTypeWeitoutiao) {
            [self p_forwardToWeitoutiao];
            wrapperTrackEventWithCustomKeys(@"wap_share", @"share_weitoutiao", nil, @"public-benefit", nil);
            if (ttvs_isShareIndividuatioEnable()){
                [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareActivitySequenceFirstActivity:itemType];
            }
        }
        else {
            [_activityActionManager performActivityActionByType:itemType inViewController:self.viewController sourceObjectType:TTShareSourceObjectTypeWap];
            NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:TTShareSourceObjectTypeWap];
            NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
            if (self.ssWebContainer.gdExtJsonDict) {
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.ssWebContainer.gdExtJsonDict];
                params[@"type"] = @"wap_share_click";
                params[@"share_platform"] = label;
                [self.ssWebContainer.ssWebView ttr_fireEvent:@"page_state_change" data:[params copy]];
            } else {
                wrapperTrackEventWithCustomKeys(tag, label, nil, nil, nil);
            }
            self.navMoreShareView = nil;
        }
    }
}

- (void)moreActionFired:(UIButton *)sender {
    NSString *host = self.ssWebContainer.ssWebView.currentURL.host;
    BOOL enableShare = NO;
    if (!isEmptyString(self.repostTitle)) { // 如果已经通过jsbridge下发了“微头条转发”信息了，则肯定是内链，允许
        enableShare = YES;
    }
    if (!isEmptyString(host)) { // 如果host在白名单，也可以分享
        NSArray *array = [KitchenMgr getArray:kKCUGCWhiteListOfShareHost];
        for (NSString *whiteListHost in array) {
            if ([host containsString:whiteListHost]) {
                enableShare = YES;
                break;
            }
        }
    }
    
    BOOL currentShouldShowShareAction = self.shouldShowShareAction;
    if (!enableShare) {
        self.shouldShowShareAction = NO;
    }
    
    if (self.shouldShowShareAction && isEmptyString(self.shareTitle)) {
        [self getShareInfoFormWap]; // 注入JSBridge，获取分享内容
    }
    
    if (self.moreShareOnly) {
        // 直接打开分享板
        [self shareActionSheetFired];
    } else {
        // 打开底部的菜单ActionSheet，里面点击分享页面后可以打开分享板
        [self menuActionSheetFired:sender];
    }
    self.shouldShowShareAction = currentShouldShowShareAction;
}

- (void)menuActionSheetFired:(UIButton *)sender {
    NSString *refreshTitle = NSLocalizedString(@"刷新", nil)?:@"刷新", *copyTitle = NSLocalizedString(@"复制链接", nil)?:@"复制链接", *safariTitle = NSLocalizedString(@"使用Safari打开", nil)?:@"使用Safari打开", *shareTitle = NSLocalizedString(@"分享页面", nil)?:@"分享页面", *cancelTitle = NSLocalizedString(@"取消", nil)?:@"取消";
    if (![TTDeviceHelper isPadDevice]) {
        TTThemedAlertController *actionSheet = [[TTThemedAlertController alloc] initWithTitle:nil message:nil preferredType:TTThemedAlertControllerTypeActionSheet];
        if (_shouldShowRefreshAction) {
            [actionSheet addActionWithTitle:refreshTitle actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                [self.ssWebContainer.ssWebView reload];
            }];
        }
        if (_shouldShowCopyAction) {
            [actionSheet addActionWithTitle:copyTitle actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                [TTActivityShareManager copyText:[self currentURLStr]];
            }];
        }
        if (_shouldShowSafariAction) {
            [actionSheet addActionWithTitle:safariTitle actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                [[UIApplication sharedApplication] openURL:[TTStringHelper URLWithURLString:[self currentURLStr]]];
            }];
        }
        if (_shouldShowShareAction) {
            __weak typeof(self) wself = self;
            [actionSheet addActionWithTitle:shareTitle actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                __strong typeof(wself) self = wself;
                [self shareActionSheetFired];
            }];
        }
        [actionSheet addActionWithTitle:cancelTitle actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [actionSheet showFrom:self.viewController animated:YES];
    } else {
        if([TTDeviceHelper OSVersionNumber] >= 8.0 && [TTDeviceHelper isPadDevice]) {
            UIViewController *topVC = [TTUIResponderHelper topViewControllerFor: self];
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *refreshAction = [UIAlertAction actionWithTitle:refreshTitle
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                                    [self.ssWebContainer.ssWebView reload];
                                                                }];
            if (_shouldShowRefreshAction) {
                [controller addAction:refreshAction];
            }
            
            UIAlertAction *copyAction = [UIAlertAction actionWithTitle:copyTitle
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                                      [TTActivityShareManager copyText:[self currentURLStr]];
                                                                  }];
            if (_shouldShowCopyAction) {
                [controller addAction:copyAction];
            }
            
            UIAlertAction *safariAction = [UIAlertAction actionWithTitle:safariTitle
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     [[UIApplication sharedApplication] openURL:[TTStringHelper URLWithURLString:[self currentURLStr]]];
                                                                 }];
            if (_shouldShowSafariAction) {
                [controller addAction:safariAction];
            }
            
            UIAlertAction *shareAction = [UIAlertAction actionWithTitle:shareTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self shareActionSheetFired];
                //to do
            }];
            
            if (_shouldShowShareAction) {
                [controller addAction:shareAction];
            }
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }];
            
            [controller addAction:cancelAction];
            controller.popoverPresentationController.sourceView = sender;
            controller.popoverPresentationController.sourceRect = sender.bounds;
            controller.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
            [topVC presentViewController:controller animated:YES completion:nil];
        } else {
            
            UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                delegate:self
                                                       cancelButtonTitle:cancelTitle
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:nil];
            if (_shouldShowRefreshAction){
                [sheet addButtonWithTitle:refreshTitle];
            }
            if (_shouldShowCopyAction) {
                [sheet addButtonWithTitle:copyTitle];
            }
            if (_shouldShowSafariAction) {
                [sheet addButtonWithTitle:safariTitle];
            }
            if (_shouldShowShareAction) {
                [sheet addButtonWithTitle:shareTitle];
            }
            sheet.tag = SSWebViewMoreActionSheetTag;
            [sheet showInView:self];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == SSWebViewMoreActionSheetTag) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return;
        }
        NSString * title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:@"刷新"]) {
            [self.ssWebContainer.ssWebView reload];
        } else if ([title isEqualToString:@"复制链接"]) {
            [TTActivityShareManager copyText:[self currentURLStr]];
        } else if ([title isEqualToString:@"使用Safari打开"]) {
            [[UIApplication sharedApplication] openURL:self.ssWebContainer.ssWebView.request.URL];
        } else if ([title isEqualToString:@"分享页面"]) {
           [self shareActionSheetFired];
        }
    }
}

- (void)p_forwardToWeitoutiao{
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    NSString *coverURL = self.repostCoverUrl;
    NSString *title = self.repostTitle;
    NSString *schema = self.repostSchema;
    NSInteger repostType = self.repostType;

    if (self.isRepostWeitoutiaoFromWeb == NO
        && [KitchenMgr getBOOL:kKCUGCRepostLinkEnable]) {
        
        NSURL *curURL = _ssWebContainer.ssWebView.currentURL;
        if ([curURL.host containsString:@"mp.weixin.qq.com"]) {
            title = [self.ssWebContainer.ssWebView stringByEvaluatingJavaScriptFromString:@"msg_title" completionHandler:nil];
            coverURL = [self.ssWebContainer.ssWebView stringByEvaluatingJavaScriptFromString:@"msg_cdn_url" completionHandler:nil];
        }
        
        if (isEmptyString(coverURL)) {
            coverURL = self.shareImageUrl;
        }
        if (isEmptyString(title)) {
            title = self.shareTitle;
        }
        
        schema = [self currentURLStr];
        repostType = 215;
    }
    
    [parameters setValue:coverURL forKey:@"cover_url"];
    [parameters setValue:title forKey:@"title"];
    [parameters setValue:@(repostType) forKey:@"repost_type"];
    [parameters setValue:@(0) forKey:@"is_video"];
    [parameters setValue:schema forKey:@"schema"];
    
    [[TTRoute sharedRoute] openURLByPresentViewController:[NSURL URLWithString:@"sslocal://repost_page"] userInfo:TTRouteUserInfoWithDict(parameters)];
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
}

- (void)showCloseButton
{
    NSLog(@"canGoBack = %d",self.ssWebContainer.ssWebView.canGoBack);
    if (self.isShowCloseWebBtn) {
        [self.backButtonView showCloseButton:self.ssWebContainer.ssWebView.canGoBack];
    }else
    {
        [self.backButtonView showCloseButton:self.isShowCloseWebBtn];
    }
}

- (void)backWebViewActionFired:(id) sender {
    
//    if (![self.backButtonView isCloseButtonShowing]) {
        [self performSelector:@selector(showCloseButton) withObject:nil afterDelay:0.1];
//    }
    if ([self.ssWebContainer.ssWebView canGoBack] && !self.shouldDisableHistory) {
        [self.ssWebContainer.ssWebView goBack];
    } else {
        
        if (self.isWebControl) {
            [self.ssWebContainer.ssWebView stringByEvaluatingJavaScriptFromString:@"ToutiaoJSBridge.trigger('close');"
                                                                completionHandler:nil];
            return;
        }
        
        if (self.viewController.navigationController) {
            if (self.viewController.navigationController.viewControllers.count == 1 && self.viewController.navigationController.presentingViewController) {
                [self.viewController.navigationController dismissViewControllerAnimated:YES completion:NULL];
            } else {
                
                NSMutableArray *vcStack = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                
                if (self.closeStackCount == 0) {
                    [self.navigationController popViewControllerAnimated:YES];
                    return;
                }
                
                if (vcStack.count > self.closeStackCount + 1) {
                    NSInteger retainVCs = vcStack.count - self.closeStackCount - 1;
                    if (retainVCs == 0) {
                        self.navigationController.viewControllers = [NSArray arrayWithObjects:vcStack.firstObject,vcStack.lastObject,nil];
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
                        
                        self.navigationController.viewControllers = viewControllersArray;
                    }
                }else
                {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    return;
                }
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            if (self.viewController.presentingViewController) {
                [self.viewController dismissViewControllerAnimated:YES completion:NULL];
            }
        }
    }
}


- (void) backViewControllerActionFired:(id) sender {
    [self.viewController.navigationController popViewControllerAnimated:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _navigationBar.frame = [self frameForTitleBarView];
    _ssWebContainer.frame = [self frameForWebViewContainer];
}


- (CGRect)frameForTitleBarView {
    return CGRectMake(0, 0, self.frame.size.width, 64.f);
}

- (CGRect)frameForWebViewContainer {
    return CGRectMake(0, 0,
                          self.frame.size.width,
                          self.frame.size.height);
}

- (NSString *)currentURLStr {
    if ([SSCommonLogic shouldAppendQueryStirngWithUrl:_ssWebContainer.ssWebView.currentURL]) {
        return [TTNetworkUtilities substringCutOffCommonParasStringFromURLString:[_ssWebContainer.ssWebView.currentURL absoluteString]];
    }
//    return [_ssWebContainer.ssWebView.request.URL absoluteString];
    return _ssWebContainer.ssWebView.currentURL.absoluteString;
}

#pragma mark - handle URL
- (void)loadWithURL:(NSURL *)requestURL {
    
    [self loadWithURL:requestURL requestHeaders:@{@"Referer": [SSWebViewUtil webViewReferrer]}];
}

- (void)loadWithURL:(NSURL *)requestURL shouldAppendQuery:(BOOL)shouldAppendQuery {
    [self loadWithURL:requestURL requestHeaders:@{@"Referer": [SSWebViewUtil webViewReferrer]} shouldAppendQuery:shouldAppendQuery];
}

- (void)loadWithURL:(NSURL *)requestURL requestHeaders:(NSDictionary *)requestHeaders {
    [self loadWithURL:requestURL requestHeaders:requestHeaders shouldAppendQuery:YES];
}

- (void)loadWithURL:(NSURL *)requestURL requestHeaders:(NSDictionary *)requestHeaders shouldAppendQuery:(BOOL)shouldAppendQuery {
    if (self.shouldShowShareAction){
        self.recordShouldShowShareAction = YES;
    }
    else{
        //如果不需要展示，标记一下
        self.recordShouldShowShareAction = NO;
    }
    self.shouldShowShareAction = NO;
    
    NSString *urlString = requestURL.absoluteString;
    
    if (!self.shouldDisableHash) {
        //需要拼接hash参数
        if (self.ssWebContainer.adID.longLongValue == 0) {
            urlString = [self _handleDayNightModeWithURL:requestURL];
        }
    }

    NSDictionary *handledHeaders = [self _handleRequestHeader:requestHeaders];
    
    NSURL *url = [TTStringHelper URLWithURLString:urlString];
    
    NSURLRequest *request = [SSWebViewUtil requestWithURL:url httpHeaderDict:handledHeaders];
    self.mainURLString = request.URL.absoluteString;
    
    [_ssWebContainer loadRequest:request shouldAppendQuery:shouldAppendQuery];
}

//处理日夜间
- (NSString *)_handleDayNightModeWithURL:(NSURL *)origURL {
    //5.9.7 紧急发版.. 不处理阳光视频.
    if ([origURL.host isEqualToString:@"m.365yg.com"] || [origURL.host isEqualToString:@"www.365yg.com"]) {
        return origURL.absoluteString;
    }
    NSString *urlString = nil;
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    NSString *fontSizeType = [TTUserSettingsManager settedFontShortString];
    
//    urlString = [SSWebViewUtil jointFragmentParamsDict:@{@"tt_daymode": isDayModel? @"1": @"0",
//    @"tt_font": fontSizeType} toURL:origURL.absoluteString];
    urlString = origURL.absoluteString;
    return urlString;
}

- (NSDictionary *)_handleRequestHeader:(NSDictionary *)headers {
    if (![headers isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:headers];
    
    NSString *referer = [result tt_stringValueForKey:@"Referer"];
    //只有referer == 头条referer 并且disableTTReferer = YES时才remove @zengruihuan
    if (self.disableTTReferer && [referer isEqualToString:[SSWebViewUtil webViewReferrer]]) {
        [result removeObjectForKey:@"Referer"];
    }
    
    return [result copy];
    
}

#pragma mark -- SSWebViewContainerDelegate

- (void)webViewDidStartLoad:(YSWebView *)webView {
    // webview在load url时，分享相关信息清掉
    self.repostTitle = nil;
    self.shareTitle = nil;
}

- (BOOL)webView:(YSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType {
    BOOL result = YES;
    NSLog(@"request url = %@",[request URL]);
    
    if ([self.ssWebContainer.ssWebView canGoBack] && self.isShowCloseWebBtn) {
        [self.backButtonView showCloseButton:YES];
    }
    
    //针对WKWebview 的下载做一个特殊处理 主动通过openURL去打开AppStore nick -5.6
    if ([ArticleWebViewToAppStoreManager isToAppStoreRequestURLStr:request.URL.absoluteString] && [webView isWKWebView]) {
        
        if ([[UIApplication sharedApplication] canOpenURL:request.URL]) {
            
            [[UIApplication sharedApplication] openURL:request.URL];
            return NO;
        }
    }
    
    if (self.ssWebContainer.adID) {
        /// 如果是广告的，则需要统计连接跳转。需求说明一下，这是一个很蛋疼的统计，要统计广告落地页中，所有跳转的统计
        BOOL needReport = (navigationType == YSWebViewNavigationTypeLinkClicked ||
                           navigationType == YSWebViewNavigationTypeFormSubmitted);
        if (needReport) {
            _jumpCount ++;
            if (navigationType == YSWebViewNavigationTypeLinkClicked) {
                _clickLinkCount ++;
            }
        }
        
        if (navigationType == YSWebViewNavigationTypeLinkClicked || [self clickJumpRecognized]) {
            NSSet *blackList = [SSCommonLogic blackListForClickJump];
            if ([blackList containsObject:request.URL.scheme]) {
                NSString *tips = [SSCommonLogic frobidClickJumpTips];
                if (!isEmptyString(tips)) {
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tips indicatorImage:nil autoDismiss:YES dismissHandler:nil];
                }
                return NO;
            }
        } else if (self.shouldInterceptAutoJump) {
            NSSet *whitList = [SSCommonLogic whiteListForAutoJump];
            if (![whitList containsObject:request.URL.scheme]) {
                return NO;
            }
        }
    }
    //暂时下掉about:blank拦截 @zengruihuan
//    if ([[request.URL absoluteString] isEqualToString:@"about:blank"]) {
//        return NO;
//    }

    return result;
}

- (void)webViewDidFinishLoad:(YSWebView *)webView {
    if (self.recordShouldShowShareAction) {
        self.shouldShowShareAction = YES;
    }
    else{
        self.shouldShowShareAction = NO;
    }
    //广告监控统计 注入js
    if ([self.ssWebContainer.adID longLongValue] > 0) {
        self.webTapGesture.enabled = YES;
        [webView stringByEvaluatingJavaScriptFromString:[SSCommonLogic shouldEvaluateActLogJsStringForAdID:self.ssWebContainer.adID] completionHandler:nil];
    }
    
}

- (void)_sendJumpEventWithCount:(NSInteger) count {
    // 只统计广告的页面停留时间，和qiuliang约定，如果停留时常<3s，则忽略
    if (count <= 0 || isEmptyString(self.ssWebContainer.adID) || self.ssWebContainer.adID.longLongValue == 0) {
        return;
    }
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:@"wap_stat" forKey:@"category"];
    [dict setValue:@"jump_count" forKey:@"tag"];
    [dict setValue:[NSString stringWithFormat:@"%ld", (long)count] forKey:@"value"];
    if (_clickLinkCount > 0) {
        [dict setValue:@(_clickLinkCount) forKey:@"link_count"];
    }
    if (!isEmptyString(self.ssWebContainer.logExtra)) {
        [dict setValue:self.ssWebContainer.logExtra forKey:@"log_extra"];
    }
    else {
        [dict setValue:@"" forKey:@"log_extra"];
    }
    [dict setValue:self.ssWebContainer.adID forKey:@"ext_value"];
    [TTTrackerWrapper eventData:dict];
}

@end
