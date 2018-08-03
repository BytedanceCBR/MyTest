//
//  TTCommentViewController.m
//  Article
//
//  Created by 冯靖君 on 16/3/30.
//
//

#import "TTCommentViewController.h"
#import "TTUniversalCommentLayout.h"
#import "TTUniversalCommentCellLite.h"
#import "TTCommentFooterCell.h"
#import "TTCommentEmptyView.h"
#import "TTCommentViewModel.h"
#import "TTCommentModel.h"
#import "TTCommentDataManager.h"
#import <TTUIWidget/TTIndicatorView.h>
#import <TTUIWidget/TTThemedAlertController.h>
#import <TTUIWidget/UIScrollView+Refresh.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import <TTUserSettings/TTUserSettingsManager+FontSettings.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTImpression/SSImpressionProtocol.h>
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <TTPlatformBaseLib/TTProfileFillManager.h>
#import <TTPlatformUIModel/TTGroupModel.h>
#import <TTServiceKit/TTModuleBridge.h>
#import <TTNetworkManager/TTNetworkUtil.h>



static NSString *kTTUniversalCommentCellLiteIdentifier = @"TTUniversalCommentCellLiteIdentifier";

static CGFloat kCommentViewLoadMoreCellHeight = 44.f;
static CGFloat kCommentViewEmptyMinHeight = 140.f;
static NSInteger kDeleteCommentActionSheetTag = 10;


@interface TTCommentViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, TTCommentEmptyViewDelegate, TTCommentCellDelegate, SSImpressionProtocol, TTCommentFooterCellDelegate, TTCommentViewModelDelegate>
{
    BOOL _isCommentShownForNatant;
}

@property(nonatomic, strong) SSThemedView *containerView;
@property(nonatomic, strong) SSThemedView *commentHeaderView;
@property(nonatomic, strong) SSThemedTableView *commentTableView;
@property(nonatomic, strong) TTCommentEmptyView *emptyView;
@property(nonatomic, strong) TTCommentViewModel *commentViewModel;
@property(nonatomic, strong) id<TTCommentModelProtocol> needDeleteCommentModel;
@property(nonatomic, strong) NSIndexPath *selectedCommentIndexPath;
@property(nonatomic, assign) CGRect controllerViewRect;
@property(nonatomic, assign) CGRect oldTableHeaderViewFrame;
@property(nonatomic, strong) NSIndexPath *needAnimatedIndexPath;
@property(nonatomic, assign) BOOL needRefreshLayout;


@end

@implementation TTCommentViewController

- (void)dealloc {
    [self.commentViewModel removeObserver:self forKeyPath:@"reloadFlag"];
    [self.commentHeaderView removeObserver:self forKeyPath:@"frame"];
    self.commentTableView.delegate = nil;
    self.commentTableView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.enableImpressionRecording) {
        [self.commentViewModel tt_unregisterFromImpressionManager:self];
    }
}

- (instancetype)initWithViewFrame:(CGRect)frame
                       dataSource:(id<TTCommentDataSource>)dataSource
                         delegate:(id<TTCommentViewControllerDelegate>)delegate {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _commentViewModel = [[TTCommentViewModel alloc] init];
        _commentViewModel.dataSource = dataSource;
        _commentViewModel.constraintWidth = frame.size.width;
        _commentViewModel.delegate = self;
        _delegate = delegate;
        _controllerViewRect = frame;
        [self configureCommentViewModel];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithViewFrame:self.view.bounds dataSource:nil delegate:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithViewFrame:self.view.bounds dataSource:nil delegate:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    [self initCommentTableView];
    [self tt_refreshComments];
    if (self.enableImpressionRecording) {
        [self.commentViewModel tt_registerToImpressionManager:self];
    }
    [self p_addObservers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.enableImpressionRecording && _isCommentShownForNatant) {
        [self.commentViewModel tt_enterCommentImpression];
    }
    [self.commentTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.enableImpressionRecording) {
        [self.commentViewModel tt_leaveCommentImpression];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.commentTableView.frame = [TTUIResponderHelper splitViewFrameForView:self.commentTableView];
    if ([TTDeviceHelper isPadDevice]) {
        self.commentTableView.frame = self.view.bounds;
        if (self.needRefreshLayout) {
            self.commentViewModel.constraintWidth = self.commentTableView.frame.size.width;
            [self.commentViewModel tt_refreshLayout:^{
                self.needRefreshLayout = NO;
                [self.commentTableView reloadData];
            }];
        }
    }
}

- (void)configureCommentViewModel {
    //bind with viewModel by KVO
    [_commentViewModel addObserver:self
                        forKeyPath:@"reloadFlag"
                           options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                           context:nil];
}

- (void)commonInit {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.ttHideNavigationBar = NO;
}

- (void)initCommentTableView {
    self.view.frame = _controllerViewRect;
    self.containerView = [[SSThemedView alloc] initWithFrame:self.view.bounds];
    self.containerView.backgroundColor = [UIColor clearColor];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.commentTableView = [[SSThemedTableView alloc] initWithFrame:self.containerView.frame style:UITableViewStyleGrouped];
    self.commentTableView.backgroundView = nil;
    self.commentTableView.backgroundColorThemeKey = kColorBackground4;
    self.commentTableView.dataSource = self;
    self.commentTableView.delegate = self;
    self.commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.commentTableView.showsVerticalScrollIndicator = ![TTDeviceHelper isPadDevice];
    self.commentTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.commentTableView registerClass:[TTUniversalCommentCellLite class] forCellReuseIdentifier:kTTUniversalCommentCellLiteIdentifier];
    [self.commentTableView registerClass:[TTCommentFooterCell class] forCellReuseIdentifier:kTTCommentFooterCellReuseIdentifier];

    self.commentHeaderView = [self.commentViewModel.dataSource tt_commentHeaderView];
    self.commentTableView.tableHeaderView = self.commentHeaderView ?: [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, CGFLOAT_MIN)]; //Grouped Style下height必须大于0.f 否则顶部会出现留白 @zengruihuan
    [self.commentHeaderView addObserver:self
                             forKeyPath:@"frame"
                                options:NSKeyValueObservingOptionNew
                                context:nil];
