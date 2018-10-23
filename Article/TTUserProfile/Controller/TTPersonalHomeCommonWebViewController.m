//
//  TTPersonalHomeCommonWebViewController.m
//  Article
//
//  Created by wangdi on 2017/3/28.
//
//

#import "TTPersonalHomeCommonWebViewController.h"
#import "TTURLUtils.h"
#import "TTThemeManager.h"
#import "Tracker.h"
#import <TTAccountBusiness.h>
#import "TTFollowThemeButton.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTMomentProfileShareHelper.h"
typedef enum {
    TTPersonalHomeActionSheetStateNone,
    TTPersonalHomeActionSheetStateFollow,
    TTPersonalHomeActionSheetStateUnFollow,
    TTPersonalHomeActionSheetStateBlock,
}TTPersonalHomeActionSheetState;

extern const CGFloat kSegmentBottomViewHeight;

@interface TTPersonalHomeCommonWebViewController ()<YSWebViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong, readwrite) ArticleMomentProfileWapView *webView;
@property (nonatomic, strong) NSDictionary *result;
@property (nonatomic, strong) TTPersonalHomeUserInfoDataResponseModel *infoModel;
@property (nonatomic, assign) TTPersonalHomeActionSheetState actionSheetState;
@property (nonatomic, copy) NSDictionary *extraParam;
@property (nonatomic, strong) TTMomentProfileShareHelper     *shareHelper;
@end

@implementation TTPersonalHomeCommonWebViewController

#if INHOUSE
+ (void)load {
    NSString *fePersonalTestHost = [[NSUserDefaults standardUserDefaults] valueForKey:@"FEPersonalTestHost"];
    if (!fePersonalTestHost) {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"FEPersonalTestHost"];
    }
}
#endif

- (void)viewDidLoad {
    [super viewDidLoad];
    self.actionSheetState = TTPersonalHomeActionSheetStateNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themedChange) name:TTThemeManagerThemeModeChangedNotification object:nil];
    [self themedChange];
}

- (BOOL)requestFailure
{
    return self.webView.requestFailure;
}

- (ArticleMomentProfileWapView *)webView
{
    if(!_webView) {
        _webView = [[ArticleMomentProfileWapView alloc] initWithFrame:self.view.bounds];
        _webView.backgroundColorThemeName = kColorBackground4;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.webViewContainer.scrollView.bounces = YES;
//        [_webView.webViewContainer.ssWebContainer hiddenProgressView:YES];
        _webView.webViewContainer.scrollView.backgroundColor = [UIColor colorWithHexString:@"#F4F5F6"];
        _webView.webViewContainer.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
//        _webView.webViewContainer.ssWebContainer.shouldShowLoading = NO;
        [self.view addSubview:_webView];
        __weak typeof(self) weakSelf = self;
        _webView.updateBlock = ^(NSDictionary *result) {
            weakSelf.result = result;
            [weakSelf updateData];
        };
        _webView.followBlock = ^(BOOL isFollow) {
            if(weakSelf.followBlock) {
                weakSelf.followBlock(isFollow);
            }
        };
        if (@available(iOS 11.0, *)) {
            _webView.webViewContainer.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    return _webView;
}

- (void)updateData
{
    UIActionSheet *actionSheet = nil;
    
    NSNumber *userID = self.result[@"moment"][@"user"][@"user_id"];
    if([userID.stringValue isEqualToString:self.infoModel.current_user_id]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除", nil];
        actionSheet.tag = 100;
    } else {
        if(self.infoModel.is_blocking.integerValue == 1) { //已经拉黑
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"解除拉黑",@"举报此内容", nil];
//            self.actionSheetState = TTPersonalHomeActionSheetStateBlock;
        } else {
            if(self.infoModel.is_following.integerValue == 1) {
                actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"取消关注",@"拉黑",@"举报此内容", nil];
                self.actionSheetState = TTPersonalHomeActionSheetStateFollow;
            } else {
                actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"关注",@"拉黑",@"举报此内容", nil];
                self.actionSheetState = TTPersonalHomeActionSheetStateUnFollow;
            }
        }
        actionSheet.tag = 200;
    }
    [actionSheet showInView:self.view];
}

