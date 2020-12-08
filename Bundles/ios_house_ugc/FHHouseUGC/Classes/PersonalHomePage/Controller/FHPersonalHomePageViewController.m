//
//  FHPersonalHomePageViewController.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import "FHPersonalHomePageViewController.h"
#import "FHPersonalHomePageScrollView.h"
#import "FHPersonalHomePageViewModel.h"
#import "FHPersonalHomePageProfileInfoView.h"
#import "FHPersonalHomePageFeedViewController.h"
#import "UIImage+FIconFont.h"
#import "TTReachability.h"
#import "FHCommonDefines.h"
#import "UIViewAdditions.h"
#import "FHUserTracker.h"
#import "TTAccountManager.h"
#import <ToastManager.h>


@interface FHPersonalHomePageViewController () <UIScrollViewDelegate>
@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) FHPersonalHomePageProfileInfoView *profileInfoView;
@property(nonatomic,strong) FHPersonalHomePageFeedViewController *feedViewController;

@property(nonatomic,assign) BOOL enableScroll;
@property(nonatomic,strong) NSString *userId;
@property(nonatomic,strong) FHPersonalHomePageViewModel *viewModel;
@end

@implementation FHPersonalHomePageViewController

-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if(self = [super initWithRouteParamObj:paramObj]) {
        NSDictionary *params = paramObj.allParams;
        self.userId = params[@"uid"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initViewModel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableScrollChange) name:kFHPersonalHomePageEnableScrollChangeNotification object:nil];
    
    [self startLoadData];
}

- (void)initView {
    [self initNavBar];
    
    self.scrollView = [[FHPersonalHomePageScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor themeWhite];
    self.scrollView.contentSize = self.view.bounds.size;
    if (@available(iOS 11.0, *)) {
        self.scrollView.insetsLayoutMarginsFromSafeArea = NO;
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.scrollView.delegate = self;
    self.scrollView.alwaysBounceVertical = YES;
    self.enableScroll = YES;
    [self.view addSubview:self.scrollView];
    
    self.profileInfoView = [[FHPersonalHomePageProfileInfoView alloc] initWithFrame:CGRectZero];
    [self.scrollView addSubview:self.profileInfoView];
    
    self.feedViewController = [[FHPersonalHomePageFeedViewController alloc] init];
    self.feedViewController.view.frame = CGRectZero;
    [self.scrollView addSubview:self.feedViewController.view];
    
    [self addDefaultEmptyViewFullScreen];
}

- (void)initNavBar {
    self.customNavBarView = [[FHNavBarView alloc] init];
    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"fh_ugc_personal_page_back_arrow"] forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"fh_ugc_personal_page_back_arrow"] forState:UIControlStateHighlighted];
    self.customNavBarView.title.text = [[TTAccountManager userID] isEqualToString:self.userId] ? @"我的主页" : @"TA的主页";
    self.customNavBarView.title.alpha = 0;
    self.customNavBarView.bgView.alpha = 0;
    self.customNavBarView.seperatorLine.alpha = 0;
    [self.view addSubview:self.customNavBarView];
    [self.customNavBarView mas_makeConstraints:^(MASConstraintMaker *maker) {
        if (@available(iOS 13.0 , *)) {
            CGFloat topInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
            maker.left.right.top.mas_equalTo(self.view);
            maker.height.mas_equalTo(24.f + topInset);
        } else if (@available(iOS 11.0 , *)) {
            maker.left.right.top.mas_equalTo(self.view);
            maker.height.mas_equalTo(24.f + self.view.tt_safeAreaInsets.top);
        } else {
            maker.left.right.top.mas_equalTo(self.view);
            maker.height.mas_equalTo(54);
        }
    }];
    WeakSelf;
    self.customNavBarView.leftButtonBlock = ^{
        StrongSelf;
        [self goBack];
    };
    
    UIButton *moreButton = [[UIButton alloc] init];
    [moreButton setBackgroundImage:[UIImage imageNamed:@"fh_ugc_icon_more"] forState:UIControlStateNormal];
    moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [moreButton addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addRightViews:@[moreButton] viewsWidth:@[@(20)] viewsHeight:@[@(20)] viewsRightOffset:@[@(20)]];
}


