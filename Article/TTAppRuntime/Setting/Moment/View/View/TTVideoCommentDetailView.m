//
//  ArticleMomentDetailView.m
//  Article
//
//  Created by Zhang Leonardo on 14-5-26.
//
//

#import "ArticleMomentDetailView.h"
#import "TTVideoCommentDetailView.h"
#import "ArticleTitleImageView.h"
#import "SSUserModel.h"
#import "ArticleAvatarView.h"
#import "TTImageView.h"
#import "SSThemed.h"
#import "ArticleMomentCommentModel.h"
#import "ArticleMomentCommentManager.h"
#import "SSLoadMoreCell.h"
#import "ArticleMomentHelper.h"
#import "ArticleMomentDigUsersViewController.h"
#import "ArticleCommentView.h"
#import "UIImageAdditions.h"
#import "ArticleMomentManager.h"
#import "ArticleMomentGroupModel.h"
#import "NetworkUtilities.h"
#import "SSAttributeLabel.h"
#import "SSNavigationBar.h"
#import "ExploreLogicSetting.h"
#import "ArticleURLSetting.h"
#import <TTAccountBusiness.h>
#import "TTUserInfoView.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "UIButton+TTAdditions.h"
#import "ExploreMomentListCellHeaderItem.h"
#import "SSMotionRender.h"
#import "DetailActionRequestManager.h"
#import "ExploreDeleteManager.h"
#import "SSIndicatorTipsManager.h"
#import "TTActivityShareManager.h"
#import "SSActivityView.h"
#import "ArticleShareManager.h"
#import "SSCommentManager.h"
#import "TTThemedAlertController.h"
#import "TTIndicatorView.h"
#import <FRPostCommonButton.h>
#import "ArticleMomentDiggManager.h"
#import "ArticleForwardViewController.h"

#import "TTReportManager.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceUIUtils.h"

#import "TTBusinessManager+StringUtils.h"
#import "TTStringHelper.h"
#import "TTLabelTextHelper.h"
#import "TTActionSheetController.h"
#import "TTAsyncLabel.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreMixListDefine.h"
#import "Comment.h"
#import "TTArticleCategoryManager.h"
//#import "TTRepostViewController.h"
//#import "TTRepostOriginModels.h"
//#import "FRThreadSmartDetailManager.h"
#import "TTCommentDetailModel.h"
#import "TTCommentDetailCell.h"
#import "TTCommentWriteView.h"
#import "TTCommentDetailModel+TTCommentDetailModelProtocolSupport.h"
#import "TTCommentDetailReplyCommentModel+TTCommentDetailReplyCommentModelProtocolSupport.h"
#import "TTActivityShareSequenceManager.h"

#define kCellElementBgColorKey kColorBackground4

#define kToReplyUserNameIndex 2
#define kCommentIndex 3

#define kReplyText NSLocalizedString(@"回复", nil)
#define kColonText @":"
//留白高度
#define kLikeViewBGTopGap                   [TTDeviceUIUtils tt_paddingForMoment:20]
#define kLikeViewFirstAvatarViewLeftPadding [TTDeviceUIUtils tt_paddingForMoment:15]
#define kLikeViewArrowViewRightPadding      [TTDeviceUIUtils tt_paddingForMoment:15]
#define kLikeViewTopMargin                  [TTDeviceUIUtils tt_paddingForMoment:15]
#define kLikeViewBottomMargin               [TTDeviceUIUtils tt_paddingForMoment:15]
#define kLikeViewAvatarViewWidth            [TTDeviceUIUtils tt_paddingForMoment:36]
#define kLikeViewAvatarViewHeight           [TTDeviceUIUtils tt_paddingForMoment:36]
#define kLikeViewArrowViewLeftPadding       [TTDeviceUIUtils tt_paddingForMoment:3]
#define kLikeViewAvatarViewGap              [TTDeviceUIUtils tt_paddingForMoment:6]
#define kLikeViewLastAvatarViewRightPadding [TTDeviceUIUtils tt_paddingForMoment:130]
#define kLikeViewShowArrowMinNumber         1
#define kLikeViewBGHeight                   (kLikeViewTopMargin + kLikeViewAvatarViewHeight + kLikeViewBottomMargin)
#define kLikeViewHeight                     kLikeViewBGTopGap + kLikeViewBGHeight

#define kLoadOnceCount 20
#define kPostCommentViewHeight 40

#define kCellAvatarViewWidth                [TTDeviceUIUtils tt_paddingForMoment:36]
#define kCellAvatarViewHeight               [TTDeviceUIUtils tt_paddingForMoment:36]
#define kCellAvatarViewLeftPadding          [TTDeviceUIUtils tt_paddingForMoment:15]
#define kCellAvatarViewRightPadding         [TTDeviceUIUtils tt_paddingForMoment:9]
#define kCellAvatarViewTopPadding           [TTDeviceUIUtils tt_paddingForMoment:14]

#define kCellNameLabelTopPadding            [TTDeviceUIUtils tt_paddingForMoment:16]
#define kCellNameLabelFontSize              [TTDeviceUIUtils tt_fontSizeForMoment:16]
#define kCellNameLabelBottomPadding         [TTDeviceUIUtils tt_paddingForMoment:6]
#define kCellDescLabelFontSize              [TTDeviceUIUtils tt_fontSizeForMoment:17]
#define kCellTimeLabelFontSize              [TTDeviceUIUtils tt_fontSizeForMoment:12]

#define kCellDescLabelBottomPadding         [TTDeviceUIUtils tt_paddingForMoment:3]
#define kCellBottomPadding                  [TTDeviceUIUtils tt_paddingForMoment:14]


#define kCellRightPadding                   [TTDeviceUIUtils tt_paddingForMoment:15]
#define kUserInfoViewRightPadding           [TTDeviceUIUtils tt_newPadding:45.f]
#define kDigButtonWidth 60
#define kDigButtonHeight 30

#define kDeleteCommentActionSheetTag 10
#define kSectionHeaderHeight                [TTDeviceUIUtils tt_paddingForMoment:40]

#define kDescLineMultiple 0.1f
////////////////////////////////////////////////////////////
#pragma mark - 发评论按钮

extern BOOL ttvs_isShareIndividuatioEnable(void);
static CGFloat globalCustomWidth = 0;
CGRect tt_splitViewFrameForView(UIView *view);
CGRect tt_splitViewFrameForView(UIView *view)
{
    CGRect frame = [TTUIResponderHelper splitViewFrameForView:view];
    if (globalCustomWidth > 0) {
        frame.origin.x = (view.width - globalCustomWidth) / 2;
        frame.size.width = globalCustomWidth;
    }
    return frame;
}

extern CGFloat fr_postCommentButtonHeight(void);

#pragma mark - 详情

@interface TTVideoCommentDetailView()<UITableViewDelegate , UITableViewDataSource, UIActionSheetDelegate, TTCommentDetailCellDelegate, SSActivityViewDelegate>
{
    NSTimeInterval _midnightInterval;
    BOOL _hasMore;
}
@property(nonatomic, assign, readwrite)ArticleMomentSourceType sourceType;
@property(nonatomic, strong)ArticleMomentCommentManager * manager;

