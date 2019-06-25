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
#import <FHEnvContext.h>

@interface FHCommunityViewController ()

@property(nonatomic , strong) FHCommunityViewModel *viewModel;
@property(nonatomic , strong) UIView *bottomLineView;
@property(nonatomic , strong) UIView *topView;
@property (nonatomic, assign) NSTimeInterval stayTime; //页面停留时间
@property (nonatomic, assign) BOOL hasShowDots;
@end

@implementation FHCommunityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.hasShowDots = NO;

    [self initView];
    [self initConstraints];
    [self initViewModel];
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_topView];
    
    self.bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = [UIColor themeGray6];
    [self.topView addSubview:_bottomLineView];
    
    self.containerView = [[UIView alloc] init];
    [self.view addSubview:_containerView];
    
    [self setupCollectionView];
    [self setupSetmentedControl];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self addStayCategoryLog:self.stayTime];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.stayTime = [[NSDate date] timeIntervalSince1970];
    
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
    [tracerDict setValue:@"main" forKey:@"tab_name"];
    [tracerDict setValue:@(0) forKey:@"with_tips"];
    [tracerDict setValue:@"click_tab" forKey:@"enter_type"];
    tracerDict[@"stay_time"] = @((int)duration);
    
    if (((int)duration) > 0) {
        [FHEnvContext recordEvent:tracerDict andEventKey:@"stay_tab"];
    }
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
    
    NSDictionary* titleTextAttributes = @{NSFontAttributeName: [UIFont themeFontRegular:14],
                                          NSForegroundColorAttributeName: [UIColor themeGray3]};
    _segmentControl.titleTextAttributes = titleTextAttributes;
    
    NSDictionary* selectedTitleTextAttributes = @{NSFontAttributeName: [UIFont themeFontMedium:14],
                                                  NSForegroundColorAttributeName: [UIColor themeGray1]};
    _segmentControl.selectedTitleTextAttributes = selectedTitleTextAttributes;
    
    
    _segmentControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    _segmentControl.isNeedNetworkCheck = NO;
    _segmentControl.segmentEdgeInset = UIEdgeInsetsMake(5, 10, 0, 10);
    _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentControl.selectionIndicatorWidth = 30.0f;
    _segmentControl.selectionIndicatorHeight = 2;
    _segmentControl.selectionIndicatorColor = [UIColor themeRed1];
    
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
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.topView);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
    
    [self.segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.topView);
        make.width.mas_equalTo([self.segmentControl totalSegmentedControlWidth]);
        make.top.mas_equalTo(self.topView).offset(2);
        make.bottom.mas_equalTo(self.topView).offset(-2);
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
    
//    FHWDAnswerPictureTextViewController *vc = [[FHWDAnswerPictureTextViewController alloc] init];
//    TTNavigationController *navVC = [[TTNavigationController alloc] initWithRootViewController:vc];
//    [self presentViewController:navVC animated:YES completion:nil];
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

@end
