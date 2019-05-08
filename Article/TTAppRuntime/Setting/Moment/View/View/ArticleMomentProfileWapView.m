//
//  ArticleMomentProfileWapView.m
//  Article
//
//  Created by Chen Hong on 16/1/19.
//
//

#import "ArticleMomentProfileWapView.h"
#import "TTViewWrapper.h"
#import "TTNavigationController.h"
#import "NSDictionary+TTAdditions.h"

#import "TTBlockManager.h"
#import "TTThemedAlertController.h"
#import "TTPhotoScrollViewController.h"
#import "TTActivityShareManager.h"
#import "SSActivityView.h"
#import "ArticleShareManager.h"
#import "TTProfileShareService.h"
#import "TTDeviceHelper.h"

#import <TTAccountBusiness.h>
#import <TTInteractExitHelper.h>

#import <TTRoute/TTRoute.h>
@interface ArticleMomentProfileWapView () <TTMomentProfileProtocol>
@property(nonatomic, strong)NSDictionary *userDict;
@property(nonatomic, strong)UIView *customeNavigationBar;
@property (nonatomic) NSTimeInterval startLoadTime;
@end

@implementation ArticleMomentProfileWapView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.momentProfileDelegate = self;
        
        SSThemedView * baseView = [[SSThemedView alloc] initWithFrame:self.bounds];
        baseView.backgroundColorThemeKey = kColorBackground4;
        baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:baseView];
        
        self.webViewContainer = [[SSJSBridgeWebView alloc] initWithFrame:self.bounds];
        _webViewContainer.disableThemedMask = YES;
        [_webViewContainer addDelegate:self];
        _webViewContainer.scrollView.bounces = NO;
        _webViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        if ([TTDeviceHelper isPadDevice]) {
            TTViewWrapper *wrapperView = [TTViewWrapper viewWithFrame:self.bounds targetView:_webViewContainer];
            [self addSubview:wrapperView];
        }
        else {
            [self addSubview:_webViewContainer];
        }
        
        [self registerJSBridgeHandler];
        
//        [self.webViewContainer.backButtonView setStyle:SSWebViewBackButtonStyleLightContent];
        
        self.startLoadTime = CACurrentMediaTime();
    }
    
    return self;
}

- (void)didAppear {
    [super willAppear];
}

- (void)willDisappear {
    [super willDisappear];
    
//    if ([self.webViewContainer.ssWebContainer.ssWebView.bridge respondsToSelector:@selector(shareManager)]) {
//        [self.webViewContainer.ssWebContainer.ssWebView.bridge setValue:nil forKey:@"_shareManager"];
//    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.webViewContainer.frame = [self frameForWebView];
    self.customeNavigationBar.left = self.webViewContainer.left;
}

- (CGRect)frameForWebView {
    CGFloat offsetY = 0;
    
    if ([TTDeviceHelper isPadDevice]) {
        CGFloat padding = [TTUIResponderHelper paddingForViewWidth:0];
        CGRect rect = self.frame;
        rect.origin.y = offsetY;
        rect.size.height -= offsetY;
        return CGRectInset(rect, padding, 0);
    }
    return CGRectMake(0, offsetY, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - offsetY);
}

- (void)hideNavBar {
//    UIView *backButtonView = _webViewContainer.navigationBar.leftBarView;
//    UIView *customeNavigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(backButtonView.frame), 44)];
//    [self addSubview:customeNavigationBar];
//    [customeNavigationBar addSubview:backButtonView];
//    // customeNavigationBar.backgroundColor = [UIColor yellowColor];
//    backButtonView.left = 8;
//    
//    self.customeNavigationBar = customeNavigationBar;
}

- (void)registerJSBridgeHandler {
    // 控制页面顶部状态条风格和返回按钮颜色
    [self registerSetBackButtonStyle];
    
    // 查看头像大图功能
    [self registerViewFullAvatar];
    
    // 调起客户端的动态分享面板
    //[self registerShare];
    
    // 与RN同步的bridge
    [self registerJSBridge];
}