@property(nonatomic, strong)ArticleMomentManager * momentManager;
@property (nonatomic, strong)SSNavigationBar    *navigationBar;
@property (nonatomic, strong)ArticleCommentView *commentView;
@property (nonatomic, strong)TTCommentDetailReplyCommentModel *needDeleteCommentModel;
@property (nonatomic, strong)SSLoadMoreCell * loadMoreCell;

@property(nonatomic, strong)TTActivityShareManager *activityActionManager;
@property(nonatomic, strong)SSActivityView *phoneShareView;
@property(nonatomic, strong)ArticleMomentCommentModel *replyMomentCommentModel;
@property(nonatomic, assign)BOOL showWriteComment;
@property(nonatomic, strong)FRPostCommonButton *postCommonButton;

@property(nonatomic, assign) BOOL isSelfDeleted; //自己是否被删除
//发表评论前没有登录，登录后发表了，用这个字段标记
@property(nonatomic, assign) NSInteger publishStatusForTrack; //0为初始值，1表示发送了unlog埋点,2表示发送了unlog_done埋点
// 统计用 作者的mediaId，uid
@property(nonatomic, copy)NSString *mediaId;
@property(nonatomic, copy)NSString *commentId;
@property(nonatomic, copy)NSString *gid;

@property(nonatomic, assign)BOOL isViewAppear;
@property(nonatomic, assign)BOOL fromVideoDetail;


@property (nonatomic, strong) Thread *thread;
@property (nonatomic, strong) Thread *originThread;
@property (nonatomic, strong) Article *originArticle;
//@property (nonatomic, assign) TTThreadRepostType repostType;
//@property (nonatomic, assign) TTThreadRepostOriginType repostOriginType;

@property (nonatomic, strong) NSString *authorID;
@property (nonatomic, assign) BOOL fromMessage;
@property (nonatomic, assign) NSInteger groupSource;

@end

@implementation TTVideoCommentDetailView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.commentView) {
        self.commentView.delegate = nil;
    }
    self.commentView = nil;
    self.momentManager = nil;
    [self refreshMomentModel:nil];
    
    self.manager = nil;
    self.commentListView = nil;
    self.navigationBar = nil;
    self.needDeleteCommentModel = nil;
    self.loadMoreCell = nil;
    self.postCommonButton = nil;
    self.delegate = nil;
}

- (id)initWithFrame:(CGRect)frame
        momentModel:(ArticleMomentModel *)model
articleMomentManager:(ArticleMomentManager *)manager
         sourceType:(ArticleMomentSourceType)sourceType
replyMomentCommentModel:(ArticleMomentCommentModel *)replyMomentCommentModel
   showWriteComment:(BOOL)show
{
    self = [super initWithFrame:frame];
    if (self) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:model.ID forKey:@"id"];
        
        self.showWriteComment = show;

        if ([TTAccountManager isLogin]) {
            [TTTrackerWrapper category:@"umeng" event:[self umengEventName] label:@"enter" dict:dict];
        }
        else {
            [TTTrackerWrapper category:@"umeng" event:[self umengEventName] label:@"enter_logoff" dict:dict];
        }
        
        self.sourceType = sourceType;
        
        self.replyMomentCommentModel = replyMomentCommentModel;
        
        self.manager = [[ArticleMomentCommentManager alloc] initWithMomentID:model.ID isNewComment:NO isFromeComment:NO];
        
        [self commonInitialization];
        
        [self refreshMomentModel:model];
        [self refreshHeaderView];
        
        [self loadMore];
        
        //强制刷新
        if (manager == nil) {
            self.momentManager = [[ArticleMomentManager alloc] init];
        }
        else {
            self.momentManager = manager;
        }
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent() * 1000.f;
        [_momentManager startGetMomentDetailWithID:_momentModel.ID sourceType:sourceType modifyTime:_momentModel.modifyTime finishBlock:^(ArticleMomentModel *model, NSError *error) {
            CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent() * 1000.f;
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:error? @(error.code): nil forKey:@"err_code"];
            [extra setValue:error.localizedFailureReason forKey:@"err_reason"];
            [extra setValue:model.ID forKey:@"moment_id"];
            if (!error) {
                [self refreshMomentModel:model];
                [self refreshHeaderView];
                [self notifyDeleteIfNeed];
                [self refreshBottomSendMomentButtonTitle];
                [self refreshDiggButtonStatus];
                [[TTMonitor shareManager] trackService:@"momentdetail_detail_finish_load" value:@(endTime - startTime) extra:extra];
                [[TTMonitor shareManager] trackService:@"momentdetail_detail_status" status:0 extra:extra];
            } else {
                [[TTMonitor shareManager] trackService:@"momentdetail_detail_status" status:1 extra:extra];
                NSDictionary *info = [error.userInfo valueForKey:@"tips"];
                if ([info isKindOfClass:[NSDictionary class]]) {
                    NSString *tip = [info stringValueForKey:@"display_info" defaultValue:@""];
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:^(BOOL isUserDismiss) {
                        if (self.fromVideoDetail) {
                            [self backButtonClicked];
                        }
                    }];
                }
            }
        }];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
        momentModel:(ArticleMomentModel *)model
articleMomentManager:(ArticleMomentManager *)manager
         sourceType:(ArticleMomentSourceType)sourceType
{
    return [self initWithFrame:frame momentModel:model articleMomentManager:manager sourceType:sourceType replyMomentCommentModel:nil showWriteComment:NO];
}

- (id)initWithFrame:(CGRect)frame
          commentId:(int64_t)commentId
        momentModel:(ArticleMomentModel *)momentModel
           delegate:(id<ExploreMomentListCellUserActionItemDelegate>)delegate
   showWriteComment:(BOOL)show
    fromVideoDetail:(BOOL)fromVideoDetail
        fromMessage:(BOOL)fromMessage
{
    self = [super initWithFrame:frame];
    if (self) {
        self.fromMessage = fromMessage;
        
        self.mediaId = momentModel.mediaId;
        self.commentId = [NSString stringWithFormat:@"%lld", commentId];
        self.gid = momentModel.gid;
        
        self.sourceType = ArticleMomentSourceTypeArticleDetail;
        self.showWriteComment = show;
        self.fromVideoDetail = fromVideoDetail;
        [self commonInitialization];
        
        //preload
        [self loadHeaderViewForMomentModel:momentModel delegate:delegate];
        
        self.manager = [[ArticleMomentCommentManager alloc] initWithMomentID:momentModel.ID isNewComment:NO isFromeComment:NO];
        
//        [self loadMore];
        
        //update
        self.momentManager = [[ArticleMomentManager alloc] init];
        [_momentManager startGetMomentDetailWithID: @(commentId).stringValue
                                        sourceType:ArticleMomentSourceTypeArticleDetail
                                        modifyTime:0
                                       finishBlock:^(ArticleMomentModel *model, NSError *error) {
                                           if (!error && model) {
                                               [self refreshMomentDetailViewWithModel:model delegate:delegate];
                                               [self refreshDiggButtonStatus];
                                               [self showWriteCommentIfNeed];
                                               
                                               if (self.updateMomentCountBlock && model.commentsCount) {
                                                   self.updateMomentCountBlock(model.commentsCount, 0);
                                               }
                                               
                                               [[NSNotificationCenter defaultCenter] postNotificationName:ArticleMomentDetailViewAddMomentNoti object:nil userInfo:@{@"count":@(model.commentsCount), @"groupID":[NSString stringWithFormat:@"%@", self.gid]}];
//                                               [self requestThreadDetailInfoIfNeed];
                                           } else {
                                               [self.loadMoreCell stopAnimating];
                                               _hasMore = NO;
                                               [self.loadMoreCell hiddenLabel:YES];
//                                               [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"加载失败", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                                           }
                                       }];
    }
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@(commentId).stringValue forKey:@"comment_id"];
    [param setValue:@"5" forKey:@"source"];
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting commentDetailURLString] params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (error) {
            return;
        }
        StrongSelf;
        TTCommentDetailModel *model = [[TTCommentDetailModel alloc] initWithDictionary:jsonObj[@"data"] error:nil];
        self.authorID = model.authorID;
        self.groupSource = model.groupSource;
    }];
    return self;
}

