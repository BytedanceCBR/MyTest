//
//  TTPersonalHomeViewController.m
//  Article
//
//  Created by 王迪 on 2017/3/13.
//
//

#import "TTPersonalHomeViewController.h"
#import "TTPersonalHomeHeaderView.h"
#import "TTPersonalHomeSegmentView.h"
#import "TTPersonalHomeBottomSegmentView.h"
#import "TTPersonalHomeTopNavView.h"
#import "TTPersonalHomeHorizontalPagingView.h"
#import "TTPersonalHomeManager.h"
#import "FriendDataManager.h"
#import "TTIndicatorView.h"
#import "SSActivityView.h"
#import "TTPersonalHomeBottomPopView.h"
#import "TTPersonalHomeCommonWebViewController.h"
#import "TTBlockManager.h"
#import "TTPhotoScrollViewController.h"
#import "TTProfileShareService.h"
#import "TTPersonalHomeErrorView.h"
#import "TTTrackerWrapper.h"
#import "ExploreMomentDefine.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import <TTAccountBusiness.h>
#import "TTNavigationController.h"

#import <TTInteractExitHelper.h>
#import "TTInteractExitHelper.h"
//#import "TTRedPacketManager.h"
//#import "TTCertificationConst.h"
#import <UIView+CustomTimingFunction.h>
#import "TTPersonalHomeSinglePlatformFollowersInfoModel.h"
#import <TTVerifyKit/TTVerifyIconHelper.h>
#import <ExploreMomentDefine_Enums.h>
#import "FriendModel.h"

static CGFloat TTMinimumHeaderHeight() {
    if ([TTDeviceHelper isIPhoneXDevice]) {
        return 88.f;
    } else {
        return 64.f;
    }
}

const CGFloat kSegmentBottomViewHeight = 47;

#define kSegmentViewHeight 41

#define kHeaderViewSpreadTopMargin 12
#define kHeaderViewOutTopMargin 2

@interface TTPersonalHomeViewController ()
<
TTHorizontalPagingViewDelegate,
TTHorizontalPagingSegmentViewDelegate,
TTPersonalHomeHeaderViewDelegate,
TTPersonalHomeTopNavViewDelegate,
SSActivityViewDelegate,
TTPersonalHomeBottomSegmentViewDelegate,
TTBlockManagerDelegate,
UIViewControllerErrorHandler,
TTAccountMulticastProtocol
> {
    TTPersonalHomeUserInfoDataResponseModel *_trickModelInLoading;
}

@property (nonatomic, strong) TTPersonalHomeHorizontalPagingView *pagingView;
@property (nonatomic, strong) TTPersonalHomeHeaderView *headerView;
@property (nonatomic, strong) TTPersonalHomeSegmentView *segmentView;
@property (nonatomic, strong) TTPersonalHomeTopNavView *topNavView;
@property (nonatomic, strong) TTPersonalHomeBottomSegmentView *bottomSegmentView;
@property (nonatomic, strong) TTPersonalHomeBottomPopView *popView;
@property (nonatomic, strong) TTPersonalHomeUserInfoResponseModel *userInfoModel;
@property (nonatomic, strong) TTPersonalHomeNavView *navView;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *mediaID;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *refer;
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *fromPage;
@property (nonatomic, copy) NSString *profileUserId;
@property (nonatomic, assign) TTFollowNewSource serverSource;
@property (nonatomic, copy) NSString *serverExtra;
@property (nonatomic, copy) NSString *currentSegmentType;
@property (nonatomic, assign) BOOL isRequestFollow;
@property (nonatomic, assign) BOOL isRequestBlock;
@property (nonatomic, copy) NSString *defaultType;

@property (nonatomic, strong) TTBlockManager *blockUserManager;

@property (nonatomic, strong) NSMutableArray *segmentTitles;

@property (nonatomic, strong) NSMutableDictionary *subControllerDict;

@property (nonatomic, assign) BOOL isFirstEnter;

@property (nonatomic, strong) TTPersonalHomeErrorView *errorView;

@property (nonatomic, assign) CGFloat currentScale;
//为了埋点加的
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) BOOL isClick;
@property (nonatomic, copy) NSDictionary *enterHomepageV3ExtraParams;//enter_homepage 埋点需要带进去一些参数
@property (nonatomic, assign) BOOL needOperationAutoFollowed;
@end

@implementation TTPersonalHomeViewController

- (instancetype)initWithUserID:(NSString *)userID
                       mediaID:(NSString *)mediaID
                         refer:(NSString *)refer
                        source:(NSString *)source
                      fromPage:(NSString *)fromPage
                      category:(NSString *)categoryName
                       groupId:(NSString *)groupId
                 profileUserId:(NSString *)profileUserId
                   serverExtra:(NSString *)serverExtra
    enterHomepageV3ExtraParams:(NSDictionary *)enterHomepageV3ExtraParams
{
    if(self = [super init]) {
        self.userID = userID;
        self.mediaID = mediaID;
        self.refer = refer;
        self.source = source;
        self.fromPage = fromPage;
        self.categoryName = categoryName;
        self.groupId = groupId;
        self.profileUserId = profileUserId;
        self.serverExtra = serverExtra;
        self.enterHomepageV3ExtraParams = enterHomepageV3ExtraParams;
    }
    return self;
}

- (void)configWithUserName:(NSString *)userName
                    avatar:(NSString *)avatarURL
              userAuthInfo:(NSString *)userAuthInfo
               isFollowing:(BOOL)isFollowing
                isFollowed:(BOOL)isFollowed
                   summary:(NSString *)summary
               followCount:(NSUInteger)followCount
                 fansCount:(NSUInteger)fansCount {
    if (isEmptyString(userName)) {
        return;
    }
    
    _trickModelInLoading = [[TTPersonalHomeUserInfoDataResponseModel alloc] init];
    _trickModelInLoading.name = userName;
    _trickModelInLoading.screen_name = userName;
    _trickModelInLoading.avatar_url = avatarURL;
    _trickModelInLoading.big_avatar_url = avatarURL;
    _trickModelInLoading.desc = summary;
    _trickModelInLoading.is_followed = @(isFollowed);
    _trickModelInLoading.is_following = @(isFollowing);
    _trickModelInLoading.user_id = self.userID;
    _trickModelInLoading.current_user_id = [TTAccountManager userID];
    _trickModelInLoading.followings_count = @(followCount);
    _trickModelInLoading.followers_count = @(fansCount);
    
    if (!isEmptyString(userAuthInfo)) {
        _trickModelInLoading.verified_agency = @"头条认证";
        _trickModelInLoading.user_auth_info = userAuthInfo;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirstEnter = YES;
    [self themedChange];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockUserNotification:) name:kTTJSOrRNBlockOrUnBlockUserNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportUserNotification:) name:kTTJSOrRNReportUserNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followChangeNotification:) name:RelationActionSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendModelChangedNotification:) name:KFriendModelChangedNotification object:nil];
    [TTAccount addMulticastDelegate:self];
    
    self.ttContentInset = UIEdgeInsetsMake(TTMinimumHeaderHeight(), 0, 0, 0);
    [self.view addSubview:self.navView];
    if (_trickModelInLoading) {
        self.topNavView.hidden = NO;
        self.headerView.infoModel = _trickModelInLoading;
        self.topNavView.infoModel = _trickModelInLoading;
        
        [self setupSubview];
        [self.pagingView reloadHeaderViewHeight:self.headerView.height];
    } else {
        [self tt_startUpdate];
    }
    
    
    
    if ([self.fromPage hasPrefix:@"weixin"]) {
        self.needOperationAutoFollowed = YES;
        self.serverSource = TTFollowNewSourceWeixinPersonalHome;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!self.headerView.operationView.followButton.isLoading) {
        [self loadUserInfoData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.currentScale >= 0.8) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
        self.ttStatusBarStyle = UIStatusBarStyleDefault;
        self.parentViewController.ttStatusBarStyle = UIStatusBarStyleDefault;
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        self.ttStatusBarStyle = UIStatusBarStyleLightContent;
        self.parentViewController.ttStatusBarStyle = UIStatusBarStyleLightContent;
    }
    
    if ([[UIApplication sharedApplication] isStatusBarHidden]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGFloat bottomInset = self.view.tt_safeAreaInsets.bottom;
    self.topNavView.height = TTMinimumHeaderHeight();
    self.ttContentInset = UIEdgeInsetsMake(TTMinimumHeaderHeight(), 0, 0, 0);
    self.pagingView.segmentTopSpace = TTMinimumHeaderHeight();
    self.navView.height = TTMinimumHeaderHeight();
    self.bottomSegmentView.height = bottomInset + kSegmentBottomViewHeight;
    self.bottomSegmentView.top = self.view.height - self.bottomSegmentView.height;
}

