//
//  FHTopicDetailViewController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/2.
//

#import "FHTopicDetailViewController.h"
#import "FHExploreDetailToolbarView.h"
#import "SSCommonLogic.h"
#import "TTUIResponderHelper.h"
#import "UIViewAdditions.h"
#import "FHCommentViewController.h"
#import "TTDeviceHelper.h"
#import "FHCommonDefines.h"
#import "FHTopicHeaderInfo.h"
#import "FHTopicSectionHeaderView.h"
#import "FHBaseTableView.h"
#import "FHTopicDetailViewModel.h"
#import "TTReachability.h"
#import "FHUGCCellManager.h"
#import "FHUGCCellHelper.h"

@interface FHTopicDetailViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong)   UIScrollView       *mainScrollView;
@property (nonatomic, strong)   UIImageView        *headerImageView;
@property (nonatomic, strong)   FHTopicHeaderInfo       *headerInfoView;
@property (nonatomic, strong)   FHTopicSectionHeaderView       *sectionHeaderView;
@property (nonatomic, assign)   CGFloat       minSubScrollViewHeight;
@property (nonatomic, assign)   CGFloat       maxSubScrollViewHeight;
@property (nonatomic, assign)   CGFloat       criticalPointHeight;// 临界点长度
@property (nonatomic, assign)   CGFloat       topHeightOffset;
@property (nonatomic, strong)   UIScrollView       *subScrollView;
@property (nonatomic, strong)   FHTopicDetailViewModel       *viewModel;

@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;
@property (nonatomic, assign) BOOL canScroll;

@end

@implementation FHTopicDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"kFHUGCLeaveTop" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"kFHUGCGoBottom" object:nil];
}

- (void)setupUI {
    self.canScroll = NO;
    self.isTopIsCanNotMoveTabView = NO;
    self.isTopIsCanNotMoveTabViewPre = NO;
    [self setupDefaultNavBar:NO];
    [self setupDetailNaviBar];
    [self setNavBarTransparent:YES];
    // _mainScrollView
    _mainScrollView = [[FHTopicDetailScrollView alloc] init];
    [self.view addSubview:_mainScrollView];
    if (@available(iOS 11.0 , *)) {
         _mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _mainScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    _mainScrollView.delegate = self;
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    
    // _headerImageView
    _headerImageView = [[UIImageView alloc] init];
    NSString *imageName = [NSString stringWithFormat:@"fh_ugc_community_detail_header_back0"];
    _headerImageView.image = [UIImage imageNamed:imageName];
    _headerImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 144);
    [self.mainScrollView addSubview:_headerImageView];
    
    // _headerInfoView
    _headerInfoView = [[FHTopicHeaderInfo alloc] init];
    _headerInfoView.frame = CGRectMake(0, 144, SCREEN_WIDTH, 50);
    [self.mainScrollView addSubview:_headerInfoView];
    
    // sectionHeaderView
    _sectionHeaderView = [[FHTopicSectionHeaderView alloc] init];
    _sectionHeaderView.frame = CGRectMake(0, 194, SCREEN_WIDTH, 50);
    [self.mainScrollView addSubview:_sectionHeaderView];
    // 244
    self.topHeightOffset = CGRectGetMaxY(self.sectionHeaderView.frame);
    
    // 计算subScrollView的高度
    CGFloat navOffset = 64;
    if (@available(iOS 11.0 , *)) {
        navOffset = 44.f + self.view.tt_safeAreaInsets.top;
    } else {
        navOffset = 64;
    }
    self.minSubScrollViewHeight = SCREEN_HEIGHT - self.topHeightOffset;// 暂时不用，数据较少时也可在下面展示空页面
    self.maxSubScrollViewHeight = SCREEN_HEIGHT - navOffset - 50;
    self.criticalPointHeight = self.maxSubScrollViewHeight - self.minSubScrollViewHeight;
    
    // subScrollView
    _subScrollView = [[UIScrollView alloc] init];
    if (@available(iOS 11.0 , *)) {
         _subScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _subScrollView.frame = CGRectMake(0, self.topHeightOffset, SCREEN_WIDTH, self.maxSubScrollViewHeight);
    _subScrollView.delegate = self;
    
    _subScrollView.backgroundColor = [UIColor whiteColor];
    [self.mainScrollView addSubview:self.subScrollView];
    self.mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, self.maxSubScrollViewHeight + self.topHeightOffset);
    // 空态页
    [self addDefaultEmptyViewFullScreen];
    
    // viewModel
    _viewModel = [[FHTopicDetailViewModel alloc] initWithController:self];
    
    // 初始化tableViews，后续可能网络返回结果
    NSArray *indexStrs = @[@"最热",@"最新"];
    [self setupSubTableViews:indexStrs];
    
    // 加载数据
    [self startLoadData];
}