//- (void)requestThreadDetailInfoIfNeed {
//    if (self.momentModel.itemType == MomentItemTypeArticle && self.momentModel.group.groupType == ArticleMomentGroupThread) {
//        int64_t userID = [TTAccountManager userIDLongInt];
//        WeakSelf;
//        if ([self.momentModel.group.itemID longLongValue] <= 0) {
//            return;
//        }
//        [FRThreadSmartDetailManager requestDetailInfoWithThreadID:[self.momentModel.group.itemID longLongValue] userID:userID callback:^(NSError * _Nullable error, NSObject<TTResponseModelProtocol> * _Nullable responseModel, FRForumMonitorModel *_Nullable monitorModel) {
//            if ([responseModel isKindOfClass:[FRUgcThreadDetailV2InfoResponseModel class]]) {
//                StrongSelf;
//                FRUgcThreadDetailV2InfoResponseModel * response = (FRUgcThreadDetailV2InfoResponseModel *)responseModel;
//                self.thread = [Thread generateThreadWithModel:response.thread];
//                self.thread.contentRichSpanJSONString = response.content_rich_span;
//                [self.thread save];
//                self.repostType = [response.repost_type integerValue];
//                self.repostOriginType = TTThreadRepostOriginTypeNone;
//                if (response.origin_group) {
//                    self.repostOriginType = TTThreadRepostOriginTypeArticle;
//                    NSString *primaryID = [Article primaryIDByUniqueID:[response.origin_group.group_id longLongValue] itemID:[response.origin_group.item_id stringValue] adID:nil];
//                    Article *originArticle = [Article updateWithDictionary:[response.origin_group toDictionary] forPrimaryKey:primaryID];
//                    originArticle.itemID = [response.origin_group.item_id stringValue];
//                    [originArticle save];
//                    self.originArticle = originArticle;
//                }
//                if (response.origin_thread) {
//                    self.repostOriginType = TTThreadRepostOriginTypeThread;
//                    NSString *originThreadId = [response.origin_thread.thread_id stringValue];
//                    //被转发原贴要传转发贴的primaryID
//                    Thread *originThread = [Thread updateWithDictionary:[response.origin_thread toDictionary] threadId:originThreadId parentPrimaryKey:self.thread.threadPrimaryID];
//                    self.originThread = originThread;
//                }
//            }
//        }];
//    }
//}

- (void)didAppear
{
    [super didAppear];
    _isViewAppear = YES;
    [self performSelector:@selector(markShowCommentViewTimeout) withObject:nil afterDelay:0.4];
    [self showWriteCommentIfNeed];
}

- (void)willDisappear{
    [super willDisappear];
    _isViewAppear = NO;
    
    //如果已经被删除 return @zengruihuan
    if (self.isSelfDeleted) {
        return;
    }
    
    [ArticleMomentManager postSyncNotificationWithMoment:self.momentModel commentCount:@([[self.manager comments] count] + [[self.manager hotComments] count])];
    if ([self.delegate respondsToSelector:@selector(didDigMoment:)]) {
        [self.delegate didDigMoment:self.momentModel];
    }
}

- (void)markShowCommentViewTimeout {
    _showWriteComment = NO;
    _showComment = NO;
}

- (void)refreshDiggButtonStatus{
    [_postCommonButton.diggButton setSelected:_momentModel.digged];
}

- (void)showWriteCommentIfNeed {
    if (_showWriteComment && !isEmptyString(self.momentModel.ID) && _isViewAppear) {
        _showWriteComment = NO;
        [self commentButtonClicked:_postCommonButton.button];
    }
}

- (void)scrollCommentIfNeed {
    if (_showComment&& !isEmptyString(self.momentModel.ID) && _isViewAppear){
        _showComment = NO;
        
        WeakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            StrongSelf;
            UITableView *commentView = self.commentListView;
            
            CGFloat scrollThrougthContentOffset = MIN(commentView.contentSize.height - commentView.height + commentView.contentInset.bottom, commentView.tableHeaderView.height - commentView.contentInset.top);
            if (scrollThrougthContentOffset > 0) {
                [commentView setContentOffset:CGPointMake(0, scrollThrougthContentOffset) animated:YES];
            }
        });
    }
}

- (void)refreshBottomSendMomentButtonTitle
{
    NSString * title = nil;
    if (self.replyMomentCommentModel) {
        title = [NSString stringWithFormat:@"回复 %@：", self.replyMomentCommentModel.user.name];
    } else {
        title = [SSCommonLogic exploreDetailToolBarWriteCommentPlaceholderText];
    }
    
    [self.postCommonButton setPlaceholderContent:title];
}

- (void)commonInitialization
{
    _hasMore = YES;
    UITableViewStyle style = _fromVideoDetail ? UITableViewStyleGrouped : UITableViewStylePlain;
    self.commentListView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationBar.frame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(self.navigationBar.frame)) style:style];
    self.commentListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _commentListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _commentListView.delegate = self;
    _commentListView.dataSource = self;
    _commentListView.contentInset = UIEdgeInsetsMake(0, 0, kPostCommentViewHeight, 0);
    _commentListView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, kPostCommentViewHeight, 0);
    [self addSubview:_commentListView];
    
    
    NSString * title = nil;;
    if (self.replyMomentCommentModel) {
        title = [NSString stringWithFormat:@"回复 %@...", self.replyMomentCommentModel.user.name];
    } else {
        title = [SSCommonLogic exploreDetailToolBarWriteCommentPlaceholderText];
    }
    
    
    // post common button
    __weak typeof(self) weakSelf = self;
    self.postCommonButton = [[FRPostCommonButton alloc] initWithFrame:CGRectMake(0, (self.height) - fr_postCommentButtonHeight(), self.width, fr_postCommentButtonHeight())];
    _postCommonButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_postCommonButton setPlaceholderContent:NSLocalizedString(@"写评论...", nil)];
    _postCommonButton.postCommentButtonClick = ^(){
        [weakSelf commentButtonClicked:weakSelf.postCommonButton.button];
    };
    _postCommonButton.emojiButtonClick = ^(){
        [weakSelf commentButtonClicked:weakSelf.postCommonButton.emojiButton];
    };
    _postCommonButton.diggButtonClick = ^(){
        [weakSelf commentDiggButtonClicked];
    };
    _postCommonButton.shareButtonClick = ^(){
        [weakSelf shareButtonPressed];
    };
    
    [self addSubview:_postCommonButton];
    
    [self reloadThemeUI];
    
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"没有网络连接", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSizeChanged:) name:kSettingFontSizeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMomentCommentNeedDeleteNotification:) name:kDeleteMomentCommentNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDeleteMomentNotification:) name:kDeleteMomentNotificationKey object:nil];
}