-(BOOL)tt_hasValidateData
{
    return NO;
}

- (NSMutableDictionary *)subControllerDict
{
    if(!_subControllerDict) {
        _subControllerDict = [NSMutableDictionary dictionary];
    }
    return _subControllerDict;
}

- (TTBlockManager *)blockUserManager
{
    if(!_blockUserManager) {
        _blockUserManager = [[TTBlockManager alloc] init];
        _blockUserManager.delegate = self;
    }
    return _blockUserManager;
}

- (void)setupSubview
{
    [self.view addSubview:self.pagingView];
    [self.view addSubview:self.topNavView];
    [self.view addSubview:self.bottomSegmentView];
}

- (void)loadUserInfoData
{
    //    __weak typeof(self) weakSelf = self;
    self.startTime = CFAbsoluteTimeGetCurrent();
    WeakSelf;
    [[TTPersonalHomeManager sharedInstance] requestPersonalHomeUserInfoWithUserID:self.userID mediaID:self.mediaID refer:self.refer Completion:^(NSError *error, TTPersonalHomeUserInfoResponseModel *responseModel,FRForumMonitorModel *monitorModel) {
        StrongSelf;
        if (monitorModel) {
            monitorModel.monitorService = @"personal_home_header_info";
            NSMutableDictionary *extra = [NSMutableDictionary dictionary];
            [extra setValue:error.description forKey:@"error_description"];
            [extra setValue:@(error.code) forKey:@"error_code"];
            [extra setValue:error.userInfo forKey:@"error_userInfo"];
            [extra setValue:self.userID forKey:@"user_id"];
            [extra setValue:self.mediaID forKey:@"media_id"];
            monitorModel.monitorExtra = extra;
        }
        
        if(self.isFirstEnter) {
            [self tt_endUpdataData:NO error:error];
            [self.navView removeFromSuperview];
            self.navView = nil;
            [self setupSubview];
        }
        [self.errorView removeFromSuperview];
        if(!error) {
            self.topNavView.hidden = NO;
            self.userInfoModel = responseModel;
            [self setupUserInfoData];
            if (self.needOperationAutoFollowed && ![responseModel.data.is_following boolValue]) {
                self.needOperationAutoFollowed = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self headerViewDidSelectedFollow];
                });
            }
        } else {
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
            
            NSString *name = [error.userInfo tt_stringValueForKey:@"name"];
            NSString *description = [error.userInfo tt_stringValueForKey:@"description"];
            BOOL isFollow = [error.userInfo tt_boolValueForKey:@"is_following"];
            NSString *usrid =  [error.userInfo tt_stringValueForKey:@"user_id"];
            
            if (name && [name isKindOfClass:[NSString class]] && [name isEqualToString:@"user_is_banned"]) {
                if (isFollow == YES) {
                    [self.view addSubview:self.errorView];
                    
                    self.errorView.errorString = description;
                    
                    if (usrid) {
                        self.errorView.userId = [NSString stringWithFormat:@"%@",usrid];
                    }
                    
                    self.errorView.errorType = ErrorTypeClosureFollowError;
                }
                
                else {
                    [self.view addSubview:self.errorView];
                    
                    self.errorView.errorString = description;
                    self.errorView.errorType = ErrorTypeClosureError;
                }
                return ;
            }
            
            else if (name || description){
                [self.view addSubview:self.errorView];
                
                self.errorView.errorString = description;
                self.errorView.errorType = ErrorTypeDataError;
                
                return ;
            }
            
            if(self.ttErrorView.viewType == TTFullScreenErrorViewTypeNetWorkError) {
                [self.view addSubview:self.errorView];
                self.errorView.errorType = ErrorTypeNetWorkError;
            }
        }
    }];
}

- (void)setupUserInfoData
{
    if(!self.isFirstEnter) {
        self.headerView.infoModel = self.userInfoModel.data;
        self.topNavView.infoModel = self.userInfoModel.data;
        [self updateSubControllerModel];
        [self.pagingView reloadHeaderViewHeight:self.headerView.height];
        
        [TTProfileShareService setShareObject:[self shareObject] forUID:self.userInfoModel.data.user_id];
    } else {
        NSMutableArray *titles = [NSMutableArray array];
        NSMutableArray *tabArray = [self.userInfoModel.data.top_tab mutableCopy];
        if(self.userInfoModel.data.star_chart && self.userInfoModel.data.star_chart.Rate.integerValue <= 100 && self.userInfoModel.data.star_chart.Rate.integerValue > 0) {
            // Lite尚不支持“频道”tab的跳转，此处先注释掉，后续接入UGC后再开启
//            TTPersonalHomeUserInfoDataItemResponseModel *item = [[TTPersonalHomeUserInfoDataItemResponseModel alloc] init];
//            item.show_name = @"频道";
//            [tabArray addObject:item];
        }
        NSInteger selectedIndex = 0;
        for(NSInteger i = 0;i < tabArray.count;i++) {
            TTPersonalHomeUserInfoDataItemResponseModel *item = tabArray[i];
            if(!isEmptyString(item.show_name)) {
                [titles addObject:item.show_name];
            }
            if(item.is_default.integerValue == 1) {
                selectedIndex = i;
                self.currentSegmentType = item.type;
                self.defaultType = item.type;
            }
        }
        
        if(self.userInfoModel.data.bottom_tab.count == 0) {
            self.bottomSegmentView.hidden = YES;
        } else {
//            self.bottomSegmentView.hidden = NO;
            self.bottomSegmentView.items = self.userInfoModel.data.bottom_tab;
        }
        self.segmentView.selectedIndex = selectedIndex;
        self.segmentView.titles = titles;
        self.segmentTitles = titles;
        self.headerView.infoModel = self.userInfoModel.data;
        
        [TTProfileShareService setShareObject:[self shareObject] forUID:self.userInfoModel.data.user_id];
        
        [self setupSubController];
        [self.pagingView reloadData];
        CGFloat deltaTime = CFAbsoluteTimeGetCurrent() - self.startTime;
        if(deltaTime >= 0) {
            wrapperTrackEventWithCustomKeys(@"stay_profile", @"enter_homepage", self.userInfoModel.data.user_id, nil, @{@"user_loadtime" : @(deltaTime)});
        }
        
        if([self.source isEqualToString:@"recommend_personal_home"]) {
            wrapperTrackEventWithCustomKeys(@"follow_sug", @"enter_profile", self.userInfoModel.data.user_id, nil, nil);
        } else {//搜索结果页由于会自己发埋点，这里就不发了
            //            if([self.userInfoModel.data.current_user_id isEqualToString:self.userInfoModel.data.user_id]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:self.userInfoModel.data.user_id forKey:@"to_user_id"];
            [dict setValue:self.categoryName forKey:@"category_name"];
            [dict setValue:self.fromPage forKey:@"from_page"];
            [dict setValue:self.groupId forKey:@"group_id"];
            [dict setValue:self.profileUserId forKey:@"profile_user_id"];
            [dict setValue:self.serverExtra forKey:@"server_extra"];
            [dict addEntriesFromDictionary:self.enterHomepageV3ExtraParams];
            [TTTrackerWrapper eventV3:@"enter_homepage" params:dict];
        }
    }
}