- (void)registerSetBackButtonStyle
{
    __weak typeof(self) wself = self;
    
//    [self.webViewContainer.ssWebContainer.sswebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
//        if (executeCallback) {
//            *executeCallback = NO;
//        }
//        
//        // style[0:黑色，1:白色]
//        int style = [result intValueForKey:@"style" defaultValue:0];
//        if (style == 1) {
//            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
//            [wself.webViewContainer.backButtonView setStyle:SSWebViewBackButtonStyleLightContent];
//            wself.viewController.ttStatusBarStyle = UIStatusBarStyleLightContent;
//        }
//        else if (style == 0) {
//            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
//            [wself.webViewContainer.backButtonView setStyle:SSWebViewBackButtonStyleDefault];
//            wself.viewController.ttStatusBarStyle = UIStatusBarStyleDefault;
//        }
//        
//        return @{@"code" : @(1)};
//    } forMethodName:@"setBackButtonStyle"];
}

- (void)registerViewFullAvatar
{
    __weak typeof(self) wself = self;
    [self.webViewContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        NSString *avatarUrl = [result stringValueForKey:@"avatar_url" defaultValue:nil];
        id frameObj = [result objectForKey:@"frame"];
        CGRect avatarFrame = [wself frameFromObject:frameObj];
        [wself showFullAvatar:avatarUrl fromFrame:avatarFrame];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"viewFullAvatar"];
}

// 分享
//- (void)registerShare
//{
//    __weak typeof(self) wself = self;
//    [self.webViewContainer.ssWebContainer.sswebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
//        NSDictionary *momentDict = [result dictionaryValueForKey:@"data" defalutValue:nil];
//        ArticleMomentModel *moment = [[ArticleMomentModel alloc] initWithDictionary:momentDict];
//        [wself shareMoment:moment];
//        return @{@"code" : @(1)};
//    } forMethodName:@"update_share"];
//}
//

// 查看头像大图
- (void)showFullAvatar:(NSString *)avatarLargeURLString fromFrame:(CGRect)avatarFrame
{
    if (isEmptyString(avatarLargeURLString)) {
        return;
    }
    
    TTPhotoScrollViewController *showImageViewController = [[TTPhotoScrollViewController alloc] init];
    showImageViewController.targetView = self;
    showImageViewController.finishBackView = [TTInteractExitHelper getSuitableFinishBackViewWithCurrentContext];
    showImageViewController.imageURLs = @[avatarLargeURLString];
    [showImageViewController setStartWithIndex:0];

    if (!CGRectIsEmpty(avatarFrame)) {
        CGRect frame = [self.viewController.view convertRect:avatarFrame fromView:self];
        showImageViewController.placeholderSourceViewFrames = @[[NSValue valueWithCGRect:frame]];
    }
    [showImageViewController presentPhotoScrollView];
}

- (CGRect)frameFromObject:(id)frameID
{
    CGRect frame = CGRectZero;
    if ([frameID isKindOfClass:[NSString class]] && [((NSString *)frameID) length] > 0) {
        frame = CGRectFromString(frameID);
    }
    else if ([frameID isKindOfClass:[NSArray class]] && [((NSArray *)frameID) count] == 4) {
        NSArray * frameAry = (NSArray *)frameID;
        frame.origin.x = (int)([[frameAry objectAtIndex:0] longLongValue]);
        frame.origin.y = (int)([[frameAry objectAtIndex:1] longLongValue]);
        frame.size.width = (int)([[frameAry objectAtIndex:2] longLongValue]);
        frame.size.height = (int)([[frameAry objectAtIndex:3] longLongValue]);
    }
    return frame;
}