- (void)moreButtonClick {
    
    __block NSMutableDictionary *clickParams = [NSMutableDictionary dictionary];
    __block NSMutableDictionary *popupShowParams = [NSMutableDictionary dictionary];
    clickParams[@"page_type"] = @"personal_homepage_detail";
    popupShowParams[@"page_type"] = @"personal_homepage_detail";
    
    clickParams[@"click_position"] = @"feed_more";
    [FHUserTracker writeEvent:@"click_options" params:clickParams];
    
    UIAlertController *dislikeActionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *dislikeAction = [UIAlertAction actionWithTitle:@"拉黑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        clickParams[@"click_position"] = @"blacklist";
        [FHUserTracker writeEvent:@"click_options" params:clickParams];
        
        UIAlertController *dislikeConfirmActionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *dislikeConfirmAction = [UIAlertAction actionWithTitle:@"确认拉黑" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[ToastManager manager] showToast:@"已拉黑该用户"];
            clickParams[@"click_position"] = @"confirm_blacklist";
            [FHUserTracker writeEvent:@"click_options" params:clickParams];
        }];

        UIAlertAction *cancelConfirmAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            clickParams[@"click_position"] = @"cancel";
            [FHUserTracker writeEvent:@"click_options" params:clickParams];
        }];

        [dislikeConfirmActionSheet addAction:dislikeConfirmAction];
        [dislikeConfirmActionSheet addAction:cancelConfirmAction];
        
        [self presentViewController:dislikeConfirmActionSheet animated:YES completion:nil];
        popupShowParams[@"popup_name"] = @"confirm_blacklist_popup";
        [FHUserTracker writeEvent:@"popup_show" params:popupShowParams];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        clickParams[@"click_position"] = @"cancel";
        [FHUserTracker writeEvent:@"click_options" params:clickParams];
    }];
    
    [dislikeActionSheet addAction:dislikeAction];
    [dislikeActionSheet addAction:cancelAction];
    
    [self presentViewController:dislikeActionSheet animated:YES completion:nil];
    popupShowParams[@"popup_name"] = @"blacklist_popup";
    [FHUserTracker writeEvent:@"popup_show" params:popupShowParams];
}

-(void)updateProfileInfoWithMdoel:(FHPersonalHomePageProfileInfoModel *)profileInfoModel tabListWithMdoel:(FHPersonalHomePageTabListModel *)tabListModel {
    [self.profileInfoView updateWithModel:profileInfoModel isVerifyShow:[tabListModel.data.isVerifyShow boolValue]];
    CGFloat profileInfoViewHeight = [self.profileInfoView viewHeight];
    self.profileInfoView.frame = CGRectMake(0, 0, SCREEN_WIDTH, profileInfoViewHeight);
    self.feedViewController.view.frame = CGRectMake(0, profileInfoViewHeight, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.feedViewController updateWithHeaderViewMdoel:tabListModel];
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, profileInfoViewHeight + SCREEN_HEIGHT);
}


- (void)initViewModel {
    self.viewModel = [[FHPersonalHomePageViewModel alloc] initWithController:self];
    self.viewModel.userId = self.userId;
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [self startLoading];
        self.isLoadingData = YES;
        [self.viewModel startLoadData];
    } else {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
}

-(void)retryLoadData {
    [self.emptyView hideEmptyView];
    [self startLoadData];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat tabListOffset = self.profileInfoView.viewHeight - self.customNavBarView.height;
    CGFloat backViewOffset = 120 - self.customNavBarView.height;
    
    if(offset < 0) {
        CGFloat shadowViewHeight = 160;
        self.profileInfoView.shadowView.transform = CGAffineTransformMakeScale(1 + offset/(-shadowViewHeight), 1 + offset/(-shadowViewHeight));
        CGRect frame = self.profileInfoView.shadowView.frame;
        frame.origin.y = offset;
        self.profileInfoView.shadowView.frame = frame;
    }else if(offset >= tabListOffset) {
        self.scrollView.contentOffset = CGPointMake(0, tabListOffset);
        self.enableScroll = NO;
        self.feedViewController.enableScroll = YES;
    }else {
        if(!self.enableScroll) {
            self.scrollView.contentOffset = CGPointMake(0, tabListOffset);
        }
    };
    
    offset = self.scrollView.contentOffset.y;
    if(offset < 0) {
        self.customNavBarView.bgView.alpha = 0;
        self.customNavBarView.title.alpha = 0;
    } else if(offset <= backViewOffset) {
        self.customNavBarView.bgView.alpha = offset / backViewOffset;
        self.customNavBarView.title.alpha = offset / backViewOffset;
    } else {
        self.customNavBarView.bgView.alpha = 1;
        self.customNavBarView.title.alpha = 1;
    }
}

- (void)enableScrollChange {
    self.enableScroll = YES;
}

@end

