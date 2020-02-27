//
//  FHSpecialTopicViewController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/2/20.
//

#import "FHSpecialTopicViewController.h"
#import "FHSpecialTopicViewModel.h"
#import "UIViewController+Track.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "FHUGCShareManager.h"
#import "TTBaseMacro.h"
#import "FHUGCFollowButton.h"
#import "UILabel+House.h"
#import "TTDeviceHelper.h"
#import "FHCommonDefines.h"
#import "FHUserTracker.h"
#import "UIViewController+NavigationBarStyle.h"
#import "UIImage+FIconFont.h"
#import <FHHouseBase/FHBaseTableView.h>

@interface FHSpecialTopicViewController ()<TTUIViewControllerTrackProtocol>
@property (nonatomic, strong) FHSpecialTopicViewModel *viewModel;
@property (nonatomic, strong) UIImage *shareWhiteImage;
@property (nonatomic, strong) UIButton *shareButton;// 分享

@end

@implementation FHSpecialTopicViewController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.ttTrackStayEnable = YES;
        self.forumId = paramObj.allParams[@"forum_id"];
        self.tabName = paramObj.allParams[@"tab_name"];
        // 取链接中的埋点数据
        NSDictionary *params = paramObj.allParams;
        NSString *origin_from = params[@"origin_from"];
        if (origin_from.length > 0) {
            self.tracerDict[@"origin_from"] = origin_from;
        }
        NSString *enter_from = params[@"enter_from"];
        if (enter_from.length > 0) {
            self.tracerDict[@"enter_from"] = enter_from;
        }
        NSString *enter_type = params[@"enter_type"];
        if (enter_type.length > 0) {
            self.tracerDict[@"enter_type"] = enter_type;
        }
        NSString *element_from = params[@"element_from"];
        if (element_from.length > 0) {
            self.tracerDict[@"element_from"] = element_from;
        }

        self.tracerDict[@"page_type"] = [self pageType];
        
        NSString *log_pb_str = params[@"log_pb"];
        if ([log_pb_str isKindOfClass:[NSString class]] && log_pb_str.length > 0) {
            NSData *jsonData = [log_pb_str dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err = nil;
            NSDictionary *dic = nil;
            @try {
                dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                      options:NSJSONReadingMutableContainers
                                                        error:&err];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            if (!err && [dic isKindOfClass:[NSDictionary class]] && dic.count > 0) {
                self.tracerDict[@"log_pb"] = dic;
            }
        }
    }
    return self;
}

// 重载方法
- (BOOL)isOpenUrlParamsSame:(NSDictionary *)queryParams {
    return NO;
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
//    [self.viewModel addStayPageLog:self.ttTrackStayTime];
//    [self tt_resetStayTime];
}

- (void)initNavBar {
    [self setupDefaultNavBar:NO];
    
    self.titleLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor themeGray1];
    
    self.titleContainer = [[UIView alloc] init];
    [self.titleContainer addSubview:self.titleLabel];
    [self.customNavBarView addSubview:self.titleContainer];
//    [self.customNavBarView addSubview:self.rightBtn];
    // 分享按钮
    self.shareButton = [[UIButton alloc] init];
    [self.shareButton setBackgroundImage:self.shareWhiteImage forState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:self.shareWhiteImage forState:UIControlStateHighlighted];
    [self.shareButton addTarget:self  action:@selector(shareButtonClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.customNavBarView addSubview:_shareButton];
    //设置导航条透明
    [self setNavBar:NO];
    
    [self.customNavBarView layoutIfNeeded];
}

- (void)initView {
    [self initHeaderView];
    [self initSegmentView];
    [self initTableView];
    [self addDefaultEmptyViewFullScreen];
}

