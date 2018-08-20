//
//  TTCommentDetailViewController.m
//  Article
//
//  Created by zhaoqin on 05/01/2017.
//
//

#import "TTCommentDetailViewController.h"
#import "TTCommentDetailToolbarView.h"
#import <TTEntry/TTFollowNotifyServer.h>
#import <TTUIWidget/TTViewWrapper.h>
#import <TTUIWidget/UIScrollView+Refresh.h>
#import <TTUIWidget/UIViewController+Refresh_ErrorHandler.h>
#import <TTUIWidget/UIView+Refresh_ErrorHandler.h>
#import <TTUIWidget/UIViewController+Track.h>
#import <TTUIWidget/SSNavigationBar.h>
#import <TTUIWidget/TTAlphaThemedButton.h>
#import <TTFriendRelation/TTFollowManager.h>
#import <TTImpression/SSImpressionManager.h>
#import <TTImpression/UIScrollView+Impression.h>
#import <TTImpression/TTRelevantDurationTracker.h>
#import <TTServiceKit/TTServiceCenter.h>
//#import <TTServiceProtocols/TTUGCPermissionService.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import "TTMomentDetailStore.h"
#import "TTCommentDetailHeader.h"
#import "TTCommentDetailCell.h"
#import "TTCommentEmptyView.h"
#import "TTCommentDetailToolbarView.h"


#define kDeleteCommentNotificationKey   @"kDeleteCommentNotificationKey"

NSString *const kTTCommentDetailForwardCommentNotification = @"kTTCommentDetailForwardCommentNotification";

@interface TTCommentDetailViewController()<TTCommentDetailHeaderDelegate, TTCommentDetailCellDelegate, UITableViewDelegate, UITableViewDataSource, Subscriber, UIGestureRecognizerDelegate, TTCommentEmptyViewDelegate, UIViewControllerErrorHandler, SSImpressionProtocol>

@property (nonatomic, strong) TTViewWrapper *viewWrapper;
@property (nonatomic, strong) TTCommentDetailHeader *headerView;
@property (nonatomic, strong) SSThemedTableView *tableView;
@property (nonatomic, strong) TTCommentEmptyView *emptyView;

@property (nonatomic, strong) TTMomentDetailStore *store;
@property (nonatomic, strong) TTMomentDetailIndependenceState *pageState;
@property (nonatomic, assign) BOOL isViewAppear;

#pragma mark - tracker
@property (nonatomic, strong) NSString *recommendReason;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSString *gtype;
@property (nonatomic, strong) NSString *clickArea;
@property (nonatomic, strong) NSString *itemId;
@property (nonatomic, strong) NSString *follow;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *fromPage;
@property (nonatomic, assign) int64_t uniqueID;

@property (nonatomic,strong) NSDate *enterDate;
@end

@implementation TTCommentDetailViewController
@synthesize hasNestedInModalContainer = _hasNestedInModalContainer;

+ (void)load {
    RegisterRouteObjWithEntryName(@"comment_detail");
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        [self setupWithBaseCondition:paramObj.allParams];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFollowStatus:) name:RelationActionSuccessNotification object:nil];
    }
    return self;
}

- (void)setupWithBaseCondition:(NSDictionary *)baseCondition {
    [self store];
    self.pageState.commentID = [baseCondition tt_stringValueForKey:@"comment_id"];
    self.pageState.stickID = [baseCondition tt_stringValueForKey:@"msg_id"];
    self.pageState.from = [baseCondition tt_integerValueForKey:@"source_type"];
    self.pageState.uniqueID = [baseCondition tt_stringValueForKey:@"uniqueID"];
    self.pageState.serviceID = [baseCondition tt_stringValueForKey:@"serviceID"];
    //从消息进入, 或者从置顶评论进入 都算isFromMessage
    self.pageState.isFromMessage = [baseCondition tt_boolValueForKey:@"from_message"] || !isEmptyString(self.pageState.stickID);
    //TODO: 后续各种id迁到 pageState中
    _commentModel = baseCondition[@"commentModel"];
    
    _recommendReason = [baseCondition tt_stringValueForKey:@"recommendReson"];
    _categoryName = [baseCondition tt_stringValueForKey:@"categoryName"];
    _commentId = [baseCondition tt_stringValueForKey:@"commentId"];
    _gtype = [baseCondition tt_stringValueForKey:@"gtype"];
    _clickArea = [baseCondition tt_stringValueForKey:@"clickArea"];
    _itemId = [baseCondition tt_stringValueForKey:@"itemId"];
    _follow = [baseCondition tt_stringValueForKey:@"follow"];
    _groupId = [baseCondition tt_stringValueForKey:@"groupId"];
    _fromPage = [baseCondition tt_stringValueForKey:@"fromPage"];
    if (_commentModel.commentID.longLongValue) {
        self.pageState.commentID = _commentModel.commentID.stringValue;
    }
    _groupModel = baseCondition[@"groupModel"];
    _showWriteComment = [baseCondition[@"writeComment"] boolValue];
    _showComment = [baseCondition[@"showComment"] boolValue];
    
    //一个trick的实现，转发需求临时方案，先把文章信息带到评论详情页 //xushuangqing....
    _article = [baseCondition tt_objectForKey:@"group" ofClass:[Article class]];
}