- (ExploreMomentListCellHeaderItem *)getDetailViewHeaderItem
{
    return nil;
}

- (void)receiveMomentCommentNeedDeleteNotification:(NSNotification *)notification
{
    NSNumber * cid = [[notification userInfo] objectForKey:@"cid"];
    NSNumber * mid = [[notification userInfo] objectForKey:@"mid"];
    if ( [mid longLongValue] == 0 || [cid longLongValue] == 0 || [mid longLongValue] != [self.momentModel.ID longLongValue]) {
        return;
    }
    ArticleMomentCommentModel * model = [_manager commentModelForID:[NSString stringWithFormat:@"%@", cid]];
    if (model) {
        [_manager deleteComment:model];
        [_commentListView reloadData];
    }
}

- (void)fontSizeChanged:(NSNotification *)notification
{
    [self refreshHeaderView];
    [self.commentListView reloadData];
}

- (void)notifyDeleteIfNeed
{
    if (_momentModel.isDeleted && _momentModel.ID) {
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:_momentModel.ID, @"momentID", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMomentDidDeleteNotification object:nil userInfo:userInfo];
    }
}

- (void)receiveDeleteMomentNotification:(NSNotification *)notification
{
    long long momengID = [[[notification userInfo] objectForKey:@"id"] longLongValue];
    if (momengID == 0) {
        return;
    }
    
    //只有评论浮层会赋值该block
    if (self.dismissBlock && momengID == [_momentModel.ID longLongValue]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kDeleteMomentNotificationKey object:nil];
        self.dismissBlock();
        return;
    }
    UINavigationController *navController = [TTUIResponderHelper topNavigationControllerFor: self];
    if (navController.topViewController == self.viewController) {
        if (momengID == [_momentModel.ID longLongValue]) {
            self.isSelfDeleted = YES;
            // 避免收到多个通知
            [[NSNotificationCenter defaultCenter] removeObserver:self name:kDeleteMomentNotificationKey object:nil];
            
            //            [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteCommentNotificationKey object:self userInfo:nil];
            [self backButtonClicked];
        }
    }
}

- (void)refreshMomentModel:(ArticleMomentModel *)model
{
    if (_momentModel != model) {
        [_momentModel removeObserver:self forKeyPath:@"diggUsers"];
        [_momentModel removeObserver:self forKeyPath:@"commentsCount"];
        
        model.digged = _momentModel.digged || model.digged;
        model.diggsCount = MAX(_momentModel.diggsCount, model.diggsCount);
        
        self.momentModel = model;
        if (!isEmptyString(model.group.ID) && self.commentView.extraTrackDict && ![self.commentView.extraTrackDict objectForKey:@"value"]) {
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithDictionary:self.commentView.extraTrackDict];
            [extraDict setValue:model.group.ID forKey:@"value"];
            self.commentView.extraTrackDict = extraDict;
        }
        
        [_momentModel addObserver:self forKeyPath:@"diggUsers" options:NSKeyValueObservingOptionNew context:nil];
        [_momentModel addObserver:self forKeyPath:@"commentsCount" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)refreshMomentDetailViewWithModel:(ArticleMomentModel *)model delegate:(id<ExploreMomentListCellUserActionItemDelegate>)delegate
{
    if (!self.manager) {
        self.manager = [[ArticleMomentCommentManager alloc] initWithMomentID:model.ID isNewComment:NO isFromeComment:NO];
    }
    
    _manager.momentID = model.ID;
    
    [self loadHeaderViewForMomentModel:model delegate:delegate];
    [self notifyDeleteIfNeed];
}

- (void)loadHeaderViewForMomentModel:(ArticleMomentModel *)model delegate:(id<ExploreMomentListCellUserActionItemDelegate>)delegate
{
    [self refreshMomentModel:model];
    [self refreshHeaderView];
    self.delegate = delegate;
}

- (void)refreshHeaderView
{
    
}

- (void)reloadListViewData
{
    [self reloadThemeUI];
    [_commentListView reloadData];
}

- (void)reloadArticleCommentListIfNeeded
{
    UIResponder *needResponder = [self _needResponder];
    if ([needResponder respondsToSelector:NSSelectorFromString(@"commentManager")]) {
        SSCommentManager *commentManager = [needResponder valueForKey:@"commentManager"];
        [commentManager reloadCommentWithTagIndex:commentManager.curTabIndex];
    }
}

- (void)loadMore
{
    if (![self.loadMoreCell isAnimating]) {
        [self.loadMoreCell startAnimating];
        [self.loadMoreCell hiddenLabel:YES];
    }
    
    __weak typeof(self) weakSelf = self;
    if (self.manager.comments.count){
        wrapperTrackEvent(@"update_detail", @"replier_loadmore");
    }
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent() * 1000.f;
    [_manager fetchCommentDetailListWithCommentID:self.commentId count:kLoadOnceCount width:tt_splitViewFrameForView(self).size.width finishBlock:^(NSArray *result, NSArray *hotComments, BOOL hasMore, NSInteger totalCount, NSError *error) {
        CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent() * 1000.f;
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:error? @(error.code): nil forKey:@"err_code"];
        [extra setValue:error.localizedFailureReason forKey:@"err_reason"];
        [extra setValue:weakSelf.manager.momentID forKey:@"moment_id"];
        if (error) {
            [[TTMonitor shareManager] trackService:@"momentdetail_comment_finish_load" status:1 extra:extra];
        } else {
            [[TTMonitor shareManager] trackService:@"momentdetail_comment_finish_load" value:@(endTime - startTime) extra:extra];
        }
        
        [self.loadMoreCell stopAnimating];
        [self.loadMoreCell hiddenLabel:NO];
        
        _hasMore = hasMore;
        if (!error) {
            if (weakSelf.updateMomentCountBlock) {
                weakSelf.updateMomentCountBlock(totalCount, 0);
            }
            [weakSelf reloadListViewData];
        }
    }];
    
    if (_manager.hotComments.count + _manager.comments.count > 0) {
        wrapperTrackEvent(@"profile", @"more_comment");
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    //    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    //    NSUInteger commentCount = self.momentModel.commentsCount;
    //    if([self.momentModel.diggUsers count] > 0 || commentCount > 0){
    _commentListView.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
    //    }
    //    else{
    //        _commentListView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    //    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([TTDeviceHelper isPadDevice])
    {
        [self.manager refreshLayoutsWithWidth:self.commentListView.width];
        [_commentListView reloadData];
        [self refreshHeaderView];
        [self.postCommonButton setNeedsLayout];
    }
}

- (void)setBanEmojiInput:(BOOL)banEmojiInput {
    if ([TTDeviceHelper isPadDevice]) { // iPad 暂时不支持
        banEmojiInput = YES;
    }

    _banEmojiInput = banEmojiInput;

    self.postCommonButton.emojiButton.hidden = banEmojiInput;
    self.postCommonButton.emojiButton.enabled = !banEmojiInput;
}

- (void)backButtonClicked
{
    [[TTUIResponderHelper topNavigationControllerFor: self] popViewControllerAnimated:YES];
}

- (void)forwardButtonClicked
{
    if ([TTAccountManager isLogin]) {
        [self openForwardView];
    }
    else {
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:@"social_item_share" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                if ([TTAccountManager isLogin]) {
                    [self openForwardView];
                }
            } else if (type == TTAccountAlertCompletionEventTypeTip) {
                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:@"social_item_share" completion:^(TTAccountLoginState state) {

                }];
            }
        }];
    }
}