- (NSDictionary *)shareObject
{
    NSMutableDictionary *shareObject = [NSMutableDictionary dictionary];
    if(!isEmptyString(self.userInfoModel.data.avatar_url)) {
        shareObject[@"avatar_url"] = self.userInfoModel.data.avatar_url;
    }
    if(!isEmptyString(self.userInfoModel.data.desc)) {
        shareObject[@"description"] = self.userInfoModel.data.desc;
    }
    if(self.userInfoModel.data.followers_count) {
        shareObject[@"followers_count"] = self.userInfoModel.data.followers_count;
    }
    if(self.userInfoModel.data.is_blocking) {
        shareObject[@"is_blocking"] = self.userInfoModel.data.is_blocking;
    }
    if(!isEmptyString(self.userInfoModel.data.share_url)) {
        shareObject[@"share_url"] = self.userInfoModel.data.share_url;
    }
    if(!isEmptyString(self.userInfoModel.data.user_id)) {
        shareObject[@"user_id"] = self.userInfoModel.data.user_id;
    }
    if(!isEmptyString(self.userInfoModel.data.media_id)) {
        shareObject[@"media_id"] = self.userInfoModel.data.media_id;
    }
    if(!isEmptyString(self.userInfoModel.data.name)) {
        shareObject[@"name"] = self.userInfoModel.data.name;
    }
    return shareObject.count > 0 ? shareObject : nil;
}

- (void)setUserInfoModel:(TTPersonalHomeUserInfoResponseModel *)userInfoModel
{
    _userInfoModel = userInfoModel;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if(isEmptyString(userInfoModel.data.name)) {
        [param setObject:@(1) forKey:@"name_error"];
    }
    if(isEmptyString(userInfoModel.data.avatar_url)) {
        [param setObject:@(1) forKey:@"avatar_error"];
    }
    if(userInfoModel.data.top_tab.count <= 0) {
        [param setObject:@(1) forKey:@"tab_error"];
    }
    if(param.count > 0) {
        [[TTMonitor shareManager] trackService:@"personal_home_info_error" status:1 extra:param];
    }
}