- (void)trySendCurrentPageStayTime {
    if (self.ttTrackStartTime == 0) {//当前页面没有在展示过
        return;
    }
    double duration = self.ttTrackStayTime * 1000.0;
    if (duration <= 200) {//低于200毫秒，忽略
        self.ttTrackStartTime = 0;
        [self tt_resetStayTime];
        return;
    }
    [self sendCurrentPageStayTime:duration];
    
    self.ttTrackStartTime = 0;
    [self tt_resetStayTime];
}

- (void)trackEndedByAppWillEnterBackground {
    [self trySendCurrentPageStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)sendCurrentPageStayTime:(double)duration {
    if (!isEmptyString(_categoryName) && [self isIndependentPage]) {
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:@"49" forKey:@"gtype"];
        [extra setValue:_pageState.detailModel.groupModel.itemID forKey:@"item_id"];
        [extra setValue:_recommendReason forKey:@"recommend_reason"];
        [extra setValue:@(duration/1000.0).stringValue forKey:@"ext_value"];
//        wrapperTrackEventWithCustomKeys(@"stay_page", [@"click_" stringByAppendingString:_categoryName], _pageState.detailModel.groupModel.groupID, nil, extra);
        
        //新加的详情页关联时常
        NSString *enterFrom = [NSString stringWithFormat:@"click_%@", _categoryName];
        [[TTRelevantDurationTracker sharedTracker] appendRelevantDurationWithGroupID:_groupId
                                                                              itemID:_itemId
                                                                           enterFrom:enterFrom
                                                                        categoryName:_categoryName
                                                                            stayTime:(NSInteger)(duration)
                                                                               logPb:@{}];
    }
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
        
    //解除Impression
    [self tt_unregisterFromImpressionManager:self];
}

- (void)updateFollowStatus:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *userID = [userInfo tt_stringValueForKey:kRelationActionSuccessNotificationUserIDKey];
    FriendActionType actionType = [userInfo tt_intValueForKey:kRelationActionSuccessNotificationActionTypeKey];
    if ([self.pageState.detailModel.user.ID isEqualToString:userID]) {
        self.pageState.detailModel.user.isFollowing = (actionType == FriendActionTypeFollow) ? YES : NO;
    }
    [self.pageState.hotComments enumerateObjectsUsingBlock:^(TTCommentDetailReplyCommentModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTCommentDetailReplyCommentModel *model = [self.pageState.hotComments objectAtIndex:idx];
        if ([model.user.ID isEqualToString:userID]) {
            model.user.isFollowing = (actionType == FriendActionTypeFollow) ? YES : NO;
        }
    }];
    [self.pageState.allComments enumerateObjectsUsingBlock:^(TTCommentDetailReplyCommentModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTCommentDetailReplyCommentModel *model = [self.pageState.allComments objectAtIndex:idx];
        if ([model.user.ID isEqualToString:userID]) {
            model.user.isFollowing = (actionType == FriendActionTypeFollow) ? YES : NO;
        }
    }];
}

