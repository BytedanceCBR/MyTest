//
//  TTVReplyViewController.m
//  Article
//
//  Created by lijun.thinker on 2017/6/1.
//
//

#import "TTVReplyViewController.h"
#import "TTHeaderScrollView.h"
//#import "TTTabContainerView.h"
#import "TTVReplyView.h"
#import "TTVReplyViewModel.h"
#import "TTVReplyTopBar.h"
#import "TTVReplyListCell.h"
#import "TTRoute.h"
#import "SSIndicatorTipsManager.h"
#import "TTIndicatorView.h"
#import "TTUIResponderHelper.h"
#import "DetailActionRequestManager.h"
#import "TTActivityShareManager.h"
#import "ArticleShareManager.h"
#import "SSActivityView.h"
//#import "TTPostThreadViewController.h"
//#import "TTRepostViewController.h"
#import <KVOController.h>
#import "TTVCommentListCell.h"
#import "NetworkUtilities.h"
#import "TTCommentWriteView.h"
#import "TTCommentDetailModelProtocol.h"
#import "TTCommentDetailReplyCommentModelProtocol.h"
#import "TTVReplyModel.h"
#import "TTActivityShareSequenceManager.h"
#import "TTRelevantDurationTracker.h"
#import "TTUGCPermissionService.h"
#import "TTAccountManager.h"
//#import "FRForumServer.h"
#import "TTCommentDataManager.h"
#import <ExploreMomentDefine_Enums.h>
#import "ExploreMomentDefine.h"
static const CGFloat kBarHeight = 49;
#define kDeleteCommentActionSheetTag 10

extern BOOL ttvs_isShareIndividuatioEnable(void);

@interface TTVReplyViewController () <UIGestureRecognizerDelegate, TTVReplyListCellDelegate, TTVReplyViewDelegate, UIActionSheetDelegate, SSActivityViewDelegate>

@property (nonatomic, strong) TTVReplyView *detailView;
@property (nonatomic, strong) TTVReplyTopBar *topBar;
@property (nonatomic, strong) UIPanGestureRecognizer *panGes;
@property (nonatomic, assign) BOOL isDraggingFloatView;
@property (nonatomic, assign) CGFloat lastY;
@property (nonatomic, assign) CGFloat originY;

@property (nonatomic, strong) TTCommentDataManager *commentDetailService;
@property (nonatomic, strong) TTCommentDetailModel *commentDetailModel;

@property (nonatomic, strong) TTVReplyViewModel *viewModel;
@property (nonatomic, strong)id <TTVReplyModelProtocol> needDeleteCommentModel;
@property(nonatomic, strong)TTActivityShareManager *activityActionManager;
@property(nonatomic, strong)SSActivityView *phoneShareView;

@property (nonatomic, strong) FRThreadEntity *thread;
//@property (nonatomic, strong) Thread *originThread;
@property (nonatomic, strong) Article *originArticle;
//@property (nonatomic, assign) TTThreadRepostType repostType;

@property(nonatomic, assign, readwrite)ArticleMomentSourceType sourceType;

@property (nonatomic, strong) TTCommentWriteView *replyWriteView;

@property (nonatomic, assign) BOOL registeredKVO;

@end

@implementation TTVReplyViewController

#pragma mark - Init

- (instancetype)initWithViewFrame:(CGRect)viewFrame comment:(id<TTVCommentModelProtocol, TTCommentDetailModelProtocol>)commentModel showWriteComment:(BOOL)showWriteComment {

    self = [super init];
    if (self) {

        _isAdVideo = NO;
        _showWriteComment = showWriteComment;
        _viewFrame = viewFrame;

        _viewModel = [[TTVReplyViewModel alloc] initWithCommentModel:commentModel containViewWidth:_viewFrame.size.width];

        [self addKVO];

        self.sourceType = ArticleMomentSourceTypeArticleDetail;
        
        _commentDetailService = [[TTCommentDataManager alloc] init];
        [self p_getCommentDetailModel];
    }
    return self;
}