- (TTPersonalHomeTopNavView *)topNavView
{
    if(!_topNavView) {
        _topNavView = [[TTPersonalHomeTopNavView alloc] init];
        _topNavView.backgroundColor = [UIColor whiteColor];
        [_topNavView updateBarTranslucentWithScale:0];
        _topNavView.hidden = YES;
        _topNavView.delegate = self;
        _topNavView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _topNavView.frame = CGRectMake(0, 0, self.view.width, TTMinimumHeaderHeight());
        [_topNavView.privateMessageBtn addTarget:self action:@selector(headerViewDidSelectedPrivateMessage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _topNavView;
}

- (TTPersonalHomeHorizontalPagingView *)pagingView
{
    if(!_pagingView) {
        _pagingView = [[TTPersonalHomeHorizontalPagingView alloc] init];
        _pagingView.delegate = self;
        _pagingView.frame = self.view.bounds;
        _pagingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _pagingView.segmentTopSpace = TTMinimumHeaderHeight();
        _pagingView.horizontalCollectionView.scrollEnabled = NO;
        _pagingView.clipsToBounds = YES;
    }
    return _pagingView;
}

- (TTPersonalHomeHeaderView *)headerView
{
    if(!_headerView) {
        _headerView = [[TTPersonalHomeHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
        _headerView.delegate = self;
        _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _headerView;
}

- (TTPersonalHomeBottomSegmentView *)bottomSegmentView
{
    if(!_bottomSegmentView) {
        _bottomSegmentView = [[TTPersonalHomeBottomSegmentView alloc] init];
        _bottomSegmentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _bottomSegmentView.frame = CGRectMake(0, self.view.height - kSegmentBottomViewHeight, self.view.width, kSegmentBottomViewHeight);
        _bottomSegmentView.hidden = YES;
        _bottomSegmentView.delegate = self;
        _bottomSegmentView.hidden = YES;
    }
    return _bottomSegmentView;
}

- (TTPersonalHomeBottomPopView *)popView
{
    if(!_popView) {
        _popView = [[TTPersonalHomeBottomPopView alloc] init];
    }
    return _popView;
}

- (TTPersonalHomeSegmentView *)segmentView
{
    if(!_segmentView) {
        _segmentView = [[TTPersonalHomeSegmentView alloc] init];
        _segmentView.delegate = self;
        [_segmentView setUpTitleEffect:^(NSString *__autoreleasing *titleScrollViewColorKey, NSString *__autoreleasing *norColorKey, NSString *__autoreleasing *selColorKey, UIFont *__autoreleasing *titleFont) {
            *norColorKey = kColorText1;
            *selColorKey = kAKMainColorHex;
            *titleFont = [UIFont systemFontOfSize:15];
        }];
        [_segmentView setUpUnderLineEffect:^(BOOL *isUnderLineDelayScroll, CGFloat *underLineH, NSString *__autoreleasing *underLineColorKey, BOOL *isUnderLineEqualTitleWidth) {
            *isUnderLineDelayScroll = NO;
            *underLineH = 2;
            *underLineColorKey = kAKMainColorHex;
            *isUnderLineEqualTitleWidth = YES;
        }];
    }
    _segmentView.backgroundColor = [UIColor clearColor];
    _segmentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    return _segmentView;
}

- (TTPersonalHomeErrorView *)errorView
{
    if(!_errorView) {
        _errorView = [[TTPersonalHomeErrorView alloc] init];
        _errorView.frame = self.view.bounds;
        _errorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        __weak typeof(self) weakSelf = self;
        _errorView.backBlock = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        _errorView.retryConnectionNetworkBlock = ^{
            [weakSelf loadUserInfoData];
        };
        
    }
    return _errorView;
}

- (TTPersonalHomeNavView *)navView
{
    if(!_navView) {
        _navView = [[TTPersonalHomeNavView alloc] init];
        _navView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _navView.frame = CGRectMake(0, 0, self.view.width, TTMinimumHeaderHeight());
        __weak typeof(self) weakSelf = self;
        _navView.backBlock = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
    }
    return _navView;
}

#pragma mark - pagingView 代理

- (NSInteger)numberOfSectionsInPagingView:(TTHorizontalPagingView *)pagingView
{
    return self.userInfoModel.data.top_tab.count;
}

- (UIScrollView *)pagingView:(TTHorizontalPagingView *)pagingView viewAtIndex:(NSInteger)index
{
    index = MIN(self.userInfoModel.data.top_tab.count - 1, index);
    TTPersonalHomeUserInfoDataItemResponseModel *model = self.userInfoModel.data.top_tab[index];
    TTPersonalHomeCommonWebViewController *webViewController = self.subControllerDict[model.type];
    BOOL isDefault = [model.type isEqualToString:self.defaultType];
    [webViewController loadRequestWithType:model.type uri:model.native_index_url isDefault:isDefault];
    return webViewController.webView.webViewContainer.scrollView;
    
}

- (void)pagingView:(TTHorizontalPagingView *)pagingView didSwitchIndex:(NSInteger)aIndex to:(NSInteger)toIndex
{
    toIndex = MIN(self.userInfoModel.data.top_tab.count - 1, toIndex);
    TTPersonalHomeUserInfoDataItemResponseModel *model = self.userInfoModel.data.top_tab[toIndex];
    TTPersonalHomeCommonWebViewController *webViewController = self.subControllerDict[model.type];
    self.currentSegmentType = model.type;
    if(webViewController.requestFailure) {
        [webViewController loadRequestWithType:model.type uri:model.native_index_url isDefault:NO];
    }
    
    NSString *key = [self tabKeyWithType:model.type];
    if(isEmptyString(key)) return;
    if(self.isClick) {
        self.isClick = NO;
        wrapperTrackEventWithCustomKeys(@"profile", [NSString stringWithFormat:@"enter_%@",key], self.userInfoModel.data.user_id, nil, nil);
    } else {
        wrapperTrackEventWithCustomKeys(@"profile", [NSString stringWithFormat:@"slide_%@",key], self.userInfoModel.data.user_id, nil, nil);
    }
}

- (UIView *)viewForHeaderInPagingView
{
    return self.headerView;
}

- (CGFloat)heightForHeaderInPagingView
{
    return self.headerView.height;
}

- (UIView *)viewForSegmentInPagingView
{
    return self.segmentView;
}

- (CGFloat)heightForSegmentInPagingView
{
    return kSegmentViewHeight;
}

- (void)pagingView:(TTHorizontalPagingView *)pagingView scrollTopOffset:(CGFloat)offset
{
    if(self.pagingView.isAnimation) return;
    [self updateNavWithOffset:offset];
    [self updateZoomViewWithOffset:offset];
    self.topNavView.infoModel = self.userInfoModel.data;
}

#pragma mark - segmentView 代理
- (void)segmentView:(TTHorizontalPagingSegmentView *)segmentView didSelectedItemAtIndex:(NSInteger)index toIndex:(NSInteger)toIndex
{
    self.isClick = YES;
    if(self.isFirstEnter) {
        [self.pagingView scrollToIndex:toIndex withAnimation:NO];
        self.isFirstEnter = NO;
    } else {
        
        if(!TTNetworkConnected()) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"网络异常，请检查网络后重试", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        }
        
        NSString *title = self.segmentTitles[toIndex];
        if([title isEqualToString:@"频道"]) {
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:self.userInfoModel.data.star_chart.url]];
        } else {
            [self.pagingView scrollToIndex:toIndex withAnimation:YES];
        }
    }
}

#pragma mark - bottomSegmentView 代理
- (void)bottomSegmentView:(TTPersonalHomeBottomSegmentView *)segmentView didSelectedItem:(TTPersonalHomeUserInfoDataBottomItemResponseModel *)item didSelectedPoint:(CGPoint)point didSelectedIndex:(NSInteger)index
{
    if(item.children.count > 0) {
        CGPoint convertPoint = [self.view convertPoint:point fromView:self.bottomSegmentView];
        CGPoint tmpPoint = CGPointMake(convertPoint.x, self.view.height - self.bottomSegmentView.height - 5);
        [self.popView showFromPoint:tmpPoint superView:self.view dataSource:item.children];
    } else {
        if(!TTNetworkConnected()) return;
        NSString *urlStr = [TTURLUtils queryItemAddingPercentEscapes:item.value];
        urlStr = [NSString stringWithFormat:@"sslocal://webview?url=%@",urlStr];
        NSURL *url = [TTURLUtils URLWithString:urlStr];
        [[TTRoute sharedRoute] openURLByPushViewController:url];
    }
    
    wrapperTrackEventWithCustomKeys(@"profile", @"click_profile_firstmenu", self.userInfoModel.data.user_id, nil, @{@"location": @(index + 1)});
}

#pragma mark - navigationView 代理
- (void)navigationViewdidSelectedFollow:(BOOL)isFollow
{
    if(isFollow) {
        [self requestFollowWithIsTopRequest:YES];
    } else {
        
        [self requestCancelFollowWithIsTopRequest:YES];
    }
}

- (void)navigationviewDidSelectedBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navigationViewDidSelectedShare
{
    if(isEmptyString(self.currentSegmentType)) return;
    
    //底层使用shareObject为单例，为避免由于其他vc dealloc时清空，每次点击都写入一遍。
    NSDictionary* shareDic = [self shareObject];
    if (shareDic && self.userInfoModel.data.user_id) {
        [TTProfileShareService setShareObject:shareDic forUID:self.userInfoModel.data.user_id];
    }
    
    TTPersonalHomeCommonWebViewController *controller = self.subControllerDict[self.currentSegmentType];
    [controller share];
}

#pragma mark - headerview 代理
- (void)headerViewDidSelectedFollow
{
    [self requestFollowWithIsTopRequest:NO];
}

- (void)headerViewDidSelectedCancelFollow
{
    [self requestCancelFollowWithIsTopRequest:NO];
}

- (void)headerViewDidSelectedUnBlock
{
    [self requestUnBlockUser];
    NSString *key = [self tabKeyWithType:self.currentSegmentType];
    if(isEmptyString(key)) return;
    wrapperTrackEventWithCustomKeys(@"prifile_more", @"quit_blacklist", self.userInfoModel.data.user_id, nil, @{@"gtype" : key});
}

- (void)headerViewDidSelectedIconView
{
    if(isEmptyString(self.userInfoModel.data.big_avatar_url)) return;
    wrapperTrackEventWithCustomKeys(@"profile", @"show_avatar", self.userInfoModel.data.user_id, nil, nil);
    TTPhotoScrollViewController *showImageViewController = [[TTPhotoScrollViewController alloc] init];
    showImageViewController.whiteMaskViewEnable = NO;
    showImageViewController.finishBackView = [TTInteractExitHelper getSuitableFinishBackViewWithCurrentContext];
    showImageViewController.imageURLs = @[self.userInfoModel.data.big_avatar_url];
    CGRect placeHolderFrame = [self.view convertRect:self.headerView.operationView.iconView.frame fromView:self.headerView.operationView];
    showImageViewController.placeholderSourceViewFrames = @[[NSValue valueWithCGRect:placeHolderFrame]];
    [showImageViewController setStartWithIndex:0];
    [showImageViewController presentPhotoScrollView];
}

- (void)headerViewDidSelectedPrivateMessage
{
    if(isEmptyString(self.userInfoModel.data.user_id))return;
    if(![TTAccountManager isLogin]) {
        UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:[TTUIResponderHelper topmostViewController]];
        [TTAccountManager presentQuickLoginFromVC:nav type:TTAccountLoginDialogTitleTypeDefault source:nil isPasswordStyle:NO completion:^(TTAccountLoginState state) {
        }];
        wrapperTrackEventWithCustomKeys(@"profile", @"private_letter", self.userInfoModel.data.user_id, nil, @{@"islogin" : @"logout"});
        return;
    }
    
    if(self.userInfoModel.data.is_following.boolValue == 0) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"关注后才可发私信", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        
        wrapperTrackEventWithCustomKeys(@"profile", @"private_letter", self.userInfoModel.data.user_id, nil, @{@"fans" : @"not_fans"});
        return;
    } else {
        wrapperTrackEventWithCustomKeys(@"profile", @"private_letter", self.userInfoModel.data.user_id, nil, @{@"fans" : @"fans"});
    }
    
    NSMutableDictionary *param =[NSMutableDictionary dictionary];
    param[@"uid"] = self.userInfoModel.data.user_id;
    param[@"from"] = @"profile_enter";
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://private_letter"] userInfo:TTRouteUserInfoWithDict(param)];
}

- (void)headerViewDidSelectedProfile
{
    NSURL *url = [NSURL URLWithString:@"sslocal://account_manager?"];
    [[TTRoute sharedRoute] openURLByPushViewController:url];
}

//- (void)headerViewDidSelectedCertification
//{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *applyMonth = [userDefaults stringForKey:kCertificaitonMonthApplyMonthKey];
//    NSInteger applyNumber = [userDefaults integerForKey:kCertificaitonMonthApplyDateKey];
//    NSDate *date = [NSDate date];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    [formatter setDateFormat:@"yyyyMM"];
//    NSString *nowMonth = [formatter stringFromDate:date];
//    
//    if (!isEmptyString(self.userInfoModel.data.user_auth_info) || ![applyMonth isEqualToString:nowMonth] || applyNumber < 2) {//本月申请少于两次或新的月
//        NSURL *url = [NSURL URLWithString:self.userInfoModel.data.apply_auth_url];
//        [[TTRoute sharedRoute] openURLByPushViewController:url];
//        NSString *verifyInfo = [TTAccountManager userAuthInfo];
//        BOOL isVerifiedUser = !isEmptyString(verifyInfo);
//        NSString *event = isVerifiedUser ? @"certificate_v_apply" : @"certificate_identity";
//        NSString *verifyType = [TTVerifyIconHelper verifyTypeOfVerifyInfo:verifyInfo];
//        NSString *status = @"";
//        if ([verifyType isEqualToString:KTTVerifyNoVVerifyType] || !isVerifiedUser) {
//            //已实名认证 未加V || 未实名
//            status = @"not_identity";
//        } else {
//            status = @"identity";
//        }
//        NSDictionary *params = @{@"source": @"homepage", @"status": status};
//        [TTTracker eventV3:event params:params];
//    } else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"本月提交认证过于频繁，请核实信息后下月重试" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
//        [alert show];
//    }
//}

- (void)headerViewDidSelectedStar
{
    if(!TTNetworkConnected()) return;
    NSURL *url = [NSURL URLWithString:@"sslocal://webview?url=https://ic.snssdk.com/ugc/star/chart/&source=user_profile&hide_bar=1&title="];
    [[TTRoute sharedRoute] openURLByPushViewController:url];
    wrapperTrackEventWithCustomKeys(@"profile", @"click_star_ranking", self.userInfoModel.data.user_id, nil, @{@"ranking" : @(self.userInfoModel.data.star_chart.Rate.integerValue)});
}

- (void)headerView:(TTPersonalHomeHeaderView *)headerView didSelectedFollowSpreadOut:(BOOL)isSpread
{
//    if(headerView.recommendFollowView.collectionView.allUserModels.count == 0) {[self stopLoadingAndRefreshFollowButtonState]; return;}
//    if(isSpread && self.headerView.recommendFollowView.isSpread) {[self stopLoadingAndRefreshFollowButtonState]; return;}
//    if(!isSpread && !self.headerView.recommendFollowView.isSpread) {[self stopLoadingAndRefreshFollowButtonState]; return;}
//    [self.headerView showRecommendViewIsSpread:isSpread];
//    CGFloat recommendViewHeight = self.headerView.recommendFollowView.height;
//    if(isSpread) {
//        [self.headerView adjustInfoViewTopMargin:kHeaderViewSpreadTopMargin];
//    } else {
//        [self.headerView adjustInfoViewTopMargin:kHeaderViewOutTopMargin];
//    }
//    CGFloat heihgt = isSpread ? self.headerView.height + recommendViewHeight : self.headerView.height - recommendViewHeight;
    [UIView animateWithDuration:kHeaderAnimationTime delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.pagingView.isAnimation = YES;
        self.pagingView.ignoreAdjust = YES;
//        if(isSpread) {
//            [self.pagingView reloadHeaderViewHeight:heihgt];
//            self.headerView.infoView.top  += recommendViewHeight;
//        } else {
//            [self.pagingView reloadHeaderViewHeight:heihgt];
//            self.headerView.infoView.top  -= recommendViewHeight;
//        }
//        self.headerView.xiguaLiveView.top = self.headerView.infoView.bottom;
    } completion:^(BOOL finished) {
        self.pagingView.isAnimation = NO;
        self.pagingView.ignoreAdjust = NO;
        [self.headerView.operationView.followButton stopLoading:nil];
        self.isRequestFollow = NO;
        self.headerView.operationView.followButton.followed = self.userInfoModel.data.is_following.boolValue;
    }];
}

