//
//  FHPostDetailViewController
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/2.
//

#import "FHPostDetailViewController.h"
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

TTDetailModel *tt_detailModel;// test add by zyk

@interface FHPostDetailViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong)   UIScrollView       *mainScrollView;
@property (nonatomic, strong)   FHExploreDetailToolbarView       *toolbarView;
@property (nonatomic, strong)   UITableView       *tableView;
@property (nonatomic, strong)   FHPostDetailViewModel       *viewModel;
@property(nonatomic,  strong)   TTCommentViewController *commentViewController;

@property (nonatomic,assign) double commentShowTimeTotal;
@property (nonatomic,strong) NSDate *commentShowDate;
@property (nonatomic, assign) BOOL beginShowComment;
@property (nonatomic, assign)   CGFloat       topContentOriginY;

// test
@property (nonatomic, strong) TTDetailModel *detailModel;

@end

@implementation FHPostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupUI];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupData {
    self.beginShowComment = YES;
    self.detailModel = tt_detailModel; // add by zyk
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
    self.viewModel = [[FHPostDetailViewModel alloc] initWithController:self tableView:_tableView];
    [self.mainScrollView addSubview:_tableView];
    _tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 300);
    // 评论
    [self p_buildCommentViewController];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self test];
    });
}

- (void)test {
    _tableView.frame = CGRectMake(0, 0, _tableView.contentSize.width, _tableView.contentSize.height);
    _topContentOriginY = _tableView.contentSize.height;
    _tableView.scrollEnabled = NO;
    self.commentViewController.view.frame = CGRectMake(0, _tableView.contentSize.height, self.view.width, _mainScrollView.frame.size.height);
    self.commentViewController.commentTableView.scrollEnabled = NO;
    
    _mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _tableView.contentSize.height + self.commentViewController.commentTableView.contentSize.height);
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
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.backgroundColor = [UIColor grayColor];
    //    if ([TTDeviceHelper isIPhoneXDevice]) {
    //        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    //    }
}