- (void)onStateChange:(TTMomentDetailIndependenceState *)state {
    self.pageState = state;
    if (self.pageState.detailModel.isDeleted) {
        [self _removeContext];
        [self tt_endUpdataData:NO error:nil];
        return;
    }
    
    if (self.pageState.needShowNetworkErrorPage) {
        self.ttViewType = TTFullScreenErrorViewTypeNetWorkError;
        [self _removeContext];
        [self tt_endUpdataData:NO error:nil];
        return;
    }
    self.toolbarView.banEmojiInput = YES;

    self.toolbarView.diggButton.selected = self.pageState.detailModel.userDigg;

    NSString *title;
    if (self.hasNestedInModalContainer) {
        title = self.pageState.detailModel.commentCount? [NSString stringWithFormat:@"%ld条回复", self.pageState.detailModel.commentCount]: @"暂无回复";
    } else {
        title = @"详情";
    }
    self.title = title;
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:title];
    
    self.tableView.pullUpView.hidden = !self.pageState.detailModel.commentCount;
    [self.headerView refreshWithModel:self.pageState.detailModel];
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.hasMore = state.hasMoreComment;
    [self.tableView reloadData];
    
    [self _refreshEmptyViewIfNeed];
    [self _scrollToSelfCommentIfNeed];
    [self _showDefaultReplyUserIfNeed];
    [self _updateWriteCommentViewIfNeeded];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ttTrackStayEnable = YES;
    self.ttViewType = TTFullScreenErrorViewTypeDeleted;
    self.ttStatusBarStyle = UIStatusBarStyleDefault;
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    self.pageState.cellWidth = self.tableView.width;
    
    [[TTFollowNotifyServer sharedServer] addObserver:self selector:@selector(followNotifyHandler:)];

    TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeInit comment:self.commentModel];
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] initWithCapacity:1];
    [payload setValue:self.groupModel forKey:@"groupModel"];
    action.payload = payload;
    action.shouldMiddlewareHandle = YES;
    [self.store dispatch:action];

    [self.view addSubview:self.viewWrapper];
    [self.view addSubview:self.tableView];
    
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground3);
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self.view addSubview:self.toolbarView];
    [self _registerObserver];
    
    //注册Impression
    [self tt_registerToImpressionManager:self];

    //来源不是文章或者帖子，那就发godetail埋点 --- 需要保证from填写准确
    // 消息页面进入时 categoryName 为空，文章和帖子进入时 isIndependentPage 为 NO，只有热评进入会命中此逻辑，但是热评现在都打包成 CommentRepost
    if (!isEmptyString(_categoryName) && [self isIndependentPage]) {
        NSMutableDictionary *goDetailExtraDic = [NSMutableDictionary dictionary];
        [goDetailExtraDic setValue:_commentId forKey:@"ext_value"];
        [goDetailExtraDic setValue:_gtype forKey:@"gtype"];
        [goDetailExtraDic setValue:_clickArea forKey:@"click_area"];
        [goDetailExtraDic setValue:_itemId forKey:@"item_id"];
        [goDetailExtraDic setValue:_follow forKey:@"follow"];
        [goDetailExtraDic setValue:self.recommendReason forKey:@"recommend_reason"];
        NSString *enterFrom = [NSString stringWithFormat:@"click_%@", _categoryName];
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
//            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"go_detail" label:enterFrom value:_groupId source:nil extraDic:goDetailExtraDic];
        }
        
        //log3.0 doubleSending
        NSMutableDictionary *logv3Dic = [NSMutableDictionary dictionaryWithCapacity:4];
        [logv3Dic setValue:_groupId forKey:@"group_id"];
        [logv3Dic setValue:_itemId forKey:@"item_id"];
        [logv3Dic setValue:enterFrom forKey:@"enter_from"];
        [logv3Dic setValue:_categoryName forKey:@"category_name"];
        [logv3Dic setValue:_commentId forKey:@"comment_id"];
        [logv3Dic setValue:_gtype forKey:@"gtype"];
        [logv3Dic setValue:_clickArea forKey:@"click_area"];
        [logv3Dic setValue:_follow forKey:@"follow"];
        [logv3Dic setValue:self.recommendReason forKey:@"recommend_reason"];
//        [TTTrackerWrapper eventV3:@"go_detail" params:logv3Dic isDoubleSending:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}

- (void)_registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observeCommentDeleted:)
                                                 name:kDeleteCommentNotificationKey
                                               object:nil];
    
}

- (void)observeCommentDeleted:(NSNotification *)notification {
    NSString *deletedID = [notification.userInfo tt_stringValueForKey:@"id"];
    if ([self.pageState.detailModel.commentID isEqualToString:deletedID]) {
        if (self.hasNestedInModalContainer) {
            [self dismissSelf];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        return;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //fix微头条转commentdetail时的埋点发两次
    
    [self.store subscribe:self];

    TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeWillAppear comment:self.commentModel];
    [self.store dispatch:action];
    
    [self.tableView tt_startImpression];
    [self tt_enterCommentImpression];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _isViewAppear = YES;

    TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeDidAppear payload:nil];
    [self.store dispatch:action];

    if (self.showWriteComment) {
        self.showWriteComment = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.isViewAppear || ![self tt_hasValidateData]) {
                return;
            }
            TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypePublishComment comment:nil];
            action.source = TTMomentDetailActionSourceTypeBottom;
            action.commentDetailModel = self.pageState.detailModel;
            action.payload = @{
                @"serviceID": self.pageState.serviceID ?: @"",
                @"view": self.view,
            };
            action.shouldMiddlewareHandle = YES;
            [self.store dispatch:action];
        });
    }
    
    if (self.showComment) {
        self.showComment = NO;
        WeakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            StrongSelf;
            CGFloat destinationOffsetY = self.headerView.height - self.tableView.contentInset.top;

            destinationOffsetY = MAX(0, MIN(destinationOffsetY, self.tableView.contentSize.height + self.tableView.contentInset.bottom - self.tableView.height));
            if (destinationOffsetY > 0) {
                [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, destinationOffsetY) animated:YES];
            }
        });
    }
    
    //记录进来的时间
    self.enterDate = [NSDate date];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isViewAppear = NO;

    TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeWillDisappear comment:self.commentModel];
    [self.store dispatch:action];
    
   //统计comment_close
    double time = [[NSDate date] timeIntervalSinceDate:self.enterDate];
    time = round(time * 1000);
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.commentModel.groupModel.itemID forKey:@"item_id"];
    [dic setValue:self.commentModel.groupModel.groupID forKey:@"group_id"];
    [dic setValue:self.commentModel.userID forKey:@"to_user_id"];
    [dic setValue:self.commentModel.commentID forKey:@"comment_id"];
    [dic setValue:@"detail" forKey:@"position"];
    [dic setValue:@(time).stringValue forKey:@"stay_time"];
    
    [TTTracker eventV3:@"comment_close" params:dic];

    [self trySendCurrentPageStayTime];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self.store unsubscribe:self];
    
    [self.tableView tt_endImpression];
    //Impression离开
    [self tt_leaveCommentImpression];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([TTDeviceHelper isPadDevice]) {
        self.tableView.frame = [TTUIResponderHelper splitViewFrameForView:self.viewWrapper];
        if (self.pageState.cellWidth == self.tableView.width) {
            return;
        }
        self.pageState.cellWidth = self.tableView.width;
        TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeRefreshComment payload:nil];
        [self.store dispatch:action];
    }
}

