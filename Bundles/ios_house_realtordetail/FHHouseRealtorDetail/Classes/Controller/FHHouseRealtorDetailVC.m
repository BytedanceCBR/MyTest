//
//  FHHouseRealtorDetailVC.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/16.
//

#import "FHHouseRealtorDetailVC.h"
#import "FHHouseRealtorDetailVM.h"
#import "UIViewController+Track.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "FHUGCShareManager.h"
#import "TTBaseMacro.h"
#import "FHUGCFollowButton.h"
#import "UILabel+House.h"
#import "UIDevice+BTDAdditions.h"
#import "FHUGCPostMenuView.h"
#import "FHCommonDefines.h"
#import "FHUserTracker.h"
#import "UIViewController+NavigationBarStyle.h"
#import "UIImage+FIconFont.h"
#import "FHLynxManager.h"
@interface FHHouseRealtorDetailVC ()<TTUIViewControllerTrackProtocol>
@property (nonatomic, strong) FHHouseRealtorDetailVM *viewModel;
@property (nonatomic, strong) UIView *bottomMaskView;
@property (nonatomic, strong )NSDictionary *realtorDetailInfo;

@end

@implementation FHHouseRealtorDetailVC

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.tabName = paramObj.allParams[@"tab_name"];
        self.realtorDetailInfo = paramObj.allParams;
        /**
            外部传递了正确的 enter_from，但是未传 page_type 的情况下，会出现 null 的情况
         */
        if (self.tracerDict[@"page_type"]) {
            self.tracerDict[@"enter_from"] = self.tracerDict[@"page_type"];
        }
        self.tracerDict[@"page_type"] = [self pageType];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initNavBar];
    [self initView];
    [self initViewModel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.viewModel updateNavBarWithAlpha:self.customNavBarView.bgView.alpha];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel updateNavBarWithAlpha:self.customNavBarView.bgView.alpha];
}

- (void)initNavBar {
    [self setupDefaultNavBar:NO];
    self.titleLabel.text =  @"经纪人主页";
    //设置导航条透明
    [self setNavBar];
}

- (void)initView {
    [self initHeaderView];
    [self initSegmentView];
    [self addDefaultEmptyViewFullScreen];
    [self initBottomBar];
    [self initBlackmailRealtorBottomBar];
    
}

- (void)showBottomBar:(BOOL)show {
    self.bottomBar.hidden = !show;
    self.bottomMaskView.hidden = !show;
}

- (void)initBottomBar {
    _bottomMaskView = [[UIView alloc] init];
    _bottomMaskView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bottomMaskView];
    self.bottomBar = [[FHRealtorDetailBottomBar alloc]init];
    [self.view addSubview:self.bottomBar];
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(64);
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
        }else {
            make.bottom.mas_equalTo(self.view);
        }
    }];
    [_bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomBar);
        make.left.right.bottom.equalTo(self.view);
    }];
    [self showBottomBar:NO];
}

- (void)initBlackmailRealtorBottomBar {
    // 关黑经纪人底部提示
    [self.view addSubview:self.blackmailReatorBottomBar];
    [self.blackmailReatorBottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
        }else {
            make.bottom.mas_equalTo(self.view);
        }
    }];
}

- (void)initHeaderView {
    CGFloat headerBackNormalHeight = 400;
    CGFloat headerBackXSeriesHeight = headerBackNormalHeight + 44; //刘海平多出24
    CGFloat height = [UIDevice btd_isIPhoneXSeries] ? headerBackXSeriesHeight : headerBackNormalHeight + 40;
    self.headerView = [[FHHouseRealtorDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
    self.headerView.controller = self;
    self.headerView.channel = @"lynx_realtor_detail_header";
    self.headerView.bacImageName = @"realtor_header";
}

- (void)initSegmentView {
    self.segmentView = [[FHCommunityDetailSegmentView alloc] init];
    self.segmentView.underLinePaddingToLab = 35;
    self.segmentView.underLineWidth = 20;
    [_segmentView setUpTitleEffect:^(NSString *__autoreleasing *titleScrollViewColorKey, NSString *__autoreleasing *norColorKey, NSString *__autoreleasing *selColorKey, UIFont *__autoreleasing *titleFont, UIFont *__autoreleasing *selectedTitleFont) {
        *titleScrollViewColorKey  = @"Background3";
        *norColorKey = @"grey1";
        *selColorKey = @"grey1";
        *titleFont = [UIFont themeFontRegular:16];
        *selectedTitleFont = [UIFont themeFontMedium:18];
    }];
    [_segmentView setUpUnderLineEffect:^(BOOL *isUnderLineDelayScroll, CGFloat *underLineH, NSString *__autoreleasing *underLineColorKey, BOOL *isUnderLineEqualTitleWidth) {
        *isUnderLineDelayScroll = NO;
        *underLineH = 4;
        *underLineColorKey = @"orange4";
        *isUnderLineEqualTitleWidth = YES;
    }];
    _segmentView.backgroundColor = [UIColor themeGray7];
    _segmentView.bottomLine.hidden = YES;
    _segmentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_segmentView setUnderLineLayer:2];
}

- (void)setNavBar {
    self.customNavBarView.title.text = @"经纪人主页";
    self.customNavBarView.title.textColor = [UIColor whiteColor];
    [self.customNavBarView.leftBtn setBackgroundImage:FHBackWhiteImage forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:FHBackWhiteImage forState:UIControlStateHighlighted];
    [self.customNavBarView setNaviBarTransparent:YES];
    self.customNavBarView.seperatorLine.hidden = YES;
}

- (void)initViewModel {
    NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:@"lynx_realtor_detail_header" templateKey:[FHLynxManager defaultJSFileName] version:0];
    if (!templateData) {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
    }else {
        self.viewModel = [[FHHouseRealtorDetailVM alloc] initWithController:self tracerDict:self.tracerDict realtorInfo:self.realtorDetailInfo bottomBar:self.bottomBar];
        [self.viewModel updateNavBarWithAlpha:self.customNavBarView.bgView.alpha];
        [self.viewModel requestDataWithRealtorId:self.realtorDetailInfo[@"realtor_id"] refreshFeed:YES];
    }
}

- (void)retryLoadData {
    [self.viewModel requestDataWithRealtorId:self.realtorDetailInfo[@"realtor_id"] refreshFeed:YES];
}

- (void)showRealtorLeaveHeader {
    [self.view addSubview:_headerView];
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
    }];
    [self.view bringSubviewToFront:self.customNavBarView];
    self.view.backgroundColor = [UIColor themeGray7];
}

- (NSString *)pageType {
    return @"realtor_detail";
}

#pragma mark - 懒加载成员
- (FHBlackmailRealtorBottomBar *)blackmailReatorBottomBar {
    if(!_blackmailReatorBottomBar) {
        _blackmailReatorBottomBar = [[FHBlackmailRealtorBottomBar alloc] init];
        _blackmailReatorBottomBar.hidden = YES;
        _blackmailReatorBottomBar.backgroundColor = [UIColor themeWhite];
    }
    return _blackmailReatorBottomBar;
}
@end