//    __weak typeof(self) wself = self;
//    [self.commentTableView tt_addPullUpLoadMoreWithNoMoreText:@"已显示全部评论" withHandler:^{
//        __strong typeof(wself) self = wself;
//        [self p_tryLoadMoreComments];
//    }];
    self.commentTableView.hasMore = NO;
    
    [self.containerView addSubview:self.commentTableView];
    [self.containerView reloadThemeUI];

    [self.view addSubview:self.containerView];
}

#pragma mark - Public Methods

- (void)tt_reloadData {
    [self.commentViewModel tt_refreshLayout:^{
        [self.commentTableView reloadData];
    }];
}

- (void)tt_refreshComments {
    //控件不关心当前所处commentCategory，交给viewModel去记录
    __weak typeof(self) wself = self;
    [self.commentViewModel tt_startLoadCommentsForMode:TTCommentLoadModeRefresh
                                 withCompletionHandler:^(NSError * _Nullable error) {
                                     __strong typeof(wself) sself = wself;
                                     if (sself.delegate && [sself.delegate respondsToSelector:@selector(tt_commentViewControllerDidFetchCommentsWithError:)]) {
                                         [sself.delegate tt_commentViewControllerDidFetchCommentsWithError:error];
                                     }
                                 }];
}

- (void)tt_insertCommentWithDict:(NSDictionary *)dict {
    [self p_profileFillAction];

    id <TTCommentModelProtocol> commentModel = [[TTCommentModel alloc] initWithDictionary:dict groupModel:[self.commentViewModel.dataSource tt_groupModel]];
    [self.commentViewModel tt_addToTopWithCommentModel:commentModel];
}

- (id<TTCommentModelProtocol>)tt_defaultReplyCommentModel {
    return self.commentViewModel.defaultReplyCommentModel;
}

- (void)tt_clearDefaultReplyCommentModel {
    self.commentViewModel.defaultReplyCommentModel = nil;
}

- (BOOL)tt_banEmojiInput {
    return self.commentViewModel.banEmojiInput;
}

- (NSString *)tt_writeCommentViewPlaceholder {
    if (isEmptyString(self.commentViewModel.commentPlaceholder)) {
        return kCommentInputPlaceHolder;
    }

    return self.commentViewModel.commentPlaceholder;
}

- (void)tt_sendShowStatusTrackForCommentShown:(BOOL)shown {
    if (_isCommentShownForNatant == shown) {
        return;
    }

    _isCommentShownForNatant = shown;
    if (_enableImpressionRecording) {
        if (shown) {
            [self.commentViewModel tt_enterCommentImpression];
        } else {
            [self.commentViewModel tt_leaveCommentImpression];
        }
    }
}

- (void)tt_sendShowTrackForVisibleCells {
    NSArray *visibleCells = [self.commentTableView visibleCells];
    [visibleCells enumerateObjectsUsingBlock:^(UITableViewCell * cell, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [self.commentTableView indexPathForCell:cell];
        [self.commentViewModel tt_sendShowTrackForEmbeddedCell:cell atIndexPath:indexPath];
    }];
}

- (void)tt_sendHalfStatusFooterImpressionsForViableCellsWithOffset:(CGFloat)rOffset {
    NSArray *visibleCells = [self.commentTableView visibleCells];
    [visibleCells enumerateObjectsUsingBlock:^(TTUniversalCommentCellLite * cell, NSUInteger idx, BOOL *stop) {
        id<TTCommentModelProtocol> commentModel;
        if ([cell respondsToSelector:@selector(commentModel)]) {
            commentModel = [cell commentModel];
        }
        if (![commentModel conformsToProtocol:@protocol(TTCommentModelProtocol)]) {
            return;
        }
        if ([cell respondsToSelector:@selector(impressionShown)]) {
            NSIndexPath *indexPath = [self.commentTableView indexPathForCell:cell];
            CGRect cellRect = [self.commentTableView rectForRowAtIndexPath:indexPath];
            CGFloat cellTop = cellRect.origin.y - self.commentTableView.tableHeaderView.height;
            CGFloat cellBottom = cellTop + cellRect.size.height;
            if (rOffset > cellTop && rOffset < cellBottom) {
                if (!cell.impressionShown) {
                    //recording
                    [self.commentViewModel tt_recordForComment:commentModel status:SSImpressionStatusRecording];
                    cell.impressionShown = YES;
                }
            }
            else if (rOffset < cellTop) {
                //end
                if (cell.impressionShown) {
                    [self.commentViewModel tt_recordForComment:commentModel status:SSImpressionStatusEnd];
                    cell.impressionShown = NO;
                }
            }
        }
    }];
}

