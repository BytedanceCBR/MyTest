//
//  FHSpecialTopicViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/2/20.
//

#import <TTBaseLib/UIButton+TTAdditions.h>
#import "FHSpecialTopicViewModel.h"
#import "FHSpecialTopicViewController.h"
#import "FHCommunityFeedListController.h"
#import "FHSpecialTopicHeaderView.h"
#import "TTBaseMacro.h"
#import "FHHouseUGCAPI.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "UIImageView+BDWebImage.h"
#import "UILabel+House.h"
#import "FHUGCFollowButton.h"
#import "FHUGCFollowHelper.h"
#import "FHUGCGuideView.h"
#import "FHUGCGuideHelper.h"
#import "FHUGCScialGroupModel.h"
#import "FHUGCConfig.h"
#import "TTAccountManager.h"
#import "FHUserTracker.h"
#import "FHCommunityDetailMJRefreshHeader.h"
#import "MJRefresh.h"
#import "FHCommonDefines.h"
#import "TTUIResponderHelper.h"
#import "TTUGCEmojiParser.h"
#import "TTAccount.h"
#import "TTAccount+Multicast.h"
#import "TTAccountManager.h"
#import "TTHorizontalPagingView.h"
#import "IMManager.h"
#import "TTThemedAlertController.h"
#import "FHFeedUGCCellModel.h"
#import "TTUGCDefine.h"
#import <FHUGCCategoryHelper.h>
#import "UIImage+FIconFont.h"
#import "FHTopicHeaderModel.h"
#import "FHSpecialTopicContentModel.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCBaseCell.h"

#import "FHTopicListModel.h"
#import "FHFeedListModel.h"
#import "UIScrollView+Refresh.h"
#import "FHFeedUGCCellModel.h"
#import "Article.h"
#import "TTBaseMacro.h"
#import "TTStringHelper.h"
#import "TTRoute.h"
#import "FHUGCModel.h"
#import "FHFeedUGCContentModel.h"
#import "FHEnvContext.h"
#import "TTAccountManager.h"
#import "TTURLUtils.h"
#import "TSVShortVideoDetailExitManager.h"
#import "HTSVideoPageParamHeader.h"
#import "FHUGCVideoCell.h"
#import "TTVFeedPlayMovie.h"
#import "TTVPlayVideo.h"
#import "TTVFeedCellWillDisplayContext.h"
#import "TTVFeedCellAction.h"
#import "FHSpecialTopicContentModel.h"
#import "FHSpecialTopicSectionHeaderView.h"

#define kSegmentViewHeight 52
#define sectionHeaderViewHeight 37

@interface FHSpecialTopicViewModel () <TTHorizontalPagingSegmentViewDelegate,UITableViewDelegate, UITableViewDataSource,FHUGCBaseCellDelegate>

@property (nonatomic, weak) FHSpecialTopicViewController *viewController;
@property (nonatomic, strong) FHTopicHeaderModel *specialTopicHeaderModel;
@property (nonatomic, strong) NSArray *tabContentModel;
@property (nonatomic, assign) BOOL isViewAppear;
@property (nonatomic, assign) BOOL isLoginSatusChangeFromPost;
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, strong) NSMutableArray *segmentTitles;
@property (nonatomic, copy) NSString *currentSegmentType;
@property (nonatomic, copy) NSString *defaultType;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) BOOL isFirstEnter;

@property(nonatomic, strong) NSMutableArray *dataArray;
@property(nonatomic, strong) NSMutableArray *sectionHeightList;

@property(nonatomic, strong) FHErrorView *errorView;
@property(nonatomic, assign) BOOL isSegmentSelectedFinished;

@end

@implementation FHSpecialTopicViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHSpecialTopicViewController *)viewController {
    self = [super initWithTableView:tableView controller:viewController];
    if (self) {
        [self initView];
        self.dataArray = [[NSMutableArray alloc] init];
        self.dataList = [[NSMutableArray alloc] init];
        self.sectionHeightList = [[NSMutableArray alloc] init];
        
        // 分享埋点
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"enter_from"] = self.viewController.tracerDict[@"enter_from"] ?: @"be_null";
        params[@"enter_type"] = self.viewController.tracerDict[@"enter_type"] ?: @"be_null";
        params[@"log_pb"] = self.viewController.tracerDict[@"log_pb"] ?: @"be_null";
        params[@"rank"] = self.viewController.tracerDict[@"rank"] ?: @"be_null";
        params[@"page_type"] = self.viewController.tracerDict[@"page_type"] ?: @"be_null";
        self.shareTracerDict = [params copy];
        
        self.isViewAppear = YES;
        self.isFirstEnter = YES;
        [self configTableView];
        self.viewController.segmentView.delegate = self;
        self.isSegmentSelectedFinished = YES;
    }
    
    return self;
}

- (void)configTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{

    }];
    self.tableView.mj_footer = self.refreshFooter;
    self.refreshFooter.hidden = YES;
}

- (FHErrorView *)errorView {
    if(!_errorView){
        _errorView = [[FHErrorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 350)];
    }
    return _errorView;
}

- (void)initView {
    MJWeakSelf;
    self.viewController.headerView.refreshHeader.refreshingBlock = ^{
        [weakSelf requestData:YES first:NO];
        weakSelf.tableView.userInteractionEnabled = NO;
    };
    
    self.viewController.headerView.refreshHeader.endRefreshingCompletionBlock = ^{
        weakSelf.tableView.userInteractionEnabled = YES;
    };
}

- (void)dealloc {
    
}

