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
#import "FHTopicTopBackView.h"
#import "FHUGCTopicRefreshHeader.h"
#import "FHRefreshCustomFooter.h"
#import "UILabel+House.h"

@interface FHTopicDetailViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong)   UIScrollView       *mainScrollView;
@property (nonatomic, strong)   FHTopicTopBackView        *topHeaderView;
@property (nonatomic, strong)   FHTopicHeaderInfo       *headerInfoView;
@property (nonatomic, strong)   FHTopicSectionHeaderView       *sectionHeaderView;
@property (nonatomic, strong)   FHUGCTopicRefreshHeader       *refreshHeader;
@property (nonatomic, assign)   CGFloat       minSubScrollViewHeight;
@property (nonatomic, assign)   CGFloat       maxSubScrollViewHeight;
@property (nonatomic, assign)   CGFloat       criticalPointHeight;// 临界点长度
@property (nonatomic, assign)   CGFloat       topHeightOffset;
@property (nonatomic, assign)   CGFloat       navOffset;
@property (nonatomic, strong)   UIScrollView       *subScrollView;
@property (nonatomic, strong)   FHTopicDetailViewModel       *viewModel;
@property (nonatomic, assign)   BOOL       isViewAppear;
@property (nonatomic, strong)   UILabel *titleLabel;
@property (nonatomic, strong)   UILabel *subTitleLabel;
@property (nonatomic, strong)   UIView *titleContainer;

@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;
@property (nonatomic, assign) BOOL canScroll;

@end

@implementation FHTopicDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    self.isViewAppear = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"kFHUGCLeaveTop" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isViewAppear = YES;
    [self refreshContentOffset:self.mainScrollView.contentOffset];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isViewAppear = NO;
}

- (void)setupUI {
    self.navOffset = 64;
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
    
    // _topHeaderView
    _topHeaderView = [[FHTopicTopBackView alloc] init];
    _topHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 144);
    [self.mainScrollView addSubview:_topHeaderView];
    [self.topHeaderView.avatar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mainScrollView).offset(20);
    }];
    
    // refreshHeader
    self.refreshHeader = [[FHUGCTopicRefreshHeader alloc] init];
    [self.topHeaderView addSubview:self.refreshHeader];
    self.refreshHeader.scrollView = self.mainScrollView;
    self.refreshHeader.beginEdgeInsets = self.mainScrollView.contentInset;
    [self.refreshHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.topHeaderView);
        make.height.mas_equalTo(14);
        make.bottom.mas_equalTo(self.topHeaderView.mas_bottom).offset(-85);
    }];
    self.refreshHeader.alpha = 0;
    __weak typeof(self) weakSelf = self;
    self.refreshHeader.refreshingBlk = ^{
        [weakSelf beginRefresh];
    };
    
    // _headerInfoView
    _headerInfoView = [[FHTopicHeaderInfo alloc] init];
    _headerInfoView.frame = CGRectMake(0, 144, SCREEN_WIDTH, 40);
    [self.mainScrollView addSubview:_headerInfoView];
    self.mainScrollView.backgroundColor = [UIColor themeGray7];
    self.topHeightOffset = CGRectGetMaxY(self.headerInfoView.frame) + 5;
    
    // 计算subScrollView的高度
    CGFloat navOffset = 64;
    if (@available(iOS 11.0 , *)) {
        navOffset = 44.f + self.view.tt_safeAreaInsets.top;
    } else {
        navOffset = 64;
    }
    self.navOffset = navOffset;
    self.minSubScrollViewHeight = SCREEN_HEIGHT - self.topHeightOffset;// 暂时不用，数据较少时也可在下面展示空页面
    self.maxSubScrollViewHeight = SCREEN_HEIGHT - navOffset;
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
    _viewModel.currentSelectIndex = 0;
    
    // self.mainScrollView.hidden = YES;
    
    // 初始化tableViews，后续可能网络返回结果
    NSArray *indexStrs = @[@"最新"];
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
            [self.viewModel.hashTable addObject:tempView];
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
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableFooterView = footerView;
    
    _tableView.sectionFooterHeight = 0.0;
    
    _tableView.estimatedRowHeight = 0;
    
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    if ([TTDeviceHelper isIPhoneXSeries]) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    // 上拉加载更多
    __weak typeof(self) weakSelf = self;
    FHRefreshCustomFooter *refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [weakSelf loadMore];
    }];
    _tableView.mj_footer = refreshFooter;
    
    refreshFooter.hidden = YES;
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

