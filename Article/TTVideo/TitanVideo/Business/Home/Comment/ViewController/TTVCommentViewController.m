//
//  TTVCommentViewController.m
//  Article
//
//  Created by lijun.thinker on 2017/5/17.
//
//

#import "TTVCommentViewController.h"
#import "TTCommentEmptyView.h"
#import "ExploreDetailBaseADView.h"
#import "TTIndicatorView.h"
#import "TTThemedAlertController.h"
#import "SSWebViewController.h"
#import "SSADActionManager.h"
#import "TTCommentViewModel.h"
#import "ArticleFriend.h"
#import "UIScrollView+Refresh.h"
#import "TTUIResponderHelper.h"
#import "NetworkUtilities.h"
#import "UIViewController+NavigationBarStyle.h"
#import "ExploreDeleteManager.h"
#import <TTABManager/TTABHelper.h>
#import "SSImpressionProtocol.h"
#import "TTCommentModel.h"
#import "TTCommentFooterCell.h"
#import "TTFoldCommentController.h"
#import "UIScrollView+Impression.h"
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "ExploreMixListDefine.h"
#import "TTUniversalCommentLayout.h"
#import "TTUniversalCommentCellLite.h"
#import "TTAccountNavigationController.h"
#import "TTCommentDetailViewController.h"
#import "TTRoute.h"

#import "TTVCommentViewModel.h"
#import "TTVCommentListCell.h"
#import "TTUserSettingsManager+FontSettings.h"
#import "TTProfileFillManager.h"
//#import "TTProfileFillViewController.h"

static NSString *kTTVCommentCellIdentifier = @"TTVCommentCellIdentifier";
static CGFloat kCommentViewLoadMoreCellHeight = 44.f;
static CGFloat kCommentViewEmptyMinHeight = 140.f;
static NSInteger kDeleteCommentActionSheetTag = 10;

@interface TTVCommentViewController ()
<UITableViewDataSource,
UITableViewDelegate,
UIActionSheetDelegate,
TTCommentEmptyViewDelegate,
TTAdDetailADViewDelegate,
TTVCommentCellDelegate,
SSImpressionProtocol,
TTCommentFooterCellDelegate>
{
    BOOL _isCommentShownForNatant;
}
@property (nonatomic, strong) SSThemedView *containerView;
@property (nonatomic, strong) SSThemedView *commentHeaderView;
@property (nonatomic, strong) TTCommentEmptyView *emptyView;
@property (nonatomic, strong) TTVCommentListItem *needDeleteItem;
@property (nonatomic, assign) CGRect controllerViewRect;
@property (nonatomic, assign) CGRect lastHeaderFrame;
@property (nonatomic, strong) NSIndexPath *needAnimatedIndexPath;
@property (nonatomic, assign) BOOL needRefreshLayout;

@property (nonatomic, strong) TTVCommentViewModel *commentViewModel;

@end

@implementation TTVCommentViewController

#pragma mark - Init

- (instancetype)initWithDataSource:(id<TTVCommentDataSource>)datasource
                         delegate:(id<TTVCommentDelegate>)delegate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _commentViewModel = [[TTVCommentViewModel alloc] init];
        _commentViewModel.datasource = datasource;
        _delegate = delegate;
        [self configureCommentViewModel];
    }
    return self;
}

- (void)applicationStautsBarDidRotate {
    self.needRefreshLayout = YES;
}

- (void)configureCommentViewModel
{
    //bind with viewModel by KVO
    [_commentViewModel addObserver:self
                        forKeyPath:@"reloadFlag"
                           options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                           context:nil];
}

- (void)commonInit
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.ttHideNavigationBar = NO;
}

- (void)initCommentTableView
{
    _commentViewModel.containViewWidth = self.view.width;

    self.containerView = [[SSThemedView alloc] initWithFrame:self.view.bounds];
    self.containerView.backgroundColor = [UIColor clearColor]; //[UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.commentTableView = [[SSThemedTableView alloc] initWithFrame:self.containerView.frame
                                                               style:UITableViewStyleGrouped];
    self.commentTableView.backgroundView = nil;
    self.commentTableView.backgroundColorThemeKey = kColorBackground4;
    self.commentTableView.dataSource = self;
    self.commentTableView.delegate = self;
    self.commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.commentTableView.showsVerticalScrollIndicator = ![TTDeviceHelper isPadDevice];
    self.commentTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.commentTableView registerClass:[TTVCommentListCell class] forCellReuseIdentifier:kTTVCommentCellIdentifier];
    [self.commentTableView registerClass:[TTCommentFooterCell class] forCellReuseIdentifier:kTTCommentFooterCellReuseIdentifier];
    self.commentHeaderView = [self.commentViewModel.datasource commentHeaderView];
    self.commentTableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 10)];

    [self.commentHeaderView addObserver:self
                             forKeyPath:@"frame"
                                options:NSKeyValueObservingOptionNew
                                context:nil];
    self.ttvContainerScrollView.hasMore = NO;
    
    [self.containerView reloadThemeUI];
    
    [self.view addSubview:self.containerView];
    [self.view addSubview:self.commentTableView];
}

