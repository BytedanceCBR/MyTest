//
//  FHCommunityViewController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/5/27.
//

#import "FHCommunityViewController.h"
#import "TTDeviceHelper.h"
#import "FHCommunityViewModel.h"
#import "UIButton+TTAdditions.h"
#import "FHTopicDetailViewController.h"
#import "FHCommunityDetailViewController.h"
#import "FHPostDetailViewController.h"
#import "FHWDAnswerPictureTextViewController.h"
#import <FHEnvContext.h>
#import "FHUGCGuideHelper.h"
#import "FHUGCGuideView.h"
#import "TTForumPostThreadStatusViewModel.h"
#import "FHEnvContext.h"
#import "FHMessageNotificationTipsManager.h"
#import "FHUnreadMsgModel.h"

@interface FHCommunityViewController ()

@property(nonatomic , strong) FHCommunityViewModel *viewModel;
@property(nonatomic , strong) UIView *bottomLineView;
@property(nonatomic , strong) UIView *topView;
@property(nonatomic , strong) UIButton *searchBtn;
@property (nonatomic, assign) NSTimeInterval stayTime; //页面停留时间
@property(nonatomic, strong) FHUGCGuideView *guideView;
@property (nonatomic, assign) BOOL hasShowDots;
@property (nonatomic, assign) BOOL alreadyShowGuide;

@end

@implementation FHCommunityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.hasShowDots = NO;
    self.isUgcOpen = [FHEnvContext isUGCOpen];
    self.alreadyShowGuide = NO;
    
    [self initView];
    [self initConstraints];
    [self initViewModel];
    
    [self onUnreadMessageChange];
    
    //切换开关
    WeakSelf;
    [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
        StrongSelf;
        FHConfigDataModel *xConfigDataModel = (FHConfigDataModel *)x;
        if(self.isUgcOpen != xConfigDataModel.ugcCitySwitch){
            self.isUgcOpen = xConfigDataModel.ugcCitySwitch;
            [self initViewModel];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topVCChange:) name:@"kExploreTopVCChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUnreadMessageChange) name:kTTMessageNotificationTipsChangeNotification object:nil];
    [TTForumPostThreadStatusViewModel sharedInstance_tt];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addUgcGuide {
    if([FHUGCGuideHelper shouldShowSearchGuide] && self.isUgcOpen && !self.alreadyShowGuide){
        [self.guideView show:self.view dismissDelayTime:5.0f];
        self.alreadyShowGuide = YES;
    }
}

- (FHUGCGuideView *)guideView {
    [self.view layoutIfNeeded];
    if(!_guideView){
        _guideView = [[FHUGCGuideView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 186, CGRectGetMaxY(self.topView.frame) - 7, 176, 42) andType:FHUGCGuideViewTypeSearch];
    }
    return _guideView;
}

- (void)topVCChange:(NSNotification *)notification {
    if(self.isUgcOpen){
        [self.guideView hide];
    }
}

- (void)onUnreadMessageChange {
    FHUnreadMsgDataUnreadModel *model = [FHMessageNotificationTipsManager sharedManager].tipsModel;
    if (model && [model.unread integerValue] > 0) {
        NSInteger count = [model.unread integerValue];
        _segmentControl.sectionMessageTips = @[@(count)];
    }else{
        _segmentControl.sectionMessageTips = @[@(0)];
    }
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
    
//    [self setupCollectionView];
    [self setupSetmentedControl];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self addStayCategoryLog:self.stayTime];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear];
    self.stayTime = [[NSDate date] timeIntervalSince1970];
    [self addUgcGuide];
    
    if(!self.hasShowDots)
    {
        [FHEnvContext hideFindTabRedDots];
        self.hasShowDots = YES;
    }
}

-(void)addStayCategoryLog:(NSTimeInterval)stayTime {
    NSMutableDictionary *tracerDict = [NSMutableDictionary new];
    NSTimeInterval duration = ([[NSDate date] timeIntervalSince1970] - self.stayTime) * 1000.0;
    //        if (duration) {
    //            [tracerDict setValue:@((int)duration) forKey:@"stay_time"];
    //        }
    [tracerDict setValue:@"discover_tab" forKey:@"tab_name"];
    [tracerDict setValue:@(0) forKey:@"with_tips"];
    [tracerDict setValue:@"click_tab" forKey:@"enter_type"];
    tracerDict[@"stay_time"] = @((int)duration);
    
    if (((int)duration) > 0) {
        [FHEnvContext recordEvent:tracerDict andEventKey:@"stay_tab"];
    }
}


- (void)setupCollectionView {
    if(self.collectionView){
        [self.collectionView removeFromSuperview];
        self.collectionView = nil;
    }
    
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
    
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
}

- (void)setupSetmentedControl {
    _segmentControl =  [[HMSegmentedControl alloc] initWithSectionTitles:@[@"关注",@"附近",@"发现"]];
    
    NSDictionary* titleTextAttributes = @{NSFontAttributeName: [UIFont themeFontRegular:16],
                                          NSForegroundColorAttributeName: [UIColor themeGray3]};
    _segmentControl.titleTextAttributes = titleTextAttributes;
    
    NSDictionary* selectedTitleTextAttributes = @{NSFontAttributeName: [UIFont themeFontMedium:18],
                                                  NSForegroundColorAttributeName: [UIColor themeGray1]};
    _segmentControl.selectedTitleTextAttributes = selectedTitleTextAttributes;
    _segmentControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    _segmentControl.isNeedNetworkCheck = NO;
    _segmentControl.segmentEdgeInset = UIEdgeInsetsMake(9, 10, 0, 10);
    _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentControl.selectionIndicatorWidth = 24.0f;
    _segmentControl.selectionIndicatorHeight = 12.0f;
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
        make.top.mas_equalTo(self.topView).offset(6);
        make.bottom.mas_equalTo(self.topView).offset(-4);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-bottom);
    }];
}

- (void)initViewModel {
    [self setupCollectionView];
    _viewModel = [[FHCommunityViewModel alloc] initWithCollectionView:self.collectionView controller:self];
}

- (void)showSegmentControl:(BOOL)isShow {
    self.segmentControl.hidden = !isShow;
    self.bottomLineView.hidden = !isShow;
    self.topView.hidden = !isShow;
    if(isShow){
        _collectionView.backgroundColor = [UIColor themeGray7];
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(60);
        }];
    }else{
        _collectionView.backgroundColor = [UIColor whiteColor];
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
  }
}

//进入搜索页
- (void)goToSearch {
    [self.guideView hide];
    [FHUGCGuideHelper hideSearchGuide];
    
    NSString *routeUrl = @"sslocal://ugc_search_list";
    NSURL *openUrl = [NSURL URLWithString:routeUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
}

@end