- (void)tt_markStickyCellNeedsAnimation {
    self.needAnimatedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)tt_commentTableViewScrollToTop {
    if ([self.commentTableView numberOfSections] && [self.commentTableView numberOfRowsInSection:0]) {
        [self.commentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentViewControllerScrollViewDidScrollToTop)]) {
        [self.delegate tt_commentViewControllerScrollViewDidScrollToTop];
    }
}

- (void)tt_updateConstraintWidth:(CGFloat)width {
    self.commentViewModel.constraintWidth = width;
}

- (void)tt_updateCommentCellLayoutAtIndexPath:(NSIndexPath *)indexPath replyCount:(NSInteger)replyCount {
    NSArray *layoutArray = [self.commentViewModel tt_curCommentLayoutArray];
    NSArray *modelArray = [self.commentViewModel tt_curCommentModels];
    if (layoutArray.count > indexPath.row) {
        TTUniversalCommentLayout *layout = layoutArray[indexPath.row];
        id<TTCommentModelProtocol> model = modelArray[indexPath.row];
        model.replyCount = @(replyCount);
        [layout setCommentCellLayoutWithCommentModel:model constraintWidth:self.commentViewModel.constraintWidth];
        [self.commentTableView reloadData];
    }
}

#pragma mark - Private Methods

- (void)p_addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observeCommentDeletedInMomentDetailView:)
                                                 name:kDeleteCommentNotificationKey
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observeMomentDeletedInMomentDetailView:)
                                                 name:kDeleteMomentNotificationKey
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fontSizeChanged)
                                                 name:kSettingFontSizeChangedNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationStatusBarDidRotate)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}

- (void)p_addPullUpViewIfNeeded {
    if ([self.commentViewModel tt_curCommentModels].count) {
        WeakSelf;
        [self.commentTableView tt_addPullUpLoadMoreWithNoMoreText:@"已显示全部评论" withHandler:^{
            StrongSelf;
            [self p_tryLoadMoreComments];
        }];
    }
}

- (void)p_tryLoadMoreComments {
    __weak typeof(self) wself = self;
    [self.commentViewModel tt_startLoadCommentsForMode:TTCommentLoadModeLoadMore withCompletionHandler:^(NSError * _Nullable error) {
        __strong typeof(self) sself = wself;
        BOOL success = !error;
        [sself.commentTableView finishPullUpWithSuccess:success];
    }];
    wrapperTrackEvent(@"detail", @"comment_loadmore");
}

- (void)p_reloadCommentTableHeaderView {
    self.commentTableView.tableHeaderView = self.commentHeaderView;
    [self.commentTableView reloadData];
}

- (CGRect)p_frameForFooterInSection:(NSInteger)section {
    CGRect rect = self.containerView.bounds;
    if (self.commentTableView.tableHeaderView) {
        rect.size.height -= self.commentTableView.tableHeaderView.height;
        if (rect.size.height < kCommentViewEmptyMinHeight) {
            rect.size.height = kCommentViewEmptyMinHeight;
        }
    }

    return rect;
}

- (BOOL)p_shouldShowFooterViewInSection:(NSInteger)section {
    NSInteger numberOfSections;
    if ([self.commentViewModel tt_curCommentModels].count) {
        numberOfSections = 1;
    } else {
        numberOfSections = 0;
    }
    if (numberOfSections == 0 && section == 0 && [self tableView:_commentTableView numberOfRowsInSection:0] == 0) {
        return YES;
    }
    return NO;
}

- (BOOL)p_shouldShowHeaderViewInSection:(NSInteger)section {
    if ([self.commentViewModel tt_curCommentModels].count == 0) {
        return NO;
    }
    return YES;
}

- (void)p_sendEnterCommentDetailTracker:(id<TTCommentModelProtocol>)model {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:model.groupModel.itemID forKey:@"item_id"];
    [dic setValue:model.groupModel.groupID forKey:@"group_id"];
    [dic setValue:model.userID forKey:@"to_user_id"];
    [dic setValue:model.commentID forKey:@"comment_id"];
    [dic setValue:@"detail" forKey:@"position"];
    
    [TTTracker eventV3:@"comment_enter" params:dic];
}