- (void)themeChanged:(NSNotification *)notification {
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
}

- (void)_showDefaultReplyUserIfNeed {
    if (self.pageState.defaultRelyModel) {
        [self.toolbarView.writeButton setTitle:[NSString stringWithFormat:@"回复 %@：", self.pageState.defaultRelyModel.user.name] forState:UIControlStateNormal];
    } else {
        [self.toolbarView.writeButton setTitle:@"写评论..." forState:UIControlStateNormal];
    }
    
}
- (void)_refreshEmptyViewIfNeed {
    BOOL isEmptyComment = !self.pageState.hotComments.count && !self.pageState.allComments.count && !self.pageState.stickComments.count;
                                 
    if (!isEmptyComment) {
        self.tableView.tableFooterView = nil;
        return;
    }
    
    self.tableView.tableFooterView = self.emptyView;
    
    if (self.pageState.isFailedLoadComment) {
        [self.emptyView refreshType:TTCommentEmptyViewTypeFailed];
        return;
    }
    
    [self.emptyView refreshType:self.pageState.isLoadingComment? TTCommentEmptyViewTypeLoading: TTCommentEmptyViewTypeCommentDetailEmpty];
}

- (void)_scrollToSelfCommentIfNeed {
    if (!self.pageState.needMarkedIndexPath) {
        return;
    }
    
    if (self.pageState.needMarkedIndexPath.section >= self.tableView.numberOfSections || self.pageState.needMarkedIndexPath.row >= [self.tableView numberOfRowsInSection:self.pageState.needMarkedIndexPath.section]) {
        return;
    }
    
    [self.tableView scrollToRowAtIndexPath:self.pageState.needMarkedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)_removeContext {
    [self.viewWrapper removeFromSuperview];
    [self.tableView removeFromSuperview];
    [self.toolbarView removeFromSuperview];
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    self.view.ttErrorView.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
}

- (BOOL)tt_hasValidateData {
    if (self.pageState.detailModel.isDeleted) {
        return NO;
    }
    
    if (self.pageState.needShowNetworkErrorPage) {
        return NO;
    }
    
    return YES;
}

- (void)_updateWriteCommentViewIfNeeded {
    TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeBanEmojiInput payload:nil];
    action.commentDetailModel = self.pageState.detailModel;
    action.shouldMiddlewareHandle = YES;
    [self.store dispatch:action];
}

