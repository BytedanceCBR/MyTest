//
//  ExploreMomentListCellHeaderItem.m
//  Article
//
//  Created by Zhang Leonardo on 15-1-28.
//
//

#import "ExploreMomentListCellHeaderItem.h"
#import <TTAccountBusiness.h>
#import "SSUserModel.h"
#import "FriendDataManager.h"
#import "TTIndicatorView.h"
#import "FriendDataManager.h"
#import "ExploreDeleteManager.h"
#import "ExploreMomentDefine.h"
#import "ArticleURLSetting.h"
#import "SSWebViewController.h"

#import "TTBlockManager.h"
#import "TTAuthorizeManager.h"
#import "TTNavigationController.h"
#import "TTThemedAlertController.h"
#import "TTGroupModel.h"
#import "SSCommentModel.h"
#import "ArticleMomentGroupModel.h"
#import "TTIndicatorView.h"
#import "TTReportManager.h"
#import "TTStringHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "ArticleMomentDetailViewController.h"
#import "TTActionSheetController.h"
//#import "TTAddFriendViewController.h"
#import "TTTabBarProvider.h"

#define kActionToSelfSheetTag      1
#define kActionToBlockingUserSheetTag 2
#define kActionToUnblockingUserSheetTag 4
#define kHasAdminActionSheetTag    8

#define kCommentItemTopInsetWhenReportShown 8.f

#define ActionTitleDelete NSLocalizedString(@"删除", nil)
#define ActionTitleBlock  NSLocalizedString(@"拉黑", nil)
#define ActionTitleUnBlock NSLocalizedString(@"取消拉黑", nil)
#define ActionTitleFollow NSLocalizedString(@"关注", nil)
#define ActionTitleUnFollow NSLocalizedString(@"取消关注", nil)
#define ActionTitleReport NSLocalizedString(@"举报此内容", nil)
#define ActionTitleAdmin NSLocalizedString(@"管理", nil)

@interface ExploreMomentListCellHeaderItem()<UIActionSheetDelegate, UIAlertViewDelegate, FriendDataManagerDelegate, TTBlockManagerDelegate>

@property(nonatomic, strong)FriendDataManager * friendDataManager;
@property(nonatomic, strong)TTBlockManager * blockUserManager;
@property(nonatomic, strong)TTActionSheetController *actionSheetController;
@end

@implementation ExploreMomentListCellHeaderItem

- (void)dealloc
{
    [_friendDataManager cancelAllRequests];
    self.friendDataManager.delegate = nil;
    self.friendDataManager = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    self = [super initWithWidth:cellWidth userInfo:uInfo];
    if (self) {
        self.blockUserManager = [[TTBlockManager alloc] init];
        _blockUserManager.delegate = self;
        self.friendDataManager = [[FriendDataManager alloc] init];
        _friendDataManager.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relationActionNotification:) name:RelationActionSuccessNotification object:nil];
    }
    return self;
}