- (void)p_profileFillAction {
    if (![TTProfileFillManager manager].isShowProfileFill) {
        return;
    }

    //实现了这个代理说明是视频的评论，直接返回，不弹出个人信息补全
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentViewControllerDidShowProfileFill)]) {
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;

        //判断开始点的位置，
        CGPoint position = [self p_firstCommentAvatarCenterPosition];
        if (position.y + [TTUniversalCommentCellLiteHelper avatarSize] / 2.0 <= 0.35 * screenHeight &&
            position.y + [TTUniversalCommentCellLiteHelper avatarSize] / 2.0 > 0) {
            CGFloat yStart = position.y + [TTUniversalCommentCellLiteHelper avatarSize] / 2.0f + [TTDeviceUIUtils tt_newPadding:4.0];

            [[TTModuleBridge sharedInstance_tt] triggerAction:@"TTProfileFillVCPresent"
                                                       object:nil
                                                   withParams:@{
                                                       @"expandPoint" : [NSValue valueWithCGPoint:CGPointMake(position.x, yStart)],
                                                       @"expandDirection" : @"down"
                                                   }
                                                     complete:nil];
        } else if (position.y - [TTUniversalCommentCellLiteHelper avatarSize] / 2.0 >= 0.65 * screenHeight &&
            position.y - [TTUniversalCommentCellLiteHelper avatarSize] / 2.0 <= screenHeight) {
            CGFloat yStart = position.y - [TTUniversalCommentCellLiteHelper avatarSize] / 2.0f - [TTDeviceUIUtils tt_newPadding:4.0];

            [[TTModuleBridge sharedInstance_tt] triggerAction:@"TTProfileFillVCPresent"
                                                       object:nil
                                                   withParams:@{
                                                       @"expandPoint" : [NSValue valueWithCGPoint:CGPointMake(position.x, yStart)],
                                                       @"expandDirection" : @"up"
                                                   }
                                                     complete:nil];
        }
    });
}

- (CGPoint)p_firstCommentAvatarCenterPosition {
    if ([self.commentTableView numberOfSections] && [self.commentTableView numberOfRowsInSection:0]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        CGRect rect = [self.commentTableView rectForRowAtIndexPath:indexPath];
        CGRect rectInWindow = [self.commentTableView convertRect:rect toView:SSGetMainWindow()];
        CGFloat xDistance = [TTUniversalCommentCellLiteHelper cellHorizontalPadding] + [TTUniversalCommentCellLiteHelper avatarSize] / 2.0;
        CGFloat yDistance = [TTUniversalCommentCellLiteHelper cellVerticalPadding] + [TTUniversalCommentCellLiteHelper avatarSize] / 2.0;
        CGPoint point = CGPointMake(rectInWindow.origin.x + xDistance, rectInWindow.origin.y + yDistance);
        return point;
    }
    return CGPointZero;
}

#pragma mark - Action

- (void)showMomentDetailViewWithComment:(id<TTCommentModelProtocol>)comment
                            atIndexPath:(NSIndexPath *)indexPath
                       showWriteComment:(BOOL)show {
    if (!isEmptyString(comment.openURL)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTNetworkUtil URLWithURLString:comment.openURL]];
    }
    else {
        BOOL shouldShow = !comment.replyCount.intValue || show;

        //钩子分发到业务层
        if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentViewController:didSelectWithInfo:)]) {
            NSMutableDictionary *baseCondition = [[NSMutableDictionary alloc] init];
            [baseCondition setValue:[self.commentViewModel.dataSource tt_groupModel] forKey:@"groupModel"];
            [baseCondition setValue:@(1) forKey:@"from"];
            [baseCondition setValue:@(shouldShow) forKey:@"writeComment"];
            [baseCondition setValue:comment forKey:@"commentModel"];
            [baseCondition setValue:@(5) forKey:@"source_type"]; // ArticleMomentSourceTypeArticleDetail
            [baseCondition setValue:@(comment.isStick) forKey:@"from_message"];
            [baseCondition setValue:self.serviceID forKey:@"serviceID"]; // serviceID
            [self.delegate tt_commentViewController:self didSelectWithInfo:baseCondition];
        }
    }
    //记录入口的comment信息
    self.selectedCommentIndexPath = indexPath;
}

- (void)deleteCommentFromListWithCommentID:(NSString *)commentID isOtherComment:(BOOL)isOtherComment
{
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络连接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    } else {
        wrapperTrackEvent(@"comment", @"delete_confirm");
        
        if (isOtherComment) {
            [[TTCommentDataManager sharedManager] deleteCommentByAuthorWithCommentID:commentID groupID:[self.commentViewModel.dataSource tt_groupModel].groupID finishBlock:^(NSError *error) {
                if (error) {
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"删除失败", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                } else {
                    [self deleteCommentActionWithCommentID:commentID];
                }
            }];
        } else {
            [[TTCommentDataManager sharedManager] deleteCommentWithCommentID:commentID finishBlock:nil];
        }

        if (_needDeleteCommentModel) {
            [self.commentViewModel tt_removeComment:self.needDeleteCommentModel];
            
            if ([self.commentViewModel.dataSource respondsToSelector:@selector(tt_zzComments)] && [self.commentViewModel.dataSource respondsToSelector:@selector(tt_groupModel)]) {
                NSInteger zzComment = [self.commentViewModel.dataSource tt_zzComments];
                if (zzComment) {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setValue:[self.commentViewModel.dataSource tt_groupModel].groupID forKey:@"group_id"];
                    [dict setValue:_needDeleteCommentModel.commentID.stringValue forKey:@"comment_id"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTTDeleteZZCommentNotification object:nil userInfo:dict];
                }
            }
        }
    }
}