// 评论有可能是依附于文章或者帖子的，也可能独立进入，这里用于判断是否是独立进入的
- (BOOL)isIndependentPage {
    return self.pageState.from != TTCommentDetailSourceTypeThread
        && self.pageState.from != TTCommentDetailSourceTypeDetail;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    wrapperTrackEvent(@"update_detail", @"reply_replier_content");
    TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypePublishComment comment:nil];
    action.source = TTMomentDetailActionSourceTypeComment;
    action.commentDetailModel = self.pageState.detailModel;
    action.replyCommentModel = self.pageState.totalComments[indexPath.section][indexPath.row];
    action.payload = @{
        @"serviceID": self.pageState.serviceID ?: @"",
        @"view": self.view,
    };
    action.shouldMiddlewareHandle = YES;
    [self.store dispatch:action];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *needMarkedIndexPath = self.pageState.needMarkedIndexPath;
    if (needMarkedIndexPath && [needMarkedIndexPath compare:indexPath] == NSOrderedSame) {
        self.pageState.needMarkedIndexPath = nil; //偷懒了... 不应该在外面直接操作state😑
        UIColor *previousColor = [cell.contentView.backgroundColor copy];
        [UIView animateWithDuration:0.35 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"0xFFFAD9"];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.35f animations:^{
                cell.contentView.backgroundColor = previousColor;
            }];
        }];
    }
    
    if (indexPath.section < self.pageState.totalComments.count) {
        NSArray<TTCommentDetailReplyCommentModel *> *array = self.pageState.totalComments[indexPath.section];
        if (indexPath.row < array.count) {

            [self tt_recordForComment:self.pageState.totalComments[indexPath.section][indexPath.row]
                               status:SSImpressionStatusRecording];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.pageState.totalComments.count) {
        NSArray<TTCommentDetailReplyCommentModel *> *array = self.pageState.totalComments[indexPath.section];
        if (indexPath.row < array.count) {
            
            [self tt_recordForComment:self.pageState.totalComments[indexPath.section][indexPath.row]
                               status:SSImpressionStatusEnd];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.pageState.totalCommentLayouts[indexPath.section].count) {
        return self.pageState.totalCommentLayouts[indexPath.section][indexPath.row].cellHeight;
    }
    return CGFLOAT_MIN;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.pageState.totalCommentLayouts[section].count) {
        if (section == 0) {
            return [TTDeviceUIUtils tt_newPadding:17.f];
        }
        if (section == 1) {
            return [TTDeviceUIUtils tt_newPadding:35.f];
        }
        if ([tableView numberOfRowsInSection:1] && section == 2) {
            return [TTDeviceUIUtils tt_newPadding:20.f];
        } else {
            return [TTDeviceUIUtils tt_newPadding:35.f];
        }
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!self.pageState.totalCommentLayouts[section].count) {
        return nil;
    }
    
    CGFloat height = [self tableView:self.tableView heightForHeaderInSection:section];
    
    if (section == 0) {
        SSThemedView *backgroundView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, height)];
        backgroundView.backgroundColorThemeKey = kColorBackground22;
        return backgroundView;
    }
    
    SSThemedView *container = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, height)];
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:15.f], 0, container.width, container.height)];
    titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
    titleLabel.height = titleLabel.font.pointSize;
    titleLabel.textColorThemeKey = kColorText1;
    titleLabel.bottom = container.bottom;
    if (section == 1) {
        titleLabel.text = NSLocalizedString(@"热门评论", nil);
    } else if (section == 2) {
        titleLabel.text = NSLocalizedString(@"全部评论", nil);
    }
    
    [container addSubview:titleLabel];
    return container;
}

- (BOOL)hasDeleteReplyPermission {
    return NO;
//    id<TTUGCPermissionService> permissionService = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTUGCPermissionService)];
//    return [permissionService hasDeletePermissionWithOriginCommentOrThreadUserID:self.pageState.detailModel.user.ID];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.pageState.totalCommentLayouts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pageState.totalCommentLayouts[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTCommentDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kTTCommentDetailCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.backgroundColorThemeKey = indexPath.section == 0? kColorBackground22: kColorBackground4;
    TTCommentDetailCellLayout *layout = self.pageState.totalCommentLayouts[indexPath.section][indexPath.row];
    if ([self hasDeleteReplyPermission]) {
        layout.deleteLayout.hidden = NO;
    }
    [cell tt_refreshConditionWithLayout:layout model:self.pageState.totalComments[indexPath.section][indexPath.row]];
    
    return cell? :[[UITableViewCell alloc] init];
}

#pragma mark - actions

- (void)toolbarDiggButtonOnClicked:(id)sender {
    wrapperTrackEvent(@"update_detail", @"bottom_digg_click");
    TTMomentDetailAction *action = [TTMomentDetailAction digActionWithCommentDetailModel:self.pageState.detailModel];
    [self.store dispatch:action];
}

- (void)toolbarShareButtonOnClicked:(id)sender {
    TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeShare comment:self.commentModel];
    action.shouldMiddlewareHandle = YES;
    action.commentDetailModel = self.pageState.detailModel;
    action.group = self.article;
    action.from = self.pageState.from;
    if (!isEmptyString(self.categoryName)) {
        action.payload = @{@"category_name":self.categoryName};
    }
    action.source = TTMomentDetailActionSourceTypeHeader;
    [self.store dispatch:action];
}

- (void)toolbarWriteButtonOnClicked:(id)sender {
    BOOL switchToEmojiInput = (sender == self.toolbarView.emojiButton);
    if (switchToEmojiInput) {
        [TTTrackerWrapper eventV3:@"emoticon_click" params:@{
            @"status" : @"no_keyboard",
            @"source" : @"comment"
        }];
    }

    TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypePublishComment comment:nil];
    action.source = TTMomentDetailActionSourceTypeBottom;
    action.commentDetailModel = self.pageState.detailModel;
    action.payload = @{
        @"serviceID": self.pageState.serviceID ?: @"",
        @"view": self.view,
        @"switchToEmojiInput": @(switchToEmojiInput)
    };
    action.shouldMiddlewareHandle = YES;
    [self.store dispatch:action];
}

