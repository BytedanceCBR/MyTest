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
#import "FHEnvContext.h"
#import "FHUserTracker.h"
#import <UIScrollView+Refresh.h>
#import "FHFeedOperationView.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "SSImpressionManager.h"
#import "FHUserTracker.h"
#import "UIViewController+Track.h"
#import "TTAccountManager.h"
#import "UIImage+FIconFont.h"

@interface FHTopicDetailViewController ()<UIScrollViewDelegate,TTUIViewControllerTrackProtocol>

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

@property (nonatomic, assign)   BOOL isTopIsCanNotMoveTabView;
@property (nonatomic, assign)   BOOL isTopIsCanNotMoveTabViewPre;
@property (nonatomic, assign)   BOOL canScroll;
@property (nonatomic, assign)   CGFloat       defaultTopHeight;
@property (nonatomic, assign)   int64_t cid;// 话题id
@property (nonatomic, strong)   UIButton       *publishBtn;
@property (nonatomic, copy)     NSString       *enter_from;// 从哪进入的当前页面
@end

@implementation FHTopicDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        // 话题
        NSDictionary *params = paramObj.allParams;
        int64_t cid = [[params objectForKey:@"cid"] longLongValue];
        self.cid = cid;
        // 埋点
        self.tracerDict[@"page_type"] = @"topic_detail";
        // 取链接中的埋点数据
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
        // 取url中的埋点数据结束
        self.enter_from = self.tracerDict[@"enter_from"];
        if (cid > 0) {
            self.tracerDict[@"concern_id"] = @(cid);
        }
        self.ttTrackStayEnable = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    self.isViewAppear = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"kFHUGCLeaveTop" object:@"topicDetail"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToSubScrollView:) name:@"kScrollToSubScrollView" object:nil];
    [[SSImpressionManager shareInstance] addRegist:self];
    __weak typeof(self) weakSelf = self;
    self.panBeginAction = ^{
        weakSelf.mainScrollView.scrollEnabled = NO;
    };
    self.panRestoreAction = ^{
        weakSelf.mainScrollView.scrollEnabled = YES;
    };
}
-(void)scrollToSubScrollView:(NSNotification *)notification {
    [self.mainScrollView setContentOffset:self.subScrollView.frame.origin animated:YES];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isViewAppear = YES;
    if (!self.mainScrollView.hidden) {
        [self refreshContentOffset:self.mainScrollView.contentOffset];
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!weakSelf.mainScrollView.hidden) {
                [weakSelf refreshContentOffset:weakSelf.mainScrollView.contentOffset];
            }
        });
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self addStayPageLog];
    self.isViewAppear = NO;
    [self.viewModel viewWillDisappear];
}