#pragma mark - KVO & Observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"reloadFlag"]) {
        BOOL oldFlag = [[change objectForKey:@"old"] boolValue];
        BOOL newFlag = [[change objectForKey:@"new"] boolValue];
        if (newFlag != oldFlag) {
            //mod 5.8.0+：添加loadmore延迟到KVO，判断数据是否应该添加
            [self p_addPullUpViewIfNeeded];
            //当从未刷新或有更多评论时，显示“加载更多”
            self.commentTableView.hasMore = [self.commentViewModel tt_needLoadingUpdate] || [self.commentViewModel tt_needLoadingMore];
            self.commentTableView.pullUpView.hidden = [self.commentViewModel tt_needShowFooterCell];
            [self.commentTableView reloadData];
            if (self.commentViewModel.tt_curCommentModels.count > 0) {
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                [userInfo setObject:@(1) forKey:@"hasComments"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TTCOMMENT_UPDATE_WRITETITLE" object:nil userInfo:userInfo];
            } else {
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                [userInfo setObject:@(0) forKey:@"hasComments"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TTCOMMENT_UPDATE_WRITETITLE" object:nil userInfo:userInfo];
            }
        }
    } else if (object == self.commentHeaderView && [keyPath isEqualToString:@"frame"]) {
        CGRect newFrame = [[change objectForKey:@"new"] CGRectValue];
        if (newFrame.size.height != self.oldTableHeaderViewFrame.size.height) {
            self.oldTableHeaderViewFrame = newFrame;
            [self p_reloadCommentTableHeaderView];
        }
    }
}

- (void)observeMomentDeletedInMomentDetailView:(NSNotification *)notification {
    NSMutableArray *mShowAry = [[self.commentViewModel tt_curCommentModels] mutableCopy];
    NSInteger rightIndex = self.selectedCommentIndexPath.row;
    if (mShowAry.count > rightIndex) {
        id<TTCommentModelProtocol> comment = mShowAry[rightIndex];
        self.needDeleteCommentModel = comment;
        [self deleteCommentFromListWithCommentID:[comment.commentID stringValue] isOtherComment:NO];
        self.needDeleteCommentModel = nil;
    }
}

- (void)observeCommentDeletedInMomentDetailView:(NSNotification *)notification {
    //新版UI 走新接口.. 这是新通知...
    NSString *deleteCommentID = [notification.userInfo tt_stringValueForKey:@"id"];
    [self deleteCommentActionWithCommentID:deleteCommentID];
}

- (void)deleteCommentActionWithCommentID:(NSString *)commentID {
    NSMutableArray *mShowAry = [[self.commentViewModel tt_curCommentModels] mutableCopy];
    if (!self.selectedCommentIndexPath || (self.selectedCommentIndexPath.row >= mShowAry.count)) {
        return;
    }

    NSInteger rightIndex = self.selectedCommentIndexPath.row;
    id<TTCommentModelProtocol> comment = mShowAry[rightIndex];
    if (![comment.commentID.stringValue isEqualToString:commentID]) {
        return;
    }

    self.needDeleteCommentModel = comment;
    if (_needDeleteCommentModel) {
        [self.commentViewModel tt_removeComment:self.needDeleteCommentModel];
        
        if ([self.commentViewModel.dataSource respondsToSelector:@selector(tt_zzComments)] && [self.commentViewModel.dataSource respondsToSelector:@selector(tt_groupModel)]) {
            NSInteger zzComment = [self.commentViewModel.dataSource tt_zzComments];
            if (zzComment) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:[self.commentViewModel.dataSource tt_groupModel].groupID forKey:@"group_id"];
                [dict setValue:_needDeleteCommentModel.commentID.stringValue forKey:@"comment_id"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTDeleteZZCommentNotification object:nil userInfo:dict];
            }
        }
    }
    self.needDeleteCommentModel = nil;
}

- (void)fontSizeChanged {
    [self.commentViewModel tt_refreshLayout:^{
        [self.commentTableView reloadData];
    }];
}

- (void)applicationStatusBarDidRotate {
    self.needRefreshLayout = YES;
}