#pragma mark - Getters & Setters

- (void)setViewFrame:(CGRect)viewFrame {
    _viewFrame = viewFrame;
    self.view.frame = _viewFrame;
}

- (id <TTVCommentModelProtocol, TTCommentDetailModelProtocol>)commentModel {
    return _viewModel.commentModel;
}

#pragma mark - Life Cycle

- (void)dealloc {
    _detailView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = _viewFrame;
    _topBar = [[TTVReplyTopBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kBarHeight)];
    [_topBar.closeBtn addTarget:self action:@selector(p_dismissSelf:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_topBar];
    BOOL showWriteComment = NO;

    _topBar.titleLabel.text = [NSString stringWithFormat:@"%ld条回复", [self.commentModel.replyCount integerValue]];
    [_topBar.titleLabel sizeToFit];

    _detailView = [[TTVReplyView alloc] initWithFrame:CGRectMake(0, _topBar.bottom, self.view.width, self.view.height - _topBar.height) viewModel:_viewModel showWriteComment:showWriteComment cellDelegate:self];
    _detailView.delegate = self;

    id <TTCommentDetailModelProtocol> commentDetailModel = self.commentDetailModel ? self.commentDetailModel : self.commentModel;

    BOOL isBanForward = NO;
    if (commentDetailModel && [commentDetailModel respondsToSelector:@selector(banForwardToWeitoutiao)]) {
        isBanForward = [commentDetailModel banForwardToWeitoutiao].boolValue;
    }
    _detailView.isBanEmoji = commentDetailModel.banEmojiInput || self.isBanEmoji || self.isAdVideo || isBanForward;
    BOOL hasDeleteReplyPermission = NO;
    NSString *selfUID = [TTAccountManager userID];
    if (!isEmptyString(selfUID) && [self.viewModel.commentModel.userID.stringValue isEqualToString:selfUID]) {
        hasDeleteReplyPermission = YES;
    };
    _detailView.hasDeleteReplyPermission = hasDeleteReplyPermission;
    WeakSelf;
    _detailView.dismissBlock = ^ {
        StrongSelf;
        [self p_dismissSelf:nil];
    };

    void (^updateMomentCountBlock)(NSInteger, NSInteger) = ^void(NSInteger count, NSInteger increment) {
        StrongSelf;
        if (count) {
            self.topBar.titleLabel.text = [NSString stringWithFormat:@"%ld条回复", count];
            [self.topBar.titleLabel sizeToFit];
        } else if (increment) {
            count = [self.topBar.titleLabel.text integerValue] + increment;
            self.topBar.titleLabel.text = [NSString stringWithFormat:@"%ld条回复", count];
            [self.topBar.titleLabel sizeToFit];
        }
    };

    _detailView.updateMomentCountBlock = ^(NSInteger count, NSInteger increment) {
        updateMomentCountBlock(count, increment);
    };

    void (^scrollViewDidScrollBlock)(UIScrollView *) = ^void(UIScrollView *scrollView) {
        StrongSelf;
        [self p_handleCommentViewDidScroll:scrollView];
    };
    _detailView.scrollViewDidScrollBlock = ^(UIScrollView *scrollView) {
        scrollViewDidScrollBlock(scrollView);
    };

    if ([self.replyMomentCommentModel conformsToProtocol:@protocol(TTVReplyModelProtocol)]) {
        [self p_insertLocalMomentCommentModel:self.replyMomentCommentModel];
    }

    [self.topBar.titleLabel sizeToFit];
    [TTVReplyView configGlobalCustomWidth:[self p_maxWidthForDetailView]];
    [self.view addSubview:_detailView];

    self.panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_handlePanGesture:)];
    self.panGes.delegate = self;
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:self.panGes];
    self.originY = self.view.top;

    [self p_loadMore];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSMutableDictionary *logDict = [NSMutableDictionary dictionary];
    [logDict setValue:self.commentModel.commentIDNum forKey:@"comment_id"];
    wrapperTrackEventWithCustomKeys(@"update_detail", @"enter_detail", self.commentModel.commentIDNum.stringValue, nil, nil);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_detailView didAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_detailView willDisappear];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _topBar.frame = CGRectMake(0, 0, self.view.width, kBarHeight);
    _detailView.frame = CGRectMake(0, _topBar.bottom, self.view.width, self.view.height - _topBar.height);
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [TTVReplyView configGlobalCustomWidth:[self p_maxWidthForDetailView]];
    } else {
        [TTVReplyView configGlobalCustomWidth:0];
    }
}