- (void)refreshForMomentModel:(ArticleMomentModel *)model {
    
    [super refreshForMomentModel:model];
    
    CGFloat width = self.width;
    
    //生成view
    BOOL needShowUserInfoItemView = [ExploreMomentListCellUserInfoItemView needShowForModel:model userInfo:self.userInfo];
    if (needShowUserInfoItemView) {
        if (!_userInfoItemView) {
            self.userInfoItemView = [[ExploreMomentListCellUserInfoItemView alloc] initWithWidth:width userInfo:self.userInfo];
            self.userInfoItemView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [_userInfoItemView.arrowButton addTarget:self action:@selector(arrowButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_userInfoItemView];
        }
        _userInfoItemView.hidden = NO;
        BOOL showTimeLabel = ![self shouldAddReportEntranceInUserInfoItem];
        self.userInfoItemView.showTimeLabel = showTimeLabel;
    }
    else {
        _userInfoItemView.hidden = YES;
    }
    
    BOOL needShowCommentItemView = [ExploreMomentListCellCommentItemView needShowForModel:model userInfo:self.userInfo];
    if (needShowCommentItemView) {
        if (!_commentItemView) {
            self.commentItemView = [[ExploreMomentListCellCommentItemView alloc] initWithWidth:width userInfo:self.userInfo];
            self.commentItemView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:_commentItemView];
            
            //            [self.commentItemView.commentLabel attachLongPressHandler];
        }
        _commentItemView.hidden = NO;
    }
    else {
        _commentItemView.hidden = YES;
    }
    
    BOOL needShowTimeAndReportItemView = ([ExploreMomentListCellTimeAndReportItem needShowForModel:model userInfo:self.userInfo] && [self shouldAddReportEntranceInUserInfoItem]);
    if (needShowTimeAndReportItemView) {
        if (!_timeAndReportItemView) {
            self.timeAndReportItemView = [[ExploreMomentListCellTimeAndReportItem alloc] initWithWidth:width userInfo:self.userInfo];
            __weak typeof(self) wself = self;
            self.timeAndReportItemView.trigReportActionBlock = ^() {
                wrapperTrackEvent(@"update_detail", @"report");
                __strong typeof(wself) self = wself;
                [self presentReportView];
            };
            self.timeAndReportItemView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:_timeAndReportItemView];
        }
        _timeAndReportItemView.hidden = NO;
    }
    else {
        _timeAndReportItemView.hidden = YES;
    }
    
//    BOOL needShowForumItemView = [ExploreMomentListCellForumItemView needShowForModel:model userInfo:self.userInfo];
//    if (needShowForumItemView) {
//        if (!_forumItemView) {
//            self.forumItemView = [[ExploreMomentListCellForumItemView alloc] initWithWidth:width userInfo:self.userInfo];
//            self.forumItemView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//            [self addSubview:_forumItemView];
//        }
//        _forumItemView.hidden = NO;
//    }
//    else {
//        _forumItemView.hidden = YES;
//    }
    
    BOOL needShowOriginArticleItemView = [ExploreMomentListCellOriginArticleItemView needShowForModel:model userInfo:self.userInfo itemViewType:ExploreMomentListCellOriginArticleItemViewTypeMoment];
    if (needShowOriginArticleItemView) {
        if (!_originArticleItemView) {
            self.originArticleItemView = [[ExploreMomentListCellOriginArticleItemView alloc] initWithWidth:width userInfo:self.userInfo itemViewType:ExploreMomentListCellOriginArticleItemViewTypeMoment];
            self.originArticleItemView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            //TODO: fromsource待完善
            NewsGoDetailFromSource fromSource = NewsGoDetailFromSourceUnknow;
            if (self.isDetailView) {
                fromSource = NewsGoDetailFromSourceUpdateDetail;
            } else {
                switch (self.sourceType) {
                    case ArticleMomentSourceTypeForum:
                    {
                        
                    }
                        break;
                    case ArticleMomentSourceTypeMoment:
                    {
                        fromSource = NewsGoDetailFromSourceUpate;
                    }
                        break;
                    case ArticleMomentSourceTypeProfile:
                        fromSource = NewsGoDetailFromSourceProfile;
                        break;
                    default:
                        break;
                }
            }
            _originArticleItemView.goDetailFromSource = fromSource;
            [self addSubview:_originArticleItemView];
        }
        _originArticleItemView.hidden = NO;
    }
    else {
        _originArticleItemView.hidden = YES;
    }
    
    BOOL needShowActionItemView = [ExploreMomentListCellUserActionItemView needShowForModel:model userInfo:self.userInfo];
    if (needShowActionItemView) {
        if (!_actionItemView) {
            self.actionItemView = [[ExploreMomentListCellUserActionItemView alloc] initWithWidth:width userInfo:self.userInfo];
            self.actionItemView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:_actionItemView];
        }
        _actionItemView.hidden = NO;
    }
    else {
        _actionItemView.hidden = YES;
    }
    
    BOOL needShowPicItemView = [ExploreMomentListCellPicItemView needShowForModel:model userInfo:self.userInfo];
    if (needShowPicItemView) {
        if (!_picItemView) {
            self.picItemView = [[ExploreMomentListCellPicItemView alloc] initWithWidth:width userInfo:self.userInfo];
            self.picItemView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:_picItemView];
        }
        _picItemView.hidden = NO;
    }
    else {
        _picItemView.hidden = YES;
    }
    
    BOOL needShowForwardItemView = [ExploreMomentListCellForwardItemView needShowForModel:model userInfo:self.userInfo];
    if (needShowForwardItemView) {
        if (!_forwardItemView) {
            self.forwardItemView = [[ExploreMomentListCellForwardItemView alloc] initWithWidth:width userInfo:self.userInfo];
            self.forwardItemView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:_forwardItemView];
            
            [self.forwardItemView.commentLabel attachLongPressHandler];
        }
        _forwardItemView.hidden = NO;
    }
    else {
        _forwardItemView.hidden = YES;
    }
    
    //设置数据
    CGFloat originY = 0;
    
    if (needShowUserInfoItemView) {
        [_userInfoItemView refreshForMomentModel:model];
        originY = (_userInfoItemView.bottom);
    }
    
    if (needShowCommentItemView) {
        [_commentItemView refreshForMomentModel:model];
        if (needShowTimeAndReportItemView) {
            originY -= kCommentItemTopInsetWhenReportShown;
        }
        _commentItemView.top = originY;
        originY = (_commentItemView.bottom);
    }
    
    if (needShowTimeAndReportItemView) {
        [_timeAndReportItemView refreshForMomentModel:model];
        _timeAndReportItemView.top = originY;
        originY = _timeAndReportItemView.bottom;
    }
    