#pragma mark - Life Cycle

- (void)dealloc
{
    [self.commentViewModel removeObserver:self forKeyPath:@"reloadFlag"];
    [self.commentHeaderView removeObserver:self forKeyPath:@"frame"];
    self.commentTableView.delegate = nil;
    self.commentTableView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.enableImpressionRecording) {
        [self.commentViewModel unregisterFromImpressionManager:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    [self initCommentTableView];
    [self refreshComments];
    if (self.enableImpressionRecording) {
        [self.commentViewModel registerToImpressionManager:self];
    }
    [self p_addObservers];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationStautsBarDidRotate) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardDidShow)
//                                                 name:UIKeyboardDidShowNotification
//                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.enableImpressionRecording && _isCommentShownForNatant) {
        [self.commentViewModel enterCommentImpression];
    }
    [self.commentTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.enableImpressionRecording) {
        [self.commentViewModel leaveCommentImpression];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.commentTableView.frame = [TTUIResponderHelper splitViewFrameForView:self.commentTableView];
    if ([TTDeviceHelper isPadDevice]) {
        self.commentTableView.frame = self.view.bounds;
        if (self.needRefreshLayout) {
            self.commentViewModel.containViewWidth = self.commentTableView.frame.size.width;
            [self.commentViewModel refreshLayout:^{
                self.needRefreshLayout = NO;
                [self.commentTableView reloadData];
            }];
        }
    }
}

#pragma mark - Public Methods

- (void)videoUpdateCommentWidth:(CGFloat)width {
    self.commentViewModel.containViewWidth = width;
}

- (void)refreshVideoCommentCellLayoutAtIndexPath:(NSIndexPath *)indexPath replyCount:(NSInteger)replyCount {
    
    TTVCommentListItem *item = [self.commentViewModel commentItemAtIndex:indexPath.row];
    
    item.commentModel.replyCount = @(replyCount);
    [item.layout setCellLayoutWithCommentModel:item.commentModel containViewWidth:self.commentViewModel.containViewWidth];
    [self.commentTableView reloadData];
}

- (void)markTopCellNeedAnimation {
    self.needAnimatedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)refreshComments
{
    //控件不关心当前所处commentCategory，交给viewModel去记录
    @weakify(self);
    [self.commentViewModel startLoadCommentsForMode:TTVCommentLoadModeRefresh completionHandler:^(NSError * _Nullable error) {
        @strongify(self);
        
        [self.delegate commentViewControllerDidFetchCommentsWithError:error];
    }];
}

- (void)insertCommentWithDict:(NSDictionary *)dict
{
    //暂时废弃视频弹出逻辑。
//    [self fillAction];

    TTVCommentListItem *item = [[TTVCommentListItem alloc] init];
    item.commentModel = [[TTVideoCommentItem alloc] initWithDictionary:dict groupModel:[self.commentViewModel.getArticle groupModel]];
    [self.commentViewModel addToTopWithCommentItem:item];
}

//- (void)fillAction
//{
//    if (![TTProfileFillManager manager].isShowProfileFill) {
//        return;
//    }
//    if (self.delegate && [self.delegate respondsToSelector:@selector(commentViewControllerDidShowProfileFill)]) {
//        [self.delegate commentViewControllerDidShowProfileFill];
//    }
//    WeakSelf;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if (!self) return;
//        StrongSelf;
//        CGPoint position = [self p_firstCommentAvatarCenterPosition];
//        if (position.y + [TTVCommentListCellHelper avatarSize]/2.0 <= 0.35 * SSScreenHeight
//            && position.y + [TTVCommentListCellHelper avatarSize]/2.0 > 0) {
//            CGFloat yStart = position.y + [TTVCommentListCellHelper avatarSize]/2.0 + [TTDeviceUIUtils tt_newPadding:4.0];
//            TTProfileFillViewController *vc = [[TTProfileFillViewController alloc] init];
//            [vc presentExpandLocation:CGPointMake(position.x, yStart) direction:TTProfileFillExpandDirectionDown];
//        } else if (position.y - [TTVCommentListCellHelper avatarSize]/2.0 >= 0.65 * SSScreenHeight
//                   && position.y - [TTVCommentListCellHelper avatarSize]/2.0 <= SSScreenHeight) {
//            CGFloat yStart = position.y - [TTVCommentListCellHelper avatarSize]/2.0 - [TTDeviceUIUtils tt_newPadding:4.0];
//            TTProfileFillViewController *vc = [[TTProfileFillViewController alloc] init];
//            [vc presentExpandLocation:CGPointMake(position.x, yStart) direction:TTProfileFillExpandDirectionUp];
//        }
//    });
//}