- (void)keyboardDidShow {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];

    //视频下
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentViewControllerDidShowProfileFill)]) {
        return;
    }

    [[TTProfileFillManager manager] isShowProfileFill:nil log_action:YES disable:NO];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    count = [self.commentViewModel tt_curCommentLayoutArray].count;
    
    if ([self.commentViewModel tt_needShowFooterCell]) {
        count += 1;
    }
    
    return count;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (![self p_shouldShowFooterViewInSection:section]) {
        self.commentTableView.pullUpView.hidden = [self.commentViewModel tt_needShowFooterCell];
        return nil;
    }
    CGRect frame = [self p_frameForFooterInSection:section];
    if (!_emptyView) {
        self.emptyView = [[TTCommentEmptyView alloc] initWithFrame:frame];
        self.emptyView.delegate = self;
        self.emptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }

    if (!TTNetworkConnected()) {
        [_emptyView refreshType:TTCommentEmptyViewTypeNotNetwork];
    } else if (self.commentViewModel.loadResult == TTCommentLoadResultFailed) {
        [_emptyView refreshType:TTCommentEmptyViewTypeFailed];
    } else if (self.commentViewModel.isLoading) {
        [_emptyView refreshType:TTCommentEmptyViewTypeLoading];
    } else if (self.commentViewModel.detailNoComment && [self.commentViewModel tt_curCommentModels].count > 0) {
        [_emptyView refreshType:TTCommentEmptyViewTypeForceShowCommentButton];
    } else {
        self.commentTableView.pullUpView.hidden = YES;
        [_emptyView refreshType:TTCommentEmptyViewTypeEmpty];
    }
    return self.emptyView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (![self p_shouldShowFooterViewInSection:section]) {
        return CGFLOAT_MIN;
    }
    return [self p_frameForFooterInSection:section].size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.commentViewModel tt_isFooterCellWithIndexPath:indexPath]) {
        return [TTCommentFooterCell cellHeight];
    }

    NSArray *layoutArray = [self.commentViewModel tt_curCommentLayoutArray];
    if (layoutArray.count && indexPath.row < layoutArray.count) {
        TTUniversalCommentLayout *layout = layoutArray[indexPath.row];
        return layout.cellHeight;
    } else {
        return kCommentViewLoadMoreCellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.commentViewModel tt_isFooterCellWithIndexPath:indexPath]) {
        TTCommentFooterCell *footerCell = [tableView dequeueReusableCellWithIdentifier:kTTCommentFooterCellReuseIdentifier forIndexPath:indexPath];
        footerCell.type = [self footerCellType];
        footerCell.delegate = self;
        return footerCell;
    }
    
    if (indexPath.row >= [self.commentViewModel tt_curCommentModels].count) {
        return [[UITableViewCell alloc] init];
    }
    
    NSArray *modelArray = [self.commentViewModel tt_curCommentModels];
    NSArray *layoutArray = [self.commentViewModel tt_curCommentLayoutArray];
    NSInteger rightIndex = indexPath.row;
    if ([layoutArray count] > 0 && rightIndex < [layoutArray count]) {
        TTUniversalCommentCellLite *commentCell = (TTUniversalCommentCellLite *)[tableView dequeueReusableCellWithIdentifier:kTTUniversalCommentCellLiteIdentifier forIndexPath:indexPath];
        id<TTCommentModelProtocol> commentModel = [modelArray objectAtIndex:rightIndex];
        commentCell.delegate = self;
        TTUniversalCommentLayout *layout = layoutArray[indexPath.row];
        [commentCell tt_refreshConditionWithLayout:layout model:commentModel];
        return commentCell;
    } else {
        return [[UITableViewCell alloc] init];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hasSelfShown) {
        [self.commentViewModel tt_sendShowTrackForEmbeddedCell:cell atIndexPath:indexPath];
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
    NSArray *modelArray = [self.commentViewModel tt_curCommentModels];
    NSInteger rightIndex =  indexPath.row;
    if ([modelArray count] > 0 && rightIndex < [modelArray count]) {
        NSInteger rightIndex =  indexPath.row;
        id model = [modelArray objectAtIndex:rightIndex];
        if ([model isKindOfClass:[TTCommentModel class]]) {
            TTCommentModel *comment = ((TTCommentModel *)[modelArray objectAtIndex:rightIndex]);
            if (self.commentViewModel.goTopicDetail) {
                wrapperTrackEventWithCustomKeys(@"update_detail", @"enter_detail", comment.commentID.stringValue, nil, @{@"ext_value": @"3", @"source": @"1"});
                [self p_sendEnterCommentDetailTracker:model];
                if (!_delegate || ![_delegate respondsToSelector:@selector(tt_commentViewController:shouldPresentCommentDetailViewControllerWithCommentModel:indexPath:showKeyBoard:)] || ![_delegate tt_commentViewController:self shouldPresentCommentDetailViewControllerWithCommentModel:comment indexPath:indexPath showKeyBoard:NO]) {
                    //置顶评论 强制弹键盘, 其他 0评时才弹
                    [self showMomentDetailViewWithComment:comment atIndexPath:indexPath showWriteComment:comment.isStick];
                } else {
                    self.selectedCommentIndexPath = indexPath;
                }
                if (_delegate && [_delegate respondsToSelector:@selector(tt_commentViewController:didClickCommentCellWithCommentModel:)]) {
                    [_delegate tt_commentViewController:self didClickCommentCellWithCommentModel:model];
                }
            } else if (comment) {
                id<TTCommentModelProtocol> clickCommentModel = comment;
                if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentViewController:didClickCommentCellWithCommentModel:)]) {
                    [self.delegate tt_commentViewController:self didClickCommentCellWithCommentModel:clickCommentModel];
                }
            }
            wrapperTrackEvent(@"comment", @"click_comment");
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentViewController:scrollViewDidScroll:)]) {
        [self.delegate tt_commentViewController:self scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentViewController:scrollViewDidEndScrollAnimation:)]) {
        [self.delegate tt_commentViewController:self scrollViewDidEndScrollAnimation:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentViewController:scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate tt_commentViewController:self scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentViewController:scrollViewDidEndDecelerating:)]) {
        [self.delegate tt_commentViewController:self scrollViewDidEndDecelerating:scrollView];
    }
}