- (void)setupToolbarView {
    self.toolbarView = [[FHExploreDetailToolbarView alloc] initWithFrame:[self p_frameForToolBarView]];
    
    if ([SSCommonLogic detailNewLayoutEnabled]) {
        self.toolbarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    self.toolbarView.toolbarType = FHExploreDetailToolbarTypeArticleComment;
    //    self.toolbarView.backgroundColorThemeKey = kColorBackground4;
    [self.view addSubview:self.toolbarView];
    
    [self.toolbarView.collectButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.writeButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.emojiButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.commentButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.shareButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.toolbarView.frame = [self p_frameForToolBarView];
    self.toolbarView.hidden = NO;
    [self p_refreshToolbarView];
}

- (void)p_buildCommentViewController
{
//    self.commentViewController = [[TTCommentViewController alloc] initWithViewFrame:[self p_contentVisableRect] dataSource:self delegate:self];
    self.commentViewController = [[TTCommentViewController alloc] initWithViewFrame:CGRectMake(0, 320, self.view.width, 200) dataSource:self delegate:self];
    self.commentViewController.enableImpressionRecording = YES;
    [self.commentViewController willMoveToParentViewController:self];
    [self addChildViewController:self.commentViewController];
    [self.commentViewController didMoveToParentViewController:self];
    
    self.commentViewController.view.frame = CGRectMake(0, 320, self.view.width, 200);
    [self.mainScrollView addSubview:self.commentViewController.view];
//    self.tableView.tableFooterView = self.commentViewController.view;
//    self.tableView.tableFooterView.frame = CGRectMake(0, 0, self.view.width, 200);
    
}

//当前详情页可视范围标准rect(去掉顶部导航,且根据articleType判断是否去掉底部toolbar)
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
    //    if (sender == self.toolbarView.collectButton) {
    //        self.toolbarView.collectButton.imageView.contentMode = UIViewContentModeCenter;
    //        self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    //        self.toolbarView.collectButton.alpha = 1.f;
    //        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    //            self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
    //            self.toolbarView.collectButton.alpha = 0.f;
    //        } completion:^(BOOL finished){
    //            [self p_willChangeArticleFavoriteState];
    //            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    //                self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    //                self.toolbarView.collectButton.alpha = 1.f;
    //            } completion:^(BOOL finished){
    //            }];
    //        }];
    //    }
    //    else if (sender == self.toolbarView.writeButton) {
    //        if ([self.commentViewController respondsToSelector:@selector(tt_defaultReplyCommentModel)] && self.commentViewController.tt_defaultReplyCommentModel) {
    //            [self tt_commentViewController:self.commentViewController didSelectWithInfo:({
    //                NSMutableDictionary *baseCondition = [[NSMutableDictionary alloc] init];
    //                [baseCondition setValue:self.detailModel.article.groupModel forKey:@"groupModel"];
    //                [baseCondition setValue:@(1) forKey:@"from"];
    //                [baseCondition setValue:@(YES) forKey:@"writeComment"];
    //                [baseCondition setValue:self.commentViewController.tt_defaultReplyCommentModel forKey:@"commentModel"];
    //                [baseCondition setValue:@(ArticleMomentSourceTypeArticleDetail) forKey:@"sourceType"];
    //                [baseCondition setValue:self.detailModel.article forKey:@"group"]; //竟然带了article.....
    //                baseCondition;
    //            })];
    //            if ([self.commentViewController respondsToSelector:@selector(tt_clearDefaultReplyCommentModel)]) {
    //                [self.commentViewController tt_clearDefaultReplyCommentModel];
    //            }
    //            [self.toolbarView.writeButton setTitle:@"写评论" forState:UIControlStateNormal];
    //            return;
    //        }
    //        [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
    //        [self p_sendDetailLogicTrackWithLabel:@"write_button"];
    //        TLS_LOG(@"write_button");
    //    }
    //    else if (sender == self.toolbarView.emojiButton) {
    //        if ([self.commentViewController respondsToSelector:@selector(tt_defaultReplyCommentModel)] && self.commentViewController.tt_defaultReplyCommentModel) {
    //            [self tt_commentViewController:self.commentViewController didSelectWithInfo:({
    //                NSMutableDictionary *baseCondition = [[NSMutableDictionary alloc] init];
    //                [baseCondition setValue:self.detailModel.article.groupModel forKey:@"groupModel"];
    //                [baseCondition setValue:@(1) forKey:@"from"];
    //                [baseCondition setValue:@(YES) forKey:@"writeComment"];
    //                [baseCondition setValue:self.commentViewController.tt_defaultReplyCommentModel forKey:@"commentModel"];
    //                [baseCondition setValue:@(ArticleMomentSourceTypeArticleDetail) forKey:@"sourceType"];
    //                [baseCondition setValue:self.detailModel.article forKey:@"group"]; //竟然带了article.....
    //                baseCondition;
    //            })];
    //            if ([self.commentViewController respondsToSelector:@selector(tt_clearDefaultReplyCommentModel)]) {
    //                [self.commentViewController tt_clearDefaultReplyCommentModel];
    //            }
    //            [self.toolbarView.writeButton setTitle:@"写评论" forState:UIControlStateNormal];
    //            return;
    //        }
    //        [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:YES];
    //        //        [self p_sendDetailLogicTrackWithLabel:@"write_button"];
    //        TLS_LOG(@"emoji_button");
    //        //        [self p_sendDetailTTLogV2WithEvent:@"click_write_button" eventContext:nil referContext:nil];
    //    }
    //    else if (sender == _toolbarView.commentButton) {
    //
    //        [self p_sendNatantViewVisableTrack];
    //        if ([self.detailView.detailWebView isNatantViewOnOpenStatus]) {
    //            [self p_closeNatantView];
    //        }
    //        else {
    //            [self p_openNatantView];
    //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([self.detailView.detailWebView isNewWebviewContainer]? 0.6: 0.3) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //                [[TTAuthorizeManager sharedManager].loginObj showAlertAtActionDetailComment:^{
    //
    //                    [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:nil completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
    //                        if (type == TTAccountAlertCompletionEventTypeDone) {
    //                            if ([TTAccountManager isLogin]) {
    //                                [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
    //                            }
    //                        } else if (type == TTAccountAlertCompletionEventTypeTip) {
    //                            [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:nil completion:^(TTAccountLoginState state) {
    //
    //                            }];
    //                        }
    //                    }];
    //                }];
    //            });
    //
    //            //added 5.3 无评论时引导用户发评论
    //            //与新版浮层动画冲突.延迟到0.6s执行
    //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([self.detailView.detailWebView isNewWebviewContainer]? 0.6: 0.3) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //                if (!self.detailModel.article.commentCount) {
    //                    [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
    //                }
    //            });
    //
    //            //added5.7:评论较少或无评论时，点击评论按钮弹起浮层时不会走scrollDidScroll，此处需强制调用一次检查浮层诸item是否需要发送show事件
    //            [self.natantContainerView sendNatantItemsShowEventWithContentOffset:0 isScrollUp:YES shouldSendShowTrack:YES];
    //        }
    //    }
    //    else if (sender == _toolbarView.shareButton) {
    //        [self p_willShowSharePannel];
    //    }
}

- (void)p_refreshToolbarView
{
    // add by zyk
    //    self.toolbarView.collectButton.selected = self.detailModel.article.userRepined;
    //    self.toolbarView.commentBadgeValue = [@(self.detailModel.article.commentCount) stringValue];
}

- (CGRect)p_frameForToolBarView
{
    self.toolbarView.height = FHExploreDetailGetToolbarHeight() + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    return CGRectMake(0, self.view.height - self.toolbarView.height, self.view.width, self.toolbarView.height);
    
    //    CGFloat toolbarOriginY = [self p_frameForDetailView].size.height - self.toolbarView.height;
    //    if ([TTDeviceHelper isPadDevice]) {
    //        CGSize windowSize = [TTUIResponderHelper windowSize];
    //        return CGRectMake(0, toolbarOriginY, windowSize.width, self.toolbarView.height);
    //    }
    //    else {
    //        return CGRectMake(0, [self p_contentVisableRect].size.height, [self p_frameForDetailView].size.width, self.toolbarView.height);
    //    }
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
    [commentDataManager startFetchCommentsWithGroupModel:self.detailModel.article.groupModel forLoadMode:loadMode  loadMoreOffset:offset loadMoreCount:@(TTCommentDefaultLoadMoreFetchCount) msgID:self.detailModel.msgID options:options finishBlock:finishBlock];
}

- (SSThemedView *)tt_commentHeaderView
{
    return nil;
}

- (TTGroupModel *)tt_groupModel
{
    return self.detailModel.article.groupModel;
}

- (NSInteger)tt_zzComments
{
    return self.detailModel.article.zzComments.count;
}

- (BOOL)tt_canDeleteComments
{
    return NO;
}

- (void)tt_commentViewControllerDidFetchCommentsWithError:(NSError *)error
{
    //点击评论进入文章时跳转到评论区
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self p_scrollToCommentIfNeeded];
    });
    
    if ([self.commentViewController respondsToSelector:@selector(tt_defaultReplyCommentModel)] && self.commentViewController.tt_defaultReplyCommentModel) {
        NSString *userName = self.commentViewController.tt_defaultReplyCommentModel.userName;
        [self.toolbarView.writeButton setTitle:isEmptyString(userName)? @"写评论": [NSString stringWithFormat:@"回复 %@：", userName] forState:UIControlStateNormal];
    }
    
    // toolbar 禁表情
    BOOL isBanRepostOrEmoji = ![TTKitchen getBOOL:kTTKCommentRepostFirstDetailEnable] || (self.detailModel.adID > 0) || ak_banEmojiInput();
    if ([self.commentViewController respondsToSelector:@selector(tt_banEmojiInput)]) {
        self.toolbarView.banEmojiInput = self.commentViewController.tt_banEmojiInput || isBanRepostOrEmoji;
    }
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController digCommentWithCommentModel:(id<TTCommentModelProtocol>)model
{
    if (!model.userDigged) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
        [params setValue:@"house_app2c_v2" forKey:@"event_type"];
        [params setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
        [params setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
        [params setValue:model.commentID.stringValue forKey:@"comment_id"];
        [params setValue:model.userID.stringValue forKey:@"user_id"];
        [params setValue:self.detailModel.orderedData.logPb forKey:@"log_pb"];
        [params setValue:self.detailModel.orderedData.categoryID forKey:@"category_name"];
        [params setValue:self.detailModel.clickLabel forKey:@"enter_from"];
        [TTTrackerWrapper eventV3:@"comment_undigg" params:params];
    } else {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
        [params setValue:@"house_app2c_v2" forKey:@"event_type"];
        [params setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
        [params setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
        [params setValue:model.commentID.stringValue forKey:@"comment_id"];
        //        [params setValue:model.userID.stringValue forKey:@"user_id"];
        [params setValue:self.detailModel.orderedData.logPb forKey:@"log_pb"];
        [params setValue:self.detailModel.orderedData.categoryID forKey:@"category_name"];
        [params setValue:[FHTraceEventUtils generateEnterfrom:self.detailModel.orderedData.categoryID] forKey:@"enter_from"];
        [params setValue:@"comment" forKey:@"position"];
        [TTTrackerWrapper eventV3:@"rt_like" params:params];
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
    [mdict setValue:self.detailModel.categoryID forKey:@"categoryName"];
    [mdict setValue:self.detailModel.article.groupModel.groupID forKey:@"groupId"];
    [mdict setValue:self.detailModel.article forKey:@"group"];
    
    [mdict setValue:self.detailModel.categoryID forKey:@"categoryID"];
    [mdict setValue:self.detailModel.clickLabel forKey:@"enterFrom"];
    [mdict setValue:self.detailModel.logPb forKey:@"logPb"];
    
    TTCommentDetailViewController *detailRoot = [[TTCommentDetailViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(mdict.copy)];
    
    detailRoot.categoryID = self.detailModel.categoryID;
    detailRoot.enterFrom = self.detailModel.clickLabel;
    detailRoot.logPb = self.detailModel.logPb;
    
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
    self.detailModel.article.commentCount = count;
    [self.detailModel.article save];
}

- (void)tt_commentViewControllerFooterCellClicked:(nonnull id<TTCommentViewControllerProtocol>)ttController
{
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
    wrapperTrackEventWithCustomKeys(@"fold_comment", @"click", self.detailModel.article.groupModel.groupID, nil, extra);
    NSMutableDictionary *condition = [[NSMutableDictionary alloc] init];
    [condition setValue:self.detailModel.article.groupModel.groupID forKey:@"groupID"];
    [condition setValue:self.detailModel.article.groupModel.itemID forKey:@"itemID"];
    [condition setValue:self.detailModel.article.aggrType forKey:@"aggrType"];
    [condition setValue:[self.detailModel.article zzCommentsIDString] forKey:@"zzids"];
    
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://fold_comment"] userInfo:TTRouteUserInfoWithDict(condition)];
}

//
- (void)p_willOpenWriteCommentViewWithReservedText:(NSString *)reservedText switchToEmojiInput:(BOOL)switchToEmojiInput  {
    
}

- (void)p_scrollToCommentIfNeeded
{
    if (self.beginShowComment && [self p_needShowToolBarView]) {
        [self toolBarButtonClicked:self.toolbarView.commentButton];
    }
}


- (BOOL)p_needShowToolBarView
{
    return YES;
}

#pragma mark - UIScrollViewDelegate
// mainScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _mainScrollView) {
        CGFloat offsetY = scrollView.contentOffset.y;
        if (offsetY > _topContentOriginY) {
            self.commentViewController.view.frame = CGRectMake(0,  offsetY, self.view.width, _mainScrollView.frame.size.height);
            //    self.commentViewController.commentTableView.scrollEnabled = NO;
            CGFloat offset = offsetY - _topContentOriginY;
            self.commentViewController.commentTableView.contentOffset = CGPointMake(0, offset);
            
            _mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _tableView.contentSize.height + self.commentViewController.commentTableView.contentSize.height);
        } else {
            self.commentViewController.view.frame = CGRectMake(0, _tableView.contentSize.height, self.view.width, _mainScrollView.frame.size.height);
            //    self.commentViewController.commentTableView.scrollEnabled = NO;
            
            self.commentViewController.commentTableView.contentOffset = CGPointMake(0, 0);
            
            _mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _tableView.contentSize.height + self.commentViewController.commentTableView.contentSize.height);
        }
    }
}

@end