- (void)setupUI {
    self.navOffset = 64;
    CGFloat navOffset = 64;
    if (@available(iOS 11.0 , *)) {
        navOffset = 44.f + self.view.tt_safeAreaInsets.top;
    } else {
        navOffset = 64;
    }
    self.navOffset = navOffset;
    self.defaultTopHeight = 144;
    if ([TTDeviceHelper isIPhoneXSeries]) {
        self.defaultTopHeight = self.navOffset + 80;
    }
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
    _mainScrollView.scrollsToTop = YES;
    // _topHeaderView
    _topHeaderView = [[FHTopicTopBackView alloc] init];
    _topHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.defaultTopHeight);
    [self.mainScrollView addSubview:_topHeaderView];
    [self.topHeaderView.avatar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mainScrollView).offset(20);
    }];
    _topHeaderView.hidden = YES;
    
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
    _headerInfoView.frame = CGRectMake(0, self.defaultTopHeight, SCREEN_WIDTH, 40);
    [self.mainScrollView addSubview:_headerInfoView];
    self.mainScrollView.backgroundColor = [UIColor themeGray7];
    self.topHeightOffset = CGRectGetMaxY(self.headerInfoView.frame) + 5;
    _headerInfoView.hidden = YES;
    
    // 计算subScrollView的高度
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
    _subScrollView.scrollsToTop = NO;
    
    _subScrollView.backgroundColor = [UIColor whiteColor];
    [self.mainScrollView addSubview:self.subScrollView];
    self.mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, self.maxSubScrollViewHeight + self.topHeightOffset);
    
    // 发布按钮
    [self setupPublishBtn];
    CGFloat publishBtnBottomHeight = 10;
    if ([TTDeviceHelper isIPhoneXSeries]) {
        publishBtnBottomHeight = 44;
    }else{
        publishBtnBottomHeight = 10;
    }
    [self.publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).offset(-publishBtnBottomHeight);
        make.right.mas_equalTo(self.view).offset(-12);
        make.width.height.mas_equalTo(64);
    }];
    // 空态页
    [self addDefaultEmptyViewFullScreen];
    
    // viewModel
    _viewModel = [[FHTopicDetailViewModel alloc] initWithController:self];
    _viewModel.currentSelectIndex = 0;
    // self.cid = 1642474912698382;//1643171844947979;//1642474912698382;
    _viewModel.cid = self.cid;
    _viewModel.enter_from = self.enter_from;
    
    // self.mainScrollView.hidden = YES;
    
    // 初始化tableViews，后续可能网络返回结果
    NSArray *indexStrs = @[@"最新"];
    [self setupSubTableViews:indexStrs];
    
    // 加载数据
    self.isViewAppear = YES;
    [self startLoadData];
    
    // goDetail
    [self addGoDetailLog];
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
            tempView.scrollsToTop = NO;
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
    _tableView.backgroundColor = [UIColor themeGray7];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableFooterView = footerView;
    
//    _tableView.sectionFooterHeight = 0.0;
//    
//    _tableView.estimatedRowHeight = 0;
    
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
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
        UIImage *blackBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]);
        [self.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:NO];
    } else {
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        UIImage *whiteBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor whiteColor]);
        [self.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:YES];
    }
}

- (void)refreshHeaderData {
    FHTopicHeaderModel       *headerModel = self.viewModel.headerModel;
    if (headerModel && headerModel.forum) {
        [self hiddenEmptyView];
        self.topHeaderView.hidden = NO;
        self.headerInfoView.hidden = NO;
        NSString *forumName = headerModel.forum.forumName;
        if (![headerModel.forum.forumName hasPrefix:@"#"]) {
            forumName = [NSString stringWithFormat:@"#%@#",headerModel.forum.forumName];
        }
        self.titleLabel.text = forumName;
        self.subTitleLabel.text = headerModel.forum.subDesc;
        [self.topHeaderView updateWithInfo:headerModel];
        [self updateTopicNotice:headerModel.forum.desc];// 话题简介
        // 更新顶部布局
        self.topHeightOffset = CGRectGetMaxY(self.headerInfoView.frame) + 5;
        if (headerModel.forum.desc.length > 0) {
            self.headerInfoView.hidden = NO;
            self.topHeightOffset = CGRectGetMaxY(self.headerInfoView.frame) + 5;
        } else {
            self.headerInfoView.hidden = YES;
            self.topHeightOffset = CGRectGetMaxY(self.topHeaderView.frame);
        }
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
        self.headerInfoView.frame = CGRectMake(0, self.defaultTopHeight, SCREEN_WIDTH, attSize.height + 20);
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

- (void)setupPublishBtn {
    self.publishBtn = [[UIButton alloc] init];
    [_publishBtn setImage:[UIImage imageNamed:@"fh_ugc_publish"] forState:UIControlStateNormal];
    [_publishBtn addTarget:self action:@selector(gotoPublish:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_publishBtn];
}

- (void)gotoPublish:(UIButton *)sender {
    
    [self gotoPostThreadVC];

}

// 发布按钮点击
- (void)gotoPostThreadVC {
    if ([TTAccountManager isLogin]) {
        [self gotoPostVC];
    } else {
        [self gotoLogin:FHUGCLoginFrom_POST];
    }
}

- (void)gotoLogin:(FHUGCLoginFrom)from {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *page_type = @"topic_detail";
    [params setObject:page_type forKey:@"enter_from"];
    [params setObject:@"click_publisher" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                if(from == FHUGCLoginFrom_POST) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wSelf gotoPostVC];
                    });
                }
            }
        }
    }];
}