#pragma mark - Public Methods

#pragma mark - Private Methods

- (void)addKVO {

    if (!self.registeredKVO) {

        @weakify(self);
        [self.KVOController observe:self.viewModel keyPath:@"reloadFlag" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {

            @strongify(self);
            [self.detailView reloadListViewData];
            self.detailView.updateMomentCountBlock(self.viewModel.totalReplyItemsCount, 0);
        }];

        self.registeredKVO = YES;
    }
}

- (void)p_loadMore {

    if (![self.detailView.loadMoreCell isAnimating]) {
        [self.detailView.loadMoreCell startAnimating];
        [self.detailView.loadMoreCell hiddenLabel:YES];
    }

    if (_viewModel.curAllReplyItems.count) {
        wrapperTrackEvent(@"update_detail", @"replier_loadmore");
    }
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent() * 1000.f;
    @weakify(self);
    [_viewModel startLoadReplyListFinishBlock:^(NSError *error) {
        @strongify(self);
        CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent() * 1000.f;
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:error? @(error.code): nil forKey:@"err_code"];
        [extra setValue:error.localizedFailureReason forKey:@"err_reason"];
        [extra setValue:self.viewModel.commentModel.commentIDNum forKey:@"moment_id"];
        if (error) {
            [[TTMonitor shareManager] trackService:@"momentdetail_comment_finish_load" status:1 extra:extra];
        } else {
            [[TTMonitor shareManager] trackService:@"momentdetail_comment_finish_load" value:@(endTime - startTime) extra:extra];
        }
        self.viewModel.commentModel.replyCount = @(self.viewModel.totalReplyItemsCount);
        [self.detailView.loadMoreCell stopAnimating];
        [self.detailView.loadMoreCell hiddenLabel:NO];
    }];

    if (_viewModel.curAllReplyItems.count + _viewModel.curHotReplyItems.count > 0) {
        wrapperTrackEvent(@"profile", @"more_comment");
    }
}

- (void)p_getCommentDetailModel {
    @weakify(self);
    [_commentDetailService fetchCommentDetailWithCommentID:[self.commentModel.commentIDNum stringValue] finishBlock:^(TTCommentDetailModel *model, NSError *error) {
        @strongify(self);
        if (model) {
            self.commentDetailModel = model;

            id <TTCommentDetailModelProtocol> commentDetailModel = self.commentDetailModel ? self.commentDetailModel : self.commentModel;

            BOOL isBanForward = NO;
            if (commentDetailModel && [commentDetailModel respondsToSelector:@selector(banForwardToWeitoutiao)]) {
                isBanForward = [commentDetailModel banForwardToWeitoutiao].boolValue;
            }
            _detailView.isBanEmoji = commentDetailModel.banEmojiInput || self.isBanEmoji || self.isAdVideo || isBanForward;
        } else {
            NSDictionary *info = [error.userInfo valueForKey:@"tips"];
            if ([info isKindOfClass:[NSDictionary class]]) {
                NSString *tip = [info stringValueForKey:@"display_info" defaultValue:@""];
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:^(BOOL isUserDismiss) {
                }];
            }
        }
    }];
}

- (CGFloat)p_maxWidthForDetailView {
    return self.view.width;
}

- (void)p_dismissSelf:(UIButton *)sender {
    [self p_dismissSelf:sender animate:YES];
}