- (void)setInfoModel:(TTPersonalHomeUserInfoDataResponseModel *)infoModel trackDict:(NSDictionary *)dict needAdjustInset:(BOOL)needAdjustInset
{
    self.infoModel = infoModel;
    self.extraParam = dict;
    if(needAdjustInset) {
        UIEdgeInsets inset = self.webView.webViewContainer.scrollView.contentInset;
        if(infoModel.bottom_tab.count > 0) {
            inset.bottom = kSegmentBottomViewHeight;
        } else {
            inset.bottom = 0;
        }
        self.webView.webViewContainer.scrollView.contentInset = inset;
    }
}

#pragma mark - actionSheet代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSNumber *updateId = self.result[@"id"];
    NSNumber *gType = [self.result tt_dictionaryValueForKey:@"moment"][@"type"];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if(updateId) {
        param[@"update_id"] = updateId;
    }
    if(gType) {
        param[@"gtype"] = gType;
    }
    
    if(actionSheet.tag == 100) {
        if(buttonIndex == 0) {
            NSDictionary *moment = [self.result tt_dictionaryValueForKey:@"moment"];
            NSString *momentID = [moment tt_stringValueForKey:@"id_str"];
            if (isEmptyString(momentID)) {
                momentID = [moment tt_stringValueForKey:@"id"];
            }
            [self.webView deleteMoment:momentID];
        }
    } else {
        if(actionSheet.numberOfButtons == 3) {
            if(buttonIndex == 0 && self.infoModel.is_blocking.integerValue == 1) { //取消拉黑
                if(self.blockUserBlock) {
                    wrapperTrackEventWithCustomKeys(@"profile_more", @"deblacklist", self.infoModel.user_id, nil, param);
                    self.blockUserBlock(NO,self.result);
                }
            } else if(buttonIndex == 1) { //举报此内容
                [self.webView report:self.result];
                wrapperTrackEventWithCustomKeys(@"profile_more", @"report", self.infoModel.user_id, nil, param);
            }
        } else if(actionSheet.numberOfButtons == 4) {
            if(buttonIndex == 0) {
                if(self.infoModel.is_following.integerValue == 1 && self.actionSheetState == TTPersonalHomeActionSheetStateFollow) {  //取消关注 或者关注
                    if(self.followBlock) {
                        self.followBlock(NO);
                        wrapperTrackEventWithCustomKeys(@"profile_more", @"update_unfollow", self.infoModel.user_id, nil, param);
                    }
                } else if(self.infoModel.is_following.integerValue == 0 && self.actionSheetState == TTPersonalHomeActionSheetStateUnFollow){ //关注
                    if(self.followBlock) {
                        self.followBlock(YES);
                        wrapperTrackEventWithCustomKeys(@"profile_more", @"update_follow", self.infoModel.user_id, nil, param);
                    }
                }
            } else if(buttonIndex == 1 && self.infoModel.is_blocking.integerValue == 0) { //拉黑
                if(self.blockUserBlock) {
                    wrapperTrackEventWithCustomKeys(@"profile_more", @"click_blacklist", self.infoModel.user_id, nil, param);
                    self.blockUserBlock(YES,self.result);
                }
            } else if(buttonIndex == 2) { //举报此内容
                [self.webView report:self.result];
                wrapperTrackEventWithCustomKeys(@"profile_more", @"report", self.infoModel.user_id, nil, param);
            }
        }
    }
}

- (void)loadRequestWithType:(NSString *)type uri:(NSString *)uri isDefault:(BOOL)isDefault
{
    NSString *host = [CommonURLSetting baseURL];
#if INHOUSE
    NSString *fePersonalTestHost = [[NSUserDefaults standardUserDefaults] valueForKey:@"FEPersonalTestHost"];
    if (!isEmptyString(fePersonalTestHost)) {
        host = fePersonalTestHost;
    }
#endif
    NSString *tmpUrl = [NSString stringWithFormat:@"%@%@",host,uri];
    NSURL *url = [TTURLUtils URLWithString:tmpUrl queryItems:[self paramStringWithType:type isDefault:isDefault]];
    [self.webView.webViewContainer loadRequest:[NSURLRequest requestWithURL:url]];
//    [self.webView.webViewContainer loadWithURL:url shouldAppendQuery:YES];
}