- (void)viewWillAppear {
    
}

- (void)viewDidAppear {
    self.isViewAppear = YES;
    [self updateNavBarWithAlpha:self.viewController.customNavBarView.bgView.alpha];
}

- (void)viewWillDisappear {
    self.isViewAppear = NO;
}

- (void)endRefreshing {
    [self.viewController.headerView.refreshHeader endRefreshing];
}

- (void)requestData:(BOOL)userPull refreshFeed:(BOOL)refreshFeed showEmptyIfFailed:(BOOL)showEmptyIfFailed showToast:(BOOL) showToast{
    if(self.isFirstEnter){
        [self.viewController tt_startUpdate];
    }
    
    if (![TTReachability isNetworkConnected]) {
        [self onNetworError:showEmptyIfFailed showToast:showToast];
        if(userPull){
            [self endRefreshing];
        }
        [self.viewController tt_endUpdataData];
        return;
    }
    
    if(self.viewController.forumId.length <= 0) {
        [self.viewController tt_endUpdataData];
        if(userPull){
            [self endRefreshing];
        }
        return;
    }
    WeakSelf;
    [FHHouseUGCAPI requestSpecialTopicHeaderWithforumId:self.viewController.forumId completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        [self.viewController tt_endUpdataData];
        if(userPull){
            [self endRefreshing];
        }
        
        if(error){
            [self onNetworError:showEmptyIfFailed showToast:showToast];
            return;
        }
        
        if (model) {
            FHTopicHeaderModel *responseModel = (FHTopicHeaderModel *)model;
            self.specialTopicHeaderModel = responseModel;
            [self updateUIWithData:responseModel];

            if (refreshFeed) {
                [self requestData:YES first:self.isFirstEnter];
            }
        }
    }];
}

-(void)onNetworError:(BOOL)showEmpty showToast:(BOOL)showToast{
    if(showEmpty){
        self.tableView.hidden = YES;
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
    if(showToast){
        [[ToastManager manager] showToast:@"网络异常"];
    }
}
// 发布按钮点击
- (void)gotoPostThreadVC {
    if ([TTAccountManager isLogin]) {
        [self goPostDetail];
    } else {
        [self gotoLogin:FHUGCLoginFrom_POST];
    }
}

- (void)initSegment {
    NSMutableArray *titles = [NSMutableArray array];
    NSInteger selectedIndex = 0;
    if(self.tabContentModel && self.tabContentModel.count > 1) {
        for(NSInteger i = 0;i < self.tabContentModel.count;i++) {
            FHFeedContentModel *item = self.tabContentModel[i];
            if(!isEmptyString(item.rawData.cardHeader.title)) {
                [titles addObject:item.rawData.cardHeader.title];
            }
        }
        self.viewController.segmentView.hidden = NO;
    }else{
        [titles addObject:@"全部"];
        self.viewController.segmentView.hidden = YES;
    }
    self.selectedIndex = selectedIndex;
    self.viewController.segmentView.selectedIndex = selectedIndex;
    self.viewController.segmentView.titles = titles;
    self.segmentTitles = titles;
    
    if(titles.count > 1){
        [self addSegmentView];
    }else{
        [self removeSegmentView];
    }
}

- (void)addSegmentView {
    self.viewController.tableHeaderView.height = self.viewController.headerView.height + kSegmentViewHeight;
    self.viewController.segmentView.frame = CGRectMake(0, CGRectGetMaxY(self.viewController.headerView.frame), SCREEN_WIDTH, kSegmentViewHeight);
    [self.viewController.tableHeaderView addSubview:self.viewController.segmentView];
    self.tableView.tableHeaderView = self.viewController.tableHeaderView;
}

- (void)removeSegmentView {
    self.viewController.tableHeaderView.height = self.viewController.headerView.height;
    [self.viewController.segmentView removeFromSuperview];
    self.tableView.tableHeaderView = self.viewController.tableHeaderView;
}

- (void)gotoLogin:(FHUGCLoginFrom)from {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"community_group_detail" forKey:@"enter_from"];
    [params setObject:@"feed_like" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);

    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
       
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                if(from == FHUGCLoginFrom_GROUPCHAT) {
//                    [self onLoginIn];
                }
                else {
                    if(from == FHUGCLoginFrom_POST){
//                        self.isLoginSatusChangeFromPost = YES;
                    }else{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            switch(from) {
                                case FHUGCLoginFrom_VOTE:
                                {
//                                    [self gotoVoteVC];
                                }
                                    break;
                                case FHUGCLoginFrom_WENDA:
                                {
//                                    [self gotoWendaVC];
                                }
                                    break;
                                default:
                                    break;
                            }
                        });
                    }
                }
            }
        }
    }];
}

- (void)goPostDetail {
    [self gotoPostVC];
}

- (void)gotoPostVC {
    // 跳转发布器
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"element_type"] = @"feed_publisher";
    tracerDict[@"page_type"] = @"community_group_detail";
    [FHUserTracker writeEvent:@"click_publisher" params:tracerDict];
    
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"page_type"] = @"feed_publisher";
    traceParam[@"enter_from"] = @"community_group_detail";
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
//    dic[@"select_group_id"] = self.data.socialGroupId;
//    dic[@"select_group_name"] = self.data.socialGroupName;
    dic[TRACER_KEY] = traceParam;
    dic[VCTITLE_KEY] = @"发帖";
    if (self.specialTopicHeaderModel) {
        dic[@"topic_model"] = self.specialTopicHeaderModel;
    }
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dic];
    NSURL *url = [NSURL URLWithString:@"sslocal://ugc_post"];
    [[TTRoute sharedRoute] openURLByPresentViewController:url userInfo:userInfo];
}

