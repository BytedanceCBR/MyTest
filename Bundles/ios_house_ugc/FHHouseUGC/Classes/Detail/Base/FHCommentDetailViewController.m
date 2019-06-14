//
//  FHCommentDetailViewController
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/2.
//

#import "FHCommentDetailViewController.h"
#import "FHExploreDetailToolbarView.h"
#import "SSCommonLogic.h"
#import "TTUIResponderHelper.h"
#import "UIViewAdditions.h"
#import "TTCommentViewController.h"
#import "TTDeviceHelper.h"
#import "FHPostDetailViewModel.h"
#import "TTCommentDataManager.h"
#import "TTKitchen.h"
#import "TTDetailModel.h"
#import "TTCommentModelProtocol.h"
#import "FHTraceEventUtils.h"
#import "TTCommentDetailViewController.h"
#import "TTModalContainerController.h"
#import "TTRoute.h"
#import "TTUGCTrackerHelper.h"
#import "TTNetworkUtil.h"
#import "TTTrackerWrapper.h"
#import "AKHelper.h"
#import "FHCommonDefines.h"
#import "FHCommentDetailViewModel.h"
#import "ExploreDetailToolbarView.h"
#import "ExploreDetailNavigationBar.h"
#import "ExploreSearchViewController.h"
#import "ExploreMomentDefine_Enums.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "UIImage+TTThemeExtension.h"
#import "SSCommentInputHeader.h"
#import "TTCommentWriteManager.h"
#import "TTCommentWriteView.h"
#import "ExploreItemActionManager.h"
#import "FHPostDetailCommentWriteView.h"

@interface FHCommentDetailViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong)   UIScrollView       *mainScrollView;
@property (nonatomic, strong)   FHExploreDetailToolbarView       *toolbarView;
@property(nonatomic,  strong)   TTCommentViewController *commentViewController;

@property (nonatomic,assign) double commentShowTimeTotal;
@property (nonatomic,strong) NSDate *commentShowDate;
@property (nonatomic, assign) BOOL beginShowComment;
@property (nonatomic, assign)   CGFloat       topTableViewContentHeight;
@property (nonatomic, assign)   BOOL       isAppearing;
@property(nonatomic, strong) FHPostDetailCommentWriteView *commentWriteView;
@property (nonatomic, strong) ExploreItemActionManager *itemActionManager;
@property (nonatomic, assign)   BOOL       hasLoadedComment;

@end

@implementation FHCommentDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isAppearing = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
     [self.commentWriteView dismissAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.commentShowDate) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentShowDate];
        self.commentShowTimeTotal += timeInterval*1000;
        self.commentShowDate = nil;
    }
    
    NSDictionary *commentDic = @{@"stay_comment_time":[[NSNumber numberWithDouble:round(self.commentShowTimeTotal)] stringValue]};
    _isAppearing = NO;
}

- (void)dealloc
{
    [self p_removeDetailViewKVO];
    [self p_removeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupData {
    // 默认帖子
    if (self.postType == 0) {
        self.postType = FHUGCPostTypePost;
    }
    self.hasLoadedComment = NO;
    self.topTableViewContentHeight = 0;
    self.beginShowComment = NO;
}

- (void)setupUI {
    [self setupNaviBar];
    [self setupToolbarView];
    _mainScrollView = [[UIScrollView alloc] init];
    [self.view addSubview:_mainScrollView];
    CGFloat navOffset = 65;
    if (@available(iOS 11.0 , *)) {
        navOffset = 44.f + self.view.tt_safeAreaInsets.top;
    } else {
        navOffset = 65;
    }
    _mainScrollView.frame = CGRectMake(0, navOffset, SCREEN_WIDTH, SCREEN_HEIGHT - navOffset - self.toolbarView.height);
    _mainScrollView.delegate = self;
    [self configTableView];
    self.viewModel = [FHCommentDetailViewModel createDetailViewModelWithPostType:self.postType withController:self tableView:_tableView];
    [self.mainScrollView addSubview:_tableView];
    _tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, _mainScrollView.frame.size.height);
    // 评论
    [self p_buildCommentViewController];
    // 观察者
    [self p_addObserver];
    // KVO
    [self p_addDetailViewKVO];
}

- (void)setupNaviBar {
    [self setupDefaultNavBar:YES];
}

- (void)configTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = 100;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.backgroundColor = [UIColor grayColor];
}