- (void)p_dismissSelf:(UIButton *)sender animate:(BOOL)animate {
    dispatch_block_t block = ^ {
        if ([_vcDelegate respondsToSelector:@selector(videoDetailFloatCommentViewControllerDidDimiss:)]) {
            [_vcDelegate videoDetailFloatCommentViewControllerDidDimiss:self];
        }
    };
    if (animate) {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.top = self.view.bottom;
        } completion:^(BOOL finished) {
            block();
        }];
    } else {
        block();
    }
}

- (void)p_handleCommentViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.y = 0;
        scrollView.contentOffset = contentOffset;
        if (!self.isDraggingFloatView) {
            self.isDraggingFloatView = YES;
        }
    }
    if (self.isDraggingFloatView && self.view.top != self.originY) {
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.y = 0;
        scrollView.contentOffset = contentOffset;
    }
}

- (void)p_handlePanGesture:(UIPanGestureRecognizer *)ges {
    CGPoint locationPoint = [ges locationInView:self.view.superview];
    CGPoint velocityPoint = [ges velocityInView:self.view.superview];
    BOOL flag = (self.detailView && self.detailView.commentListView.contentOffset.y <= 0);
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.lastY = locationPoint.y;
            if (velocityPoint.y > 0 && flag && !self.isDraggingFloatView) {
                self.isDraggingFloatView = YES;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {

            if (velocityPoint.y > 0 && flag && !self.isDraggingFloatView) {
                self.isDraggingFloatView = YES;
            }
            if (self.isDraggingFloatView) {
                CGFloat step = locationPoint.y - self.lastY;
                CGRect frame = self.view.frame;
                frame.origin.y += step;
                if (frame.origin.y < self.originY) {
                    frame.origin.y = self.originY;
                }
                if (frame.origin.y > self.view.superview.height) {
                    frame.origin.y = self.view.superview.height;
                }
                self.view.frame = frame;
            }
            self.lastY = locationPoint.y;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            if (self.isDraggingFloatView) {
                CGRect frame = self.view.frame;
                frame.origin.y = velocityPoint.y > 0 ? self.view.superview.height : self.originY;
                [UIView animateWithDuration:0.2 animations:^{
                    self.view.frame = frame;
                } completion:^(BOOL finished) {
                    if (velocityPoint.y > 0) {
                        [self p_dismissSelf:nil animate:NO];
                    }
                }];
            }
            self.isDraggingFloatView = NO;
        }
            break;
        default:
            break;
    }
}

#pragma mark - Actions

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGes) {
        CGPoint velocityPoint = [self.panGes velocityInView:self.view.superview];
        if (fabs(velocityPoint.x) > fabs(velocityPoint.y)) {
            return NO;
        }
        return YES;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (otherGestureRecognizer.view == self.detailView.commentListView) {
        return YES;
    }

    return NO;
}

#pragma mark private(cell)
- (void)p_enterProfileWithUserID:(NSString *)userID {
    
    // add by zjing 去掉个人主页跳转
    return;
    
    NSMutableDictionary *baseCondition = [[NSMutableDictionary alloc] init];
    [baseCondition setValue:userID forKey:@"uid"];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://profile"] userInfo:TTRouteUserInfoWithDict(baseCondition)];
}