//- (void)forwardToWeitoutiao {
//
//    //    能走到这里的只有
//    //    动态详情页中“文章的评论”/旧版文章评论详情页/帖子评论详情页的转发
//
//    if (self.momentModel.itemType == MomentItemTypeArticle) { //MomentItemTypeArticle代表的是“评论”
//        if (self.momentModel.group.groupType == ArticleMomentGroupArticle) { //评论的内容是文章，则实际转发的内容为文章，操作的对象为评论
//            TTRepostOriginArticle *originArticle = [[TTRepostOriginArticle alloc] init];
//            originArticle.groupID = self.momentModel.group.ID;
//            originArticle.itemID = self.momentModel.group.itemID;
//            originArticle.title = self.momentModel.group.title;
//            originArticle.isVideo = (self.momentModel.group.mediaType == ArticleWithVideo);
//            if (!isEmptyString(self.momentModel.group.thumbnailURLString)) {
//                originArticle.thumbImage = [[FRImageInfoModel alloc] initWithURL:self.momentModel.group.thumbnailURLString];;
//            }
//            TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] initWithText:self.momentModel.content userID:self.momentModel.user.ID username:self.momentModel.user.name];
//            NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
//            [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeArticle
//                                                                            originArticle:originArticle
//                                                                             originThread:nil
//                                                                         originShortVideoOriginalData:nil
//                                                                        operationItemType:TTRepostOperationItemTypeComment
//                                                                          operationItemID:self.momentModel.ID
//                                                                           repostSegments:segments];
//        }
//        else if (self.momentModel.group.groupType == ArticleMomentGroupThread) { //评论的内容是帖子
//            if (self.thread) {
//                if (self.repostOriginType == TTThreadRepostOriginTypeNone) { //被评论的是一个普通帖子，则转发这个帖子，拼接评论，操作的对象为评论
//                    TTRepostOriginThread *originThread = [[TTRepostOriginThread alloc] init];
//                    originThread.threadID = self.thread.threadId;
//                    originThread.content = self.thread.content;
//                    originThread.title = self.thread.title;
//                    if ([[self.thread getThumbImageModels] count] > 0) {
//                        originThread.thumbImage = [self.thread.getThumbImageModels firstObject];
//                    }
//                    originThread.userID = [self.thread userID];
//                    originThread.userName = [self.thread screenName];
//                    originThread.userAvatar = [self.thread avatarURL];
//                    originThread.isDeleted = self.thread.actionDataModel.hasDelete;
//                    TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] initWithText:self.momentModel.content userID:self.momentModel.user.ID username:self.momentModel.user.screen_name];
//                    NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
//                    [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeThread
//                                                                                    originArticle:nil
//                                                                                     originThread:originThread
//                                                                                 originShortVideoOriginalData:nil
//                                                                                operationItemType:TTRepostOperationItemTypeComment
//                                                                                  operationItemID:self.momentModel.ID
//                                                                                   repostSegments:segments];
//                }
//                else if (self.repostOriginType == TTThreadRepostOriginTypeThread) { //被评论的帖子有原帖，则转发原帖，拼接评论，拼接被转发帖子内容
//                    TTRepostOriginThread *originThread = [[TTRepostOriginThread alloc] initWithThread:self.originThread];
//                    TTRepostContentSegment *segmentThread = [[TTRepostContentSegment alloc] initWithRichSpanText:[[TTRichSpanText alloc] initWithText:self.thread.content richSpans:[TTRichSpans richSpansForJSONString:self.thread.contentRichSpanJSONString]] userID:[self.thread userID] username:[self.thread screenName]];
//                    TTRepostContentSegment *segmentComment = [[TTRepostContentSegment alloc] initWithText:self.momentModel.content userID:self.momentModel.user.ID username:self.momentModel.user.screen_name];
//                    NSArray *segments = [[NSArray alloc] initWithObjects:segmentComment, segmentThread, nil];
//                    [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeThread
//                                                                                    originArticle:nil
//                                                                                     originThread:originThread
//                                                                                 originShortVideoOriginalData:nil
//                                                                                operationItemType:TTRepostOperationItemTypeComment
//                                                                                  operationItemID:self.momentModel.ID
//                                                                                   repostSegments:segments];
//                }
//                else if (self.repostOriginType == TTThreadRepostOriginTypeArticle) { //被评论的帖子有原文，则转发原文，拼接评论，拼接被转发帖子内容，操作的对象为评论
//                    TTRepostOriginArticle *originArticle = [[TTRepostOriginArticle alloc] initWithArticle:self.originArticle];
//                    TTRepostContentSegment *segmentThread = [[TTRepostContentSegment alloc] initWithRichSpanText:[[TTRichSpanText alloc] initWithText:self.thread.content richSpans:[TTRichSpans richSpansForJSONString:self.thread.contentRichSpanJSONString]] userID:[self.thread userID] username:[self.thread screenName]];
//                    TTRepostContentSegment *segmentComment = [[TTRepostContentSegment alloc] initWithText:self.momentModel.content userID:self.momentModel.user.ID username:self.momentModel.user.screen_name];
//                    NSArray *segments = [[NSArray alloc] initWithObjects:segmentComment, segmentThread, nil];
//                    [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeArticle
//                                                                                    originArticle:originArticle
//                                                                                     originThread:nil
//                                                                                 originShortVideoOriginalData:nil
//                                                                                operationItemType:TTRepostOperationItemTypeComment
//                                                                                  operationItemID:self.momentModel.ID
//                                                                                   repostSegments:segments];
//                }
//            }
//        }
//    }
//}

- (void)openForwardView
{
//    wrapperTrackEvent(self.headerView.header.detailUmengEventName, @"repost");

    ArticleForwardSourceType sourceType = ArticleForwardSourceTypeOther;
    switch (self.sourceType) {
        case ArticleMomentSourceTypeMoment:
            sourceType = ArticleForwardSourceTypeMoment;
            break;
        case ArticleMomentSourceTypeProfile:
            sourceType = ArticleForwardSourceTypeProfile;
            break;
        case ArticleMomentSourceTypeForum:
            sourceType = ArticleForwardSourceTypeTopic;
            break;
        case ArticleMomentSourceTypeMessage:
            sourceType = ArticleForwardSourceTypeNotify;
            break;
        default:
            break;
    }
    ArticleForwardViewController * forwardController = [[ArticleForwardViewController alloc] initWithMomentModel:self.momentModel];
    forwardController.sourceType = sourceType;
    
    TTNavigationController * nav = [[TTNavigationController alloc] initWithRootViewController:forwardController];
    nav.ttDefaultNavBarStyle = @"White";
    
    [[TTUIResponderHelper topNavigationControllerFor: self] presentViewController:nav animated:YES completion:nil];
}