- (void)stopLoadingAndRefreshFollowButtonState {
    [self.headerView.operationView.followButton stopLoading:nil];
    self.headerView.operationView.followButton.followed = self.userInfoModel.data.is_following.boolValue;
    self.isRequestFollow = NO;
}

- (void)headerView:(TTPersonalHomeHeaderView *)headerView didSelectedIntroduceSpreadOut:(BOOL)isSpread
{
    self.pagingView.isAnimation = YES;
    if(isSpread) {
        [self.headerView adjustInfoViewTopMargin:self.headerView.infoView.headerViewTopMargin];
    } else {
        [self.headerView adjustInfoViewTopMargin:self.headerView.infoView.headerViewTopMargin];
    }
    wrapperTrackEventWithCustomKeys(@"profile", @"signature_detail", self.userInfoModel.data.user_id, nil, nil);
    [self.pagingView reloadHeaderViewHeight:self.headerView.height];
    self.pagingView.isAnimation = NO;
}

- (void)headerView:(TTPersonalHomeHeaderView *)headerView didSelectedMultiplePlatformFollowersInfoViewSpreadOut:(BOOL)spreadOut
{
    BOOL originalClipsToBounds = self.headerView.clipsToBounds;
    self.headerView.clipsToBounds = YES;
    [UIView animateWithDuration:0.2 customTimingFunction:CustomTimingFunctionSineOut animation:^{
        self.pagingView.isAnimation = YES;
        self.pagingView.ignoreAdjust = YES;
        [self.headerView refreshUIWithMultiplePlatformFollowersInfoViewSpreadOut:spreadOut];
        [self.pagingView reloadHeaderViewHeight:self.headerView.height];
    } completion:^(BOOL finished) {
        self.headerView.clipsToBounds = originalClipsToBounds;
        self.pagingView.isAnimation = NO;
        self.pagingView.ignoreAdjust = NO;
    }];
}

#pragma mark - blockUserManager 代理
- (void)blockUserManager:(TTBlockManager *)manager blocResult:(BOOL)success blockedUserID:(NSString *)userID error:(NSError *)error errorTip:(NSString *)errorTip
{
    self.isRequestBlock = NO;
    if (error) {
        NSString * failedDescription = @"操作失败，请重试";
        if (!isEmptyString(errorTip)) {
            failedDescription = errorTip;
        }
        
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:failedDescription indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    } else {
        self.userInfoModel.data.is_blocking = @(1);
        if(self.userInfoModel.data.is_following.boolValue == 1 && self.userInfoModel.data.is_followed.integerValue == 1) { //互相关注
            [self updateFollowersCountWithFollowing:NO];
            NSInteger followsingCount = self.userInfoModel.data.followings_count.integerValue;
            followsingCount = followsingCount - 1 < 0 ? 0 : followsingCount - 1;
            self.userInfoModel.data.followings_count = @(followsingCount);
        } else if(self.userInfoModel.data.is_following.boolValue == 1) {
            [self updateFollowersCountWithFollowing:NO];
        } else if(self.userInfoModel.data.is_followed.integerValue == 1) {
            NSInteger followsingCount = self.userInfoModel.data.followings_count.integerValue;
            followsingCount = followsingCount - 1 < 0 ? 0 : followsingCount - 1;
            self.userInfoModel.data.followings_count = @(followsingCount);
        }
        self.headerView.operationView.infoModel = self.userInfoModel.data;
        self.headerView.infoView.infoModel = self.userInfoModel.data;
        self.topNavView.infoModel = self.userInfoModel.data;
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"拉黑成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        [TTProfileShareService setBlocking:YES forUID:userID];
    }
}

- (void)blockUserManager:(TTBlockManager *)manager unblockResult:(BOOL)success unblockedUserID:(NSString *)userID error:(NSError *)error errorTip:(NSString *)errorTip;
{
    self.isRequestBlock = NO;
    if (error) {
        NSString * failedDescription = @"操作失败，请重试";
        if (!isEmptyString(errorTip)) {
            failedDescription = errorTip;
        }
        
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:failedDescription indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    } else {
        self.userInfoModel.data.is_blocking = @(0);
        self.headerView.operationView.infoModel = self.userInfoModel.data;
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"已解除黑名单" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        [TTProfileShareService setBlocking:NO forUID:userID];
        
    }
}


#pragma mark - private

- (void)requestBlockUserWithParam:(NSDictionary *)param
{
    if(![TTAccountManager isLogin]) {
        [self showLoginViewWithSource:@"social_other"];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"请先登录" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    __weak typeof(self) weakSelf = self;
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"确定拉黑该用户？" message:@"拉黑后此用户不能关注您，也无法给您发送任何消息" preferredType:TTThemedAlertControllerTypeAlert];
    NSNumber *updateId = param[@"id"];
    NSNumber *gType = [param tt_dictionaryValueForKey:@"moment"][@"type"];
    NSMutableDictionary *tmpParam = [NSMutableDictionary dictionary];
    if(updateId) {
        tmpParam[@"update_id"] = updateId;
    }
    if(gType) {
        tmpParam[@"gtype"] = gType;
    }
    [alert addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        if(tmpParam.count > 0) {
            wrapperTrackEventWithCustomKeys(@"profile_more", @"quit_blacklist", self.userInfoModel.data.user_id, nil, tmpParam);
        }
    }];
    [alert addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        if(tmpParam.count > 0) {
            wrapperTrackEventWithCustomKeys(@"profile_more", @"confirm_blacklist", self.userInfoModel.data.user_id, nil, tmpParam);
        }
        if(weakSelf.isRequestBlock) return;
        weakSelf.isRequestBlock = YES;
        [weakSelf.blockUserManager blockUser:weakSelf.userInfoModel.data.user_id];
    }];
    
    [alert showFrom:self animated:YES];
}

- (void)requestUnBlockUser
{
    if(self.isRequestBlock) return;
    self.isRequestBlock = YES;
    [self.blockUserManager unblockUser:self.userInfoModel.data.user_id];
}