//    if (needShowForumItemView) {
//        _forumItemView.top = originY;
//        [_forumItemView refreshForMomentModel:model];
//        originY = (_forumItemView.bottom);
//    }
    
    if (needShowOriginArticleItemView) {
        _originArticleItemView.top = originY;
        [_originArticleItemView refreshForMomentModel:model];
        originY = (_originArticleItemView.bottom);
    }
    
    if (needShowForwardItemView) {
        _forwardItemView.top = originY;
        [_forwardItemView refreshForMomentModel:model];
        originY = (_forwardItemView.bottom);
    }
    
    if (needShowPicItemView) {
        _picItemView.top = originY;
        [_picItemView refreshForMomentModel:model];
        originY = (_picItemView.bottom);
    }
    
    if (needShowActionItemView) {
        _actionItemView.top = originY;
        [_actionItemView refreshForMomentModel:model];
    }
}

+ (BOOL)needShowForModel:(ArticleMomentModel *)model userInfo:(NSDictionary *)uInfo
{
    return YES;
}

- (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth
{
    return [ExploreMomentListCellHeaderItem heightForMomentModel:model cellWidth:cellWidth userInfo:self.userInfo];
}

+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)width userInfo:(NSDictionary *)uInfo
{
    CGFloat height = 0;
    height = [ExploreMomentListCellUserInfoItemView heightForMomentModel:model cellWidth:width userInfo:uInfo];
    height += [ExploreMomentListCellCommentItemView heightForMomentModel:model cellWidth:width userInfo:uInfo];
    ArticleMomentSourceType sourceType = [[uInfo objectForKey:kMomentListCellItemBaseUserInfoSourceTypeKey] integerValue];
    if ([self.class reportSourceWithSourceType:sourceType] == TTReportSourceCommentMoment) {
        height += [ExploreMomentListCellTimeAndReportItem heightForMomentModel:model cellWidth:width userInfo:uInfo];
        height -= kCommentItemTopInsetWhenReportShown;
    }
//    height += [ExploreMomentListCellForumItemView heightForMomentModel:model cellWidth:width userInfo:uInfo];
    height += [ExploreMomentListCellForwardItemView heightForMomentModel:model cellWidth:width userInfo:uInfo];
    height += [ExploreMomentListCellPicItemView heightForMomentModel:model cellWidth:width userInfo:uInfo];
    height += [ExploreMomentListCellUserActionItemView heightForMomentModel:model cellWidth:width userInfo:uInfo];
    height += [ExploreMomentListCellOriginArticleItemView heightForMomentModel:model cellWidth:width userInfo:uInfo itemViewType:ExploreMomentListCellOriginArticleItemViewTypeMoment];
    return height;
}