+ (void)configGlobalCustomWidth:(CGFloat)width
{
    globalCustomWidth = width;
}

- (void)insertLocalMomentCommentModel:(TTCommentDetailReplyCommentModel *)model
{
    if ([model isKindOfClass:[ArticleMomentCommentModel class]]) {
        TTCommentDetailReplyCommentModel *commentModel = [[TTCommentDetailReplyCommentModel alloc] init];
        commentModel.user = ((ArticleMomentCommentModel *)model).user;
        commentModel.content = model.content;
        commentModel.commentID = ((ArticleMomentCommentModel *)model).ID;
        commentModel.createTime = ((ArticleMomentCommentModel *)model).createTime;
        model = commentModel;
    }
    if (![model isKindOfClass:[TTCommentDetailReplyCommentModel class]]) {
        
        return ;
    }
    
    TTCommentDetailCellLayout *cellLayout = [[TTCommentDetailCellLayout alloc] initWithCommentModel:model containViewWidth:tt_splitViewFrameForView(self).size.width];
    if (cellLayout) {
        
        [self.manager insertComment:model];
        [self.manager insertCommentLayout:cellLayout];
        [self.commentListView reloadData];
    }
}

- (void)deleteLocalCommentModel:(TTCommentDetailReplyCommentModel *)model {
    
    if (![model isKindOfClass:[TTCommentDetailReplyCommentModel class]]) {
        
        return ;
    }
    
    TTCommentDetailCellLayout *cellLayout = [[TTCommentDetailCellLayout alloc] initWithCommentModel:model containViewWidth:tt_splitViewFrameForView(self).size.width];
    
    [self.manager deleteComment:model];
    [self.manager deleteCommentLayout:cellLayout];
    
    [self reloadListViewData];
}

#pragma mark -- UITableViewDelegate , UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger hotComCnt = [_manager hotComments].count;
    NSUInteger comCnt = [_manager comments].count;
    
    if (section == 0) {
        return hotComCnt;
    } else {
        return comCnt + (_hasMore ? 1 : 0);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if ([_manager hotComments].count == 0) {
            return 0.01;
        }
    } else {
        if ([_manager comments].count == 0) {
            return 0.01;
        }
    }
    return kSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if ([_manager hotComments].count == 0) {
            return nil;
        }
    } else {
        if ([_manager comments].count == 0) {
            return nil;
        }
    }
    UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectMake(tt_splitViewFrameForView(self).origin.x, 0, tt_splitViewFrameForView(self).size.width, kSectionHeaderHeight)];
    SSThemedView *view = [[SSThemedView alloc] initWithFrame:CGRectMake(tt_splitViewFrameForView(self).origin.x, 0, tt_splitViewFrameForView(self).size.width, kSectionHeaderHeight)];
    [wrapperView addSubview:view];
    
    view.backgroundColorThemeKey = kCellElementBgColorKey;
    
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColorThemeKey = kCellElementBgColorKey;
    titleLabel.textColorThemeKey = kColorText1;
    titleLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
    titleLabel.clipsToBounds = YES;
    
    titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSizeForMoment:16.f]];
    [wrapperView addSubview:titleLabel];
    
    if (section == 0) {
        titleLabel.text = NSLocalizedString(@"热门评论", nil);
    } else {
        titleLabel.text = NSLocalizedString(@"全部评论", nil);
    }
    [titleLabel sizeToFit];
    titleLabel.origin = CGPointMake(kCellAvatarViewLeftPadding + tt_splitViewFrameForView(self).origin.x, [TTDeviceUIUtils tt_paddingForMoment:12.f]);
    
    return wrapperView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([_manager hotComments].count > 0) {
            TTCommentDetailCellLayout *layout = [[_manager hotCommentLayouts] objectAtIndex:indexPath.row];
            return layout.cellHeight;
        } else {
            return 0;
        }
    } else {
        NSUInteger comCnt = [[_manager comments] count];
        if (comCnt == 0 && !_hasMore) {
            return 0;
        }
        else if (indexPath.row < comCnt) {
            TTCommentDetailCellLayout *layout = [[_manager commentLayouts] objectAtIndex:indexPath.row];
            return layout.cellHeight;
        }
        else {
            return kLoadMoreCellHeight;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"kTTCommentDetailCellIdentifier";
    static NSString * loadMoreCellIdentifier = @"loadMoreCellIdentifier";
    
    if ((indexPath.section == 0 && indexPath.row < [[_manager hotComments] count]) ||
        (indexPath.section == 1 && indexPath.row < [[_manager comments] count]))
    {
        //        ArticleMomentCommentModel * model = nil;
        TTCommentDetailReplyCommentModel *model = nil;
        TTCommentDetailCellLayout *layout = nil;
        if (indexPath.section == 0) {
            model = [[_manager hotComments] objectAtIndex:indexPath.row];
            layout = [[_manager hotCommentLayouts] objectAtIndex:indexPath.row];
        }
        else if (indexPath.section == 1) {
            model = [[_manager comments] objectAtIndex:indexPath.row];
            layout = [[_manager commentLayouts] objectAtIndex:indexPath.row];
        }
        
        
        TTCommentDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[TTCommentDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.width = tt_splitViewFrameForView(self).size.width;
        cell.delegate = self;
        if (globalCustomWidth > 0) {
            cell.needMargin = NO;
        } else {
            cell.needMargin = YES;
        }
        if ([TTDeviceHelper isPadDevice]) {
            
            [layout setCellLayoutWithCommentModel:model containViewWidth:cell.width];
        }
        [cell tt_refreshConditionWithLayout:layout model:model];
        
        return cell;
    }
    else
    {
        
        if (!self.loadMoreCell)
        {
            self.loadMoreCell = [[SSLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMoreCellIdentifier];
            self.loadMoreCell.labelStyle = SSLoadMoreCellLabelStyleAlignMiddle;
            [self.loadMoreCell addMoreLabel];
            self.loadMoreCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        return self.loadMoreCell;
    }
    
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell == self.loadMoreCell) {
        if (_hasMore && ![_manager isLoading]) {
            [self loadMore];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    wrapperTrackEvent(@"update_detail", @"reply_replier_content");
    TTCommentDetailReplyCommentModel *model = nil;
    
    if (indexPath.section == 0) {
        if (indexPath.row < [[_manager hotComments] count]) {
            model = [[_manager hotComments] objectAtIndex:indexPath.row];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row < [[_manager comments] count]) {
            model = [[_manager comments] objectAtIndex:indexPath.row];
        } else {
            [self loadMore];
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            return;
        }
    }
    
    [self tt_commentCell:[tableView cellForRowAtIndexPath:indexPath] replyButtonClickedWithModel:model];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -- scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollViewDidScrollBlock) {
        self.scrollViewDidScrollBlock(scrollView);
    }
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if ([menu isMenuVisible]) {
        [menu setMenuVisible:NO animated:YES];
    }
}

#pragma mark -- commentAction
- (void)commentButtonClicked:(id)sender {
    BOOL switchToEmojiInput = (sender == self.postCommonButton.emojiButton);
    if (switchToEmojiInput) {
        [TTTrackerWrapper eventV3:@"emoticon_click" params:@{
            @"status" : @"no_keyboard",
            @"source" : @"comment"
        }];
    }

    [self p_replyCommentWithModel:nil switchToEmojiInput:switchToEmojiInput];
}

- (void)userInfoDiggButtonClicked:(UIButton *)sender{
    if (![sender isSelected]){
        wrapperTrackEvent(@"update_detail", @"top_digg_click");
    }
    [self diggButtonPressed];
    
}

- (void)commentDiggButtonClicked{
    wrapperTrackEvent(@"update_detail", @"bottom_digg_click");
    [self diggButtonPressed];
}

- (void)diggButtonPressed{
    DetailActionRequestType actionType;
    if (self.momentModel.digged) {
        self.momentModel.diggsCount = MAX(0, self.momentModel.diggsCount - 1);
        [_postCommonButton.diggButton setSelected:NO];
        self.momentModel.digged = NO;
        actionType = DetailActionCommentUnDigg;
    } else {
        self.momentModel.diggsCount += 1;
        self.momentModel.digged = YES;
        [_postCommonButton.diggButton setSelected:YES];
        actionType = DetailActionCommentDigg;
    }
    
//    self.momentModel.digged = YES;
    if (self.momentModel.diggLimit <= 0) {
        self.momentModel.diggLimit = 1;
    }
    else {
        self.momentModel.diggLimit += 1;
    }
//    self.momentModel.diggsCount += 1;
    [self.momentModel insertDiggUser:[[TTAccountManager sharedManager] myUser]];
    
    DetailActionRequestManager *commentActionManager = [[DetailActionRequestManager alloc] init];
    
    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
    if (_commentModel.commentID) {
        context.itemCommentID = [NSString stringWithFormat:@"%@", _commentModel.commentID];
    }
    context.groupModel = _commentModel.groupModel;
    [commentActionManager setContext:context];
    
    [commentActionManager startItemActionByType:actionType];
    
    //    [ArticleMomentDiggManager startDiggMoment:self.momentModel.ID finishBlock:^(int newCount, NSError *error) {
    //    }]; // modify by lijun 接口替换
    //如果已经被删除 return  @zengruihuan
    if (self.isSelfDeleted) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(didDigMoment:)]) {
        [self.delegate didDigMoment:self.momentModel];
    }
    if (self.syncDigCountBlock) {
        self.syncDigCountBlock();
    }
//    [_postCommonButton.diggButton setSelected:YES];
}

- (void)shareButtonPressed
{
    [self.activityActionManager clearCondition];
    if (!self.activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
    }
    
    NSMutableArray * activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager moment:self.momentModel sourceType:_sourceType threadInfoLoaded:(self.thread != nil)];
    
    self.phoneShareView = [[SSActivityView alloc] init];
    _phoneShareView.delegate = self;
    _phoneShareView.activityItems = activityItems;
    [_phoneShareView showOnWindow:self.window];
    [self sendMomentDetailShareTrackWithItemType:TTActivityTypeShareButton];
}
#pragma mark - SSActivityViewDelegate
- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    if (view == _phoneShareView) {
        TTShareSourceObjectType sourceType = TTShareSourceObjectTypeMoment;
//        if (itemType == TTActivityTypeWeitoutiao) {
//            wrapperTrackEventWithCustomKeys(@"comment_detail_share", @"share_weitoutiao", self.momentModel.group.ID, nil, nil);
//            [self forwardToWeitoutiao];
//            if (ttvs_isShareIndividuatioEnable()){
//                [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareActivitySequenceFirstActivity:itemType];
//            }
//
//        }
//        else {
            [_activityActionManager performActivityActionByType:itemType inViewController:[TTUIResponderHelper topViewControllerFor: self] sourceObjectType:sourceType uniqueId:self.momentModel.ID];
//        }
        [self sendMomentDetailShareTrackWithItemType:itemType];
        self.phoneShareView = nil;
    }
}
/**
 *  登录后，则直接回复， 没有登录，则先登录， 再回复
 */