- (void)share
{
    if (!self.shareHelper) {
        self.shareHelper = [[TTMomentProfileShareHelper alloc] init];
    }
    [self.shareHelper shareWithUserID:self.infoModel.user_id? :@""];
}

- (void)reportWithUserID:(NSString *)userID
{
    if(isEmptyString(userID)) return;
    [self.webView report:@{@"uid" : userID}];
//    wrapperTrackEventWithCustomKeys(@"profile_more", @"report", self.infoModel.user_id, nil, nil);
}

- (NSDictionary *)paramStringWithType:(NSString *)type isDefault:(BOOL)isDefault
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if(!isEmptyString(self.infoModel.user_id)) {
        param[@"user_id"] = self.infoModel.user_id;
    }
    if(!isEmptyString(type)) {
        param[@"current_type"] = type;
    }
    if(!isEmptyString(self.infoModel.media_id)) {
        param[@"media_id"] = self.infoModel.media_id;
    }
    if(self.infoModel.is_blocking) {
        param[@"is_blocked"] = [NSString stringWithFormat:@"%@",self.infoModel.is_blocking];
    }
    if(self.infoModel.is_following) {
        param[@"is_following"] = [NSString stringWithFormat:@"%@",self.infoModel.is_following];
    }
    if(!isEmptyString(self.infoModel.current_user_id)) {
        param[@"current_user_id"] = self.infoModel.current_user_id;
    }
    if(!isEmptyString(self.infoModel.ugc_publish_media_id)) {
        param[@"ugc_publish_media_id"] = self.infoModel.ugc_publish_media_id;
    }
    if(self.infoModel.article_limit_enable) {
        param[@"article_limit_enable"] = [NSString stringWithFormat:@"%@",self.infoModel.article_limit_enable];
    }
    if(!isEmptyString(self.infoModel.avatar_url)) {
        param[@"user_logo"] = self.infoModel.avatar_url;
    }
    NSString *followButtonColorSetting = [SSCommonLogic followButtonColorStringForWap];
    if (followButtonColorSetting) {
        param[@"followbtn_template"] = followButtonColorSetting;
    }
    
    if (self.extraParam) {
        [param addEntriesFromDictionary:self.extraParam];
    }

    param[@"is_default_tab"] = [NSString stringWithFormat:@"%@",@(isDefault)];
    
    NSString *projectID = [self projectID];
    if (projectID.length) {
        param[@"tt_project_id"] = projectID;
    }
    
    return  param;
}

//离线包项目id
- (NSString *)projectID {
    NSDictionary *config = [[TTSettingsManager sharedManager] settingForKey:@"tt_h5_offline_config" defaultValue:@{} freeze:NO];
    
    if (![config isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSDictionary *profileConfig = [config tt_dictionaryValueForKey:@"profile"];
    if (![profileConfig tt_boolValueForKey:@"enable"]) {
        return nil;
    }
    
    NSString *projectID = [profileConfig tt_stringValueForKey:@"project_id"];
    
    return projectID;
}

- (void)themedChange
{
    if([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay) {
        self.webView.backgroundColor = [UIColor colorWithHexString:@"#F4F5F6"];
        self.webView.webViewContainer.scrollView.backgroundColor = [UIColor colorWithHexString:@"#F4F5F6"];
    } else {
        self.webView.backgroundColor = [UIColor colorWithHexString:@"#1B1B1B"];
        self.webView.webViewContainer.scrollView.backgroundColor = [UIColor colorWithHexString:@"#1B1B1B"];
    }
}

- (void)updateUserInfo
{
    NSString *userName = [TTAccountManager userName];
    NSString *avatar = [TTAccountManager avatarURLString];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if(!isEmptyString(userName)) {
        param[@"name"] = userName;
    }
    if(!isEmptyString(avatar)) {
        param[@"logo"] = avatar;
    }
    if(!isEmptyString(self.infoModel.user_id)) {
        param[@"uid"] = self.infoModel.user_id;
    }
    [self.webView.webViewContainer ttr_fireEvent:@"updateProfile" data:param];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