- (void)refreshContentOffset:(CGFloat)offset {
    CGFloat alpha = offset / (80.0f);
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
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateHighlighted];
        self.viewController.titleContainer.hidden = YES;
        self.viewController.rightBtn.hidden = YES;
        self.shareButton.hidden = NO;
    } else if (alpha > 0.1f && alpha < 0.9f) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        self.viewController.customNavBarView.title.textColor = [UIColor themeGray1];
        UIImage *blackBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]);
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateHighlighted];
        self.viewController.titleContainer.hidden = YES;
        self.viewController.rightBtn.hidden = YES;
        self.shareButton.hidden = NO;
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        UIImage *blackBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]);
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateHighlighted];
        self.viewController.titleContainer.hidden = NO;
        self.viewController.rightBtn.hidden = NO;
        self.shareButton.hidden = YES;
    }
    [self.viewController.customNavBarView refreshAlpha:alpha];
}

- (void)updateUIWithData:(FHTopicHeaderModel *)headerModel {
    if (!headerModel) {
        self.tableView.hidden = YES;
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        return;
    }

    // 第一次服务端返回数据
    if (headerModel.shareInfo && self.shareInfo == nil) {
        FHUGCShareInfoModel *shareInfo = [[FHUGCShareInfoModel alloc] init];
        shareInfo.title = headerModel.shareInfo.shareTitle;
        shareInfo.isVideo = @"0";
        shareInfo.desc = headerModel.shareInfo.shareDesc;
        if(headerModel.shareInfo.shareUrl.length > 0){
            shareInfo.shareUrl = [NSString stringWithFormat:@"%@?origin_from=share",headerModel.shareInfo.shareUrl];
        }
        shareInfo.coverImage = headerModel.shareInfo.shareCover;
        self.shareInfo = shareInfo;
    }
    self.tableView.hidden = NO;
    self.viewController.emptyView.hidden = YES;
    
    if(headerModel.forum.bannerUrl.length > 0){
        NSURL *url = [NSURL URLWithString:headerModel.forum.bannerUrl];
        [self.viewController.headerView.topBack bd_setImageWithURL:url placeholder:nil];
    }
    
    self.viewController.headerView.nameLabel.text = isEmptyString(headerModel.forum.forumName) ? @"" : headerModel.forum.forumName;
    NSString *subtitle = headerModel.forum.desc;
    self.viewController.headerView.subtitleLabel.text = isEmptyString(subtitle) ? @"" : subtitle;
    
    self.viewController.titleLabel.text = isEmptyString(headerModel.forum.forumName) ? @"" : headerModel.forum.forumName;
    self.viewController.subTitleLabel.text = isEmptyString(subtitle) ? @"" : subtitle;
}

- (void)updateJoinUI:(BOOL)followed {
    self.viewController.rightBtn.followed = followed;
}