- (BOOL)isUserHimself
{
    return [TTAccountManager isLogin] && ([[TTAccountManager userID] longLongValue] == [self.momentModel.user.ID longLongValue]);
}

- (void)arrowButtonClicked
{
    if ([TTTabBarProvider isWeitoutiaoOnTabBar] && self.sourceType == ArticleMomentSourceTypeMoment) {
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:self.momentModel.ID forKey:@"item_id"];
        [extra setValue:self.momentModel.group.ID forKey:@"value"];
        [TTTrackerWrapper event:@"micronews_tab" label:@"more" value:nil extValue:nil extValue2:nil dict:[extra copy]];
    }
    else if (self.listUmengEventName) {
        wrapperTrackEvent(self.listUmengEventName, @"more");
    }else if (self.detailUmengEventName){
        wrapperTrackEvent(self.detailUmengEventName, @"more");
    }
    
    NSString * destructiveButtonTitle = nil;
    NSString * followUnfollowButtonTitle = nil;
    NSString * blockUnblockButtonTitle = nil;
    NSString * reportButtonTitle = nil;
    int tag = 0;
    if ([self isUserHimself]) {
        destructiveButtonTitle = ActionTitleDelete;
        tag = kActionToSelfSheetTag;
    }
    else {
        if (self.momentModel.user.isBlocking) {
            blockUnblockButtonTitle = ActionTitleUnBlock;
            tag = kActionToBlockingUserSheetTag;
        } else {
            blockUnblockButtonTitle = ActionTitleBlock;
            if (self.momentModel.user.isFriend) {
                followUnfollowButtonTitle = ActionTitleUnFollow;
            }
            else {
                followUnfollowButtonTitle = ActionTitleFollow;
            }
            
            tag = kActionToUnblockingUserSheetTag;
        }
        reportButtonTitle = ActionTitleReport;
    }
    
    NSString * adminTitle = nil;
    if (self.momentModel.isAdmin) {
        tag = tag | kHasAdminActionSheetTag;
        adminTitle = ActionTitleAdmin;
    }
    
    UIActionSheet * sheet = nil;
    if (tag & kActionToSelfSheetTag) {
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:adminTitle, nil];
        
    } else if (tag & kActionToBlockingUserSheetTag) {
        if ([self shouldAddReportEntranceInUserInfoItem]) {
            sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:blockUnblockButtonTitle,
                     adminTitle, nil];
        }
        else {
            sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:blockUnblockButtonTitle, reportButtonTitle, adminTitle, nil];
        }
    } else {
        if ([self shouldAddReportEntranceInUserInfoItem]) {
            sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:followUnfollowButtonTitle, blockUnblockButtonTitle, adminTitle, nil];
        }
        else {
            sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:followUnfollowButtonTitle, blockUnblockButtonTitle, reportButtonTitle, adminTitle, nil];
        }
    }
    sheet.tag = tag;
    [sheet showInView:self];
}