#pragma mark - TTCommentCellDelegate

- (void)tt_commentCell:(UITableViewCell *)view digCommentWithCommentModel:(id<TTCommentModelProtocol>)model {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentViewController:digCommentWithCommentModel:)]) {
        [self.delegate tt_commentViewController:self digCommentWithCommentModel:model];
    }
}

- (void)tt_commentCell:(UITableViewCell *)view deleteCommentWithCommentModel:(id<TTCommentModelProtocol>)model {
    if (model.commentID) {
        self.needDeleteCommentModel = model;
        if ([TTDeviceHelper OSVersionNumber] < 8.f) {
            TTThemedAlertController *actionSheet = [[TTThemedAlertController alloc] initWithTitle:@"确定删除此评论?" message:nil preferredType:TTThemedAlertControllerTypeActionSheet];
            [actionSheet addActionWithTitle:@"确认删除" actionType:TTThemedAlertActionTypeDestructive actionBlock:^{
                if ([_needDeleteCommentModel.commentID longLongValue] != 0) {
                    [self deleteCommentFromListWithCommentID:[_needDeleteCommentModel.commentID stringValue] isOtherComment:([TTAccountManager userIDLongInt] != [model.userID longLongValue])];
                }
                self.needDeleteCommentModel = nil;
            }];
            [actionSheet addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
            [actionSheet showFrom:self animated:YES];
        } else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确定删除此评论?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认删除" otherButtonTitles:nil, nil];
            actionSheet.tag = kDeleteCommentActionSheetTag;
            [actionSheet showInView:self.view];
        }
    } else {
        self.needDeleteCommentModel = nil;
    }
}

- (void)tt_commentCell:(UITableViewCell *)view replyButtonClickedWithModel:(id<TTCommentModelProtocol>)model {
    if (self.commentViewModel.goTopicDetail) {
        NSIndexPath *indexPath = [self.commentTableView indexPathForCell:view];
        if (indexPath) {
            wrapperTrackEventWithCustomKeys(@"update_detail", @"enter_detail", model.commentID.stringValue, nil, @{@"ext_value": @"3",
                                                                                      @"source": @"3"});
            [self p_sendEnterCommentDetailTracker:model];
            if (!_delegate || ![_delegate respondsToSelector:@selector(tt_commentViewController:shouldPresentCommentDetailViewControllerWithCommentModel:indexPath:showKeyBoard:)] || ![_delegate tt_commentViewController:self shouldPresentCommentDetailViewControllerWithCommentModel:model indexPath:indexPath showKeyBoard:YES]) {
                [self showMomentDetailViewWithComment:model atIndexPath:indexPath showWriteComment:model.isStick];
            } else {
                self.selectedCommentIndexPath = indexPath;
            }
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentViewController:didClickReplyButtonWithCommentModel:)]) {
        [self.delegate tt_commentViewController:self didClickReplyButtonWithCommentModel:model];
    }
}

- (void)tt_commentCell:(UITableViewCell *)view showMoreButtonClickedWithModel:(id<TTCommentModelProtocol>)model {
    NSIndexPath *indexPath = [self.commentTableView indexPathForCell:view];
    if (indexPath) {
        [self showMomentDetailViewWithComment:model atIndexPath:indexPath showWriteComment:model.isStick];
    }
}

- (void)tt_commentCell:(UITableViewCell *)view avatarTappedWithCommentModel:(id<TTCommentModelProtocol>)model {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentViewController:avatarTappedWithCommentModel:)]) {
        [self.delegate tt_commentViewController:self avatarTappedWithCommentModel:model];
    }
}

- (void)tt_commentCell:(UITableViewCell *)view tappedWithUserID:(nonnull NSString *)userID {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentViewController:tappedWithUserID:)]) {
        [self.delegate tt_commentViewController:self tappedWithUserID:userID];
    }
}

- (void)tt_commentCell:(UITableViewCell *)view nameViewonClickedWithCommentModel:(id<TTCommentModelProtocol>)model {
    [self tt_commentCell:view avatarTappedWithCommentModel:model];
}

- (void)tt_commentCell:(UITableViewCell *)view replyListClickedWithModel:(id<TTCommentModelProtocol>)model {
    NSIndexPath *indexPath = [_commentTableView indexPathForCell:view];
    if (indexPath) {
        wrapperTrackEvent(@"comment", @"click_outcomment");
        wrapperTrackEventWithCustomKeys(@"update_detail", @"enter_detail", model.commentID.stringValue, nil, @{@"ext_value": @"3",@"source": @"2"});
        [self p_sendEnterCommentDetailTracker:model];
        if (!_delegate || ![_delegate respondsToSelector:@selector(tt_commentViewController:shouldPresentCommentDetailViewControllerWithCommentModel:indexPath:showKeyBoard:)] || ![_delegate tt_commentViewController:self shouldPresentCommentDetailViewControllerWithCommentModel:model indexPath:indexPath showKeyBoard:YES]) {
            [self showMomentDetailViewWithComment:model atIndexPath:indexPath showWriteComment:model.isStick];
        } else {
            self.selectedCommentIndexPath = indexPath;
        }
    }
}