- (void)commentViewWillScrollToTopCommentCell
{
    [self commentViewWillScrollToTopCommentCellSimple];
}

- (void)commentViewWillScrollToTopCommentCellSimple
{
    if ([self.commentTableView numberOfSections] && [self.commentTableView numberOfRowsInSection:0]) {
        [self.commentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentViewControllerScrollViewDidScrollToTop)]) {
        [self.delegate commentViewControllerScrollViewDidScrollToTop];
    }
}

- (TTVCommentListItem *)defaultReplyCommentModel
{
    return [self.commentViewModel defaultReplyCommentItem];
}

- (void)clearDefalutReplyCommentModel
{
    [self.commentViewModel clearDefaultReplyCommentItem];
}

- (void)sendShowStatusTrackForCommentShown:(BOOL)shown
{
    if (_isCommentShownForNatant == shown) {
        return;
    }
    _isCommentShownForNatant = shown;
    if (_enableImpressionRecording) {
        if (shown) {
            [self.commentViewModel enterCommentImpression];
        }
        else {
            [self.commentViewModel leaveCommentImpression];
        }
    }
}

- (void)sendShowTrackForVisibleCells
{
    NSArray *visibleCells = [self.commentTableView visibleCells];
    [visibleCells enumerateObjectsUsingBlock:^(UITableViewCell * cell, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [self.commentTableView indexPathForCell:cell];
        
        [self.commentViewModel sendShowTrackForEmbeddedCell:cell atIndexPath:indexPath];
    }];
}

- (void)sendHalfStatusFooterImpressionsForViableCellsWithOffset:(CGFloat)rOffset
{
    NSArray *visibleCells = [self.commentTableView visibleCells];
    [visibleCells enumerateObjectsUsingBlock:^(TTVCommentListCell * cell, NSUInteger idx, BOOL *stop) {
        
        if (![cell isKindOfClass:[TTVCommentListCell class]]) {
            
            return ;
        }
        
        if ([cell respondsToSelector:@selector(impressionShown)]) {
            NSIndexPath *indexPath = [self.commentTableView indexPathForCell:cell];
            CGRect cellRect = [self.commentTableView rectForRowAtIndexPath:indexPath];
            CGFloat cellTop = cellRect.origin.y - self.commentTableView.tableHeaderView.height;
            CGFloat cellBottom = cellTop + cellRect.size.height;
            if (rOffset > cellTop && rOffset < cellBottom) {
                if (!cell.impressionShown) {
                    //recording
                    [self.commentViewModel recordForComment:cell.item status:SSImpressionStatusRecording];
                    cell.impressionShown = YES;
                }
            }
            else if (rOffset < cellTop) {
                //end
                if (cell.impressionShown) {
                    [self.commentViewModel recordForComment:cell.item status:SSImpressionStatusEnd];
                    cell.impressionShown = NO;
                }
            }
        }
    }];
}

#pragma mark - Private Methods

- (void)p_addObservers
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fontSizeChanged)
                                                 name:kSettingFontSizeChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_updateComment) name:@"UPDATE_COMMENT" object:nil];
}

- (void)p_addPullUpViewIfNeeded
{
    if ([self.commentViewModel curCommentItems].count) {
        WeakSelf;
        [self.ttvContainerScrollView tt_addPullUpLoadMoreWithNoMoreText:@"已显示全部评论" withHandler:^{
            StrongSelf;
            [self p_tryLoadMoreComments];
        }];
    }
}

- (void)p_updateComment {
    [self.commentViewModel refreshLayout:^{
        [self.commentTableView reloadData];
    }];
}

- (void)p_tryLoadMoreComments
{
    @weakify(self);
    [self.commentViewModel startLoadCommentsForMode:TTVCommentLoadModeLoadMore completionHandler:^(NSError * _Nullable error) {
       
        @strongify(self);
        BOOL success = !error;
        [self.ttvContainerScrollView finishPullUpWithSuccess:success];
    }];
    
    wrapperTrackEvent(@"detail", @"comment_loadmore");
}

