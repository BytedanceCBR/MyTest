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
#import "FHRealtorDetailBottomBar.h"
#import "FHLynxManager.h"
@interface FHHouseRealtorDetailVC ()<TTUIViewControllerTrackProtocol>
@property (nonatomic, strong) FHHouseRealtorDetailVM *viewModel;
@property (nonatomic, strong) UIImage *shareWhiteImage;
@property (nonatomic, strong) UIButton *shareButton;// 分享
@property (nonatomic, strong) UIView *bottomMaskView;
@property (nonatomic, strong) FHRealtorDetailBottomBar *bottomBar;
@property (nonatomic, strong )NSDictionary *realtorDetailInfo;
@end

@implementation FHHouseRealtorDetailVC

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.ttTrackStayEnable = YES;
        self.communityId = paramObj.allParams[@"community_id"];
        self.tabName = paramObj.allParams[@"tab_name"];
        self.realtorDetailInfo = paramObj.allParams;
//        // 取链接中的埋点数据
//        self.tracerDict = paramObj.allParams[@"tracer"];
        self.tracerDict[@"enter_from"] =  self.tracerDict[@"page_type"];
        self.tracerDict[@"page_type"] = [self pageType];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initNavBar];
    [self initView];
    [self initConstrains];
    [self initViewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.viewModel viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.viewModel viewWillDisappear];
    [self.viewModel addStayPageLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

- (void)initNavBar {
    [self setupDefaultNavBar:NO];
    self.titleLabel =  @"经纪人主页";
    //设置导航条透明
    [self setNavBar];
}

- (void)initView {

    [self initHeaderView];
    [self initSegmentView];
    [self addDefaultEmptyViewFullScreen];
    [self initBottomBar];
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
        make.top.mas_equalTo(self.bottomBar.mas_top);
        make.left.right.bottom.mas_equalTo(self.view);
    }];
    [self showBottomBar:NO];
}

- (void)initHeaderView {
    CGFloat headerBackNormalHeight = 400;
    CGFloat headerBackXSeriesHeight = headerBackNormalHeight + 44; //刘海平多出24
    CGFloat height = [UIDevice btd_isIPhoneXSeries] ? headerBackXSeriesHeight : headerBackNormalHeight + 40;
    self.headerView = [[FHHouseRealtorDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, headerBackXSeriesHeight)];
    self.headerView.controller = self;
    self.headerView.channel = @"lynx_realtor_detail_header";
    self.headerView.bacImageName = @"realtor_header";
//    self.headerView.channel = @"http://192.168.50.221:30334/lynx_realtor_detail_header/template.js?1595163180304";
    
    
//        self.headerView = [[FHHouseRealtorDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
//        self.headerView.controller = self;
////        self.headerView.channel = @"lynx_realtor_detail_header";
//        self.headerView.channel = @"http://192.168.50.221:30334/lynx_realtor_detail_header/template.js?1595139974768";
//        self.headerView.bacImageName = @"realtor_header";
//        self.headerView.height = self.headerView.viewHeight;

}

- (void)initSegmentView {
    self.segmentView = [[FHCommunityDetailSegmentView alloc] init];
    self.segmentView.underLinePaddingToLab = 35;
    self.segmentView.underLineWidth = 20;
    [_segmentView setUpTitleEffect:^(NSString *__autoreleasing *titleScrollViewColorKey, NSString *__autoreleasing *norColorKey, NSString *__autoreleasing *selColorKey, UIFont *__autoreleasing *titleFont, UIFont *__autoreleasing *selectedTitleFont) {
        *titleScrollViewColorKey  = @"Background21",
        *norColorKey = @"grey3"; //
        *selColorKey = @"grey1";//grey1
        *titleFont = [UIFont themeFontRegular:16];
        *selectedTitleFont = [UIFont themeFontSemibold:16];
    }];
    [_segmentView setUpUnderLineEffect:^(BOOL *isUnderLineDelayScroll, CGFloat *underLineH, NSString *__autoreleasing *underLineColorKey, BOOL *isUnderLineEqualTitleWidth) {
        *isUnderLineDelayScroll = NO;
        *underLineH = 4;
        *underLineColorKey = @"orange4";
        *isUnderLineEqualTitleWidth = YES;
    }];
    _segmentView.backgroundColor = [UIColor colorWithHexStr:@"#f8f8f8"];
    _segmentView.bottomLine.hidden = YES;
    _segmentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_segmentView setUnderLineLayer:2];
}

- (void)initConstrains {
}

- (void)setNavBar {
        self.customNavBarView.title.text = @"经纪人主页";
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        UIImage *whiteBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor whiteColor]);
        [self.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:YES];
    self.customNavBarView.seperatorLine.hidden = YES;
}

- (void)initViewModel {
    NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:@"lynx_realtor_detail_header" templateKey:[FHLynxManager defaultJSFileName] version:0];
    if (!templateData) {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
    }else {
        self.viewModel = [[FHHouseRealtorDetailVM alloc] initWithController:self tracerDict:self.tracerDict realtorInfo:self.realtorDetailInfo bottomBar:self.bottomBar];
        [self.viewModel addGoDetailLog];
        [self.viewModel updateNavBarWithAlpha:self.customNavBarView.bgView.alpha];
        [self.viewModel requestDataWithRealtorId:self.realtorDetailInfo[@"realtor_id"] refreshFeed:YES];
    }
}

- (void)retryLoadData {
    [self.viewModel requestDataWithRealtorId:self.realtorDetailInfo[@"realtor_id"] refreshFeed:YES];
}

// 白色
- (UIImage *)shareWhiteImage
{
    if (!_shareWhiteImage) {
        _shareWhiteImage = ICON_FONT_IMG(24, @"\U0000e692", [UIColor whiteColor]); //detail_share_white
    }
    return _shareWhiteImage;
}

- (NSString *)pageType {
    return @"realtor_detail";
}

#pragma mark - 埋点

- (NSDictionary *)followButtonTraceDict {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"community_id"] = self.communityId;
    params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"be_null";
    params[@"click_position"] = @"join_like";
    params[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @"be_null";
    return [params copy];
}

@end