#pragma UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat delta = scrollView.contentOffset.y;
    [self refreshContentOffset:delta];
    [self.viewController.headerView updateWhenScrolledWithContentOffset:delta isScrollTop:NO scrollView:self.tableView];
    
    if(delta < self.viewController.headerView.height - self.viewController.customNavBarView.height){
        if(self.viewController.segmentView.superview != self.viewController.tableHeaderView){
            [self.viewController.segmentView removeFromSuperview];
            self.viewController.segmentView.top = self.viewController.headerView.bottom;
            [self.viewController.tableHeaderView addSubview:self.viewController.segmentView];
        }
    }else{
        if(self.viewController.segmentView.superview != self.viewController.view){
            [self.viewController.segmentView removeFromSuperview];
            self.viewController.segmentView.top = self.viewController.customNavBarView.bottom;
            [self.viewController.view addSubview:self.viewController.segmentView];
        }
    }
    
    NSInteger section = [self getSectionIndex:delta];
    if(section < self.segmentTitles.count && self.isSegmentSelectedFinished && section != self.viewController.segmentView.selectedIndex){
        [self.viewController.segmentView setSelectedIndexNoEvent:section];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(decelerate){
        CGFloat delta = scrollView.contentOffset.y;
        if(delta <= -50){
            [self.viewController.headerView.refreshHeader beginRefreshing];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.isSegmentSelectedFinished = YES;
}

- (void)addGoDetailLog {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"be_null";
    params[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @"be_null";
    params[@"rank"] = self.tracerDict[@"rank"] ?: @"be_null";
    params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    params[@"group_id"] = self.tracerDict[@"group_id"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    [FHUserTracker writeEvent:@"go_detail_community" params:params];
}

- (void)addStayPageLog:(NSTimeInterval)stayTime {
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"be_null";
    params[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @"be_null";
    params[@"rank"] = self.tracerDict[@"rank"] ?: @"be_null";
    params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    params[@"group_id"] = self.tracerDict[@"group_id"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_page_community" params:params];
}

- (void)addPublicationsShowLog {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"element_type"] = @"community_group_notice";
    params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"group_id"] = self.tracerDict[@"group_id"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    [FHUserTracker writeEvent:@"element_show" params:params];
}

- (void)addPublisherPopupShowLog {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"page_type"] = @"community_publisher_popup";
    params[@"enter_from"] = @"community_group_detail";
    [FHUserTracker writeEvent:@"community_publisher_popup_show" params:params];
}

- (void)addPublisherPopupClickLog:(BOOL)positive {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"page_type"] = @"community_publisher_popup";
    params[@"enter_from"] = @"community_group_detail";
    params[@"click_position"] = positive ? @"confirm" : @"cancel";
    [FHUserTracker writeEvent:@"community_publisher_popup_click" params:params];
}

- (void)addClickOptionsLog:(NSString *)position {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"group_id"] = self.tracerDict[@"group_id"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"enter_type"] =  @"click";
    params[@"click_position"] = position;
    [FHUserTracker writeEvent:@"click_options" params:params];
}

#pragma mark - segmentView 代理
- (void)segmentView:(TTHorizontalPagingSegmentView *)segmentView didSelectedItemAtIndex:(NSInteger)index toIndex:(NSInteger)toIndex {
    
    if(!self.isSegmentSelectedFinished){
        return;
    }

    self.selectedIndex = toIndex;

    if(self.isFirstEnter) {
//        [self.pagingView scrollToIndex:toIndex withAnimation:NO];
        self.isFirstEnter = NO;
    } else {
        //上报埋点
//        NSString *position = @"be_null";
//        if(toIndex < self.socialGroupModel.data.tabInfo.count){
//            FHUGCScialGroupDataTabInfoModel *tabModel = self.socialGroupModel.data.tabInfo[toIndex];
//            if(tabModel.tabName){
//                position = [NSString stringWithFormat:@"%@_list",tabModel.tabName];
//            }
//        }
//        [self addClickOptionsLog:position];
        if(toIndex < self.sectionHeightList.count){
            CGFloat height = [self.sectionHeightList[toIndex] integerValue];
            CGFloat offsetY = (NSInteger)self.tableView.contentOffset.y;
            if(height != offsetY){
                self.isSegmentSelectedFinished = NO;
                [self.tableView setContentOffset:CGPointMake(0, height) animated:YES];
            }
        }
    }
}

- (void)caculateSectionHeight {
    [self.sectionHeightList removeAllObjects];
    for (NSInteger i = 0; i < self.dataArray.count; i++) {
        CGFloat height = self.viewController.headerView.height - self.viewController.customNavBarView.height;
        for (NSInteger j = 0; j < i; j++) {
            CGRect rect = [self.tableView rectForSection:j];
            height += rect.size.height;
        }
        [self.sectionHeightList addObject:@(height)];
    }
}

- (NSInteger)getSectionIndex:(CGFloat)offsetY {
    NSInteger section = 0;
    
    for (NSInteger i = self.sectionHeightList.count - 1; i > 0; i--) {
        NSInteger height = [self.sectionHeightList[i] integerValue];
        if(offsetY >= height){
            section = i;
            break;
        }
    }
    return section;
}

//获取feed
- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    if(self.viewController.isLoadingData){
        return;
    }
    
    self.viewController.isLoadingData = YES;
    
    if(self.isRefreshingTip){
        [self.tableView finishPullDownWithSuccess:YES];
        return;
    }
    
    if(isFirst){
        self.tableView.scrollEnabled = NO;
        [self.viewController startLoading];
    }
    
    __weak typeof(self) wself = self;
    
    //下拉刷新关闭视频播放
    if(isHead){
        [self endDisplay];
    }
    
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    NSString *fCityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    if(fCityId){
        [extraDic setObject:fCityId forKey:@"f_city_id"];
    }
    FHSpecialTopicHeaderTabsModel *tabModel = [self.specialTopicHeaderModel.tabs firstObject];
 
    self.requestTask = [FHHouseUGCAPI requestSpecialTopicContentWithTabId:tabModel.tabId queryPath:tabModel.url categoryName:tabModel.categoryName queryId:self.viewController.forumId  extraDic:extraDic completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {

        [self endRefreshing];
        wself.viewController.isLoadingData = NO;

        if (error) {
            //TODO: show handle error
            dispatch_async(dispatch_get_main_queue(), ^{
                if(isFirst){
                    if(error.code != -999){
                        [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
                        wself.viewController.showenRetryButton = YES;
                        wself.refreshFooter.hidden = YES;
                        
                        [wself.viewController endLoading];
                        wself.tableView.scrollEnabled = YES;
                    }
                }else{
                    [[ToastManager manager] showToast:@"网络异常"];
                    [wself updateTableViewWithMoreData:YES];
                }
                return;
            });
        }
        
        FHSpecialTopicContentModel *specialTopicContentModel = (FHSpecialTopicContentModel *)model;

        if(model){
            NSMutableArray *resultArray = [NSMutableArray array];
            NSMutableArray *dataContentModel = [NSMutableArray array];
            for (FHSpecialTopicContentDataModel *dataModel in specialTopicContentModel.data) {
                FHFeedContentModel *contentModel = [FHFeedUGCCellModel contentModelFromFeedContent:dataModel.content];
                if(contentModel){
                    [dataContentModel addObject:contentModel];
                }
                
                wself.tabContentModel = dataContentModel;
                
                for (NSDictionary *dic in contentModel.subRawDatas) {
                    FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:dic];
                    if(cellModel){
                        [resultArray addObject:cellModel];
                    }
                }
            }
            specialTopicContentModel.dataContent = [dataContentModel copy];
            
            if(isHead){
                [wself.dataArray removeAllObjects];
                [wself.dataList removeAllObjects];
            }

            wself.tableView.hasMore = NO;

            if(isFirst){
                [wself.clientShowDict removeAllObjects];
                [wself.dataArray removeAllObjects];
                [wself.dataList removeAllObjects];
            }
            
            wself.dataArray = [wself convertModel:dataContentModel];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                wself.viewController.hasValidateData = wself.dataList.count > 0;
                wself.tableView.scrollEnabled = YES;
                [wself reloadTableViewData];
                if(isFirst){
                    [wself initSegment];
                }
                [wself caculateSectionHeight];
            });
        }else{
            if(isFirst){
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [wself.viewController endLoading];
                      wself.tableView.scrollEnabled = YES;
                  });
            }
        }
    }];
}