//- (void)requestRecommendFollow
//{
//    if (self.headerView.recommendFollowView.rtFollowExtraDict == nil) { //卡片展开前赋值
//        // "rt_follow" 关注动作统一化 埋点
//        NSMutableDictionary* rtFollowDict = [NSMutableDictionary dictionaryWithObject:@"from_recommend" forKey:@"follow_type"];
//        [rtFollowDict setValue:self.userInfoModel.data.user_id forKey:@"profile_user_id"];
//        [rtFollowDict setValue:@"profile" forKey:@"category_name"];
//        [rtFollowDict setValue:@"detail_follow_card" forKey:@"source"];
//        [rtFollowDict setValue:@(TTFollowNewSourceRecommendUserOtherCategory) forKey:@"server_source"];
//        //此处还差order关注的卡片上第几个人、to_user_id被关注用户的user_id两个字段，这两个字段会在recommendFollowView中发送时机进行赋值
//        self.headerView.recommendFollowView.rtFollowExtraDict = [rtFollowDict copy];
//    }
//
//    WeakSelf;
//    [TTRecommendUserCollectionView requestDataWithSource:@"homepage" scene:@"follow" sceneUserId:self.userID groupId:self.groupId complete:^(NSArray<FRRecommendCardStructModel *> *models) {
//        StrongSelf;
//        if (models) {
//            [self.headerView.recommendFollowView.collectionView configUserModels:models requesetModel:nil];
//            [self.headerView.operationView recommendViewOperationBtnAnimationWithSpread:YES];
//            [self headerView:self.headerView didSelectedFollowSpreadOut:YES];
//            [TTTrackerWrapper eventV3:@"follow_card" params:@{@"action_type":@"show",
//                                                              @"category_name":@"profile",
//                                                              @"source": @"profile",
//                                                              @"is_direct" : @(0)
//                                                              }];
//        } else {
//            [self.headerView.operationView.followButton stopLoading:nil];
//            self.isRequestFollow = NO;
//            self.headerView.operationView.followButton.followed = self.userInfoModel.data.is_following.boolValue;
//        }
//    }];
//}