#pragma mark - TTCommentEmptyViewDelegate

- (void)emptyView:(TTCommentEmptyView *)view buttonClickedForType:(TTCommentEmptyViewType)type {
    if (type == TTCommentEmptyViewTypeEmpty) {
        [self toolbarWriteButtonOnClicked:nil];
    } else if (type == TTCommentEmptyViewTypeFailed) {
        TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeLoadComment comment:self.commentModel];
        action.shouldMiddlewareHandle = YES;
        [self.store dispatch:action];
    }
}

#pragma mark - TTDynamicDetailHeaderDelegate

- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header avatarViewOnClick:(id)sender {
    TTMomentDetailAction *action = [TTMomentDetailAction enterProfileActionWithUserID:self.pageState.detailModel.user.ID];
    NSMutableDictionary *mdict = action.payload.mutableCopy;
    [mdict setValue:_categoryName forKey:@"categoryName"];
    [mdict setValue:_groupId forKey:@"groupId"];
    NSString *fromPage = _fromPage;
    if ([_fromPage hasSuffix:@"_dig"]) {
        fromPage = [_fromPage substringToIndex:[_fromPage rangeOfString:@"_dig"].location];
    }
    [mdict setValue:fromPage forKey:@"fromPage"];
    action.payload = mdict.copy;
    [self.store dispatch:action];
}

- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header nameViewOnClick:(id)sender {
    TTMomentDetailAction *action = [TTMomentDetailAction enterProfileActionWithUserID:self.pageState.detailModel.user.ID];
    [self.store dispatch:action];
}

- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header digButtonOnClick:(id)sender {
    TTMomentDetailAction *action = [TTMomentDetailAction digActionWithCommentDetailModel:self.pageState.detailModel];
    [self.store dispatch:action];
}

- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header replyButtonOnClick:(id)sender {
    TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypePublishComment comment:self.commentModel];
    action.shouldMiddlewareHandle = YES;
    action.source = TTMomentDetailActionSourceTypeHeader;
    action.payload = @{
        @"serviceID": self.pageState.serviceID ?: @"",
        @"view": self.view,
    };
    [self.store dispatch:action];
}

- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header followButtonOnClick:(id)sender {
    TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:self.pageState.detailModel.user.isFollowing? TTMomentDetailActionTypeUnfollow: TTMomentDetailActionTypeFollow comment:nil];
    action.commentDetailModel = self.pageState.detailModel;
    action.shouldMiddlewareHandle = YES;
    action.source = TTMomentDetailActionSourceTypeHeader;
    action.from = self.pageState.from;
    if (!isEmptyString(self.categoryName)) {
        action.payload = @{@"category_name":self.categoryName};
    }
    [self.store dispatch:action];
}

- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header blockButtonOnClick:(id)sender {
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    [payload setValue:[self.commentModel.userID stringValue] forKey:@"userID"];
    TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeUnblock payload:payload];
    action.source = TTMomentDetailActionSourceTypeHeader;
    action.shouldMiddlewareHandle = YES;
    [self.store dispatch:action];
}

- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header deleteButtonOnClick:(id)sender {
    TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeDeleteComment comment:self.commentModel];
    action.commentDetailModel = self.pageState.detailModel;
    action.shouldMiddlewareHandle = YES;
    action.source = TTMomentDetailActionSourceTypeHeader;
    [self.store dispatch:action];
}

- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header reportButtonOnClick:(id)sender {
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    [payload setValue:[self.commentModel.commentID stringValue] forKey:@"commentID"];
    TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeReport payload:payload];
    action.source = TTMomentDetailActionSourceTypeHeader;
    [self.store dispatch:action];
}

- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header quotedNameViewOnClick:(id)sender {
    TTMomentDetailAction *action = [TTMomentDetailAction enterProfileActionWithUserID:self.pageState.detailModel.qutoedCommentModel.userID];
    [self.store dispatch:action];
}

- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header diggedUserAvatarOnClick:(SSUserModel *)user {
    TTMomentDetailAction *action = [TTMomentDetailAction enterProfileActionWithUserID:user.ID];
    NSMutableDictionary *mdict = action.payload.mutableCopy;
    [mdict setValue:_categoryName forKey:@"categoryName"];
    [mdict setValue:_groupId forKey:@"groupId"];
    [mdict setValue:_fromPage forKey:@"fromPage"];
    action.payload = mdict.copy;
    [self.store dispatch:action];
}