- (void)reloadTableViewData {
    if(self.dataArray.count > 0){
        [self updateTableViewWithMoreData:self.tableView.hasMore];
        self.tableView.backgroundColor = [UIColor themeGray7];
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,0.001)];
        [self.tableView reloadData];
    }else{
        [self.errorView showEmptyWithTip:@"暂无内容" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
        
        CGFloat errorViewHeight = [UIScreen mainScreen].bounds.size.height - self.viewController.customNavBarView.height - self.viewController.headerView.height;
        
        UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, errorViewHeight)];
        
        tableFooterView.backgroundColor = [UIColor whiteColor];
        [tableFooterView addSubview:self.errorView];
        self.tableView.tableFooterView = tableFooterView;
        self.refreshFooter.hidden = YES;
        self.tableView.backgroundColor = [UIColor whiteColor];
        [self.tableView reloadData];
    }
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (hasMore) {
        [self.tableView.mj_footer endRefreshing];
    }else {
        [self.refreshFooter setUpNoMoreDataText:@"没有更多信息了" offsetY:-3];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}

- (NSMutableArray *)convertModel:(NSArray *)content {
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (FHFeedContentModel *itemModel in content) {
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < itemModel.subRawDatas.count; i++) {
            NSDictionary *dic = itemModel.subRawDatas[i];
            FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:dic];
            cellModel.categoryId = self.categoryId;
            cellModel.tableView = self.tableView;
            cellModel.showCommunity = NO;
            cellModel.hiddenMore = YES;
            if(i == itemModel.subRawDatas.count - 1){
                cellModel.bottomLineHeight = 5;
                cellModel.bottomLineLeftMargin = 0;
                cellModel.bottomLineRightMargin = 0;
            }else{
                cellModel.bottomLineHeight = 1;
                cellModel.bottomLineLeftMargin = 15;
                cellModel.bottomLineRightMargin = 15;
            }
            
            if(cellModel){
                [resultArray addObject:cellModel];
            }
        }
        [dataArray addObject:resultArray];
    }
    return dataArray;
}

