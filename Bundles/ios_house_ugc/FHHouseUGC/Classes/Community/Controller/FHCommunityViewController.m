//
//  FHCommunityViewController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/5/27.
//

#import "FHCommunityViewController.h"
#import "FHPostUGCViewController.h"
#import "TTNavigationController.h"
#import "FHWDPostViewController.h"
#import "TTDeviceHelper.h"
#import "FHCommunityViewModel.h"
#import "FHTopicDetailViewController.h"
#import "FHCommunityDetailViewController.h"
#import "FHPostDetailViewController.h"
#import "FHWDAnswerPictureTextViewController.h"
#import "FHUGCFollowListController.h"
#import "UIButton+TTAdditions.h"

@interface FHCommunityViewController ()

@property(nonatomic , strong) FHCommunityViewModel *viewModel;
@property(nonatomic , strong) UIView *bottomLineView;
@property(nonatomic , strong) UIView *topView;
@property(nonatomic , strong) UIButton *searchBtn;

@end

@implementation FHCommunityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initView];
    [self initConstraints];
    [self initViewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear];
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_topView];
    
    self.bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = [UIColor themeGray6];
    [self.topView addSubview:_bottomLineView];
    
    self.searchBtn = [[UIButton alloc] init];
    [_searchBtn setImage:[UIImage imageNamed:@"fh_ugc_search"] forState:UIControlStateNormal];
    _searchBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [_searchBtn addTarget:self action:@selector(goToSearch) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:_searchBtn];
    
    self.containerView = [[UIView alloc] init];
    [self.view addSubview:_containerView];
    
    [self setupCollectionView];
    [self setupSetmentedControl];
}

- (void)setupCollectionView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    //2.初始化collectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.allowsSelection = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor themeGray7];
    [self.containerView addSubview:_collectionView];
}

- (void)setupSetmentedControl {
    _segmentControl =  [[HMSegmentedControl alloc] initWithSectionTitles:@[@"我关注的",@"附近",@"发现"]];
    
    NSDictionary* titleTextAttributes = @{NSFontAttributeName: [UIFont themeFontRegular:16],
                                          NSForegroundColorAttributeName: [UIColor themeGray3]};
    _segmentControl.titleTextAttributes = titleTextAttributes;
    
    NSDictionary* selectedTitleTextAttributes = @{NSFontAttributeName: [UIFont themeFontMedium:16],
                                                  NSForegroundColorAttributeName: [UIColor themeGray1]};
    _segmentControl.selectedTitleTextAttributes = selectedTitleTextAttributes;
    
    
    _segmentControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    _segmentControl.isNeedNetworkCheck = NO;
    _segmentControl.segmentEdgeInset = UIEdgeInsetsMake(5, 10, 0, 10);
    _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentControl.selectionIndicatorWidth = 24.0f;
    _segmentControl.selectionIndicatorHeight = 12.0f;
//    _segmentControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 0, -5, 0);
    _segmentControl.selectionIndicatorImage = [UIImage imageNamed:@"fh_ugc_segment_selected"];
    
    [self.topView addSubview:_segmentControl];
    
    __weak typeof(self) weakSelf = self;
    _segmentControl.indexChangeBlock = ^(NSInteger index) {
        [weakSelf.viewModel segmentViewIndexChanged:index];
    };
}

- (void)initConstraints {
    
    CGFloat bottom = 49;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    
    CGFloat top = 0;
    CGFloat safeTop = 0;
    if (@available(iOS 11.0, *)) {
        safeTop =  [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].top;
    }
    if (safeTop > 0) {
        top += safeTop;
    }else{
        top += [[UIApplication sharedApplication]statusBarFrame].size.height;
    }
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(top);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(60);
    }];
    
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView);
        make.right.mas_equalTo(self.topView).offset(-20);
        make.width.height.mas_equalTo(24);
    }];
    
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.topView);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
    
    [self.segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.topView);
        make.width.mas_equalTo([self.segmentControl totalSegmentedControlWidth]);
        make.top.mas_equalTo(self.topView).offset(10);
        make.bottom.mas_equalTo(self.topView).offset(-4);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-bottom);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
}

- (void)initViewModel {
    _viewModel = [[FHCommunityViewModel alloc] initWithCollectionView:self.collectionView controller:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
//    FHUGCFollowListController *vc = [[FHUGCFollowListController alloc] init];
//    TTNavigationController *navVC = [[TTNavigationController alloc] initWithRootViewController:vc];
//    [self presentViewController:navVC animated:YES completion:nil];
    
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"title"] = @"选择小区";
    dict[@"action_type"] = @(1);
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_follow_communitys"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)hideSegmentControl {
    self.segmentControl.hidden = YES;
    self.bottomLineView.hidden = YES;
    self.topView.hidden = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
}

//进入搜索页
- (void)goToSearch {
    
}

@end