- (void)setupToolbarView {
    self.toolbarView = [[FHExploreDetailToolbarView alloc] initWithFrame:[self p_frameForToolBarView]];
    
    if ([SSCommonLogic detailNewLayoutEnabled]) {
        self.toolbarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    self.toolbarView.toolbarType = FHExploreDetailToolbarTypeArticleComment;
    
    [self.view addSubview:self.toolbarView];

    [self.toolbarView.writeButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.digButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.toolbarView.frame = [self p_frameForToolBarView];
    self.toolbarView.hidden = NO;
    [self p_refreshToolbarView];
}

#pragma mark - KVO

- (void)p_addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pn_applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pn_applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pn_userDidTakeScreenshot:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
}

- (void)commentCountChanged {
    
}

- (void)p_removeObserver {
    
}

- (void)pn_applicationDidEnterBackground:(NSNotification *)notification {
    if (_isAppearing) {
        //进入后台 暂停计时 @liangxinyu
        if (self.commentShowDate) {
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentShowDate];
            self.commentShowTimeTotal += timeInterval*1000;
            self.commentShowDate = nil;
        }
        NSDictionary *commentDic = @{@"stay_comment_time":[[NSNumber numberWithDouble:round(self.commentShowTimeTotal)] stringValue]};
        self.commentShowTimeTotal = 0;
    }
}

- (void)pn_applicationWillEnterForeground:(NSNotification *)notification {
    if (_isAppearing) {
        
    }
    
    self.commentShowDate = [NSDate date];
}

- (void)pn_userDidTakeScreenshot:(NSNotification *)notification {
    
}

- (void)p_addDetailViewKVO
{
    // 详情内容高度改变-改变主scrollView的控件高度
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self.commentViewController.commentTableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)p_removeDetailViewKVO
{
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
    [self.commentViewController.commentTableView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    // 详情页列表
    if (object == self.tableView) {
        if ([keyPath isEqualToString:@"contentSize"]) {
            [self p_tableViewContentSizeChange];
        }
    }
    // 评论列表
    if (object == self.commentViewController.commentTableView) {
        if ([keyPath isEqualToString:@"contentSize"]) {
            [self p_tableViewContentSizeChange];
        }
    }
}

- (void)p_tableViewContentSizeChange {
    // 改变tableView frame为内容高度
    _tableView.frame = CGRectMake(0, 0, _tableView.contentSize.width, _tableView.contentSize.height);
    _topTableViewContentHeight = _tableView.contentSize.height;
    _tableView.scrollEnabled = NO;
    CGFloat commentViewHeight = _mainScrollView.frame.size.height;
    if (_mainScrollView.contentOffset.y <= 1 && !self.hasLoadedComment) {
        self.commentViewController.view.frame = CGRectMake(0, _tableView.contentSize.height, self.view.width, commentViewHeight);
    }
    self.commentViewController.commentTableView.scrollEnabled = NO;
    
    _mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _tableView.contentSize.height + self.commentViewController.commentTableView.contentSize.height);
}

- (void)p_buildCommentViewController
{
    self.commentViewController = [[TTCommentViewController alloc] initWithViewFrame:CGRectMake(0, _mainScrollView.frame.size.height, self.view.width, _mainScrollView.frame.size.height) dataSource:self delegate:self];
    self.commentViewController.enableImpressionRecording = YES;
    [self.commentViewController willMoveToParentViewController:self];
    [self addChildViewController:self.commentViewController];
    [self.commentViewController didMoveToParentViewController:self];
    [self.mainScrollView addSubview:self.commentViewController.view];
}

// 当前详情页可视范围标准rect(去掉顶部导航,且根据articleType判断是否去掉底部toolbar)
- (CGRect)p_contentVisableRect
{
    CGFloat visableHeight = self.view.size.height;
    visableHeight -= self.toolbarView.height;
    
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeInset = self.view.safeAreaInsets;
        visableHeight += safeInset.bottom;
    }
    return CGRectMake(0, 0, [TTUIResponderHelper splitViewFrameForView:self.view].size.width, visableHeight);
}

#pragma mark - Toolbar actions