- (void)p_replyCommentWithModel:(id <TTVReplyModelProtocol>)model switchToEmojiInput:(BOOL)switchToEmojiInput {

    BOOL (^handleBlock)(BOOL, BOOL) = ^(BOOL isBlocking, BOOL isBlocked){
        NSString * description = nil;
        if (isBlocked) {
            description = [[SSIndicatorTipsManager shareInstance] indicatorTipsForKey:kTipForActionToBlockedUser]? :@" 根据对方设置，您不能进行此操作";
        } else if (isBlocking) {
            description = [[SSIndicatorTipsManager shareInstance] indicatorTipsForKey:kTipForActionToBlockingUser]? :@"您已拉黑此用户，不能进行此操作";
        }
        if (!description) {
            return NO;
        }
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(description, nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return YES;
    };

    if (handleBlock(model.user.isBlocking, model.user.isBlocked)) {
        return;
    }
    if (handleBlock(model.user.isBlocking, model.user.isBlocked)) {
        return;
    }
    
    id<TTVCommentModelProtocol, TTCommentDetailModelProtocol> commentModel = self.commentModel;
    id<TTVReplyModelProtocol, TTCommentDetailReplyCommentModelProtocol> replyCommentModel = nil;
    if (model == nil || [model conformsToProtocol:@protocol(TTCommentDetailReplyCommentModelProtocol)]) {
        replyCommentModel = (id<TTVReplyModelProtocol, TTCommentDetailReplyCommentModelProtocol> )model;
    } else {
        NSAssert(NO, @"please check model class whether conforms to TTCommentDetailReplyCommentModelProtocol");
        return;
    }

    id<TTCommentDetailModelProtocol> commentDetailModel = self.commentDetailModel ? self.commentDetailModel : commentModel;


    NSString *fw_id = commentDetailModel.groupModel.itemID ?:commentDetailModel.groupModel.groupID;
    WeakSelf;
    TTCommentDetailReplyWriteManager *replyManager =  [[TTCommentDetailReplyWriteManager alloc] initWithCommentDetailModel:commentDetailModel replyCommentModel:replyCommentModel commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {
        *willRepostFwID = fw_id;
    } publishCallback:^(id<TTCommentDetailReplyCommentModelProtocol> replyModel, NSError *error) {
        StrongSelf;
        if (error) {
            return;
        }
        if (replyModel) {

            [self p_insertLocalMomentCommentModel:replyModel];

            //            if (self.detailView.updateMomentCountBlock) {
            //                self.detailView.updateMomentCountBlock(0, 1);
            //            }

            [[NSNotificationCenter defaultCenter] postNotificationName:ArticleMomentDetailViewAddMomentNoti object:nil userInfo:@{@"increment":@(1), @"groupID":[NSString stringWithFormat:@"%@", self.commentModel.groupModel.groupID]}];
        }
    } getReplyCommentModelClassBlock:^Class{
        if (replyCommentModel != nil && [replyCommentModel respondsToSelector:@selector(initWithDictionary:error:)]) {
            return [replyCommentModel class];
        } else {
            return [TTVReplyModel class];
        }

    } commentRepostWithPreRichSpanText:nil commentSource:nil];

    self.replyWriteView = [[TTCommentWriteView alloc] initWithCommentManager:replyManager];

    if (self.isAdVideo) {
        self.replyWriteView.banCommentRepost = YES;
    }

    self.replyWriteView.emojiInputViewVisible = switchToEmojiInput;
    self.replyWriteView.banEmojiInput = commentDetailModel.banEmojiInput || self.isBanEmoji;

    [self.replyWriteView showInView:self.view animated:YES];

}

- (void)p_deleteReplyComment {
    BOOL deleteSelfComment = NO;
    NSString *selfUID = [TTAccountManager userID];
    if (!isEmptyString(selfUID)) {
        if ([_needDeleteCommentModel.user.ID isEqualToString:selfUID]) { //自己的评论
            deleteSelfComment = YES;
        }
    }
    NSMutableDictionary *trackDict = [NSMutableDictionary new];
    [trackDict setValue:self.viewModel.commentModel.groupModel.groupID forKey:@"group_id"];
    [trackDict setValue:_needDeleteCommentModel.commentID forKey:@"comment_id"];
    [trackDict setValue:deleteSelfComment?@"own":@"others" forKey:@"comment_type"];
    [TTTrackerWrapper eventV3:@"comment_delete" params:trackDict];

    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"确定删除此评论?", nil) delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认删除" otherButtonTitles:nil, nil];
    sheet.tag = kDeleteCommentActionSheetTag;
    [sheet showInView:self.view];
}

- (void)p_insertLocalMomentCommentModel:(id <TTVReplyModelProtocol>)model
{
    if (![model conformsToProtocol:@protocol(TTVReplyModelProtocol)]) {

        return ;
    }

    [_viewModel addToTopWithReplyModel:model];
}