//- (void)removeDuplicaionModel:(NSString *)groupId {
//    for (FHFeedUGCCellModel *itemModel in self.dataList) {
//        if([groupId isEqualToString:itemModel.groupId]){
//            [self.dataList removeObject:itemModel];
//            break;
//        }
//    }
//}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section < self.dataArray.count){
        NSArray *resultArray = self.dataArray[section];
        return [resultArray count];
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section < self.dataArray.count){
        NSArray *resultArray = self.dataArray[indexPath.section];
        if(indexPath.row < resultArray.count){
            [self traceClientShowAtIndexPath:indexPath];
            FHFeedUGCCellModel *cellModel = resultArray[indexPath.row];
            /*impression统计相关*/
            SSImpressionStatus impressionStatus = self.isShowing ? SSImpressionStatusRecording : SSImpressionStatusSuspend;
            [self recordGroupWithCellModel:cellModel status:impressionStatus];
            
            if (![cell isKindOfClass:[FHUGCVideoCell class]]) {
                return;
            }
            //视频
            if(cellModel.hasVideo){
                FHUGCVideoCell *cellBase = (FHUGCVideoCell *)cell;
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(willFinishLoadTable) object:nil];
                [self willFinishLoadTable];
                
                [cellBase willDisplay];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section < self.dataArray.count){
        NSArray *resultArray = self.dataArray[indexPath.section];
        // impression统计
        if(indexPath.row < resultArray.count){
            FHFeedUGCCellModel *cellModel = resultArray[indexPath.row];
            [self recordGroupWithCellModel:cellModel status:SSImpressionStatusEnd];
            
            if(cellModel.hasVideo){
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(willFinishLoadTable) object:nil];
                [self willFinishLoadTable];
                
                if([cell isKindOfClass:[FHUGCVideoCell class]] && [cell conformsToProtocol:@protocol(TTVFeedPlayMovie)]) {
                    FHUGCVideoCell<TTVFeedPlayMovie> *cellBase = (FHUGCVideoCell<TTVFeedPlayMovie> *)cell;
                    BOOL hasMovie = NO;
                    NSArray *indexPaths = [tableView indexPathsForVisibleRows];
                    for (NSIndexPath *path in indexPaths) {
                        if (path.row < self.dataList.count) {
                            
                            BOOL hasMovieView = NO;
                            if ([cellBase respondsToSelector:@selector(cell_hasMovieView)]) {
                                hasMovieView = [cellBase cell_hasMovieView];
                            }
                            
                            if ([cellBase respondsToSelector:@selector(cell_movieView)]) {
                                UIView *view = [cellBase cell_movieView];
                                if (view && ![self.movieViews containsObject:view]) {
                                    [self.movieViews addObject:view];
                                }
                            }
                            if (cellModel == self.movieViewCellData) {
                                hasMovie = YES;
                                break;
                            }
                        }
                    }
                    
                    if (self.isShowing) {
                        if (!hasMovie) {
                            [cellBase endDisplay];
                        }
                    }
                }
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section < self.dataArray.count){
        NSArray *resultArray = self.dataArray[indexPath.section];
        if(indexPath.row < resultArray.count){
            FHFeedUGCCellModel *cellModel = resultArray[indexPath.row];
            NSString *cellIdentifier = NSStringFromClass([self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil]);
            FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                Class cellClass = NSClassFromString(cellIdentifier);
                cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.delegate = self;
            cellModel.tracerDic = [self trackDict:cellModel rank:indexPath.row];
            
            if(indexPath.row < resultArray.count){
                [cell refreshWithData:cellModel];
            }
            return cell;
        }
    }
    return [[FHUGCBaseCell alloc] init];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section < self.dataArray.count){
        NSArray *resultArray = self.dataArray[indexPath.section];
        if(indexPath.row < resultArray.count){
            FHFeedUGCCellModel *cellModel = resultArray[indexPath.row];
            Class cellClass = [self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil];
            if([cellClass isSubclassOfClass:[FHUGCBaseCell class]]) {
                return [cellClass heightForData:cellModel];
            }
        }
    }
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section < self.dataArray.count){
        NSArray *resultArray = self.dataArray[indexPath.section];
        if(indexPath.row < resultArray.count){
            FHFeedUGCCellModel *cellModel = resultArray[indexPath.row];
            self.currentCellModel = cellModel;
            self.currentCell = [tableView cellForRowAtIndexPath:indexPath];
            [self jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat height = 0.001f;
    if(section < self.dataArray.count && section < self.tabContentModel.count && section != 0){
        height = sectionHeaderViewHeight;
    }
    FHSpecialTopicSectionHeaderView *headerView = [[FHSpecialTopicSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
    if(section < self.dataArray.count && section < self.tabContentModel.count && section != 0){
        FHFeedContentModel *model = self.tabContentModel[section];
        headerView.titleLabel.text =  model.rawData.cardHeader.title;
        if(model.rawData.cardHeader.publisherText.length > 0){
            headerView.postBtn.hidden = NO;
            [headerView.postBtn setTitle:model.rawData.cardHeader.publisherText forState:UIControlStateNormal];
            WeakSelf;
            headerView.gotoPublishBlock = ^{
                StrongSelf;
                [self gotoPostThreadVC];
            };
        }else{
            headerView.postBtn.hidden = YES;
        }
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0.001f;
    if(section < self.dataArray.count && section < self.tabContentModel.count && section != 0){
        height = sectionHeaderViewHeight;
    }
    return height;
}

- (void)jumpToDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType {
    if(cellModel.cellType == FHUGCFeedListCellTypeArticle || cellModel.cellType == FHUGCFeedListCellTypeQuestion){
        if(cellModel.hasVideo){
            //跳转视频详情页
            [self jumpToVideoDetail:cellModel showComment:showComment enterType:enterType];
        }else{
            BOOL canOpenURL = NO;
            if (!canOpenURL && !isEmptyString(cellModel.openUrl)) {
                NSURL *url = [TTStringHelper URLWithURLString:cellModel.openUrl];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    canOpenURL = YES;
                    [[UIApplication sharedApplication] openURL:url];
                }
                else if([[TTRoute sharedRoute] canOpenURL:url]){
                    canOpenURL = YES;
                    //优先跳转openurl
                    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
                }
            }else{
                NSURL *openUrl = [NSURL URLWithString:cellModel.detailScheme];
                [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
            }
        }
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGC){
        [self jumpToPostDetail:cellModel showComment:showComment enterType:enterType];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeArticleComment || cellModel.cellType == FHUGCFeedListCellTypeArticleComment2){
        // 评论
        NSMutableDictionary *dict = [NSMutableDictionary new];
        NSMutableDictionary *traceParam = @{}.mutableCopy;
        traceParam[@"enter_from"] = @"community_group_detail";
        traceParam[@"enter_type"] = enterType ? enterType : @"be_null";
        traceParam[@"rank"] = cellModel.tracerDic[@"rank"];
        traceParam[@"log_pb"] = cellModel.logPb;
        dict[TRACER_KEY] = traceParam;
        
        dict[@"data"] = cellModel;
        dict[@"begin_show_comment"] = showComment ? @"1" : @"0";
        dict[@"social_group_id"] = cellModel.community.socialGroupId ?: @"";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeAnswer){
        // 问题 回答
        BOOL jump_comment = NO;
        if (showComment) {
            jump_comment = YES;
        }
        NSDictionary *dict = @{@"is_jump_comment":@(jump_comment)};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGCVote){
        [self goToVoteDetail:cellModel value:0];
    } if(cellModel.cellType == FHUGCFeedListCellTypeUGCSmallVideo){
        //小视频
        if (![TTReachability isNetworkConnected]) {
            [[ToastManager manager] showToast:@"网络异常"];
            return;
        }
        WeakSelf;
        TSVShortVideoDetailExitManager *exitManager = [[TSVShortVideoDetailExitManager alloc] initWithUpdateBlock:^CGRect{
            StrongSelf;
            CGRect imageFrame = [self selectedSmallVideoFrame];
            imageFrame.origin = CGPointZero;
            return imageFrame;
        } updateTargetViewBlock:^UIView *{
            StrongSelf;
            return [self currentSelectSmallVideoView];
        }];
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];
        [info setValue:exitManager forKey:HTSVideoDetailExitManager];
        if (showComment) {
            [info setValue:@(1) forKey:AWEVideoShowComment];
        }
        
        if(cellModel.tracerDic){
            NSMutableDictionary *tracerDic = [cellModel.tracerDic mutableCopy];
            tracerDic[@"page_type"] = @"small_video_detail";
            tracerDic[@"enter_type"] = enterType;
            tracerDic[@"enter_from"] = [self pageType];
            [info setValue:tracerDic forKey:@"extraDic"];
        }
        
        NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:TTRouteUserInfoWithDict(info)];
    } else if(cellModel.cellType == FHUGCFeedListCellTypeUGCVoteInfo) {
        // 投票
        BOOL jump_comment = NO;
        if (showComment) {
            jump_comment = YES;
        }
        NSMutableDictionary *dict = @{@"begin_show_comment":@(jump_comment)}.mutableCopy;
        dict[@"data"] = cellModel;
        dict[@"social_group_id"] = cellModel.community.socialGroupId ?: @"";
        NSMutableDictionary *traceParam = @{}.mutableCopy;
        traceParam[@"enter_from"] = @"community_group_detail";
        traceParam[@"enter_type"] = enterType;
        traceParam[@"rank"] = cellModel.tracerDic[@"rank"] ?: @"be_null";
        traceParam[@"log_pb"] = cellModel.logPb;
        dict[TRACER_KEY] = traceParam;
        
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

- (void)jumpToPostDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType {
    NSMutableDictionary *dict = @{}.mutableCopy;
    // 埋点
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"enter_from"] = @"community_group_detail";
    traceParam[@"enter_type"] = enterType ? enterType : @"be_null";
    traceParam[@"rank"] = cellModel.tracerDic[@"rank"];
    traceParam[@"log_pb"] = cellModel.logPb;
    dict[TRACER_KEY] = traceParam;
    
    dict[@"data"] = cellModel;
    dict[@"begin_show_comment"] = showComment ? @"1" : @"0";
    dict[@"social_group_id"] = cellModel.community.socialGroupId ?: @"";
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    FHFeedUGCContentModel *contentModel = cellModel.originData;
    NSString *routeUrl = @"sslocal://thread_detail";
    if (contentModel && [contentModel isKindOfClass:[FHFeedUGCContentModel class]]) {
        NSString *schema = contentModel.schema;
        if (schema.length > 0) {
            routeUrl = schema;
        }
    }
    
    NSURL *openUrl = [NSURL URLWithString:routeUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)jumpToVideoDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType {
    if(self.currentCell && [self.currentCell isKindOfClass:[FHUGCVideoCell class]]){
        FHUGCVideoCell *cell = (FHUGCVideoCell *)self.currentCell;
        
        TTVFeedCellSelectContext *context = [[TTVFeedCellSelectContext alloc] init];
        context.refer = self.refer;
        context.categoryId = self.categoryId;
        context.feedListViewController = self;
        context.clickComment = showComment;
        context.enterType = enterType;
        context.enterFrom = [self pageType];
        
        [cell didSelectCell:context];
    }else if (cellModel.openUrl) {
        NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
    }
    self.needRefreshCell = NO;
}

- (void)topCell:(FHFeedUGCCellModel *)cellModel isTop:(BOOL)isTop {
    NSInteger row = [self getCellIndex:cellModel];
    if(row < self.dataList.count && row >= 0){
        FHFeedUGCCellModel *originCellModel = self.dataList[row];
        originCellModel.isStick = cellModel.isStick;
        originCellModel.stickStyle = cellModel.stickStyle;
        originCellModel.contentDecoration = cellModel.contentDecoration;
        originCellModel.ischanged = YES;
        
        [self.dataList removeObjectAtIndex:row];
        if(isTop){
            [self.dataList insertObject:originCellModel atIndex:0];
        }else{
            if(self.dataList.count == 0){
                [self.dataList insertObject:originCellModel atIndex:0];
            }else{
                for (NSInteger i = 0; i < self.dataList.count; i++) {
                    FHFeedUGCCellModel *item = self.dataList[i];
                    //最后还没找到，插到最后
                    
                    if(!item.isStick || (item.isStick && (item.stickStyle != FHFeedContentStickStyleTop && item.stickStyle != FHFeedContentStickStyleTopAndGood))){
                        //找到第一个不是置顶的cell
                        [self.dataList insertObject:originCellModel atIndex:i];
                        break;
                    }
                    
                    if(i == (self.dataList.count - 1)){
                        [self.dataList insertObject:originCellModel atIndex:(i + 1)];
                        break;
                    }
                }
                
            }
        }
        [self reloadTableViewData];
    }
}

#pragma mark - FHUGCBaseCellDelegate

- (void)deleteCell:(FHFeedUGCCellModel *)cellModel {
    NSInteger row = [self getCellIndex:cellModel];
    if(row < self.dataList.count && row >= 0){
        [self.dataList removeObjectAtIndex:row];
        [self reloadTableViewData];
    }
}

- (void)commentClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    [self trackClickComment:cellModel];
    self.currentCellModel = cellModel;
    self.currentCell = cell;
    [self jumpToDetail:cellModel showComment:YES enterType:@"feed_comment"];
}

- (void)lookAllLinkClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    self.currentCellModel = cellModel;
    self.currentCell = cell;
    [self jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
}

- (void)gotoLinkUrl:(FHFeedUGCCellModel *)cellModel url:(NSURL *)url {
    NSMutableDictionary *dict = @{}.mutableCopy;
    // 埋点
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    dict[TRACER_KEY] = traceParam;
    
    if (url) {
        BOOL isOpen = YES;
        if ([url.absoluteString containsString:@"concern"]) {
            // 话题
            traceParam[@"enter_from"] = [self pageType];
            traceParam[@"element_from"] = @"feed_topic";
            traceParam[@"enter_type"] = @"click";
            traceParam[@"rank"] = cellModel.tracerDic[@"rank"];
            traceParam[@"log_pb"] = cellModel.logPb;
        }
        else if([url.absoluteString containsString:@"profile"]) {
            // JOKER:
        }
        else if([url.absoluteString containsString:@"webview"]) {
            
        }
        else {
            isOpen = NO;
        }
        
        if(isOpen) {
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

- (void)goToVoteDetail:(FHFeedUGCCellModel *)cellModel value:(NSInteger)value {
    [self trackVoteClickOptions:cellModel value:value];
    if([TTAccountManager isLogin] || !cellModel.vote.needUserLogin){
        if(cellModel.vote.openUrl){
            NSString *urlStr = cellModel.vote.openUrl;
            if(value > 0){
                NSString *append = [TTURLUtils queryItemAddingPercentEscapes:[NSString stringWithFormat:@"&vote=%d",value]];
                urlStr = [urlStr stringByAppendingString:append];
            }
            
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
        }
    }else{
        [self gotoLogin:cellModel value:value];
    }
}

- (void)gotoLogin:(FHFeedUGCCellModel *)cellModel value:(NSInteger)value  {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[self pageType] forKey:@"enter_from"];
    [params setObject:@"" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);
//    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(cellModel.vote.openUrl){
                        NSString *urlStr = cellModel.vote.openUrl;
                        if(value > 0){
                            NSString *append = [TTURLUtils queryItemAddingPercentEscapes:[NSString stringWithFormat:@"&vote=%d",value]];
                            urlStr = [urlStr stringByAppendingString:append];
                        }
                        
                        NSURL *url = [NSURL URLWithString:urlStr];
                        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
                    }
                });
            }
        }
    }];
}