- (void)p_reloadCommentTableHeaderView
{
    self.commentTableView.tableHeaderView = self.commentHeaderView;
    [self.commentTableView reloadData];
}

- (CGRect)p_frameForFooterInSection:(NSInteger)section
{
    CGRect rect = self.containerView.bounds;
    if (self.commentTableView.tableHeaderView) {
        rect.size.height -= self.commentTableView.tableHeaderView.height;
        if (rect.size.height < kCommentViewEmptyMinHeight) {
            rect.size.height = kCommentViewEmptyMinHeight;
        }
    }
    return rect;
}

- (BOOL)p_shouldShowFooterViewInSection:(NSInteger)section
{
    NSInteger numberOfSelfSections;
    if ([self.commentViewModel curCommentItems].count) {
        numberOfSelfSections = 1;
    }
    else {
        numberOfSelfSections = 0;
    }
    if (numberOfSelfSections == 0 && section == 0 && [self tableView:_commentTableView numberOfRowsInSection:0] == 0) {
        return YES;
    }
    return NO;
}

- (BOOL)p_shouldShowHeaderViewInSection:(NSInteger)section
{
    if ([self.commentViewModel curCommentItems].count == 0) {
        return NO;
    }
    return YES;
}

- (CGPoint)p_firstCommentAvatarCenterPosition
{
    if ([self.commentTableView numberOfSections] && [self.commentTableView numberOfRowsInSection:0]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        CGRect rect = [self.commentTableView rectForRowAtIndexPath:indexPath];
        CGRect rectInWindow = [self.commentTableView convertRect:rect toView:SSGetMainWindow()];
        CGFloat xDistance = [TTVCommentListCellHelper cellHorizontalPadding] + [TTVCommentListCellHelper avatarSize]/2.0;
        CGFloat yDistance = [TTVCommentListCellHelper cellVerticalPadding] + [TTVCommentListCellHelper avatarSize]/2.0;
        CGPoint point =CGPointMake(rectInWindow.origin.x + xDistance, rectInWindow.origin.y + yDistance);
        return point;
    }
    return CGPointZero;
}

- (void)keyboardDidShow
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[TTProfileFillManager manager] isShowProfileFill:nil log_action:YES disable:NO];
}

- (void)p_sendEnterCommentDetailTracker:(id<TTVCommentModelProtocol>)model
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:model.groupModel.itemID forKey:@"item_id"];
    [dic setValue:model.groupModel.groupID forKey:@"group_id"];
    [dic setValue:model.userID forKey:@"to_user_id"];
    [dic setValue:model.commentID forKey:@"comment_id"];
    [dic setValue:@"detail" forKey:@"position"];
    
    [TTTracker eventV3:@"comment_enter" params:dic];
}


#pragma mark - Actions

- (void)deleteCommentFromListWithCommentID:(NSString *)commentID
{
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络连接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    }
    else {
        wrapperTrackEvent(@"comment", @"delete_confirm");
        [[ExploreDeleteManager shareManager] deleteArticleCommentForCommentID:commentID isAnswer:NO isNewComment:YES];
        if (_needDeleteItem) {
            [self.commentViewModel removeCommentItem:_needDeleteItem];
            
//            Article *article = [_commentViewModel.dataSource serveArticle];
//            if (article.zzComments.count) {
//                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//                [dict setValue:article.groupModel.groupID forKey:@"group_id"];
//                [dict setValue:_needDeleteCommentModel.commentID.stringValue forKey:@"comment_id"];
//                [[NSNotificationCenter defaultCenter] postNotificationName:kTTDeleteZZCommentNotification object:nil userInfo:dict];
//            }
        }
    }
}

#pragma mark - TTVCommentCellDelegate

- (void)commentCell:(UITableViewCell *)view digCommentWithCommentItem:(nonnull TTVCommentListItem *)item {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentViewController:digCommentWithCommentModel:position:)]) {
        [self.delegate commentViewController:self digCommentWithCommentModel:item.commentModel position:@"comment"];
    }
}

- (void)commentCell:(UITableViewCell *)view deleteCommentWithCommentItem:(nonnull TTVCommentListItem *)item {
    
    self.needDeleteItem = item;
    
    if ([TTDeviceHelper OSVersionNumber] < 8.f) {
        TTThemedAlertController *actionSheet = [[TTThemedAlertController alloc] initWithTitle:@"确定删除此评论?" message:nil preferredType:TTThemedAlertControllerTypeActionSheet];
        [actionSheet addActionWithTitle:@"确认删除" actionType:TTThemedAlertActionTypeDestructive actionBlock:^{
            if ([_needDeleteItem.commentModel.commentIDNum longLongValue] != 0) {
                [self deleteCommentFromListWithCommentID:[_needDeleteItem.commentModel.commentIDNum stringValue]];
            }
            self.needDeleteItem = nil;
        }];
        [actionSheet addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [actionSheet showFrom:self animated:YES];
    }
    else {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"确定删除此评论?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认删除" otherButtonTitles:nil, nil];
        sheet.tag = kDeleteCommentActionSheetTag;
        [sheet showInView:self.view];
    }
}