- (void)loginOrReplyToCommentModel:(ArticleMomentCommentModel *)model rectInKeyWindow:(CGRect)rect
{
    if (![TTAccountManager isLogin]) {
        
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypePost source:@"post_comment" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                if ([TTAccountManager isLogin]) {
                    [self replyToCommentModel:model rectInKeyWindow:rect];
                }
            } else if (type == TTAccountAlertCompletionEventTypeTip) {
                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:@"post_comment" completion:^(TTAccountLoginState state) {
                  
                }];
            }
        }];
    }
    else {
        [self replyToCommentModel:model rectInKeyWindow:rect];
    }
    
}

- (void)replyToCommentModel:(ArticleMomentCommentModel *)model rectInKeyWindow:(CGRect)rect {
    NSMutableDictionary * contextInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [contextInfo setValue:self.momentModel forKey:ArticleMomentModelKey];
    [contextInfo setValue:model forKey:ArticleMomentCommentModelKey];
    [contextInfo setValue:NSStringFromCGRect(rect) forKey:@"frame"];
    [contextInfo setValue:NSStringFromCGPoint(self.commentListView.contentOffset) forKey:@"contentOffset"];
    ArticleCommentView * commentView = [[ArticleCommentView alloc] init];
    commentView.contextInfo = contextInfo;
    commentView.delegate = self;
    commentView.fromThread = self.fromThread;
    [commentView showInView:self animated:YES];
    self.commentView = commentView;
    if (_sourceType == ArticleMomentSourceTypeFeed){
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:3];
        [extraDict setValue:@(_enterFromClickComment) forKey:@"is_click_button"];
        if (!isEmptyString(_categoryID)){
            [extraDict setValue:_categoryID forKey:@"category_id"];
        }
        if (!isEmptyString(_groupModel.groupID)){
            [extraDict setValue:_groupModel.groupID forKey:@"value"];
        } else if (!isEmptyString(self.momentModel.group.ID)) {
            [extraDict setValue:self.momentModel.group.ID forKey:@"value"];
        }
        _commentView.extraTrackDict = extraDict;
    }
    wrapperTrackEvent([self umengEventName], @"reply");
    //    wrapperTrackEvent([self umengEventName], @"reply_replier_button");
}

- (TTShareSourceObjectType)sourceTypeForSharedHeaderItem:(ExploreMomentListCellHeaderItem *)headerItem momentModel:(ArticleMomentModel *)moment
{
    if ([headerItem.forwardItemView isForumItemViewShown]) {
        return TTShareSourceObjectTypeForumPost;
    }
    else if (moment.itemType == MomentItemTypeOnlyShowInForum ||
             moment.itemType == MomentItemTypeForum) {
        return TTShareSourceObjectTypeForumPost;
    }
    else {
        return TTShareSourceObjectTypeMoment;
    }
}

#pragma mark -- Track

- (void)sendMomentDetailShareTrackWithItemType:(TTActivityType)itemType
{
    TTShareSourceObjectType sourceType = [self sourceTypeForSharedHeaderItem:nil momentModel:_momentModel];
    NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:sourceType];
    NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
    NSString *forumId = _momentModel.forumID ? [NSString stringWithFormat:@"%lld", _momentModel.forumID] : nil;
    wrapperTrackEventWithCustomKeys(tag, label, _momentModel.ID, forumId, nil);
}