- (void)toolBarButtonClicked:(id)sender
{
    if (sender == self.toolbarView.writeButton) {
        if ([self.commentViewController respondsToSelector:@selector(tt_defaultReplyCommentModel)] && self.commentViewController.tt_defaultReplyCommentModel) {
            [self tt_commentViewController:self.commentViewController didSelectWithInfo:({
                NSMutableDictionary *baseCondition = [[NSMutableDictionary alloc] init];
                [baseCondition setValue:self.groupModel forKey:@"groupModel"];
                [baseCondition setValue:@(1) forKey:@"from"];
                [baseCondition setValue:@(YES) forKey:@"writeComment"];
                [baseCondition setValue:self.commentViewController.tt_defaultReplyCommentModel forKey:@"commentModel"];
                [baseCondition setValue:@(ArticleMomentSourceTypeArticleDetail) forKey:@"sourceType"];
                baseCondition;
            })];
            if ([self.commentViewController respondsToSelector:@selector(tt_clearDefaultReplyCommentModel)]) {
                [self.commentViewController tt_clearDefaultReplyCommentModel];
            }
            [self.toolbarView.writeButton setTitle:@"说点什么..." forState:UIControlStateNormal];
            return;
        }
        [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
    }
    else if (sender == _toolbarView.digButton) {
        // 点赞
        [self p_digg];
    }
}

- (void)p_willChangeArticleFavoriteState {
    if (!TTNetworkConnected()){
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"没有网络连接", nil)
                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return;
    }
    // add by zyk 收藏
}