- (void)commentCell:(UITableViewCell *)view replyButtonClickedWithCommentItem:(nonnull TTVCommentListItem *)item
{
    
    if (!TTNetworkConnected()) {
        NSString *tip = @"连接失败，请稍后再试";
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:^(BOOL isUserDismiss) {
        }];
        return;
    }
    
    
    if (self.commentViewModel.goTopicDetail) {
        NSIndexPath *indexPath = [self.commentTableView indexPathForCell:view];
        if (indexPath) {
            wrapperTrackEventWithCustomKeys(@"update_detail", @"enter_detail", item.commentModel.commentIDNum.stringValue, nil, @{@"ext_value": @"3",
                                                                                                              @"source": @"3"});
            [self p_sendEnterCommentDetailTracker:item.commentModel];
            if ([self.delegate respondsToSelector:@selector(commentViewController:shouldPresentCommentDetailViewControllerWithCommentModel:indexPath:showKeyBoard:)]) {
                
                [self.delegate commentViewController:self shouldPresentCommentDetailViewControllerWithCommentModel:item.commentModel indexPath:indexPath showKeyBoard:YES];
            }
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentViewController:didClickReplyButtonWithCommentModel:)]) {
        [self.delegate commentViewController:self didClickReplyButtonWithCommentModel:item.commentModel];
    }
}

- (void)commentCell:(UITableViewCell *)view avatarTappedWithCommentItem:(nonnull TTVCommentListItem *)item
{
    if ([self.delegate respondsToSelector:@selector(commentViewController:avatarTappedWithCommentModel:)]) {
        [self.delegate commentViewController:self avatarTappedWithCommentModel:item.commentModel];
    }
}

- (void)commentCell:(UITableViewCell *)view tappedWithUserID:(nonnull NSString *)userID {
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentViewController:tappedWithUserID:)]) {
        [self.delegate commentViewController:self tappedWithUserID:userID];
    }
}

- (void)commentCell:(UITableViewCell *)view nameViewonClickedWithCommentItem:(nonnull TTVCommentListItem *)item {
    [self commentCell:view avatarTappedWithCommentItem:item];
}

- (void)commentCell:(UITableViewCell *)view replyListClickedWithCommentItem:(nonnull TTVCommentListItem *)item
{
    NSIndexPath *indexPath = [_commentTableView indexPathForCell:view];
    if (indexPath) {
        wrapperTrackEvent(@"comment", @"click_outcomment");
        wrapperTrackEventWithCustomKeys(@"update_detail", @"enter_detail", item.commentModel.commentIDNum.stringValue, nil, @{@"ext_value": @"3",
                                                                                                          @"source": @"2"});
         [self p_sendEnterCommentDetailTracker:item.commentModel];
        if ([self.delegate respondsToSelector:@selector(commentViewController:shouldPresentCommentDetailViewControllerWithCommentModel:indexPath:showKeyBoard:)]) {
            
            [self.delegate commentViewController:self shouldPresentCommentDetailViewControllerWithCommentModel:item.commentModel indexPath:indexPath showKeyBoard:YES];
        }
    }
}

- (void)commentCell:(UITableViewCell *)view replyListAvatarClickedWithUserID:(nonnull NSString *)userID commentItem:(nonnull TTVCommentListItem *)item
{
    
    // add by zjing 去掉个人主页跳转
    return;
    
    if (isEmptyString(userID)) {
        return;
    }
    
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://profile"] userInfo:TTRouteUserInfoWithDict(@{@"uid": userID})];
}

- (void)commentCell:(nonnull UITableViewCell *)view quotedNameViewonClickedWithCommentItem:(nonnull TTVCommentListItem *)item {
    
    if (isEmptyString(item.commentModel.quotedComment.user_id.stringValue)) {
        return;
    }
    
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://profile"] userInfo:TTRouteUserInfoWithDict(@{@"uid": item.commentModel.quotedComment.user_id})];
}

- (void)commentCell:(UITableViewCell *)view contentUnfoldWithCommentItem:(nonnull TTVCommentListItem *)item
{
    item.layout.isUnFold = YES;
    
    [_commentTableView reloadData];
}

- (BOOL)tt_banEmojiInput
{
    return self.commentViewModel.banEmojiInput;
}