- (void)setupSubTableViews:(NSArray *)tabIndexStrs {
    if ([tabIndexStrs isKindOfClass:[NSArray class]] && tabIndexStrs.count > 0) {
        [self.emptyView hideEmptyView];
        self.mainScrollView.hidden = NO;
        [self setNavBarTransparent:YES];
        NSInteger tabCount = tabIndexStrs.count;
        _subScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * tabCount, self.maxSubScrollViewHeight);
        _subScrollView.pagingEnabled = YES;
        _subScrollView.bounces = NO;
        _subScrollView.showsVerticalScrollIndicator = NO;
        _subScrollView.showsHorizontalScrollIndicator = NO;
        for (NSInteger i = 0; i < tabCount; i++) {
            UITableView *tempView = [self createTableView];
            tempView.frame = CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, self.maxSubScrollViewHeight);
            tempView.tag = i;
            [self.viewModel.ugcCellManager registerAllCell:tempView];
            tempView.delegate = self.viewModel;
            tempView.dataSource = self.viewModel;
            tempView.scrollEnabled = YES;
//            tempView.bounces = NO;
            [_subScrollView addSubview:tempView];
        }
    } else {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
        self.mainScrollView.hidden = YES;
        [self setNavBarTransparent:NO];
    }
}

- (UITableView *)createTableView {
    UITableView *_tableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor themeGray7];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableFooterView = footerView;
    
    _tableView.sectionFooterHeight = 0.0;
    
    _tableView.estimatedRowHeight = 0;
    
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    if ([TTDeviceHelper isIPhoneXDevice]) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    return _tableView;
}

// 导航栏透明
- (void)setNavBarTransparent:(BOOL)transparent {
    if (!transparent) {
        self.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:NO];
    } else {
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:YES];
    }
}

- (void)setupDetailNaviBar {
    self.customNavBarView.title.text = @"话题";
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [self startLoading];
        self.isLoadingData = YES;
        [self.viewModel startLoadData];
    } else {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        self.mainScrollView.hidden = YES;
        [self setNavBarTransparent:NO];
    }
}

// 重新加载
- (void)retryLoadData {
    if (!self.isLoadingData) {
        [self startLoadData];
    }
}

- (void)acceptMsg:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _canScroll = YES;
    }
}

#pragma mark - UIScrollViewDelegate
// mainScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _mainScrollView) {
        CGFloat tabOffsetY;
        CGFloat offsetY = scrollView.contentOffset.y;
        
        _isTopIsCanNotMoveTabViewPre = _isTopIsCanNotMoveTabView;
        
        tabOffsetY = self.criticalPointHeight;
        
        if (offsetY >= tabOffsetY) {
            scrollView.contentOffset = CGPointMake(0, tabOffsetY);
            _isTopIsCanNotMoveTabView = YES;// 底部列表不能移动
        } else {
            _isTopIsCanNotMoveTabView = NO;// 底部列表能移动
        }
        
        if (_isTopIsCanNotMoveTabView != _isTopIsCanNotMoveTabViewPre) {
            if (!_isTopIsCanNotMoveTabViewPre && _isTopIsCanNotMoveTabView) {
                // 滑动到顶端
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHUGCGoTop" object:nil userInfo:@{@"canScroll":@"1"}];
                _canScroll = NO;
            }
            if(_isTopIsCanNotMoveTabViewPre && !_isTopIsCanNotMoveTabView){
                // 离开顶端
                if (!_canScroll) {
                    scrollView.contentOffset = CGPointMake(0, tabOffsetY);
                }
            }
        }
    } if (scrollView == _subScrollView) {
        // 列表父scrollview
    } else {
        // sub
//        CGFloat mainOffsetY = self.mainScrollView.contentOffset.y;
//        CGFloat offsetY = scrollView.contentOffset.y;
//        if (mainOffsetY < self.criticalPointHeight || offsetY <= 0) {
//            self.mainScrollView.contentOffset = CGPointMake(0, mainOffsetY + offsetY);
//            scrollView.contentOffset = CGPointZero;
//        }
    }
}

@end

// FHTopicDetailScrollView
@implementation FHTopicDetailScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


@end