- (void)requestCancelFollowWithIsTopRequest:(BOOL)isTopRequest
{
    if(!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"无网络连接", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    if(self.isRequestFollow) return;
    self.isRequestFollow = YES;
    if (isTopRequest) {
        [self.topNavView.followBtn startLoading];
    } else {
        [self.headerView.operationView.followButton startLoading];
    }
    TTFollowNewSource source = isTopRequest? TTFollowNewSourceProfileBar: TTFollowNewSourceProfile;
    { // "rt_unfollow" 关注动作统一化 埋点
        NSMutableDictionary* rtFollowDict = [NSMutableDictionary dictionaryWithObject:@"from_others" forKey:@"follow_type"];
        [rtFollowDict setValue:self.userInfoModel.data.user_id forKey:@"to_user_id"];
        [rtFollowDict setValue:self.userInfoModel.data.media_id forKey:@"media_id"];
        [rtFollowDict setValue:@"profile" forKey:@"category_name"];
        [rtFollowDict setValue:@"profile" forKey:@"source"];
        [rtFollowDict setValue:self.serverSource != TTFollowNewSourceUnknown ? @(self.serverSource) : [@(source) stringValue] forKey:@"server_source"];
        [rtFollowDict setValue:@"click_pgc" forKey:@"enter_from"];
        [rtFollowDict setValue:self.fromPage forKey:@"from_page"];
        [rtFollowDict setValue:self.groupId forKey:@"group_id"];
        [rtFollowDict setValue:self.profileUserId forKey:@"profile_user_id"];
        [rtFollowDict setValue:(isTopRequest? @"top_title_bar": @"avatar_right") forKey:@"position"];
        [rtFollowDict setValue:@100353 forKey:@"demand_id"];///埋点自动化验证使用
        [TTTrackerWrapper eventV3:@"rt_unfollow" params:rtFollowDict];
    }
    
    [[TTPersonalHomeManager sharedInstance] requestFollowWithUserID:self.userInfoModel.data.user_id action:FriendActionTypeUnfollow source:source reason:nil newReason:nil completion:^(NSError *error, FriendActionType type, NSDictionary *result) {
        
        if(!error) {
            //只要关注状态修改，则干掉红包数据，同时所有followbutton的类型归为默认的蓝底白字
            self.topNavView.followBtn.unfollowedType = TTUnfollowedType101;
            self.headerView.operationView.followButton.unfollowedType = TTUnfollowedType101;
            self.userInfoModel.data.activity = nil;
            
            self.userInfoModel.data.is_following = @(0);
            if(!isTopRequest) {
                [self headerView:self.headerView didSelectedFollowSpreadOut:NO];
                [self.headerView.operationView recommendViewOperationBtnAnimationWithSpread:NO];
            } else {
                [self.topNavView.followBtn stopLoading:nil];
                self.isRequestFollow = NO;
                self.headerView.operationView.followButton.followed = self.userInfoModel.data.is_following.boolValue;
            }
            self.topNavView.infoModel = self.userInfoModel.data;
            [self updateFollowersCountWithFollowing:NO];
            self.headerView.infoView.infoModel = self.userInfoModel.data;
            
            NSMutableDictionary *dict = [@{@"action_type": @(type)} mutableCopy];
            [dict setValue:result[@"result"][@"data"][@"user"] forKey:@"user_data"];
            [[NSNotificationCenter defaultCenter] postNotificationName:KFriendModelChangedNotification object:nil userInfo:dict];
        } else {
            if (isTopRequest) {
                [self.topNavView.followBtn stopLoading:nil];
            } else {
                [self.headerView.operationView.followButton stopLoading:nil];
            }
            self.isRequestFollow = NO;
            self.headerView.operationView.followButton.followed = self.userInfoModel.data.is_following.boolValue;
            [self showFollowMessagewWithResult:result isFollow:NO];
        }
    }];
}

- (void)requestFollowWithIsTopRequest:(BOOL)isTopRequest
{
    if (self.userInfoModel.data.is_following.boolValue) {
        return;
    }
    if(!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"无网络连接", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    if(self.isRequestFollow) return;
    //    if ([TTFirstConcernManager firstTimeGuideEnabled]){//第一次关注动画
    //        TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
    //        [manager showFirstConcernAlertViewWithDismissBlock:nil];
    //    }
    
    self.isRequestFollow = YES;
    if (isTopRequest) {
        [self.topNavView.followBtn startLoading];
    } else {
        [self.headerView.operationView.followButton startLoading];
    }
    TTFollowNewSource source = isTopRequest? TTFollowNewSourceProfileBar: TTFollowNewSourceProfile;
    if ([self.userInfoModel.data.activity.redpack isKindOfClass:[FRRedpackStructModel class]]) {
        source = isTopRequest? TTFollowNewSourceProfileBarRedPacket: TTFollowNewSourceProfileRedPacket;
    }
    { // "rt_follow" 关注动作统一化 埋点
        NSMutableDictionary* rtFollowDict = [NSMutableDictionary dictionaryWithObject:@"from_others" forKey:@"follow_type"];
        [rtFollowDict setValue:self.userInfoModel.data.user_id forKey:@"to_user_id"];
        [rtFollowDict setValue:self.userInfoModel.data.media_id forKey:@"media_id"];
        [rtFollowDict setValue:@"profile" forKey:@"category_name"];
        [rtFollowDict setValue:@"profile" forKey:@"source"];
        [rtFollowDict setValue:self.serverSource != TTFollowNewSourceUnknown ? @(self.serverSource) : [@(source) stringValue] forKey:@"server_source"];
        [rtFollowDict setValue:@"click_pgc" forKey:@"enter_from"];
        [rtFollowDict setValue:self.fromPage forKey:@"from_page"];
        [rtFollowDict setValue:self.profileUserId forKey:@"profile_user_id"];
        [rtFollowDict setValue:self.groupId forKey:@"group_id"];
        [rtFollowDict setValue:(isTopRequest? @"top_title_bar": @"avatar_right") forKey:@"position"];
        if (source == TTFollowNewSourceProfileBarRedPacket
            || source == TTFollowNewSourceProfileRedPacket) { //红包带来的
            [rtFollowDict setValue:@(1) forKey:@"is_redpacket"];
        }
        [rtFollowDict setValue:@100353 forKey:@"demand_id"];///埋点自动化验证使用
        [TTTrackerWrapper eventV3:@"rt_follow" params:rtFollowDict];
    }
    [[TTPersonalHomeManager sharedInstance] requestFollowWithUserID:self.userInfoModel.data.user_id action:FriendActionTypeFollow source:source reason:nil newReason:nil completion:^(NSError *error, FriendActionType type, NSDictionary *result) {
        
        if(!error) {
            self.userInfoModel.data.is_following = @(1);
            if(!isTopRequest) {
//                if (![self.userInfoModel.data.activity.redpack isKindOfClass:[FRRedpackStructModel class]]) { //红包关注不出推人卡片
////                    [self requestRecommendFollow];
//                    [self.headerView.operationView.followButton stopLoading:nil];
//                    self.isRequestFollow = NO;
//                    self.headerView.operationView.followButton.followed = self.userInfoModel.data.is_following.boolValue;
//                } else {
                    [self.headerView.operationView.followButton stopLoading:nil];
                    self.isRequestFollow = NO;
                    self.headerView.operationView.followButton.followed = self.userInfoModel.data.is_following.boolValue;
//                }
            } else {
                [self.topNavView.followBtn stopLoading:nil];
                self.isRequestFollow = NO;
                self.headerView.operationView.followButton.followed = self.userInfoModel.data.is_following.boolValue;
            }
            
//            if ([self.userInfoModel.data.activity.redpack isKindOfClass:[FRRedpackStructModel class]]) {
//                TTRedPacketTrackModel * redPacketTrackModel = [TTRedPacketTrackModel new];
//                redPacketTrackModel.userId = self.userInfoModel.data.user_id;
//                redPacketTrackModel.mediaId = self.userInfoModel.data.media_id;
//                redPacketTrackModel.source = @"profile";
//                redPacketTrackModel.position = (isTopRequest? @"top_title_bar": @"avatar_right");
//                [[TTRedPacketManager sharedManager] presentRedPacketWithRedpacket:self.userInfoModel.data.activity.redpack
//                                                                           source:redPacketTrackModel
//                                                                   viewController:self];
//            }
            self.topNavView.followBtn.unfollowedType = TTUnfollowedType101;
            self.headerView.operationView.followButton.unfollowedType = TTUnfollowedType101;
            self.userInfoModel.data.activity = nil;
            
            self.topNavView.infoModel = self.userInfoModel.data;
            [self updateFollowersCountWithFollowing:YES];
            self.headerView.infoView.infoModel = self.userInfoModel.data;
            NSMutableDictionary *dict = [@{@"action_type": @(type)} mutableCopy];
            [dict setValue:result[@"result"][@"data"][@"user"] forKey:@"user_data"];
            [[NSNotificationCenter defaultCenter] postNotificationName:KFriendModelChangedNotification object:nil userInfo:dict];
        } else {
            if (isTopRequest) {
                [self.topNavView.followBtn stopLoading:nil];
            } else {
                [self.headerView.operationView.followButton stopLoading:nil];
            }
            self.isRequestFollow = NO;
            self.headerView.operationView.followButton.followed = self.userInfoModel.data.is_following.boolValue;
            [self showFollowMessagewWithResult:result isFollow:YES];
        }
    }];
}

- (void)showFollowMessagewWithResult:(NSDictionary *)result isFollow:(BOOL)isFollow
{
    NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
    if (isEmptyString(hint)) {
        NSString *message = isFollow ? @"关注失败" : @"取消关注失败";
        hint = NSLocalizedString(message, nil);
    }
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
}

- (void)updateNavWithOffset:(CGFloat)offset
{
    CGFloat delta = self.pagingView.currentContentViewTopInset + offset;
    CGFloat scale = delta / (TTHeaderViewZoomViewHeight() - self.topNavView.height);
    if(scale >= 1) {
        scale = 1;
        [self updateNavNameWithOffset:offset];
    } else if(scale <= 0) {
        scale = 0;
        [self.headerView.operationView setVerified];
        [self.topNavView updateOtherTranslucentWithScale:0];
    } else {
        [self.topNavView updateOtherTranslucentWithScale:0];
    }
    [self.topNavView updateBarTranslucentWithScale:scale];
    self.currentScale = scale;
}

- (void)updateNavNameWithOffset:(CGFloat)offset
{
    UIView *targetView = self.headerView.operationView.followButton;
    CGFloat targetY = [self.headerView.operationView convertPoint:targetView.center toView:self.headerView].y;
    CGFloat offsetDelta = self.pagingView.currentContentViewTopInset + offset;
    if(targetY - self.topNavView.height <= offsetDelta) {
        CGFloat delta = offsetDelta - targetY + self.topNavView.height;
        CGFloat scale = delta / (targetView.height * 0.5);
        if(scale >= 1) {
            scale = 1;
        } else if(scale <= 0) {
            scale = 0;
        }
        [self.topNavView updateOtherTranslucentWithScale:scale];
        if(scale >= 1) {
            self.headerView.operationView.hasVerified = NO;
            [self.headerView.operationView clearVerified];
        } else if(scale < 1 && !self.headerView.operationView.hasVerified) {
            [self.headerView.operationView setVerified];
        }
    } else {
        [self.topNavView updateOtherTranslucentWithScale:0];
    }
}

- (void)updateZoomViewWithOffset:(CGFloat)offset
{
    if(offset > 0) return;
    CGFloat delta = self.pagingView.currentContentViewTopInset + offset;
    if(delta < 0) {
        self.headerView.zoomView.frame = CGRectMake(delta, delta, self.view.width - 2 * delta, TTHeaderViewZoomViewHeight() - delta);
    } else {
        self.headerView.zoomView.frame = CGRectMake(0, 0, self.view.width, TTHeaderViewZoomViewHeight());
    }
    [self.headerView updateStarLocationWithOffset:delta];
    
}

- (void)setupSubController
{
    [self.subControllerDict removeAllObjects];
    for(TTPersonalHomeUserInfoDataItemResponseModel *item in self.userInfoModel.data.top_tab) {
        TTPersonalHomeCommonWebViewController *controller = [[TTPersonalHomeCommonWebViewController alloc] init];
        [controller setInfoModel:self.userInfoModel.data trackDict:[self updateWebViewControllerExtraDict] needAdjustInset:YES];
        __weak typeof(self) weakSelf = self;
        controller.followBlock = ^(BOOL isFollow) {
            if(isFollow) {
                [weakSelf requestFollowWithIsTopRequest:YES];
            } else {
                [weakSelf requestCancelFollowWithIsTopRequest:YES];
            }
        };
        controller.blockUserBlock = ^(BOOL isBlock,NSDictionary *dict) {
            if(isBlock) {
                [weakSelf requestBlockUserWithParam:dict];
            } else {
                [weakSelf requestUnBlockUser];
            }
        };
        self.subControllerDict[item.type] = controller;
    }
}

- (void)updateSubControllerModel
{
    [self.subControllerDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, TTPersonalHomeCommonWebViewController * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj setInfoModel:self.userInfoModel.data trackDict:[self updateWebViewControllerExtraDict] needAdjustInset:NO];
    }];
}

- (NSDictionary *)updateWebViewControllerExtraDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.fromPage forKey:@"from_page"];
    [dict setValue:self.groupId forKey:@"group_id"];
    return dict.copy;
}

- (NSString *)tabKeyWithType:(NSString *)type
{
    if([type isEqualToString:@"all"]) {
        return @"article";
    } else if([type isEqualToString:@"video"]) {
        return @"video";
    } else if([type isEqualToString:@"matrix_atricle_list"]) {
        return @"article_list";
    } else if([type isEqualToString:@"matrix_media_list"]) {
        return @"matrix";
    } else if([type isEqualToString:@"wenda"]) {
        return @"wenda";
    } else if([type isEqualToString:@"dongtai"]) {
        return @"update";
    } else if([type isEqualToString:@"column"]) {
        return @"column";
    } else {
        return type;
    }
}

- (void)showLoginViewWithSource:(NSString *)source
{
    [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeSocial source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeTip) {
            [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:source completion:^(TTAccountLoginState state) {
            }];
        }
    }];
}