// 点赞
- (void)p_digg {
    self.user_digg = (self.user_digg == 1) ? 0 : 1;
    self.digg_count = self.user_digg == 1 ? (self.digg_count + 1) : MAX(0, (self.digg_count - 1));
    
    if (!self.itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    Article *article = [[Article alloc] init];
    article.groupType = TTCommentsGroupTypeArticle;
    article.uniqueID = [self.groupModel.groupID longLongValue];
    article.itemID = self.groupModel.itemID;
    article.aggrType = @(self.groupModel.aggrType);
    
    [self.itemActionManager sendActionForOriginalData:article adID:nil actionType:(self.user_digg == 1) ? DetailActionTypeLike: DetailActionTypeUnlike finishBlock:nil];
    [self p_refreshToolbarView];
}

- (void)p_willShowSharePannel {
    
}

- (void)p_refreshToolbarView
{
    self.toolbarView.digButton.selected = self.user_digg == 1;
    self.toolbarView.digCountValue = [NSString stringWithFormat:@"%ld",self.digg_count];
}

- (CGRect)p_frameForToolBarView
{
    self.toolbarView.height = FHExploreDetailGetToolbarHeight() + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    return CGRectMake(0, self.view.height - self.toolbarView.height, self.view.width, self.toolbarView.height);
}

- (void)dismissSelf
{
    if (self.navigationController.viewControllers.count>1) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        if (viewControllers && viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

#pragma mark - TTCommentDataSource & TTCommentDelegate

- (void)tt_loadCommentsForMode:(TTCommentLoadMode)loadMode
        possibleLoadMoreOffset:(NSNumber *)offset
                       options:(TTCommentLoadOptions)options
                   finishBlock:(TTCommentLoadFinishBlock)finishBlock
{
    TTCommentDataManager *commentDataManager = [[TTCommentDataManager alloc] init];
    [commentDataManager startFetchCommentsWithGroupModel:self.groupModel forLoadMode:loadMode  loadMoreOffset:offset loadMoreCount:@(TTCommentDefaultLoadMoreFetchCount) msgID:0 options:options finishBlock:finishBlock];
}

- (SSThemedView *)tt_commentHeaderView
{
    return nil;
}

- (TTGroupModel *)tt_groupModel
{
    return self.groupModel;
}

- (NSInteger)tt_zzComments
{
    return 0;
}

- (BOOL)tt_canDeleteComments
{
    return NO;
}

- (void)tt_commentViewControllerDidFetchCommentsWithError:(NSError *)error
{
    //点击评论进入文章时跳转到评论区
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf p_scrollToCommentIfNeeded];
        weakSelf.hasLoadedComment = YES;
    });
    
    if ([self.commentViewController respondsToSelector:@selector(tt_defaultReplyCommentModel)] && self.commentViewController.tt_defaultReplyCommentModel) {
        NSString *userName = self.commentViewController.tt_defaultReplyCommentModel.userName;
        [self.toolbarView.writeButton setTitle:isEmptyString(userName)? @"说点什么...": [NSString stringWithFormat:@"回复 %@：", userName] forState:UIControlStateNormal];
    }
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController digCommentWithCommentModel:(id<TTCommentModelProtocol>)model
{
    // 对评论 点赞
    if (!model.userDigged) {

    } else {

    }
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didClickCommentCellWithCommentModel:(id<TTCommentModelProtocol>)model
{
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didClickReplyButtonWithCommentModel:(nonnull id<TTCommentModelProtocol>)model
{
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController avatarTappedWithCommentModel:(id<TTCommentModelProtocol>)model
{
    
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController tappedWithUserID:(NSString *)userID {
    if ([userID longLongValue] == 0) {
        return;
    }
    NSString *userIDstr = [NSString stringWithFormat:@"%@", userID];
    
    NSMutableString *linkURLString = [NSMutableString stringWithFormat:@"sslocal://media_account?uid=%@", userIDstr];
    
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:linkURLString]];
    
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController startWriteComment:(id<TTCommentModelProtocol>)model
{
    [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
}

- (void)tt_commentViewController:(id <TTCommentViewControllerProtocol>)ttController
             scrollViewDidScroll:(nonnull UIScrollView *)scrollView{
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didSelectWithInfo:(NSDictionary *)info {
    NSMutableDictionary *mdict = info.mutableCopy;
    [mdict setValue:@"detail_article_comment_dig" forKey:@"fromPage"];
    [mdict setValue:@"favorite" forKey:@"categoryName"];
    [mdict setValue:self.groupModel.groupID forKey:@"groupId"];
//    [mdict setValue:self.detailModel.article forKey:@"group"];
    
    [mdict setValue:@"favorite" forKey:@"categoryID"];
//    [mdict setValue:self.detailModel.clickLabel forKey:@"enterFrom"];
//    [mdict setValue:self.detailModel.logPb forKey:@"logPb"];
    
    /*{
     categoryID = favorite;
     categoryName = favorite;
     commentModel = "_groupID: 6682645929197044227, _commentID 6688965152903004174, forumID:(null), _userAvatarURL http://p0.pstatp.com/origin/3791/5070639578, badgeList:(\n)";
     enterFrom = "click_favorite";
     from = 1;
     fromPage = "detail_article_comment_dig";
     "from_message" = 0;
     group = "<Article: 0x119061610>";
     groupId = 6682645929197044227;
     groupModel = "<TTGroupModel: 0x28260f400>";
     "source_type" = 5;
     writeComment = 0;
     }
     */
    
    TTCommentDetailViewController *detailRoot = [[TTCommentDetailViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(mdict.copy)];
    
//    detailRoot.categoryID = self.detailModel.categoryID;
//    detailRoot.enterFrom = self.detailModel.clickLabel;
//    detailRoot.logPb = self.detailModel.logPb;
    
    TTModalContainerController *navVC = [[TTModalContainerController alloc] initWithRootViewController:detailRoot];
    navVC.containerDelegate = self;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f) {
        self.commentViewController.view.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self.commentViewController presentViewController:navVC animated:NO completion:nil];
        self.commentViewController.view.window.rootViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    else {
        [self.commentViewController presentViewController:navVC animated:NO completion:nil];
    }
    
    
    //停止评论时间
    if (self.commentShowDate) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentShowDate];
        self.commentShowTimeTotal += timeInterval*1000;
        self.commentShowDate = nil;
    }
}

- (void)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController
             refreshCommentCount:(int)count
{
    self.comment_count = count;
    [self commentCountChanged];
}

- (void)tt_commentViewControllerFooterCellClicked:(nonnull id<TTCommentViewControllerProtocol>)ttController
{
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    [extra setValue:self.groupModel.itemID forKey:@"item_id"];
    wrapperTrackEventWithCustomKeys(@"fold_comment", @"click", self.groupModel.groupID, nil, extra);
    NSMutableDictionary *condition = [[NSMutableDictionary alloc] init];
    [condition setValue:self.groupModel.groupID forKey:@"groupID"];
    [condition setValue:self.groupModel.itemID forKey:@"itemID"];
    [condition setValue:@(self.groupModel.aggrType) forKey:@"aggrType"];
    [condition setValue:@"0" forKey:@"zzids"];
    
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://fold_comment"] userInfo:TTRouteUserInfoWithDict(condition)];
}

- (void)p_willOpenWriteCommentViewWithReservedText:(NSString *)reservedText switchToEmojiInput:(BOOL)switchToEmojiInput  {
    
    NSMutableDictionary *condition = [NSMutableDictionary dictionaryWithCapacity:10];
    [condition setValue:self.groupModel forKey:kQuickInputViewConditionGroupModel];
    [condition setValue:reservedText forKey:kQuickInputViewConditionInputViewText];
    [condition setValue:@(NO) forKey:kQuickInputViewConditionHasImageKey];
    
    NSString *fwID = self.groupModel.groupID;
    
    TTArticleReadQualityModel *qualityModel = [[TTArticleReadQualityModel alloc] init];
    double readPct = (self.mainScrollView.contentOffset.y + self.mainScrollView.frame.size.height) / self.mainScrollView.contentSize.height;
    NSInteger percent = MAX(0, MIN((NSInteger)(readPct * 100), 100));
    qualityModel.readPct = @(percent);
//    qualityModel.stayTimeMs = @([self.detailModel.sharedDetailManager currentStayDuration]);
    
    TTCommentWriteManager *commentManager = [[TTCommentWriteManager alloc] initWithCommentCondition:condition commentViewDelegate:self commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {
        *willRepostFwID = fwID;
    } extraTrackDict:nil bindVCTrackDict:nil commentRepostWithPreRichSpanText:nil readQuality:qualityModel];
    commentManager.enterFrom = @"article";
    
//    commentManager.enterFromStr = self.detailModel.clickLabel;
//    commentManager.categoryID = self.detailModel.categoryID;
//    commentManager.logPb = self.detailModel.logPb;
    
    self.commentWriteView = [[FHPostDetailCommentWriteView alloc] initWithCommentManager:commentManager];
    
    self.commentWriteView.emojiInputViewVisible = switchToEmojiInput;
    
    
    
    // writeCommentView 禁表情
//    if ([self.commentViewController respondsToSelector:@selector(tt_banEmojiInput)]) {
//        self.commentWriteView.banEmojiInput = self.commentViewController.tt_banEmojiInput;
//    }
    
//    if ([self.commentViewController respondsToSelector:@selector(tt_writeCommentViewPlaceholder)]) {
//        [self.commentWriteView setTextViewPlaceholder:self.commentViewController.tt_writeCommentViewPlaceholder];
//    }
    
    [self.commentWriteView showInView:self.view animated:YES];
}

- (void)p_scrollToCommentIfNeeded
{
    if (self.beginShowComment && [self p_needShowToolBarView]) {
        // 跳转到评论 区域
        CGFloat totalHeight = self.tableView.contentSize.height + self.commentViewController.commentTableView.contentSize.height;
        
        CGFloat offset = self.topTableViewContentHeight - SCREEN_HEIGHT / 3;
        if (offset <= 0) {
            offset = 0;
        } else {
            CGFloat frameHeight = self.mainScrollView.bounds.size.height;
            if (totalHeight - offset < frameHeight) {
                offset = totalHeight - frameHeight - 1;
            }
        }
        
        [self.mainScrollView setContentOffset:CGPointMake(0, offset) animated:YES];
    }
}


- (BOOL)p_needShowToolBarView
{
    return YES;
}

#pragma mark - TTModalContainerDelegate

- (void)didDismissModalContainerController:(TTModalContainerController *)container {
    if ([self.commentViewController respondsToSelector:@selector(tt_reloadData)]) {
        [self.commentViewController tt_reloadData];
    }
    [self scrollViewDidScroll:self.mainScrollView];
    // 续上评论列表时间
    self.commentShowDate = [NSDate date];
}

#pragma mark - UIScrollViewDelegate
// mainScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _mainScrollView) {
        CGFloat offsetY = scrollView.contentOffset.y;
        CGFloat commentViewHeight = _mainScrollView.frame.size.height;
        if (offsetY > _topTableViewContentHeight) {
            self.commentViewController.view.frame = CGRectMake(0,  offsetY, self.view.width, commentViewHeight);
            CGFloat offset = offsetY - _topTableViewContentHeight;
            self.commentViewController.commentTableView.contentOffset = CGPointMake(0, offset);
            
            self.mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _tableView.contentSize.height + self.commentViewController.commentTableView.contentSize.height);
        } else {
            self.commentViewController.view.frame = CGRectMake(0, _tableView.contentSize.height, self.view.width, commentViewHeight);
            self.commentViewController.commentTableView.contentOffset = CGPointMake(0, 0);
            self.mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _tableView.contentSize.height + self.commentViewController.commentTableView.contentSize.height);
        }
    }
}

#pragma mark - TTWriteCommentViewDelegate

- (void)commentView:(TTCommentWriteView *) commentView cancelledWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager {
    commentWriteManager.delegate = nil;
}

- (void)commentView:(TTCommentWriteView *) commentView sucessWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager responsedData:(NSDictionary *)responseData
{
    commentWriteManager.delegate = nil;
    self.commentViewController.hasSelfShown = YES;
    if(![responseData objectForKey:@"error"])  {
        [commentView dismissAnimated:YES];
        self.comment_count += 1;
        [self commentCountChanged];
        NSMutableDictionary * data = [NSMutableDictionary dictionaryWithDictionary:[responseData objectForKey:@"data"]];
        [self.commentViewController tt_insertCommentWithDict:data];
        [self.commentViewController tt_markStickyCellNeedsAnimation];
    }
}

#pragma mark - UIKeyboardWillHideNotification
- (void)keyboardDidHide {
    [self.commentWriteView dismissAnimated:NO];
}

@end