#pragma mark - 视频相关

- (void)willFinishLoadTable {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didFinishLoadTable) object:nil];
    [self performSelector:@selector(didFinishLoadTable) withObject:nil afterDelay:0.1];
}

- (void)didFinishLoadTable {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    NSArray *cells = [self.tableView visibleCells];
    NSMutableArray *visibleCells = [NSMutableArray arrayWithCapacity:cells.count];
    for (id cell in cells) {
        if([cell isKindOfClass:[FHUGCVideoCell class]] && [cell conformsToProtocol:@protocol(TTVFeedPlayMovie)]){
            FHUGCVideoCell<TTVFeedPlayMovie> *vCell = (FHUGCVideoCell<TTVFeedPlayMovie> *)cell;
            UIView *view = [vCell cell_movieView];
            if (view) {
                [visibleCells addObject:view];
            }
        }
    }
    
    for (UIView *view in self.movieViews) {
        if ([view isKindOfClass:[TTVPlayVideo class]]) {
            TTVPlayVideo *movieView = (TTVPlayVideo *)view;
            if (!movieView.player.context.isFullScreen &&
                !movieView.player.context.isRotating && ![visibleCells containsObject:movieView]) {
                if (movieView.player.context.playbackState != TTVVideoPlaybackStateBreak || movieView.player.context.playbackState != TTVVideoPlaybackStateFinished) {
                    [movieView stop];
                }
                [movieView removeFromSuperview];
            }
        }
    }
    
    self.movieViewCellData = nil;
    self.movieView = nil;
    [self.movieViews removeAllObjects];
}

