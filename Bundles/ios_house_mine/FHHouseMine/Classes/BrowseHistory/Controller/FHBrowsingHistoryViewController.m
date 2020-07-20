//
//  FHBrowsingHistoryViewController.m
//  BDSSOAuthSDK-BDSSOAuthSDK
//
//  Created by wangxinyu on 2020/7/10.
//

#import "FHSuggestionCollectionView.h"
#import "TTDeviceHelper.h"
#import "HMSegmentedControl.h"
#import "FHBrowsingHistoryViewModel.h"
#import "FHEnvContext.h"
#import "FHHouseType.h"
#import "FHUserTracker.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "UIViewAdditions.h"
#import "UIViewController+Track.h"
#import "FHFakeInputNavbar.h"
#import <FHHouseBase/UIImage+FIconFont.h>

static const float kSegementedOneWidth = 50;

@interface FHBrowsingHistoryViewController ()

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) FHBrowsingHistoryViewModel *viewModel;
@property (nonatomic, strong) FHFakeInputNavbar *navbar;

@end

@implementation FHBrowsingHistoryViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _houseType = -1;
        self.paramObj = paramObj;
        self.ttTrackStayEnable = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.houseTypeArray = [[NSMutableArray alloc] init];
    [self houseTypeConfig];
    [self setupUI];
    self.viewModel = [[FHBrowsingHistoryViewModel alloc] initWithController:self andCollectionView:self.collectionView];
    [self.viewModel addGoDetailLog];
    self.houseType = FHHouseTypeSecondHandHouse;
}

- (void)initNav {
    self.title = @"浏览历史";
    [self setupDefaultNavBar:NO];
    [self.customNavBarView.leftBtn setBackgroundImage:ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]) forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]) forState:UIControlStateHighlighted];
    self.customNavBarView.seperatorLine.hidden = NO;
}

- (void)setupUI {
    [self initNav];
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_topView];
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    CGFloat naviHeight = 44 + (isIphoneX ? 44 : 20);
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(naviHeight);
        make.height.mas_equalTo(44);
    }];
    [self setupSegmentedControl];
    
    self.containerView = [[UIView alloc] init];
    [self.view addSubview:_containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(self.topView.mas_bottom);
    }];
    
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - naviHeight - 44);
    //设置collectionView滚动方向
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    //2.初始化collectionView
    self.collectionView = [[FHSuggestionCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.allowsSelection = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.bounces = NO;
    _collectionView.scrollEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor themeGray7];
    [self.containerView addSubview:_collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

-(NSArray *)getSegmentTitles {
    NSArray *items = @[@"二手房", @"新房", @"租房", @"小区"];
    return items;
}

- (void)setupSegmentedControl {
    _segmentControl = [[HMSegmentedControl alloc] initWithSectionTitles:[self getSegmentTitles]];
    NSDictionary *titleTextAttributes = @{NSFontAttributeName: [UIFont themeFontRegular:16],
                                          NSForegroundColorAttributeName: [UIColor themeGray1]};
    _segmentControl.titleTextAttributes = titleTextAttributes;
    NSDictionary *selectedTitleTextAttributes = @{NSFontAttributeName: [UIFont themeFontSemibold:16],
                                                  NSForegroundColorAttributeName: [UIColor themeGray1]};
    _segmentControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(3, 0, 0, 0);
    _segmentControl.selectedTitleTextAttributes = selectedTitleTextAttributes;
    _segmentControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    _segmentControl.isNeedNetworkCheck = NO;
    _segmentControl.segmentEdgeInset = UIEdgeInsetsMake(9, 14, 0, 14);
    _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentControl.selectionIndicatorWidth = 20.0f;
    _segmentControl.selectionIndicatorHeight = 4.0f;
    
    _segmentControl.selectionIndicatorCornerRadius = 2.0f;
    _segmentControl.selectionIndicatorColor = [UIColor colorWithHexStr:@"#ff9629"];
    [_segmentControl setBackgroundColor:[UIColor clearColor]];
    [self.topView addSubview:_segmentControl];
    [_segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_topView);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo((kSegementedOneWidth + 16) * self.houseTypeArray.count);
    }];
    
    WeakSelf;
    _segmentControl.indexChangeBlock = ^(NSInteger index) {
        StrongSelf;
        if (index >= 0 && index < self.houseTypeArray.count) {
            self.houseType = [self.houseTypeArray[index] integerValue];
        }
    };
}

- (void)setHouseType:(FHHouseType)houseType {
    if (_houseType == houseType) {
        return;
    }
    _houseType = houseType;
    self.viewModel.currentTabIndex = _segmentControl.selectedSegmentIndex;
    [self.collectionView layoutIfNeeded];
    [self.viewModel updateSubVCTrackStatus];
}

- (void)houseTypeConfig {
    [self.houseTypeArray addObject:[NSNumber numberWithInt: FHHouseTypeSecondHandHouse]];
    [self.houseTypeArray addObject:[NSNumber numberWithInt: FHHouseTypeNewHouse]];
    [self.houseTypeArray addObject:[NSNumber numberWithInt: FHHouseTypeRentHouse]];
    [self.houseTypeArray addObject:[NSNumber numberWithInt: FHHouseTypeNeighborhood]];
}

- (void)dealloc
{
    
}

@end