#pragma mark -- UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    NSString * title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:ActionTitleAdmin]) {
        if (self.listUmengEventName) {
            wrapperTrackEvent(self.listUmengEventName, @"manage");
        }else if (self.detailUmengEventName){
            wrapperTrackEvent(self.detailUmengEventName, @"manage");
        }
        NSString * str = [NSString stringWithFormat:@"%@%@", [ArticleURLSetting momentAdminURL], self.momentModel.ID];
        ssOpenWebView([TTStringHelper URLWithURLString:str], NSLocalizedString(@"管理", nil), [TTUIResponderHelper topNavigationControllerFor: self], NO, nil);
        return;
    }
    
    if ([title isEqualToString:ActionTitleDelete]) {
        if (!isEmptyString(self.momentModel.ID)) {
            if (self.sourceType == ArticleMomentSourceTypeMoment) {
                wrapperTrackEvent(@"delete", @"update");
            } else if (self.sourceType == ArticleMomentSourceTypeForum) {
                wrapperTrackEvent(@"delete", @"post");
            } else if (self.sourceType == ArticleMomentSourceTypeProfile) {
                wrapperTrackEvent(@"delete", @"profile");
            }
            
            //统一由 ExploreDeleteManager发通知 @zengruihuan
            [[ExploreDeleteManager shareManager] deleteMomentForMomentID:self.momentModel.ID];
        }
        
        return;
    }
    
    if ([title isEqualToString:ActionTitleReport]) {
        if ([TTTabBarProvider isWeitoutiaoOnTabBar] && self.sourceType == ArticleMomentSourceTypeMoment) {
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.momentModel.ID forKey:@"item_id"];
            [extra setValue:self.momentModel.group.ID forKey:@"value"];
            [TTTrackerWrapper event:@"micronews_tab" label:@"report" value:nil extValue:nil extValue2:nil dict:[extra copy]];
        }
        wrapperTrackEvent(@"update_detail", @"report");
        [self presentReportView];
        return;
    }
    
    if ([title isEqualToString:ActionTitleFollow]) {
        if (![TTAccountManager isLogin]) {
            [self showLoginViewWithSource:@"social_other"];
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"请先登录" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        } else {
            if ([TTTabBarProvider isWeitoutiaoOnTabBar] && self.sourceType == ArticleMomentSourceTypeMoment) {
                NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
                [extra setValue:self.momentModel.ID forKey:@"item_id"];
                [extra setValue:self.momentModel.group.ID forKey:@"value"];
                [TTTrackerWrapper event:@"micronews_tab" label:@"follow" value:nil extValue:nil extValue2:nil dict:[extra copy]];
            }
            else if (self.listUmengEventName) {
                wrapperTrackEvent(self.listUmengEventName, @"follow");
            }else if (self.detailUmengEventName){
                wrapperTrackEvent(self.detailUmengEventName, @"follow");
            }
            
            [[TTFollowManager sharedManager] startFollowAction:FriendActionTypeFollow userID:self.momentModel.user.ID platform:nil name:self.momentModel.user.name from:nil reason:nil newReason:nil newSource:@(TTFollowNewSourceMomentList) completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
                NSString * indicatorTip = nil;
                if (error) {
                    indicatorTip = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
                    if (isEmptyString(indicatorTip)) {
                        indicatorTip = NSLocalizedString(type == FriendActionTypeFollow ? @"关注失败" : @"取消关注失败", nil);
                    }
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:indicatorTip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                } else {
                    if (type == FriendActionTypeFollow) {
                        indicatorTip = @"关注成功";
                        self.momentModel.user.isFriend = YES;
                        
//                        [[TTAuthorizeManager sharedManager].addressObj showAlertAtActionAddFriend:^{
//                            TTAddFriendViewController *addFriendController = [[TTAddFriendViewController alloc] init];
//                            addFriendController.autoSynchronizeAddressBook = YES;
//                            [[TTUIResponderHelper topNavigationControllerFor: nil] pushViewController:addFriendController animated:YES];
//                        }];
                        
                    } else if (type == FriendActionTypeUnfollow) {
                        indicatorTip = @"取消关注";
                        self.momentModel.user.isFriend = NO;
                    }
                    if (indicatorTip) {
                        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:indicatorTip indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                    }
                }
            }];
        }
        
        return;
    }
    
    if ([title isEqualToString:ActionTitleUnFollow]) {
        if ([TTTabBarProvider isWeitoutiaoOnTabBar] && self.sourceType == ArticleMomentSourceTypeMoment) {
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.momentModel.ID forKey:@"item_id"];
            [extra setValue:self.momentModel.group.ID forKey:@"value"];
            [TTTrackerWrapper event:@"micronews_tab" label:@"unfollow" value:nil extValue:nil extValue2:nil dict:[extra copy]];
        }
        else if (self.listUmengEventName) {
            wrapperTrackEvent(self.listUmengEventName, @"unfollow");
        }else if (self.detailUmengEventName){
            wrapperTrackEvent(self.detailUmengEventName, @"unfollow");
        }
        
        [[TTFollowManager sharedManager] startFollowAction:FriendActionTypeUnfollow userID:self.momentModel.user.ID platform:nil name:self.momentModel.user.name from:nil reason:nil newReason:nil newSource:@(TTFollowNewSourceMomentList) completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
            NSString * indicatorTip = nil;
            if (error) {
                indicatorTip = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
                if (isEmptyString(indicatorTip)) {
                    indicatorTip = NSLocalizedString(type == FriendActionTypeFollow ? @"关注失败" : @"取消关注失败", nil);
                }
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:indicatorTip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            } else {
                if (type == FriendActionTypeFollow) {
                    indicatorTip = @"关注成功";
                    self.momentModel.user.isFriend = YES;
                    
//                    [[TTAuthorizeManager sharedManager].addressObj showAlertAtActionAddFriend:^{
//                        TTAddFriendViewController *addFriendVC = [[TTAddFriendViewController alloc] init];
//                        addFriendVC.autoSynchronizeAddressBook = YES;
//                        [[TTUIResponderHelper topNavigationControllerFor: nil] pushViewController:addFriendVC animated:YES];
//                    }];
                    
                } else if (type == FriendActionTypeUnfollow) {
                    indicatorTip = @"取消关注";
                    self.momentModel.user.isFriend = NO;
                }
                if (indicatorTip) {
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:indicatorTip indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                }
            }
        }];
        
        return;
    }
    
    if ([title isEqualToString:ActionTitleBlock]) {
        if (![TTAccountManager isLogin]) {
            [self showLoginViewWithSource:@"social_other"];
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"请先登录" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            return;
        }
        if ([TTTabBarProvider isWeitoutiaoOnTabBar] && self.sourceType == ArticleMomentSourceTypeMoment) {
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.momentModel.ID forKey:@"item_id"];
            [extra setValue:self.momentModel.group.ID forKey:@"value"];
            [TTTrackerWrapper event:@"micronews_tab" label:@"blacklist" value:nil extValue:nil extValue2:nil dict:[extra copy]];
        }
        else if (self.listUmengEventName) {
            wrapperTrackEvent(self.listUmengEventName, @"blacklist");
            wrapperTrackEvent(@"blacklist", @"click_blacklist");
        }else if (self.detailUmengEventName){
            wrapperTrackEvent(self.detailUmengEventName, @"blacklist");
        }
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"确定拉黑该用户？" message:@"拉黑后此用户不能关注你，也无法给你发送任何消息" preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            if (self.listUmengEventName) {
                wrapperTrackEvent(self.listUmengEventName, @"quit_blacklist");
                wrapperTrackEvent(@"blacklist", @"quit_blacklist");
            }else if (self.detailUmengEventName){
                wrapperTrackEvent(self.detailUmengEventName, @"quit_blacklist");
            }
        }];
        [alert addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            if (self.listUmengEventName) {
                wrapperTrackEvent(self.listUmengEventName, @"confirm_blacklist");
                wrapperTrackEvent(@"blacklist", @"confirm_blacklist");
            }else if (self.detailUmengEventName){
                wrapperTrackEvent(self.detailUmengEventName, @"confirm_blacklist");
            }
            [_blockUserManager blockUser:self.momentModel.user.ID];
        }];
        [alert showFrom:self.viewController animated:YES];
        return;
    }
    
    if ([title isEqualToString:ActionTitleUnBlock]) {
        if ([TTTabBarProvider isWeitoutiaoOnTabBar] && self.sourceType == ArticleMomentSourceTypeMoment) {
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.momentModel.ID forKey:@"item_id"];
            [extra setValue:self.momentModel.group.ID forKey:@"value"];
            [TTTrackerWrapper event:@"micronews_tab" label:@"deblacklist" value:nil extValue:nil extValue2:nil dict:[extra copy]];
        }
        else if (self.listUmengEventName) {
            wrapperTrackEvent(self.listUmengEventName, @"deblacklist");
            wrapperTrackEvent(@"blacklist", @"click_deblacklist");
        }else if (self.detailUmengEventName){
            wrapperTrackEvent(self.detailUmengEventName, @"deblacklist");
        }
        [_blockUserManager unblockUser:self.momentModel.user.ID];
        return;
    }
}