#pragma mark - Helper

- (UIResponder *)_needResponder
{
    UIResponder *responder = self.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:NSClassFromString(@"ArticleMomentDetailViewController")]) {
            return responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}


#pragma mark -- observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"diggUsers"] ||
        [keyPath isEqualToString:@"commentsCount"]) {
        [self refreshHeaderView];
        [self reloadThemeUI];
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
                [[ExploreDeleteManager shareManager] deleteReplyedComment:_needDeleteCommentModel.commentID InHostComment:self.commentId];
                if (_needDeleteCommentModel) {
                    if (self.sourceType == ArticleMomentSourceTypeMoment) {
                        wrapperTrackEvent(@"delete", @"reply_update");
                    } else if (self.sourceType == ArticleMomentSourceTypeForum) {
                        wrapperTrackEvent(@"delete", @"reply_post");
                    } else if (self.sourceType == ArticleMomentSourceTypeProfile) {
                        wrapperTrackEvent(@"delete", @"reply_profile");
                    }
                    
                    [self deleteLocalCommentModel:_needDeleteCommentModel];
                    
                    //                    [_manager deleteComment:_needDeleteCommentModel];
                    //                    [_momentModel deleteComment:_needDeleteCommentModel];
                    //                    [self reloadListViewData];
                    if (self.fromVideoDetail) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:ArticleMomentDetailViewAddMomentNoti object:nil userInfo:@{@"increment":@(-1), @"groupID":[NSString stringWithFormat:@"%@", self.gid]}];
                        if (!([self.commentListView visibleCells].count > 0) && self.dismissBlock) {
                            self.dismissBlock();
                        }
                    }
                }
            }
        }
        self.needDeleteCommentModel = nil;
    }
}


- (NSString *)umengEventName {
    if (_sourceType == ArticleMomentSourceTypeForum) {
        return @"topic_detail";
    } else {
        return @"update_detail";
    }
}

#pragma mark - TTCommentDetailCellDelegate
- (void)tt_commentCell:(UITableViewCell *)view replyButtonClickedWithModel:(TTCommentDetailReplyCommentModel *)model {
    
    [self p_replyCommentWithModel:model switchToEmojiInput:NO];

    return;
}

- (void)tt_commentCell:(UITableViewCell *)view avatarTappedWithCommentModel:(TTCommentDetailReplyCommentModel *)model {
    
    [self p_enterProfileWithUserID:model.user.ID];
}

- (void)tt_commentCell:(UITableViewCell *)view deleteCommentWithCommentModel:(TTCommentDetailReplyCommentModel *)model {
    
    wrapperTrackEvent(@"update_detail", @"delete");
    
    self.needDeleteCommentModel = model;
    [self p_deleteReplyComment];
}

- (void)tt_commentCell:(UITableViewCell *)view digCommentWithCommentModel:(TTCommentDetailReplyCommentModel *)model {
    
    [_manager handleReplyCommentDigWithCommentID:self.commentId replayID:model.commentID userDigg:model.userDigg finishBlock:nil];
    
    model.diggCount = MAX(0, (model.userDigg) ? model.diggCount - 1: model.diggCount + 1);
    
    model.userDigg = !model.userDigg;
    
    [self.commentListView reloadData];
    
    if (!model.userDigg) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:model.commentID forKey:@"comment_id"];
        [params setValue:model.user.ID forKey:@"user_id"];
        [TTTrackerWrapper eventV3:@"comment_undigg" params:params];
    }
    
}

- (void)tt_commentCell:(UITableViewCell *)view nameViewonClickedWithCommentModel:(TTCommentDetailReplyCommentModel *)model {
    
    [self p_enterProfileWithUserID:model.user.ID];
}

- (void)tt_commentCell:(UITableViewCell *)view quotedNameOnClickedWithCommentModel:(TTCommentDetailReplyCommentModel *)model {
    
    [self p_enterProfileWithUserID:model.qutoedCommentModel.userID];
}

- (void)p_enterProfileWithUserID:(NSString *)userID {
    
    NSMutableDictionary *baseCondition = [[NSMutableDictionary alloc] init];
    [baseCondition setValue:userID forKey:@"uid"];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://profile"] userInfo:TTRouteUserInfoWithDict(baseCondition)];
}

- (void)p_replyCommentWithModel:(TTCommentDetailReplyCommentModel *)model switchToEmojiInput:(BOOL)switchToEmojiInput {

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

    NSString *fw_id = [self.commentModel groupModel].itemID ?: [self.commentModel groupModel].groupID;

    TTCommentDetailModel *detailModel = [TTCommentDetailModel new];
    detailModel.commentID = [self.commentModel commentID].stringValue;
    detailModel.groupModel = [self.commentModel groupModel];
    detailModel.banEmojiInput = self.banEmojiInput;
    detailModel.user = model.user;
    detailModel.content = model.content;
    detailModel.contentRichSpanJSONString = model.contentRichSpanJSONString;
    detailModel.banForwardToWeitoutiao = @(self.isAdVideo);

    WeakSelf;
    TTCommentDetailReplyWriteManager *replyManager = [[TTCommentDetailReplyWriteManager alloc] initWithCommentDetailModel:detailModel replyCommentModel:model commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {
        *willRepostFwID = fw_id;
    } publishCallback:^(id<TTCommentDetailReplyCommentModelProtocol> replyModel, NSError *error) {
        StrongSelf;
        if (error) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"发布失败" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            return;
        }
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:replyModel.qutoedCommentModel_commentID? :[self.commentModel commentID].stringValue forKey:@"comment_id"];
        [params setValue:@(self.groupSource).stringValue forKey:@"group_source"];
        [params setValue:[self.authorID isEqualToString:[TTAccountManager userID]]? @"1": @"0" forKey:@"author"];
        [params setValue:@(self.fromMessage) forKey:@"message"];
        [params setValue:[self.commentModel groupModel].groupID forKey:@"group_id"];
        [TTTrackerWrapper eventV3:@"comment_reply" params:[params copy]];
        if (replyModel) {

            [self insertLocalMomentCommentModel:replyModel];

            if (self.updateMomentCountBlock) {
                self.updateMomentCountBlock(0, 1);
            }

            if (self.fromVideoDetail) {
                [[NSNotificationCenter defaultCenter] postNotificationName:ArticleMomentDetailViewAddMomentNoti object:nil userInfo:@{@"increment":@(1), @"groupID":[NSString stringWithFormat:@"%@", self.gid]}];
            }
        }
    } getReplyCommentModelClassBlock:nil commentRepostWithPreRichSpanText:nil commentSource:nil];

    TTCommentWriteView *replyWriteView = [[TTCommentWriteView alloc] initWithCommentManager:replyManager];

    replyWriteView.emojiInputViewVisible = switchToEmojiInput;
    replyWriteView.banEmojiInput = self.banEmojiInput;

    [replyWriteView showInView:nil animated:YES];
}

- (void)p_deleteReplyComment {
    
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"确定删除此评论?", nil) delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认删除" otherButtonTitles:nil, nil];
    sheet.tag = kDeleteCommentActionSheetTag;
    [sheet showInView:self];
}

@end