- (void)refreshHeaderData {
    FHTopicHeaderModel       *headerModel = self.viewModel.headerModel;
    if (headerModel && headerModel.forum) {
        self.titleLabel.text = headerModel.forum.forumName;
        self.subTitleLabel.text = headerModel.forum.subDesc;
        [self.topHeaderView updateWithInfo:headerModel];
        [self updateTopicNotice:headerModel.forum.desc];// 话题简介
        // 更新顶部布局
        self.topHeightOffset = CGRectGetMaxY(self.headerInfoView.frame) + 5;
        self.minSubScrollViewHeight = SCREEN_HEIGHT - self.topHeightOffset;
        self.criticalPointHeight = self.maxSubScrollViewHeight - self.minSubScrollViewHeight;
        self.subScrollView.frame = CGRectMake(0, self.topHeightOffset, SCREEN_WIDTH, self.maxSubScrollViewHeight);
        self.mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, self.maxSubScrollViewHeight + self.topHeightOffset);
    }
}

- (void)updateTopicNotice:(NSString *)announcement {
    NSMutableAttributedString *attributedText = [NSMutableAttributedString new];
    if (isEmptyString(announcement)) {
        announcement = @"-";
    }
    if(!isEmptyString(announcement)) {
        UIFont *titleFont = [UIFont themeFontSemibold:12];
        NSDictionary *announcementTitleAttributes = @{
                                                      NSFontAttributeName: titleFont,
                                                      NSForegroundColorAttributeName: [UIColor themeGray1]
                                                      };
        NSAttributedString *announcementTitle = [[NSAttributedString alloc] initWithString:@"[话题简介] " attributes: announcementTitleAttributes];
        
        UIFont *contentFont = [UIFont themeFontRegular:12];
        NSDictionary *announcemenContentAttributes = @{
                                                       NSFontAttributeName: contentFont,
                                                       NSForegroundColorAttributeName: [UIColor themeGray1]
                                                       };
        NSAttributedString *announcementContent = [[NSAttributedString alloc] initWithString:announcement attributes:announcemenContentAttributes];
        
        [attributedText appendAttributedString:announcementTitle];
        [attributedText appendAttributedString:announcementContent];
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        CGFloat lineHeight = 20;
        paragraphStyle.minimumLineHeight = lineHeight;
        paragraphStyle.maximumLineHeight = lineHeight;
        
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedText.length)];
        
        CGSize attSize = [attributedText boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 40, 100) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
        self.headerInfoView.frame = CGRectMake(0, 144, SCREEN_WIDTH, attSize.height + 20);
        // ... 逻辑
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedText.length)];
    }
    self.headerInfoView.infoLabel.attributedText = attributedText;
}

- (void)setupDetailNaviBar {
    self.customNavBarView.title.text = @"";
    self.titleLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor themeGray1];
    
    self.subTitleLabel = [UILabel createLabel:@"" textColor:@"" fontSize:10];
    self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subTitleLabel.textColor = [UIColor themeGray3];
    
    self.titleContainer = [[UIView alloc] init];
    [self.titleContainer addSubview:self.titleLabel];
    [self.titleContainer addSubview:self.subTitleLabel];
    [self.customNavBarView addSubview:self.titleContainer];
    [self.titleContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.customNavBarView.leftBtn.mas_centerY);
        make.left.mas_equalTo(self.customNavBarView.leftBtn.mas_right).offset(10.0f);
        make.right.mas_equalTo(self.customNavBarView.mas_right).offset(-50);
        make.height.mas_equalTo(34);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.titleContainer);
        make.height.mas_equalTo(20);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.titleContainer);
        make.height.mas_equalTo(14);
    }];
    self.titleContainer.hidden = YES;
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
        [self showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
}