- (void)showLoginViewWithSource:(NSString *)source
{
    [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeSocial source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeTip) {
            [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:source completion:^(TTAccountLoginState state) {
            }];
        }
    }];
}

- (void)presentReportView
{
    //added 5.2 举报请求增加commentID，groupID参数
    NSString *groupID = self.momentModel.group.ID;
    NSString *momentID = self.momentModel.ID;
    NSString *commentID = nil;
    TTGroupModel *groupModel = nil;
    UIResponder *needResponder = [self needResponder];
    if (needResponder) {
        if (isEmptyString(groupID) && [needResponder respondsToSelector:NSSelectorFromString(@"groupModel")]) {
            groupModel = [needResponder valueForKey:@"groupModel"];
            groupID = groupModel.groupID;
        }
        
        if (isEmptyString(momentID) && [needResponder respondsToSelector:NSSelectorFromString(@"momentModel")]) {
            ArticleMomentModel *momentModel = [needResponder valueForKey:@"momentModel"];
            momentID = momentModel.ID;
        }
        
        if ([needResponder respondsToSelector:NSSelectorFromString(@"commentModel")]) {
            SSCommentModel *commentModel = [needResponder valueForKey:@"commentModel"];
            commentID = [commentModel.commentID stringValue];
        }
    }
    
    self.actionSheetController = [[TTActionSheetController alloc] init];
    [self.actionSheetController insertReportArray:[TTReportManager fetchReportUserOptions]];
    [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
        if (parameters[@"report"]) {
            TTReportUserModel *model = [[TTReportUserModel alloc] init];
            model.userID = self.momentModel.user.ID;
            model.commentID = commentID;
            model.momentID = momentID;
            model.groupID = groupID;
            [[TTReportManager shareInstance] startReportUserWithType:parameters[@"report"] inputText:parameters[@"criticism"] message:nil source:@(TTReportSourceComment).stringValue userModel:model animated:YES];
        }
    }];
    
}