#pragma mark - ExploreCommentEmptyViewDelegate

- (void)emptyView:(TTCommentEmptyView *)view buttonClickedForType:(TTCommentEmptyViewType)type
{
    if (type == TTCommentEmptyViewTypeForceShowCommentButton) {
        [self p_tryLoadMoreComments];
    }
    else if (type == TTCommentEmptyViewTypeFailed) {
        [_emptyView refreshType:TTCommentEmptyViewTypeLoading];
        [self refreshComments];
    }
    else if (type == TTCommentEmptyViewTypeEmpty) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(commentViewController:startWriteComment:)]) {
            [self.delegate commentViewController:self startWriteComment:nil];
        }
    } else if(type == TTCommentEmptyViewTypeNotNetwork  ){
        if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentViewControllerRefreshDataInNoNetWorkCondition)]) {
            [self.delegate tt_commentViewControllerRefreshDataInNoNetWorkCondition];
        }
        [self refreshComments];
    }
}

- (TTCommentFooterCellType)footerCellType {
    NSUInteger commentCount = [self.commentViewModel curCommentItems].count;
    BOOL hasFoldComment = self.commentViewModel.hasFoldComment;
    
    if (hasFoldComment && commentCount > 0) {
        return TTCommentFooterCellTypeFold;
    }
    
    if (hasFoldComment && commentCount == 0) {
        return TTCommentFooterCellTypeFoldLeft;
    }
    
    if (!hasFoldComment && commentCount < 10) {
        return TTCommentFooterCellTypeNone;
    }
    
    return TTCommentFooterCellTypeNoMore;
}

#pragma mark - TTCommentFooterCellDelegate
- (void)commentFooterCell:(TTCommentFooterCell *)cell onClickForType:(TTCommentFooterCellType)type {
    if (type == TTCommentFooterCellTypeFold || type == TTCommentFooterCellTypeFoldLeft) {
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:self.commentViewModel.getArticle.itemID forKey:@"item_id"];
        wrapperTrackEventWithCustomKeys(@"fold_comment", @"click", self.commentViewModel.getArticle.groupModel.groupID, nil, extra);
        NSMutableDictionary *condition = [[NSMutableDictionary alloc] init];
        [condition setValue:self.commentViewModel.getArticle.groupModel.groupID forKey:@"groupID"];
        [condition setValue:self.commentViewModel.getArticle.itemID forKey:@"itemID"];
        [condition setValue:self.commentViewModel.getArticle.aggrType forKey:@"aggrType"];
        [condition setValue:[self.commentViewModel.getArticle zzCommentsIDString] forKey:@"zzids"];
        
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://fold_comment"] userInfo:TTRouteUserInfoWithDict(condition)];
    }
}

#pragma mark - ExploreDetailBaseADViewDelegate

- (void)detailBaseADView:(nonnull ExploreDetailBaseADView *)adView didClickWithModel:(nonnull ArticleDetailADModel *)adModel
{
    switch (adModel.actionType) {
        case SSADModelActionTypeApp: {
            [adModel trackRealTimeDownload];
            [[SSADActionManager sharedManager] handleAppActionForADBaseModel:adModel forTrackEvent:@"comment_ad" needAlert:YES];
        }
            break;
        case SSADModelActionTypeWeb: {
            NSMutableString *urlString = [NSMutableString stringWithString:adModel.webURL];
            SSWebViewController * controller = [[SSWebViewController alloc] initWithSupportIPhoneRotate:YES];
            controller.adID = adModel.ad_id;
            controller.logExtra = adModel.log_extra;
            [controller requestWithURL:[TTStringHelper URLWithURLString:urlString]];
            UINavigationController *topController = [TTUIResponderHelper topNavigationControllerFor: self];
            [topController pushViewController:controller animated:YES];
            [controller setTitleText:adModel.webTitle];
            [adModel sendTrackEventWithLabel:@"click" eventName:@"comment_ad"];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kDeleteCommentActionSheetTag) {
        if ([_needDeleteItem.commentModel.commentIDNum longLongValue] != 0 &&
            buttonIndex != actionSheet.cancelButtonIndex) {
            
            [self deleteCommentFromListWithCommentID:[_needDeleteItem.commentModel.commentIDNum stringValue]];
            
            id <TTVArticleProtocol> article = [_commentViewModel.datasource serveArticle];
            if (article.zzComments.count) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:article.groupModel.groupID forKey:@"group_id"];
                [dict setValue:_needDeleteItem.commentModel.commentIDNum.stringValue forKey:@"comment_id"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTDeleteZZCommentNotification object:nil userInfo:dict];
            }
        }
        self.needDeleteItem = nil;
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            wrapperTrackEvent(@"comment", @"delete_cancel");
        }
    }
}