- (void)p_deleteLocalCommentModel:(id <TTVReplyModelProtocol>)model {

    if (![model conformsToProtocol:@protocol(TTVReplyModelProtocol)]) {

        return ;
    }

    [_viewModel removeReplyItemWithReplyModel:model];
}

- (void)p_diggButtonPressed{
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络连接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }

    if ([self.commentModel userDigged])
    {
        self.commentModel.userDigged = NO;
        self.commentModel.digCount = @(self.commentModel.digCount.integerValue - 1);
        DetailActionRequestManager *commentActionManager = [[DetailActionRequestManager alloc] init];
        TTDetailActionReuestContext *requestContext = [[TTDetailActionReuestContext alloc] init];
        requestContext.itemCommentID = [self.commentModel.commentIDNum stringValue];
        requestContext.groupModel = self.commentModel.groupModel;
        [commentActionManager setContext:requestContext];
        [commentActionManager startItemActionByType:DetailActionCommentUnDigg];

        if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(videoDetailFloatCommentViewControllerDidChangeDigCount)]) {
            [self.vcDelegate videoDetailFloatCommentViewControllerDidChangeDigCount];
        }

        [self.detailView.toolBar.digButton setSelected:NO];
    }
    else{

        self.commentModel.userDigged = YES;
        self.commentModel.digCount = @(self.commentModel.digCount.integerValue + 1);
        DetailActionRequestManager *commentActionManager = [[DetailActionRequestManager alloc] init];
        TTDetailActionReuestContext *requestContext = [[TTDetailActionReuestContext alloc] init];
        requestContext.itemCommentID = [self.commentModel.commentIDNum stringValue];
        requestContext.groupModel = self.commentModel.groupModel;
        [commentActionManager setContext:requestContext];
        [commentActionManager startItemActionByType:DetailActionCommentDigg];

        if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(videoDetailFloatCommentViewControllerDidChangeDigCount)]) {
            [self.vcDelegate videoDetailFloatCommentViewControllerDidChangeDigCount];
        }

        [self.detailView.toolBar.digButton setSelected:YES];
    }
}

#pragma mark - UI

#pragma mark - SSActivityViewDelegate
- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    if (view == _phoneShareView) {
        TTShareSourceObjectType sourceType = TTShareSourceObjectTypeMoment;
        [_activityActionManager performActivityActionByType:itemType inViewController:[TTUIResponderHelper topViewControllerFor: self] sourceObjectType:sourceType uniqueId:self.commentDetailModel.groupModel.groupID];
        self.phoneShareView = nil;
    }
}

#pragma mark -- UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kDeleteCommentActionSheetTag) {
        if ([_needDeleteCommentModel.commentID longLongValue] != 0 &&
            buttonIndex != actionSheet.cancelButtonIndex) {
            if (!TTNetworkConnected()) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络连接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
            else {
                BOOL deleteSelfComment = NO;
                NSString *selfUID = [TTAccountManager userID];
                if (!isEmptyString(selfUID)) {
                    if ([_needDeleteCommentModel.user.ID isEqualToString:selfUID]) { //自己的评论
                        deleteSelfComment = YES;
                    }
                }
                NSMutableDictionary *trackDict = [NSMutableDictionary new];
                [trackDict setValue:self.viewModel.commentModel.groupModel.groupID forKey:@"group_id"];
                [trackDict setValue:_needDeleteCommentModel.commentID forKey:@"comment_id"];
                [trackDict setValue:deleteSelfComment?@"own":@"others" forKey:@"comment_type"];
                [TTTrackerWrapper eventV3:@"comment_delete_confirm" params:trackDict];

                if (deleteSelfComment) {
                    [_viewModel deleteReplyedComment:_needDeleteCommentModel.commentID InHostComment:[self.commentModel commentIDNum].stringValue];
                } else {
//                    [[FRForumServer sharedInstance_tt] authorDeleteReply:_needDeleteCommentModel.commentID.longLongValue commentID:[self.commentModel commentIDNum].longLongValue finish:nil];
                }
                if (_needDeleteCommentModel) {
                    if (self.sourceType == ArticleMomentSourceTypeMoment) {
                        wrapperTrackEvent(@"delete", @"reply_update");
                    } else if (self.sourceType == ArticleMomentSourceTypeForum) {
                        wrapperTrackEvent(@"delete", @"reply_post");
                    } else if (self.sourceType == ArticleMomentSourceTypeProfile) {
                        wrapperTrackEvent(@"delete", @"reply_profile");
                    }

                    [self p_deleteLocalCommentModel:_needDeleteCommentModel];

                    [[NSNotificationCenter defaultCenter] postNotificationName:ArticleMomentDetailViewAddMomentNoti object:nil userInfo:@{@"increment":@(-1), @"groupID":[NSString stringWithFormat:@"%@", self.commentModel.groupModel.groupID]}];
                    if (!([self.detailView.commentListView visibleCells].count > 0) && self.detailView.dismissBlock) {
                        self.detailView.dismissBlock();
                    }
                }
            }
        }
        self.needDeleteCommentModel = nil;
    }
}