- (BOOL)webView:(YSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType {
    if ([request.URL.scheme isEqualToString:@"sslocal"] || [request.URL.scheme hasPrefix:@"snssdk35"]) {
        
        [[TTRoute sharedRoute] openURLByPushViewController:request.URL];
        
        return NO;
    }
    return YES;
}
- (void)webViewDidFinishLoad:(nullable YSWebView *)webView {
    self.requestFailure = NO;
    if (self.startLoadTime > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSNumber *loadTime = @((CACurrentMediaTime() - self.startLoadTime) * 1000); //ms
        [dict setValue:loadTime forKey:@"loadTime"];
        [Answers logCustomEventWithName:@"wap_profile_load" customAttributes:dict];
        [[TTMonitor shareManager] trackService:@"wap_profile_load" value:loadTime extra:nil];
        self.startLoadTime = 0;
    }
}

- (void)webView:(nullable YSWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    if(error.code == 101) return;
    self.requestFailure = YES;
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    if(!isEmptyString(error.description)) {
        [extra setObject:error.description forKey:@"error_description"];
    }
    [extra setObject:@(error.code) forKey:@"error_code"];
    [[TTMonitor shareManager] trackService:@"personal_home_tab_load_failure" status:1 extra:extra];
}


- (void)registerJSBridge {
    
    WeakSelf;

#pragma mark update_share
    [self.webViewContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
//        NSDictionary *momentDict = [result dictionaryValueForKey:@"data" defalutValue:nil];
//        ArticleMomentModel *moment = [[ArticleMomentModel alloc] initWithDictionary:momentDict];
//        [wself shareMoment:moment];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"update_share"];

#pragma mark update_delete
    [self.webViewContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        NSDictionary *moment = [result tt_dictionaryValueForKey:@"moment"];
        NSString *momentID = [moment tt_stringValueForKey:@"id"];
        [wself deleteMoment:momentID];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"update_delete"];

#pragma mark update_comment_delete
    [self.webViewContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        NSString *commentID = [result tt_stringValueForKey:@"id"];
        [wself deleteMomentComment:commentID];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"update_comment_delete"];

#pragma mark update_report
    [self.webViewContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        [wself report:result];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"update_report"];

#pragma mark follow
    [self.webViewContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        [wself follow:result];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"follow"];
    
#pragma mark unfollow
    [self.webViewContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        [wself unfollow:result];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"unfollow"];

#pragma mark block_user
    [self.webViewContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        NSString *userID = [result tt_stringValueForKey:@"id"];
        [wself block:userID isBlock:YES];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"block_user"];

#pragma mark unblock_user
    [self.webViewContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        NSString *userID = [result tt_stringValueForKey:@"id"];
        [wself block:userID isBlock:NO];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"unblock_user"];

#pragma mark update_digg
    [self.webViewContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        NSString *momentID = [result tt_stringValueForKey:@"id"];
        NSString *type = [result tt_stringValueForKey:@"type"];
        if ([type isEqualToString:@"ugc_video_digg"]) {
            [wself updateShortVideoDigg:momentID];
        }
        else{
            [wself updateDigg:momentID];
        }
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"update_digg"];
    
    [self.webViewContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        NSString *momentID = [result tt_stringValueForKey:@"id"];
        NSString *type = [result tt_stringValueForKey:@"type"];
        NSString *userID = [result tt_stringValueForKey:@"user_id"]? :wself.userID;
        if ([type isEqualToString:@"ugc_video_digg"]) {
            [wself cancelShortVideoDigg:momentID];
        }
        else{
            [wself cancelDigg:momentID];
        }
        NSString *event;
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:@"profile" forKey:@"enter_from"];
        [params setValue:@"profile" forKey:@"category_name"];
        [params setValue:userID forKey:@"user_id"];
        if ([type isEqualToString:@"1"] || [type isEqualToString:@"3"] || [type isEqualToString:@"5"] || [type isEqualToString:@"109"] || [type isEqualToString:@"110"]) {
            //评论
            event = @"comment_undigg";
            [params setValue:momentID forKey:@"comment_id"];
        } else {
            //其他
            event = @"rt_unlike";
            [params setValue:momentID forKey:@"group_id"];
        }
        [TTTrackerWrapper eventV3:event params:params];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"delete_digg"];

#pragma mark update_comment_digg
    [self.webViewContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        NSString *comentID = [result tt_stringValueForKey:@"comment_id"];
        [wself updateCommentDigg:comentID];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"update_comment_digg"];

#pragma mark update_write_comment
    //调起Native评论
    [self.webViewContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
//        NSDictionary *momentDict = [result tt_dictionaryValueForKey:@"moment"];     //动态数据
//        int commentIndex = [result intValueForKey:@"comment_index" defaultValue:-1];   //评论数据
//        [wself showCommentViewWithMoment:momentDict commentIndex:commentIndex];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"update_write_comment"];

#pragma mark gallery
    [self.webViewContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        [wself showGallery:result];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"gallery"];
    
#pragma mark init_profile
    [self.webViewContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        NSDictionary *data = [wself parseUserProfileData:result];
        NSString *uid = [data valueForKey:@"user_id"];
        [TTProfileShareService setShareObject:data forUID:uid];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"init_profile"];
    
    [self.webViewContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        if(wself.updateBlock) {
            wself.updateBlock(result);
        }
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"edit_update"];

}

#pragma mark - TTMomentProfileProtocol

- (void)didPublishComment:(NSDictionary *)commentModel momentID:(NSString *)momentID {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setValue:momentID forKey:@"id"];
    [dict setValue:commentModel forKey:@"comment"];
    [self.webViewContainer ttr_fireEvent:@"commentPublishEvent" data:dict];
}

- (void)didDigUpdate:(NSString *)momentID {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setValue:momentID forKey:@"id"];
    [self.webViewContainer ttr_fireEvent:@"updateDiggEvent" data:dict];
}

