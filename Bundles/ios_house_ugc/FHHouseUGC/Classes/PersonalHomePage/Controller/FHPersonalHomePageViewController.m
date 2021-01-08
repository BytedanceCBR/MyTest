//
//  FHPersonalHomePageViewController.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import "FHPersonalHomePageViewController.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTNavigationController.h"
#import "FHPersonalHomePageViewModel.h"
#import "FHPersonalHomePageFeedViewController.h"
#import "FHPersonalHomePageManager.h"
#import "UIImage+FIconFont.h"
#import "FHCommonDefines.h"
#import "UIViewAdditions.h"
#import "FHUserTracker.h"
#import "TTAccountManager.h"
#import <ToastManager.h>

#define dragBackEdge 30

@interface FHPersonalHomePageScrollView : UIScrollView <UIGestureRecognizerDelegate>
@end

@implementation FHPersonalHomePageScrollView
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

@interface FHPersonalHomePageViewController () 
@property(nonatomic,strong) FHPersonalHomePageFeedViewController *feedViewController;
@property(nonatomic,copy) NSString *userId;
@property(nonatomic,strong) FHPersonalHomePageViewModel *viewModel;
@property(nonatomic,strong) FHPersonalHomePageManager *homePageManager;
@end

@implementation FHPersonalHomePageViewController

-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if(self = [super initWithRouteParamObj:paramObj]) {
        NSDictionary *params = paramObj.allParams;
        self.userId = params[@"uid"];
        self.homePageManager = [[FHPersonalHomePageManager alloc] init];
        self.homePageManager.userId = self.userId;
        [self.homePageManager initTracerDictWithParams:params];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initViewModel];
    
    self.homePageManager.viewController = self;
    self.homePageManager.feedViewController = self.feedViewController;
    self.feedViewController.homePageManager = self.homePageManager;
    [self startLoadData];
}

- (void)initView {
    [self initScrollView];

    self.profileInfoView = [[FHPersonalHomePageProfileInfoView alloc] initWithFrame:CGRectZero];
    self.profileInfoView.homePageManager = self.homePageManager;
    self.profileInfoView.hidden = YES;
    [self.scrollView addSubview:self.profileInfoView];
    
    self.feedViewController = [[FHPersonalHomePageFeedViewController alloc] init];
    self.feedViewController.view.frame = CGRectZero;
    [self.scrollView addSubview:self.feedViewController.view];
    
    [self initNavBar];
    [self addDefaultEmptyViewFullScreen];
    self.automaticallyAdjustsScrollViewInsets = NO;
}


- (void)initScrollView {
    self.scrollView = [[FHPersonalHomePageScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor themeWhite];
    self.scrollView.contentSize = self.view.bounds.size;
    if (@available(iOS 11.0, *)) {
//        self.scrollView.insetsLayoutMarginsFromSafeArea = NO;
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
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
            maker.height.mas_equalTo(44.f + topInset);
        } else if (@available(iOS 11.0 , *)) {
            maker.left.right.top.mas_equalTo(self.view);
            maker.height.mas_equalTo(44.f + self.view.tt_safeAreaInsets.top);
        } else {
            maker.left.right.top.mas_equalTo(self.view);
            maker.height.mas_equalTo(65);
        }
    }];
    WeakSelf;
    self.customNavBarView.leftButtonBlock = ^{
        StrongSelf;
        [self goBack];
    };
    
    _moreButton = [[UIButton alloc] init];
    [_moreButton setBackgroundImage:[UIImage imageNamed:@"fh_ugc_personal_more_white"] forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [self.customNavBarView addRightViews:@[_moreButton] viewsWidth:@[@(20)] viewsHeight:@[@(20)] viewsRightOffset:@[@(20)]];
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


- (void)initViewModel {
    self.viewModel = [[FHPersonalHomePageViewModel alloc] initWithController:self];
    self.viewModel.homePageManager = self.homePageManager;
}

- (void)startLoadData {
    [self.viewModel startLoadData];
}

-(void)retryLoadData {
    [self.emptyView hideEmptyView];
    [self startLoadData];
}

@end