- (void)dynamicDetailHeader:(TTCommentDetailHeader *)header diggCountLabelOnClick:(id)sender {
    TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeEnterDiggList payload:@{
        @"group_id" : self.groupId ?: @"",
        @"category_id" : self.categoryName ?: @"",
        @"from_page" : self.pageState.from == TTCommentDetailSourceTypeThread ? @"detail_topic_comment_dig" : (self.pageState.from == TTCommentDetailSourceTypeDetail ? @"detail_article_comment_dig" : @""),
        @"comment_id" : self.pageState.detailModel.commentID ?: @"",
        @"digg_count" : @(self.pageState.detailModel.diggCount)
    }];
    [self.store dispatch:action];
}

- (void)followNotifyHandler:(TTFollowNotify *)notify {
    if (!notify || isEmptyString(notify.ID)) {
        return;
    }
    TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeFollowNotify comment:nil];
    action.payload = @{@"notify": notify};
    [self.store dispatch:action];
}

#pragma mark - TTCommentDetailCellDelegate

- (void)tt_commentCell:(UITableViewCell *)view avatarTappedWithCommentModel:(TTCommentDetailReplyCommentModel *)model {
    TTMomentDetailAction *action = [TTMomentDetailAction enterProfileActionWithUserID:model.user.ID];
    [self.store dispatch:action];
}

- (void)tt_commentCell:(UITableViewCell *)view deleteCommentWithCommentModel:(TTCommentDetailReplyCommentModel *)model {
    TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeDeleteComment payload:nil];
    action.commentDetailModel = self.pageState.detailModel;
    action.replyCommentModel = model;
    action.source = TTMomentDetailActionSourceTypeComment;
    action.shouldMiddlewareHandle = YES;
    [self.store dispatch:action];
}

- (void)tt_commentCell:(UITableViewCell *)view digCommentWithCommentModel:(TTCommentDetailReplyCommentModel *)model {
    TTMomentDetailAction *action = [TTMomentDetailAction digActionWithReplyCommentModel:model];
    action.commentDetailModel = self.pageState.detailModel;
    [self.store dispatch:action];
}

- (void)tt_commentCell:(UITableViewCell *)view nameViewonClickedWithCommentModel:(TTCommentDetailReplyCommentModel *)model {
    TTMomentDetailAction *action = [TTMomentDetailAction enterProfileActionWithUserID:model.user.ID];
    [self.store dispatch:action];
}

- (void)tt_commentCell:(UITableViewCell *)view quotedNameOnClickedWithCommentModel:(TTCommentDetailReplyCommentModel *)model {
    TTMomentDetailAction *action = [TTMomentDetailAction enterProfileActionWithUserID:model.qutoedCommentModel.userID];
    [self.store dispatch:action];
}

- (UIScrollView *)tt_scrollView {
    return self.tableView;
}

#pragma mark -- SSImpressionManager

- (void)needRerecordImpressions {
    if (self.isViewAppear) {
        self.headerView.willAppearBlock();
        for (id cell in [self.tableView visibleCells]) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            if (indexPath.section < self.pageState.totalComments.count) {
                NSArray<TTCommentDetailReplyCommentModel *> *array = self.pageState.totalComments[indexPath.section];
                if (indexPath.row < array.count) {
                    
                    [self tt_recordForComment:self.pageState.totalComments[indexPath.section][indexPath.row]
                                       status:SSImpressionStatusRecording];
                }
            }
        }
    }
}

- (void)tt_registerToImpressionManager:(id)object {
    [[SSImpressionManager shareInstance] addRegist:object];
}

- (void)tt_unregisterFromImpressionManager:(id)object {
    [[SSImpressionManager shareInstance] removeRegist:object];
}

- (void)tt_enterCommentImpression {
    [[SSImpressionManager shareInstance] enterCommentDetailViewForGroupID:self.commentModel.groupModel.groupID];
    [[SSImpressionManager shareInstance] enterCommentDetailViewForGroupID:[self.commentModel.groupModel replyImpressionDescription]];
}

- (void)tt_leaveCommentImpression {
    [[SSImpressionManager shareInstance] leaveCommentDetailViewForGroupID:self.commentModel.groupModel.groupID];
    [[SSImpressionManager shareInstance] leaveCommentDetailViewForGroupID:[self.commentModel.groupModel replyImpressionDescription]];
}

- (void)tt_recordForComment:(TTCommentDetailReplyCommentModel *)replyModel status:(SSImpressionStatus)status {
    if ([replyModel.commentID longLongValue] != 0 && replyModel.groupID != 0) {
        NSString * cIDStr = [NSString stringWithFormat:@"%@", replyModel.commentID];
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        [extra setValue:@"comment_detail" forKey:@"comment_position"];
        [extra setValue:@"comment_reply" forKey:@"comment_type"];
        [extra setValue:self.commentModel.groupModel.itemID forKey:@"item_id"];
        [extra setValue:@(self.commentModel.groupModel.aggrType) forKey:@"aggr_type"];
        [[SSImpressionManager shareInstance] recordCommentDetailReplyImpressionGroupID:self.commentModel.groupModel.groupID commentID:cIDStr status:status userInfo:@{@"extra":extra}];
    }
}