- (UIResponder *)needResponder
{
    UIResponder *responder = [self nextResponder];
    while (responder) {
        if ([responder isKindOfClass:NSClassFromString(@"ArticleMomentDetailViewController")]) {
            return responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}

+ (TTReportSource)reportSourceWithSourceType:(ArticleMomentSourceType)sourceType
{
    switch (sourceType) {
        case ArticleMomentSourceTypeArticleDetail:
        case ArticleMomentSourceTypeMomentDetail:
        case ArticleMomentSourceTypeMessage:
            return TTReportSourceCommentMoment;
        case ArticleMomentSourceTypeMoment:
            return TTReportSourceMomentList;
        case ArticleMomentSourceTypeProfile:
            return TTReportSourceProfileMoment;
        default:
            return TTReportSourceOthers;
    }
}

- (BOOL)shouldAddReportEntranceInUserInfoItem
{
    return ([self.class reportSourceWithSourceType:self.sourceType] == TTReportSourceCommentMoment) && ![self isUserHimself];
}

#pragma mark -- UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        if (self.listUmengEventName) {
            wrapperTrackEvent(self.listUmengEventName, @"confirm_blacklist");
            wrapperTrackEvent(@"blacklist", @"confirm_blacklist");
        }else if (self.detailUmengEventName){
            wrapperTrackEvent(self.detailUmengEventName, @"confirm_blacklist");
        }
        [_blockUserManager blockUser:self.momentModel.user.ID];
    } else {
        if (self.listUmengEventName) {
            wrapperTrackEvent(self.listUmengEventName, @"quit_blacklist");
            wrapperTrackEvent(@"blacklist", @"quit_blacklist");
        }else if (self.detailUmengEventName){
            wrapperTrackEvent(self.detailUmengEventName, @"quit_blacklist");
        }
    }
}