#pragma mark - TTVReplyListCellDelegate

- (void)replyListCell:(UITableViewCell *)view replyButtonClickedWithModel:(id<TTVReplyModelProtocol>)model {

    [self p_replyCommentWithModel:model switchToEmojiInput:NO];

    return;
}

- (void)replyListCell:(UITableViewCell *)view avatarTappedWithModel:(id<TTVReplyModelProtocol>)model {

    [self p_enterProfileWithUserID:model.user.ID];
}

- (void)replyListCell:(UITableViewCell *)view deleteCommentWithModel:(id<TTVReplyModelProtocol>)model {

    wrapperTrackEvent(@"update_detail", @"delete");

    self.needDeleteCommentModel = model;
    [self p_deleteReplyComment];
}

- (void)replyListCell:(UITableViewCell *)view digCommentWithModel:(id<TTVReplyModelProtocol>)model {

    if (model.userDigg) {

        [_viewModel handleReplyCommentDigWithCommentID:[self.commentModel commentIDNum].stringValue replayID:model.commentID ifDigg:YES finishBlock:^(NSError *error) {

            if (!error) {

                model.userDigg = NO;
            }
        }];

        if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(videoDetailFloatCommentViewCellDidDigg:withModel:)]) {
            [self.vcDelegate videoDetailFloatCommentViewCellDidDigg:NO withModel:model];
        }

    } else {

        [_viewModel handleReplyCommentDigWithCommentID:[self.commentModel commentIDNum].stringValue replayID:model.commentID finishBlock:^(NSError *error) {

            if (!error) {

                model.userDigg = YES;
            }
        }];

        if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(videoDetailFloatCommentViewCellDidDigg:withModel:)]) {
            [self.vcDelegate videoDetailFloatCommentViewCellDidDigg:YES withModel:model];
        }

    }
}

- (void)replyListCell:(UITableViewCell *)view nameViewonClickedWithModel:(id<TTVReplyModelProtocol>)model {

    [self p_enterProfileWithUserID:model.user.ID];
}

- (void)replyListCell:(UITableViewCell *)view quotedNameOnClickedWithModel:(id<TTVReplyModelProtocol>)model {
    [self p_enterProfileWithUserID:model.tt_qutoedCommentStructModel.user_id.stringValue];
}

#pragma mark - TTVReplyViewDelegate
- (void)replyView:(TTVReplyView *)replyView commentButtonClicked:(id)sender {

    BOOL switchToEmojiInput = (sender == self.detailView.toolBar.emojiButton);
    [self p_replyCommentWithModel:nil switchToEmojiInput:switchToEmojiInput];
}

- (void)replyView:(TTVReplyView *)replyView userInfoDiggButtonClicked:(id)sender {

    [self p_diggButtonPressed];
}

- (void)replyView:(TTVReplyView *)replyView loadMoreCellTrigger:(TTVReplyViewLoadMoreCellTriggerSource)triggerSource
{
    [self p_loadMore];
}

@end