#pragma mark - SSImpressionProtocol

- (void)needRerecordImpressions
{
    if (self.enableImpressionRecording && self.hasSelfShown) {
        for (id cell in [self.commentTableView visibleCells]) {
            
            [self _recordImpressionsIfNeedWithCell:cell status:_isCommentShownForNatant? SSImpressionStatusRecording: SSImpressionStatusSuspend];
        }
    }
}

- (void)_recordImpressionsIfNeedWithCell:(UITableViewCell *)cell status:(SSImpressionStatus)status {
    
    if (!_enableImpressionRecording || !self.hasSelfShown) {
        return;
    }
    
    if ([cell isKindOfClass:[TTVCommentListCell class]]) {
        
        [self.commentViewModel recordForComment:((TTVCommentListCell *)cell).item status:status];
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [self.commentViewModel curCommentItems].count;
    
    if ([self.commentViewModel needShowFooterCell]) {
        count += 1;
    }
    
    return count;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (![self p_shouldShowFooterViewInSection:section]) {
        self.ttvContainerScrollView.pullUpView.hidden = [self.commentViewModel needShowFooterCell];
        return nil;
    }
    CGRect frame = [self p_frameForFooterInSection:section];
    if (!_emptyView) {
        self.emptyView = [[TTCommentEmptyView alloc] initWithFrame:frame];
        self.emptyView.delegate = self;
        self.emptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    if (!TTNetworkConnected()){
        [_emptyView refreshType:TTCommentEmptyViewTypeNotNetwork];
    }
    else if (self.commentViewModel.loadResult == TTCommentLoadResultFailed) {
        [_emptyView refreshType:TTCommentEmptyViewTypeFailed];
    }
    else if (self.commentViewModel.isLoading) {
        [_emptyView refreshType:TTCommentEmptyViewTypeLoading];
    }
    else if (self.commentViewModel.detailNoComment && [self.commentViewModel curCommentItems].count > 0) {
        [_emptyView refreshType:TTCommentEmptyViewTypeForceShowCommentButton];
    }
    else {
        self.ttvContainerScrollView.pullUpView.hidden = YES;
        [_emptyView refreshType:TTCommentEmptyViewTypeEmpty];
    }
    return self.emptyView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (![self p_shouldShowFooterViewInSection:section]) {
        return CGFLOAT_MIN;
    }
    return [self p_frameForFooterInSection:section].size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.commentViewModel isFooterCellWithIndexPath:indexPath]) {
        return [TTCommentFooterCell cellHeight];
    }
    
    if (indexPath.row >= [self.commentViewModel curCommentItems].count) {
        
        return kCommentViewLoadMoreCellHeight;
    }
    
    return [self.commentViewModel curCommentItems][indexPath.row].layout.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.commentViewModel isFooterCellWithIndexPath:indexPath]) {
        TTCommentFooterCell *footerCell = [tableView dequeueReusableCellWithIdentifier:kTTCommentFooterCellReuseIdentifier forIndexPath:indexPath];
        footerCell.type = [self footerCellType];
        footerCell.delegate = self;
        return footerCell;
    }
    
    if (indexPath.row >= [self.commentViewModel curCommentItems].count) {
        return [[UITableViewCell alloc] init];
    }
    
    TTVCommentListCell *cell = [tableView dequeueReusableCellWithIdentifier:kTTVCommentCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.item = [self.commentViewModel curCommentItems][indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.hasSelfShown) {
        [self.commentViewModel sendShowTrackForEmbeddedCell:cell atIndexPath:indexPath];
    }
    
    if (self.needAnimatedIndexPath && self.needAnimatedIndexPath.row == indexPath.row && self.needAnimatedIndexPath.section == indexPath.section) {
        self.needAnimatedIndexPath = nil;
        
        UIColor *origColor = [cell.contentView.backgroundColor copy];
        [UIView animateWithDuration:0.35f animations:^{
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"0xFFFAD9"];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.35f animations:^{
                cell.contentView.backgroundColor = origColor;
            }];
        }];
    }
    
    [self _recordImpressionsIfNeedWithCell:cell status:SSImpressionStatusRecording];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    [self _recordImpressionsIfNeedWithCell:cell status:SSImpressionStatusEnd];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray <TTVCommentListItem *>* commentItems = [self.commentViewModel curCommentItems];
    
    if (indexPath.row >= commentItems.count) {
        
        return ;
    }
    
    if (!TTNetworkConnected()) {
        NSString *tip = @"连接失败，请稍后再试";
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:^(BOOL isUserDismiss) {
        }];
        return;
    }
    
    NSInteger rightIndex =  indexPath.row;
    id <TTVCommentModelProtocol, TTCommentDetailModelProtocol> comment = [commentItems objectAtIndex:rightIndex].commentModel;
    if ([comment conformsToProtocol:@protocol(TTVCommentModelProtocol)]) {
        if (self.commentViewModel.goTopicDetail) {
            wrapperTrackEventWithCustomKeys(@"update_detail", @"enter_detail", comment.commentIDNum.stringValue, nil, @{@"ext_value": @"3",
             
                                                                                                                @"source": @"1"});
             [self p_sendEnterCommentDetailTracker:comment];
            
            if ([self.delegate respondsToSelector:@selector(commentViewController:shouldPresentCommentDetailViewControllerWithCommentModel:indexPath:showKeyBoard:)]) {
                
                [self.delegate commentViewController:self shouldPresentCommentDetailViewControllerWithCommentModel:comment indexPath:indexPath showKeyBoard:NO];
            }

            if (_delegate && [_delegate respondsToSelector:@selector(commentViewController:didClickCommentCellWithCommentModel:)]) {
                [_delegate commentViewController:self didClickCommentCellWithCommentModel:comment];
            }
        } else if (comment){
            if (self.delegate && [self.delegate respondsToSelector:@selector(commentViewController:didClickCommentCellWithCommentModel:)]) {
                [self.delegate commentViewController:self didClickCommentCellWithCommentModel:comment];
            }
        }
//        wrapperTrackEvent(@"comment", @"click_comment");
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //fake code
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentViewControllerScrollViewDidScrollToTop)]) {
        [self.delegate commentViewControllerScrollViewDidScrollToTop];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentViewController:scrollViewDidScroll:)]) {
        [self.delegate commentViewController:self scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentViewController:scrollViewDidEndScrollAnimation:)]) {
        [self.delegate commentViewController:self scrollViewDidEndScrollAnimation:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentViewController:scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate commentViewController:self scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentViewController:scrollViewDidEndDecelerating:)]) {
        [self.delegate commentViewController:self scrollViewDidEndDecelerating:scrollView];
    }
}
#pragma mark - KVO & Observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"reloadFlag"]) {
        BOOL oldFlag = [[change objectForKey:@"old"] boolValue];
        BOOL newFlag = [[change objectForKey:@"new"] boolValue];
        if (newFlag != oldFlag) {
            //mod 5.8.0+：添加loadmore延迟到KVO，判断数据是否应该添加
            [self p_addPullUpViewIfNeeded];
            //当从未刷新或有更多评论时，显示“加载更多”
            self.ttvContainerScrollView.hasMore = [self.commentViewModel needLoadingUpdate] || [self.commentViewModel needLoadingMore];
            self.ttvContainerScrollView.pullUpView.hidden = [self.commentViewModel needShowFooterCell];
            [self.commentTableView reloadData];
            if (self.commentViewModel.curCommentItems.count > 0) {
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                [userInfo setObject:@(1) forKey:@"hasComments"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TTCOMMENT_UPDATE_WRITETITLE" object:nil userInfo:userInfo];
            }
            else {
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                [userInfo setObject:@(0) forKey:@"hasComments"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TTCOMMENT_UPDATE_WRITETITLE" object:nil userInfo:userInfo];
            }
        }
    }
    else if (object == self.commentHeaderView && [keyPath isEqualToString:@"frame"]) {
        CGRect newFrame = [[change objectForKey:@"new"] CGRectValue];
        if (newFrame.size.height != self.lastHeaderFrame.size.height) {
            self.lastHeaderFrame = newFrame;
            [self p_reloadCommentTableHeaderView];
        }
    }
}

- (void)observeCommentDeletedInMomentDetailView:(NSNotification *)notification
{
    //新版UI 走新接口.. 这是新通知...
    NSString *commentID = [notification.userInfo tt_stringValueForKey:@"id"];
    
    if ([_commentViewModel removeCommentItemWithCommentID:commentID]) {
        
        id <TTVArticleProtocol> article = [_commentViewModel.datasource serveArticle];
        if (article.zzComments.count) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:article.groupModel.groupID forKey:@"group_id"];
            [dict setValue:commentID forKey:@"comment_id"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTDeleteZZCommentNotification object:nil userInfo:dict];
        }
    }
}

- (void)fontSizeChanged {
    [self.commentViewModel refreshLayout:^{
        [self.commentTableView reloadData];
    }];
}

#pragma mark - Getters & Setters

@end