#pragma mark - 埋点

- (void)traceClientShowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row >= self.dataList.count) {
        return;
    }
    
    FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
    
    if (!self.clientShowDict) {
        self.clientShowDict = [NSMutableDictionary new];
    }
    
//    NSString *row = [NSString stringWithFormat:@"%i",indexPath.row];
    NSString *groupId = cellModel.groupId;
    if(groupId){
        if (self.clientShowDict[groupId]) {
            return;
        }
        
        self.clientShowDict[groupId] = @(indexPath.row);
        [self trackClientShow:cellModel rank:indexPath.row];
    }
}

- (void)trackClientShow:(FHFeedUGCCellModel *)cellModel rank:(NSInteger)rank {
    NSMutableDictionary *dict =  [self trackDict:cellModel rank:rank];
    TRACK_EVENT(@"feed_client_show", dict);
}

- (NSMutableDictionary *)trackDict:(FHFeedUGCCellModel *)cellModel rank:(NSInteger)rank {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[@"enter_from"] = @"community_group";
    dict[@"page_type"] = [self pageType];
    dict[@"log_pb"] = cellModel.logPb;
    dict[@"rank"] = @(rank);
    
    return dict;
}

- (NSString *)pageType {
    return @"community_group_detail";
}

- (void)trackClickComment:(FHFeedUGCCellModel *)cellModel {
    NSMutableDictionary *dict = [cellModel.tracerDic mutableCopy];
    dict[@"click_position"] = @"feed_comment";
    TRACK_EVENT(@"click_comment", dict);
}

- (void)trackVoteClickOptions:(FHFeedUGCCellModel *)cellModel value:(NSInteger)value {
    NSMutableDictionary *dict = [cellModel.tracerDic mutableCopy];
    dict[@"log_pb"] = cellModel.logPb;
    if(value == [cellModel.vote.leftValue integerValue]){
        dict[@"click_position"] = @"1";
    }else if(value == [cellModel.vote.rightValue integerValue]){
        dict[@"click_position"] = @"2";
    }else{
        dict[@"click_position"] = @"vote_content";
    }
    TRACK_EVENT(@"click_options", dict);
}

@end