#pragma mark -- TTBlockManagerDelegate

- (void)blockUserManager:(TTBlockManager *)manager blocResult:(BOOL)success blockedUserID:(NSString *)userID error:(NSError *)error errorTip:(NSString *)errorTip
{
    if (error) {
        NSString * failedDescription = @"操作失败，请重试";
        if (!isEmptyString(errorTip)) {
            failedDescription = errorTip;
        }
        
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:failedDescription indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
    } else {
        self.momentModel.user.isBlocking = YES;
        self.momentModel.user.isFriend = NO;
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"拉黑成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
    }
}

- (void)blockUserManager:(TTBlockManager *)manager unblockResult:(BOOL)success unblockedUserID:(NSString *)userID error:(NSError *)error errorTip:(NSString *)errorTip
{
    if (error) {
        NSString * failedDescription = @"操作失败，请重试";
        if (!isEmptyString(errorTip)) {
            failedDescription = errorTip;
        }
        
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:failedDescription indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
    } else {
        self.momentModel.user.isBlocking = NO;
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"已解除黑名单" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
    }
}

#pragma mark -- FriendDataManagerDelegate

- (void)friendDataManager:(FriendDataManager*)dataManager finishActionType:(FriendActionType)type error:(NSError*)error result:(NSDictionary*)result
{
    NSString * indicatorTip = nil;
    if (error) {
        indicatorTip = @"操作失败，请重试";
        if (indicatorTip) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:indicatorTip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        }
    } else {
        if (type == FriendActionTypeFollow) {
            indicatorTip = @"关注成功";
            self.momentModel.user.isFriend = YES;
            
//            [[TTAuthorizeManager sharedManager].addressObj showAlertAtActionAddFriend:^{
//                TTAddFriendViewController *addFriendVC = [[TTAddFriendViewController alloc] init];
//                addFriendVC.autoSynchronizeAddressBook = YES;
//                [[TTUIResponderHelper topNavigationControllerFor: nil] pushViewController:addFriendVC animated:YES];
//            }];
            
        } else if (type == FriendActionTypeUnfollow) {
            indicatorTip = @"取消关注";
            self.momentModel.user.isFriend = NO;
        }
        if (indicatorTip) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:indicatorTip indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        }
    }
    
}

- (UIView *)topMostView
{
    UIViewController * topMost = [TTUIResponderHelper topViewControllerFor: self];
    if (topMost) {
        return topMost.view;
    }
    
    return nil;
}

- (void)relationActionNotification:(NSNotification*)notification
{
    FriendActionType tType = [[notification.userInfo objectForKey:kRelationActionSuccessNotificationActionTypeKey] intValue];
    if(tType == FriendActionTypeFollow || tType == FriendActionTypeUnfollow)
    {
        NSString *userID = [notification.userInfo objectForKey:kRelationActionSuccessNotificationUserIDKey];
        
        if ([userID longLongValue] == [self.momentModel.user.ID longLongValue]) {
            self.momentModel.user.isFriend = (tType == FriendActionTypeFollow ? YES : NO);
        }
    }
}

@end