- (void)tt_commentCell:(UITableViewCell *)view replyListAvatarClickedWithUserID:(NSString *)userID commentModel:(id<TTCommentModelProtocol>)model {
    if (isEmptyString(userID)) {
        return;
    }
    
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://profile"] userInfo:TTRouteUserInfoWithDict(@{@"uid": userID})];
}

- (void)tt_commentCell:(nonnull UITableViewCell *)view quotedNameViewonClickedWithCommentModel:(nonnull id<TTCommentModelProtocol>)model {
    if (isEmptyString(model.quotedComment.userID)) {
        return;
    }
    
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://profile"] userInfo:TTRouteUserInfoWithDict(@{@"uid": model.quotedComment.userID})];
}

- (void)tt_commentCell:(UITableViewCell *)view contentUnfoldWithCommentModel:(id<TTCommentModelProtocol>)model {
    NSIndexPath *indexPath = [_commentTableView indexPathForCell:view];
    if (!indexPath) {
        return;
    }
    
    NSArray *layoutArray = [self.commentViewModel tt_curCommentLayoutArray];
    TTUniversalCommentLayout *layout = layoutArray[indexPath.row];
    if ([model respondsToSelector:@selector(isUnFold)]) {
        model.isUnFold = YES;
    }
    layout.isUnFold = YES;

    [_commentTableView reloadData];
}

#pragma mark - TTCommentEmptyViewDelegate

- (void)emptyView:(TTCommentEmptyView *)view buttonClickedForType:(TTCommentEmptyViewType)type {
    if (type == TTCommentEmptyViewTypeForceShowCommentButton) {
        [self p_tryLoadMoreComments];
    } else if (type == TTCommentEmptyViewTypeFailed) {
        [_emptyView refreshType:TTCommentEmptyViewTypeLoading];
        [self tt_refreshComments];
    } else if (type == TTCommentEmptyViewTypeEmpty) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentViewController:startWriteComment:)]) {
            [self.delegate tt_commentViewController:self startWriteComment:nil];
        }
    } else if (type == TTCommentEmptyViewTypeNotNetwork) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentViewControllerRefreshDataInNoNetWorkCondition)]) {
            [self.delegate tt_commentViewControllerRefreshDataInNoNetWorkCondition];
        }
        [self tt_refreshComments];
    }
}

- (TTCommentFooterCellType)footerCellType {
    NSUInteger commentCount = [self.commentViewModel tt_curCommentModels].count;
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
        if ([self.delegate respondsToSelector:@selector(tt_commentViewControllerFooterCellClicked:)]) {
            [self.delegate tt_commentViewControllerFooterCellClicked:self];
        }
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kDeleteCommentActionSheetTag) {
        if ([_needDeleteCommentModel.commentID longLongValue] != 0 &&
            buttonIndex != actionSheet.cancelButtonIndex) {
            [self deleteCommentFromListWithCommentID:[_needDeleteCommentModel.commentID stringValue] isOtherComment:([TTAccountManager userIDLongInt] != [_needDeleteCommentModel.userID longLongValue])];
            
            if ([self.commentViewModel.dataSource respondsToSelector:@selector(tt_zzComments)] && [self.commentViewModel.dataSource respondsToSelector:@selector(tt_groupModel)]) {
                NSInteger zzComment = [self.commentViewModel.dataSource tt_zzComments];
                if (zzComment) {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setValue:[self.commentViewModel.dataSource tt_groupModel].groupID forKey:@"group_id"];
                    [dict setValue:_needDeleteCommentModel.commentID.stringValue forKey:@"comment_id"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTTDeleteZZCommentNotification object:nil userInfo:dict];
                }
            }
        }
        self.needDeleteCommentModel = nil;
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            wrapperTrackEvent(@"comment", @"delete_cancel");
        }
    }
}

#pragma mark - TTCommentViewModelDelegate

- (void)commentViewModel:(TTCommentViewModel *)viewModel refreshCommentCount:(int)commentCount {
    if ([self.delegate respondsToSelector:@selector(tt_commentViewController:refreshCommentCount:)]) {
        [self.delegate tt_commentViewController:self refreshCommentCount:commentCount];
    }
}

#pragma mark - SSImpressionProtocol

- (void)needRerecordImpressions {
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
    
    id<TTCommentModelProtocol> commentModel;
    
    if ([cell respondsToSelector:@selector(commentModel)]) {
        commentModel = [(id)cell commentModel];
    }
    
    if (![commentModel conformsToProtocol:@protocol(TTCommentModelProtocol) ]) {
        return;
    }
    
    [self.commentViewModel tt_recordForComment:commentModel status:status];
}

@end