#pragma mark - getter & setter

- (TTCommentDetailHeader *)headerView {
    if (!_headerView) {
        CGRect frame = [TTUIResponderHelper splitViewFrameForView:self.view];
        CGFloat height = [TTCommentDetailHeader heightWithModel:self.pageState.detailModel width:frame.size.width];
        _headerView = [[TTCommentDetailHeader alloc] initWithModel:self.pageState.detailModel frame:CGRectMake(0, 0, frame.size.width, height) needShowGroupItem:!(self.pageState.from == TTCommentDetailSourceTypeDetail || self.pageState.from == TTCommentDetailSourceTypeThread)];
        _headerView.delegate = self;
        _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //headView主评论出现的时间
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        [extra setValue:@"comment_detail" forKey:@"comment_position"];
        [extra setValue:@"comment" forKey:@"comment_type"];
        [extra setValue:self.commentModel.groupModel.itemID forKey:@"item_id"];
        [extra setValue:@(self.commentModel.groupModel.aggrType) forKey:@"aggr_type"];
        __weak typeof(self) weakSelf = self;
        [_headerView setWillAppearBlock:^{
             [[SSImpressionManager shareInstance] recordCommentDetailReplyImpressionGroupID:[weakSelf.commentModel.groupModel replyImpressionDescription] commentID:weakSelf.commentModel.commentID.stringValue status:SSImpressionStatusRecording userInfo:@{@"extra":extra}];
        }];
        [_headerView setWillDisAppearBlock:^() {
              [[SSImpressionManager shareInstance] recordCommentDetailReplyImpressionGroupID:[weakSelf.commentModel.groupModel replyImpressionDescription] commentID:weakSelf.commentModel.commentID.stringValue status:SSImpressionStatusEnd userInfo:@{@"extra":extra}];
        }];
        [self.tableView tt_addImpressionView:_headerView];
    }
    return _headerView;
}

- (SSThemedTableView *)tableView {
    if (!_tableView) {
        _tableView = [[SSThemedTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStyleGrouped];
        _tableView.contentInset = UIEdgeInsetsMake(_tableView.contentInset.top, _tableView.contentInset.left, _tableView.contentInset.bottom + self.toolbarView.height, _tableView.contentInset.right);
        _tableView.frame = [TTUIResponderHelper splitViewFrameForView:_tableView];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.backgroundColorThemeKey = kColorBackground4;
        [_tableView registerClass:[TTCommentDetailCell class] forCellReuseIdentifier:kTTCommentDetailCellIdentifier];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.sectionFooterHeight = CGFLOAT_MIN;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        __weak __typeof(self)weakSelf = self;
        [_tableView tt_addPullUpLoadMoreWithNoMoreText:@"已显示全部评论" withHandler:^{
            if (!weakSelf) {
                return;
            }
            wrapperTrackEvent(@"update_detail", @"replier_loadmore");
            TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeLoadComment comment:weakSelf.commentModel];
            action.shouldMiddlewareHandle = YES;
            [weakSelf.store dispatch:action];
        }];
        
    }
    return _tableView;
}

- (TTCommentDetailToolbarView *)toolbarView {
    if (!_toolbarView) {
        _toolbarView = [[TTCommentDetailToolbarView alloc] initWithFrame:CGRectMake(0, self.view.height - TTCommentDetailToolbarViewHeight(), self.view.width, TTCommentDetailToolbarViewHeight())];
        _toolbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [_toolbarView.diggButton addTarget:self action:@selector(toolbarDiggButtonOnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView.shareButton addTarget:self action:@selector(toolbarShareButtonOnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView.writeButton addTarget:self action:@selector(toolbarWriteButtonOnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView.emojiButton addTarget:self action:@selector(toolbarWriteButtonOnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _toolbarView;
}

- (TTMomentDetailStore *)store {
    if (!_store) {
        _store = [[TTMomentDetailStore alloc] init];
        _pageState = _store.state;
    }
    return _store;
}

- (TTViewWrapper *)viewWrapper {
    if (!_viewWrapper) {
        _viewWrapper = [TTViewWrapper viewWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - self.toolbarView.height) targetView:self.tableView];
        _viewWrapper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _viewWrapper;
}

- (TTCommentEmptyView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[TTCommentEmptyView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 150.f)];
        _emptyView.delegate = self;
        [_emptyView refreshType:TTCommentEmptyViewTypeLoading];
    }
    return _emptyView;
}

@end