- (void)gotoPostVC {
    // 跳转到发布器
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"element_type"] = @"topic_publisher";
    NSString *page_type = @"topic_detail";
    tracerDict[@"page_type"] = page_type;
    [FHUserTracker writeEvent:@"click_publisher" params:tracerDict];
    
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    NSMutableDictionary *dict = @{}.mutableCopy;
    traceParam[@"page_type"] = @"feed_publisher";
    traceParam[@"enter_from"] = page_type;
    dict[TRACER_KEY] = traceParam;
    dict[VCTITLE_KEY] = @"发帖";
    if (self.viewModel.headerModel) {
        dict[@"topic_model"] = self.viewModel.headerModel;
    }
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL* url = [NSURL URLWithString:@"sslocal://ugc_post"];
    [[TTRoute sharedRoute] openURLByPresentViewController:url userInfo:userInfo];
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
    // 头部数据置nil
    self.titleLabel.text = @"";
    self.subTitleLabel.text = @"";
}

- (void)hiddenEmptyView {
    [self.emptyView hideEmptyView];
    self.mainScrollView.hidden = NO;
    self.customNavBarView.title.text = @"";
    // 更新当前导航栏状态
    [self refreshContentOffset:self.mainScrollView.contentOffset];
}

// 重新加载
- (void)retryLoadData {
    if (!self.isLoadingData) {
        [self startLoadData];
    }
}

// 下拉刷新
- (void)beginRefresh {
    [self.viewModel refreshLoadData];
}

- (void)endRefreshHeader {
    __weak typeof(self) wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wSelf.refreshHeader endRefreshing];
    });
}

- (void)mainScrollToTop {
    __weak typeof(self) wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wSelf.mainScrollView setContentOffset:CGPointZero animated:YES];
        [wSelf.viewModel.currentTableView setContentOffset:CGPointZero animated:NO];
    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [wSelf.viewModel.currentTableView setContentOffset:CGPointZero animated:YES];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [wSelf.mainScrollView setContentOffset:CGPointZero animated:NO];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [wSelf.mainScrollView setContentOffset:CGPointZero animated:NO];
//    });
}

// 上拉加载
- (void)loadMore {
    [self.viewModel loadMoreData];
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
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHUGCGoTop" object:@"topicDetail" userInfo:@{@"canScroll":@"1"}];
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
            CGFloat height = self.defaultTopHeight - offsetY;
            self.topHeaderView.frame = CGRectMake(offsetY / 2, offsetY, SCREEN_WIDTH - offsetY, height);
        } else {
            self.topHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.defaultTopHeight);
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

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    [self mainScrollToTop];
    return NO;
}

- (void)refreshContentOffset:(CGPoint)contentOffset {
    CGFloat offsetY = contentOffset.y;
    CGFloat alpha = offsetY / 64.0;
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
        UIImage *whiteBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor whiteColor]);
        [self.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateHighlighted];
        self.titleContainer.hidden = YES;
    } else if (alpha > 0.1f && alpha < 0.9f) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        self.customNavBarView.title.textColor = [UIColor themeGray1];
        UIImage *blackBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]);
        [self.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateHighlighted];
        self.titleContainer.hidden = YES;
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        UIImage *blackBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]);
        [self.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateHighlighted];
        self.titleContainer.hidden = NO;
    }
    [self.customNavBarView refreshAlpha:alpha];
}


#pragma mark -- SSImpressionProtocol

- (void)needRerecordImpressions {
    [self.viewModel needRerecordImpressions];
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self addStayPageLog];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - Tracer

-(void)addGoDetailLog {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    [FHUserTracker writeEvent:@"go_detail" params:tracerDict];
}

-(void)addStayPageLog {
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_page" params:tracerDict];
    [self tt_resetStayTime];
}

@end

// FHTopicDetailScrollView
@implementation FHTopicDetailScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


@end