- (void)didCancelDidUpdate:(NSString *)momentID {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setValue:momentID forKey:@"id"];
    [self.webViewContainer ttr_fireEvent:@"deleteDiggEvent" data:dict];
}

- (void)didDeleteUpdate:(NSString *)momentID {
    if (isEmptyString(momentID)) {
        return;
    }
    [self.webViewContainer ttr_fireEvent:@"updateDeleteEvent" data:@{@"id":momentID}];
}

- (void)didDeleteComment:(NSString *)commentID {
    if (isEmptyString(commentID)) {
        return;
    }
    [self.webViewContainer ttr_fireEvent:@"commentDeleteEvent" data:@{@"comment_id":commentID}];
}

- (void)didDeleteCommentInThread:(NSString *)threadID {
    if (isEmptyString(threadID)) {
        return;
    }
    [self.webViewContainer ttr_fireEvent:@"commentDeleteEvent" data:@{@"id":threadID}];
}

- (void)didForwardUpdate:(NSDictionary *)momentDict {
    if (![TTAccountManager isLogin]) {
        return;
    }
    
    if ([[TTAccountManager userID] longLongValue] != [self.userID longLongValue]) {
        return;
    }
    
    [self.webViewContainer ttr_fireEvent:@"updateForwardEvent" data:momentDict];
}

- (void)didForwardUserInfo:(NSDictionary *)userInfoDict {
    if (![TTAccountManager isLogin]) {
        return;
    }
    
    if ([[TTAccountManager userID] longLongValue] != [self.userID longLongValue]) {
        return;
    }
    
    [self.webViewContainer ttr_fireEvent:@"accountProfileEvent" data:userInfoDict];
}

- (void)didWeitoutiaoForwardUpdate:(NSDictionary *)dataDict {
    /**
     @"repostOperationItemType" : TTRepostOperationItemType
     @"repostOperationItemID" : id
     **/
    NSString *optID = [dataDict tt_stringValueForKey:@"repostOperationItemID"];
    if (!isEmptyString(optID)) {
        [self.webViewContainer ttr_fireEvent:@"updateRepostEvent" data:@{@"id" : optID}];
    }
}

- (void)deleteDetailUGCMovie:(NSDictionary *)dict {
    [self.webViewContainer ttr_fireEvent:@"detail_delete_ugc_movie" data:dict];
}

- (void)didDeleteThread:(NSString *)threadID {
    if (isEmptyString(threadID)) {
        return;
    }
    [self.webViewContainer ttr_fireEvent:@"updateDeleteEvent" data:@{@"id" : threadID}];
}


@end