- (void)blockUserNotification:(NSNotification *)note
{
    NSDictionary *param = note.userInfo;
    NSString *userID = param[@"user_id"];
    NSNumber *isBlocking = param[@"is_blocking"];
    if(![userID isEqualToString:self.userInfoModel.data.user_id]) return;
    if(isBlocking.integerValue == 1) {
        [self requestBlockUserWithParam:nil];
    } else {
        [self requestUnBlockUser];
    }
}

- (void)reportUserNotification:(NSNotification *)note
{
    NSDictionary *param = note.userInfo;
    NSString *userID = param[@"user_id"];
    if(![userID isEqualToString:self.userInfoModel.data.user_id]) return;
    if(isEmptyString(self.currentSegmentType)) return;
    TTPersonalHomeCommonWebViewController *controller = self.subControllerDict[self.currentSegmentType];
    [controller reportWithUserID:userID];
}

- (void)followChangeNotification:(NSNotification *)note {
    if ([[note.userInfo tt_stringValueForKey:kRelationActionSuccessNotificationUserIDKey] isEqualToString:self.userInfoModel.data.user_id]) {
        if ([note.userInfo tt_integerValueForKey:kRelationActionSuccessNotificationActionTypeKey] == FriendActionTypeFollow) {
            if (self.userInfoModel.data.is_following && [self.userInfoModel.data.is_following integerValue] == 1) {
                //保护，如果是手点关注主人，不需要再进行一遍刷新
                return;
            }
            self.userInfoModel.data.is_following = @(1);
            [self updateFollowersCountWithFollowing:YES];
        } else if ([note.userInfo tt_integerValueForKey:kRelationActionSuccessNotificationActionTypeKey] == FriendActionTypeUnfollow) {
            if (self.userInfoModel.data.is_following && [self.userInfoModel.data.is_following integerValue] == 0) {
                return;
            }
            self.userInfoModel.data.is_following = @(0);
            [self updateFollowersCountWithFollowing:NO];
        } else {
            return;
        }
        
        //只要关注状态修改，则干掉红包数据，同时所有followbutton的类型归为默认的蓝底白字
        self.topNavView.followBtn.unfollowedType = TTUnfollowedType101;
        self.headerView.operationView.followButton.unfollowedType = TTUnfollowedType101;
        self.userInfoModel.data.activity = nil;
        
        self.topNavView.infoModel = self.userInfoModel.data;
        self.headerView.infoView.infoModel = self.userInfoModel.data;
        self.headerView.operationView.followButton.followed = self.userInfoModel.data.is_following.boolValue;
        self.topNavView.followBtn.followed = self.userInfoModel.data.is_following.boolValue;
    }
}

- (void)friendModelChangedNotification:(NSNotification *)notification {
    if ([notification.userInfo tt_boolValueForKey:@"sendlog"]) {
        NSMutableDictionary* rtFollowDict = [NSMutableDictionary dictionaryWithObject:@"from_others" forKey:@"follow_type"];
        [rtFollowDict setValue:self.userInfoModel.data.user_id forKey:@"to_user_id"];
        [rtFollowDict setValue:self.userInfoModel.data.media_id forKey:@"media_id"];
        [rtFollowDict setValue:@"profile" forKey:@"category_name"];
        [rtFollowDict setValue:@"profile" forKey:@"source"];
        [rtFollowDict setValue:[@(TTFollowNewSourcePersonal) stringValue] forKey:@"server_source"];
        [rtFollowDict setValue:@"click_pgc" forKey:@"enter_from"];
        [rtFollowDict setValue:self.fromPage forKey:@"from_page"];
        [rtFollowDict setValue:self.profileUserId forKey:@"profile_user_id"];
        [rtFollowDict setValue:self.groupId forKey:@"group_id"];
        [rtFollowDict setValue:(@"more_article") forKey:@"position"];
        if ([notification.userInfo tt_integerValueForKey:@"action_type"] == FriendActionTypeFollow) {
            [TTTrackerWrapper eventV3:@"rt_follow" params:rtFollowDict];
        } else {
            [TTTrackerWrapper eventV3:@"rt_unfollow" params:rtFollowDict];
        }
    }
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountUserProfileChanged:(NSDictionary *)changedFields error:(NSError *)error
{
    BOOL bUserName = [[changedFields objectForKey:@(TTAccountUserProfileTypeUserName)] boolValue];
    BOOL bUserDesp = [[changedFields objectForKey:@(TTAccountUserProfileTypeUserDesp)] boolValue];
    BOOL bUserAvatar = [[changedFields objectForKey:@(TTAccountUserProfileTypeUserAvatar)] boolValue];
    BOOL bUserGender = [[changedFields objectForKey:@(TTAccountUserProfileTypeUserGender)] boolValue];
    BOOL bUseProvince = [[changedFields objectForKey:@(TTAccountUserProfileTypeUserProvince)] boolValue];
    BOOL bUserCity = [[changedFields objectForKey:@(TTAccountUserProfileTypeUserCity)] boolValue];
    
    if (bUserName) {
        [self userNameChangeNotification];
    }
    
    if (bUserDesp) {
        [self userDescChangeNotification];
    }
    
    if (bUserAvatar) {
        [self userAvatarChangeNotification];
    }
    
    if (bUserGender) {
        [self userGenderChangeNotification];
    }
    
    if (bUseProvince || bUserCity) {
        [self userAreaChangeNotification];
    }
}

- (void)userNameChangeNotification
{
    if(![self.userInfoModel.data.user_id isEqualToString:self.userInfoModel.data.current_user_id]) return;
    
    self.userInfoModel.data.name = [TTAccountManager userName];
    self.headerView.infoModel = self.userInfoModel.data;
    TTPersonalHomeCommonWebViewController *controller = self.subControllerDict[@"dongtai"];
    [controller updateUserInfo];
}

- (void)userAvatarChangeNotification
{
    if(![self.userInfoModel.data.user_id isEqualToString:self.userInfoModel.data.current_user_id]) return;
    
    self.userInfoModel.data.avatar_url = [TTAccountManager avatarURLString];
    self.headerView.infoModel = self.userInfoModel.data;
    TTPersonalHomeCommonWebViewController *controller = self.subControllerDict[@"dongtai"];
    [controller updateUserInfo];
}

- (void)userDescChangeNotification
{
    if(![self.userInfoModel.data.user_id isEqualToString:self.userInfoModel.data.current_user_id]) return;
    
    self.userInfoModel.data.desc = [TTAccountManager currentUser].userDescription;
    self.headerView.infoModel = self.userInfoModel.data;
    [self.pagingView reloadHeaderViewHeight:self.headerView.height];
}

- (void)userAreaChangeNotification
{
    if(![self.userInfoModel.data.user_id isEqualToString:self.userInfoModel.data.current_user_id]) return;
    
    self.userInfoModel.data.area = [TTAccountManager currentUser].area;
    self.headerView.infoModel = self.userInfoModel.data;
}

- (void)userGenderChangeNotification
{
    if(![self.userInfoModel.data.user_id isEqualToString:self.userInfoModel.data.current_user_id]) return;
    
    self.userInfoModel.data.gender = [TTAccountManager currentUser].gender;
    self.headerView.infoModel = self.userInfoModel.data;
}

- (void)themedChange
{
    if([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay) {
        self.view.backgroundColor = [UIColor whiteColor];
    } else {
        self.view.backgroundColor = [UIColor colorWithHexString:@"#252525"];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
    LOGD(@"%s",__func__);
}

- (void)updateFollowersCountWithFollowing:(BOOL)following
{
    NSInteger delta = following ? 1 : -1;
    self.userInfoModel.data.followers_count = @(MAX(self.userInfoModel.data.followers_count.integerValue + delta, 0));
    self.userInfoModel.data.multiplePlatformFollowersCount = @(MAX(self.userInfoModel.data.multiplePlatformFollowersCount.integerValue + delta, 0));
    
    for (TTPersonalHomeSinglePlatformFollowersInfoModel *model in self.userInfoModel.data.platformFollowersInfoArr) {
        NSURL *url = [TTStringHelper URLWithURLString:model.openUrl];
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            model.fansCount = @(MAX(model.fansCount.integerValue + delta, 0));
        }
    }
}

@end