- (void)initHeaderView {
    CGFloat height = (NSInteger)([UIScreen mainScreen].bounds.size.width * 0.8) - CGRectGetMaxY(self.customNavBarView.frame);
    self.headerView = [[FHSpecialTopicHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
}

- (void)initSegmentView {
    self.segmentView = [[FHCommunityDetailSegmentView alloc] init];
    _segmentView.intervalPadding = 16.0f;
    [_segmentView setUpTitleEffect:^(NSString *__autoreleasing *titleScrollViewColorKey, NSString *__autoreleasing *norColorKey, NSString *__autoreleasing *selColorKey, UIFont *__autoreleasing *titleFont, UIFont *__autoreleasing *selectedTitleFont) {
        *norColorKey = @"grey1"; //grey3
        *selColorKey = @"orange1";//orange1
        *titleFont = [UIFont themeFontRegular:16];
        *selectedTitleFont = [UIFont themeFontSemibold:16];
    }];
//    [_segmentView setUpUnderLineEffect:^(BOOL *isUnderLineDelayScroll, CGFloat *underLineH, NSString *__autoreleasing *underLineColorKey, BOOL *isUnderLineEqualTitleWidth) {
//        *isUnderLineDelayScroll = NO;
//        *underLineH = 2;
//        *underLineColorKey = @"akmain";
//        *isUnderLineEqualTitleWidth = YES;
//    }];
    _segmentView.backgroundColor = [UIColor clearColor];
    _segmentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)initTableView {
    if(!_tableView){
        self.tableView = [[FHBaseTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor themeGray7];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.tableHeaderView = [[UIView alloc] initWithFrame:self.headerView.bounds];
        [_tableHeaderView addSubview:_headerView];
        _tableView.tableHeaderView = self.tableHeaderView;
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
        _tableView.tableFooterView = footerView;
        
        _tableView.sectionFooterHeight = 0.0;
        
        _tableView.estimatedRowHeight = 0;
        _tableView.showsVerticalScrollIndicator = NO;
        
        if (@available(iOS 11.0 , *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
        }
        
        if ([TTDeviceHelper isIPhoneXDevice]) {
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        }
        
        [self.view addSubview:_tableView];
    }
}

- (void)initConstrains {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.titleContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.customNavBarView.leftBtn.mas_centerY);
        make.left.mas_equalTo(self.customNavBarView.leftBtn.mas_right).offset(10.0f);
        make.right.mas_equalTo(self.rightBtn.mas_left).offset(-10);
        make.height.mas_equalTo(34);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleContainer);
        make.centerX.mas_equalTo(self.customNavBarView);
        make.height.mas_equalTo(20);
    }];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-10);
    }];
}

- (void)setNavBar:(BOOL)showJoinButton {
    if (showJoinButton) {
        self.customNavBarView.title.textColor = [UIColor themeGray1];
        UIImage *blackBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]);
        [self.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateHighlighted];
        self.shareButton.hidden = YES;
        [self.customNavBarView setNaviBarTransparent:NO];
    } else {
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        UIImage *whiteBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor whiteColor]);
        [self.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateHighlighted];
        self.shareButton.hidden = NO;
        [self.customNavBarView setNaviBarTransparent:YES];
    }
}

- (void)initViewModel {
    self.viewModel = [[FHSpecialTopicViewModel alloc] initWithTableView:self.tableView controller:self];
    self.viewModel.shareButton = self.shareButton;
    [self.viewModel addGoDetailLog];
    [self.viewModel updateNavBarWithAlpha:self.customNavBarView.bgView.alpha];
    [self.viewModel requestData:NO refreshFeed:YES showEmptyIfFailed:YES showToast:NO];
}

- (void)retryLoadData {
    [self.viewModel requestData:NO refreshFeed:YES showEmptyIfFailed:YES showToast:NO];
}

// 白色
- (UIImage *)shareWhiteImage
{
    if (!_shareWhiteImage) {
        _shareWhiteImage = ICON_FONT_IMG(24, @"\U0000e692", [UIColor whiteColor]); //detail_share_white
    }
    return _shareWhiteImage;
}

// 分享按钮点击
- (void)shareButtonClicked:(UIButton *)btn {
    if (self.viewModel.shareInfo && self.viewModel.shareTracerDict) {
        [[FHUGCShareManager sharedManager] shareActionWithInfo:self.viewModel.shareInfo tracerDic:self.viewModel.shareTracerDict];
    }
}

- (NSString *)pageType {
    return @"special_subject";
}

@end
