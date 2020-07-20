//
//  FHHouseRealtorShopVC.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/17.
//

#import "FHHouseRealtorShopVC.h"
#import "FHBaseTableView.h"
#import "FHHouseRealtorShopVM.h"

#import "UIDevice+BTDAdditions.h"
#import "FHCommonDefines.h"
#import "FHUserTracker.h"
#import "UIViewController+NavigationBarStyle.h"
#import "UIImage+FIconFont.h"
#import "FHRealtorDetailBottomBar.h"
#import "UIViewAdditions.h"
#import "FHRealtorEvaluatingPhoneCallModel.h"
@interface FHHouseRealtorShopVC ()
@property (strong, nonatomic)UITableView *tableView;
@property (strong, nonatomic) FHHouseRealtorShopVM *viewModel;
@property(nonatomic, strong) FHRealtorEvaluatingPhoneCallModel *realtorPhoneCallModel;
@property (nonatomic, strong) UIView *bottomMaskView;
@property (nonatomic, strong) FHRealtorDetailBottomBar *bottomBar;
@property (nonatomic, strong) NSMutableDictionary *realtorInfoDic;
@end
@implementation FHHouseRealtorShopVC
- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        [self createTracerDic:paramObj.allParams];
        self.realtorInfoDic = paramObj.allParams.mutableCopy;
    }
    return self;
}
//queryParams:
//{
//    "realtor_id" = undefined;
//    "report_params" = undefined;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initHeaderView];
    [self initTableView];
    [self initFrame];
    [self setNavBar];
    [self addDefaultEmptyViewFullScreen];
    [self initBottomBar];
     [self createModel];
}

- (void)initFrame {
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.bottom.equalTo(self.bottomBar);
    }];
}

- (void)createModel {
    _viewModel = [[FHHouseRealtorShopVM alloc]initWithController:self tableView:self.tableView realtorDic:self.realtorInfoDic.copy bottomBar:self.bottomBar];
}

- (void)createTracerDic:(NSDictionary *)dic {
    
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
            make.bottom.mas_equalTo(self.view).mas_offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
        }else {
            make.bottom.mas_equalTo(self.view);
        }
    }];
    [_bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomBar.mas_top);
        make.left.right.bottom.mas_equalTo(self.view);
    }];
}

- (void)initTableView {
    _tableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor colorWithHexStr:@"#f8f8f8"];
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.tableHeaderView = self.headerView;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
              if (@available(iOS 11.0, *)) {
                 make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom -64);
             }else {
                 make.bottom.mas_equalTo(-64);
             }
    }];
}

- (void)initHeaderView {
    self.headerView = [[FHHouseRealtorDetailHeaderView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    
    self.headerView.channel = @"lynx_realtor_shop_header";
//    self.headerView.channel = @"http://192.168.50.221:30334/lynx_realtor_shop_header/template.js?1595163180304";
//    self.headerView.bacImageName = @"realtor_header";
    self.headerView.height = self.headerView.viewHeight;
    self.headerView.bacImageName = @"realtor_header";
}

- (void)setNavBar {
    [self setupDefaultNavBar:NO];
        self.customNavBarView.title.text = @"经纪人店铺";
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        UIImage *whiteBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor whiteColor]);
        [self.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:YES];
    self.customNavBarView.seperatorLine.hidden = YES;
}

@end