- (void)showEmptyWithType:(FHEmptyMaskViewType)maskViewType {
    [self.emptyView showEmptyWithType:maskViewType];
    self.mainScrollView.hidden = YES;
    [self setNavBarTransparent:NO];
    self.customNavBarView.title.text = @"话题";
    [self updateNavBarWithAlpha:1.0];
}

- (void)hiddenEmptyView {
    [self.emptyView hideEmptyView];
    self.mainScrollView.hidden = NO;
    [self setNavBarTransparent:YES];
    self.customNavBarView.title.text = @"";
    [self refreshContentOffset:CGPointZero];
}

// 重新加载
- (void)retryLoadData {
    if (!self.isLoadingData) {
        [self startLoadData];
    }
}

// 下拉刷新
- (void)beginRefresh {
    NSLog(@"--------下拉刷新");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.refreshHeader endRefreshing];
    });
}

// 上拉加载
- (void)loadMore {
    NSLog(@"--------上拉加载");
    UITableView *tb = self.viewModel.currentTableView;
    if (tb) {
        FHRefreshCustomFooter *refreshFooter = tb.mj_footer;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [refreshFooter setUpNoMoreDataText:@"没有更多信息了"];
            [tb.mj_footer endRefreshingWithNoMoreData];
        });
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

// 滑动切换tab
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _mainScrollView) {
        
    } else if (scrollView == _subScrollView) {
        CGFloat offsetX = scrollView.contentOffset.x;
        CGFloat tempIndex = offsetX / SCREEN_WIDTH;
        self.viewModel.currentSelectIndex = (NSInteger)tempIndex;
    }
}

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
        
        // topHeaderView
        offsetY = scrollView.contentOffset.y;
        if (offsetY < 0) {
            CGFloat height = 144 - offsetY;
            self.topHeaderView.frame = CGRectMake(offsetY / 2, offsetY, SCREEN_WIDTH - offsetY, height);
        } else {
            self.topHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 144);
        }
        // refreshHeader
        [self.refreshHeader scrollViewDidScroll:self.mainScrollView];
        if(offsetY < 0) {
            CGFloat alpha = self.refreshHeader.mj_h <= 0 ? 0.0f : fminf(1.0f,fabsf(-offsetY / self.refreshHeader.mj_h));
            self.refreshHeader.alpha = alpha;
        }else{
            self.refreshHeader.alpha = 0;
        }
        
        // alpha
        [self refreshContentOffset:scrollView.contentOffset];
    } if (scrollView == _subScrollView) {
        // 列表父scrollview
    } else {
        // nothing
    }
}

- (void)refreshContentOffset:(CGPoint)contentOffset {
    CGFloat offsetY = contentOffset.y;
    CGFloat alpha = offsetY / (self.navOffset);
    alpha = fminf(fmaxf(0.0f, alpha), 1.0f);
    [self updateNavBarWithAlpha:alpha];
}

- (void)updateNavBarWithAlpha:(CGFloat)alpha {
    if (!self.isViewAppear) {
        return;
    }
    alpha = fminf(fmaxf(0.0f, alpha), 1.0f);
    if (alpha <= 0.1f) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
        self.titleContainer.hidden = YES;
    } else if (alpha > 0.1f && alpha < 0.9f) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        self.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        self.titleContainer.hidden = YES;
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        self.titleContainer.hidden = NO;
    }
    [self.customNavBarView refreshAlpha:alpha];
}

@end

// FHTopicDetailScrollView
@implementation FHTopicDetailScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


@end
