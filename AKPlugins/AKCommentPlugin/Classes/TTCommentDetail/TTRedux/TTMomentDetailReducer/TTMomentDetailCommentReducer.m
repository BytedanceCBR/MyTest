//
//  TTMomentDetailCommentReducer.m
//  Article
//
//  Created by muhuai on 16/8/21.
//
//

#import <TTReporter/TTReportManager.h>
#import <TTPlatformUIModel/TTGroupModel.h>
#import <TTPlatformUIModel/TTActionSheetConst.h>
#import <TTPlatformUIModel/TTActionSheetController.h>
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <TTNewsAccountBusiness/SSUserModel.h>
#import <TTNewsAccountBusiness/SSMyUserModel.h>
#import "TTMomentDetailCommentReducer.h"
#import "TTMomentDetailAction.h"
#import "TTMomentDetailStore.h"


@interface TTMomentDetailCommentReducer ()
@property (nonatomic, strong) TTActionSheetController *actionSheetController;
@property (nonatomic, strong) NSMutableSet *uniqueKeySet;
@end

@implementation TTMomentDetailCommentReducer
@synthesize store = _store;

- (State *)handleAction:(Action *)action withState:(State *)state {
    TTMomentDetailAction *detailAction = (TTMomentDetailAction *)action;
    TTMomentDetailIndependenceState *independenceState = (TTMomentDetailIndependenceState *)state;
    switch (detailAction.type) {
        case TTMomentDetailActionTypeLoadComment:
            independenceState = [self handleLoadCommentAction:detailAction withState:independenceState];
            break;
        case TTMomentDetailActionTypePublishComment:
            independenceState = [self handlePublishCommentAction:detailAction withState:independenceState];
            break;
        case TTMomentDetailActionTypeRefreshComment:
            independenceState = [self handleRefreshCommentAction:detailAction withState:independenceState];
            break;
        case TTMomentDetailActionTypeReplyCommentDig:
            independenceState = [self handleReplyCommentDigAction:detailAction withState:independenceState];
            break;
        case TTMomentDetailActionTypeCommentDig:
            independenceState = [self handleCommentDigAction:detailAction withState:independenceState];
            break;
        case TTMomentDetailActionTypeReport:
            independenceState = [self handleReportAction:detailAction withState:independenceState];
            break;
        case TTMomentDetailActionTypeDeleteComment:
            independenceState = [self handleDeleteCommentAction:detailAction withState:independenceState];
            break;
        case TTMomentDetailActionTypeLoadDig:
            independenceState = [self handleLoadDigAction:detailAction withState:independenceState];
            break;
        case TTMomentDetailActionTypeBanEmojiInput:
            independenceState = [self handleBanEmojiInputAction:detailAction withState:independenceState];
            break;
        case TTMomentDetailActionTypeUnblock:
            break;
        default:
            break;
    }
    return independenceState;
}

- (TTMomentDetailIndependenceState *)handleLoadCommentAction:(TTMomentDetailAction *)action withState:(TTMomentDetailIndependenceState *)state {
    
    state.isLoadingComment = NO;
    state.isFailedLoadComment = [action.payload tt_boolValueForKey:@"isFailedLoadComment"];
    if (state.isFailedLoadComment) {
        return state;
    }
    
    NSString *groupID = state.detailModel.groupModel.groupID;
    
    NSArray<TTCommentDetailReplyCommentModel *> *stickCommentModels = [action.payload arrayValueForKey:@"stickCommentModels" defaultValue:@[]];
    
    NSArray<TTCommentDetailReplyCommentModel *> *allCommentModels = [action.payload arrayValueForKey:@"allCommentModels" defaultValue:@[]];
    NSArray<TTCommentDetailReplyCommentModel *> *hotCommentModels = [action.payload arrayValueForKey:@"hotCommentModels" defaultValue:@[]];
    
    if (state.stashStickComments.count) {
        stickCommentModels = [state.stashStickComments arrayByAddingObjectsFromArray:stickCommentModels];
        state.stashStickComments = nil;
    }
    BOOL stickHasMore = [action.payload tt_boolValueForKey:@"stickHasMore"];
    if (state.hasMoreStickComment && !stickHasMore && !isEmptyString(state.stickID)) {
        //代表最后一次 置顶消息
        state.offset = 0;
    } else {
        state.offset += 20;
    }
    
    state.hasMoreStickComment = stickHasMore;
    state.hasMoreComment = [action.payload[@"hasMore"] boolValue];
    
    //    //这逻辑也是🌞了🐶了...
    BOOL isStickAction = [action.payload tt_boolValueForKey:@"isStickAction"];
    //此次请求是置顶请求下  如果 返回的置顶评论少于20 并且已经没有置顶评论了. 则再请求一次普通接口. 补充一下评论数
    if (!state.hasMoreStickComment && state.hasMoreComment && stickCommentModels.count < 10 && isStickAction) {
        state.stashStickComments = stickCommentModels;
        TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeLoadComment comment:state.commentModel];
        action.shouldMiddlewareHandle = YES;
        
        [self.store dispatch:action];
        return state;
    }
    
    for (TTCommentDetailReplyCommentModel *model in stickCommentModels) {
        if ([self.uniqueKeySet containsObject:model.commentID]) {
            continue;
        }
        if (state.stickComments.count == 0 && stickCommentModels.count != 0) {
            state.defaultRelyModel = stickCommentModels.firstObject;
        }
        
        model.groupID = groupID;
        [self.uniqueKeySet addObject:model.commentID];
        [state.stickComments addObject:model];
        [state.stickCommentLayouts addObject:[[TTCommentDetailCellLayout alloc] initWithCommentModel:model containViewWidth:state.cellWidth]];
    }
    
    for (TTCommentDetailReplyCommentModel *model in allCommentModels) {
        if ([self.uniqueKeySet containsObject:model.commentID]) {
            continue;
        }
        model.groupID = groupID;
        [self.uniqueKeySet addObject:model.commentID];
        [state.allComments addObject:model];
        [state.allCommentLayouts addObject:[[TTCommentDetailCellLayout alloc] initWithCommentModel:model containViewWidth:state.cellWidth]];
    }
    
    for (TTCommentDetailReplyCommentModel *model in hotCommentModels) {
        if ([self.uniqueKeySet containsObject:model.commentID]) {
            continue;
        }
        model.groupID = groupID;
        [self.uniqueKeySet addObject:model.commentID];
        [state.hotComments addObject:model];
        [state.hotCommentLayouts addObject:[[TTCommentDetailCellLayout alloc] initWithCommentModel:model containViewWidth:state.cellWidth]];
    }
    
    //接口返回的评论数
    NSInteger totalCount = [action.payload tt_integerValueForKey:@"totalCount"];
    
    state.detailModel.commentCount = totalCount;

    state.detailModel.commentPlaceholder = [action.payload tt_stringValueForKey:@"commentPlaceholder"];

    return state;
}

- (TTMomentDetailIndependenceState *)handlePublishCommentAction:(TTMomentDetailAction *)action withState:(TTMomentDetailIndependenceState *)state {
    state.defaultRelyModel = nil;
    
    TTCommentDetailReplyCommentModel *replyCommentModel = action.replyCommentModel;
    
    if (!replyCommentModel) {
        return state;
    }
    
    TTCommentDetailCellLayout *cellLayout = [[TTCommentDetailCellLayout alloc] initWithCommentModel:replyCommentModel containViewWidth:state.cellWidth];
    
    if (cellLayout) {
        [self.uniqueKeySet addObject:replyCommentModel.commentID];
        if (state.stickCommentLayouts.count) {
            [state.stickComments insertObject:replyCommentModel atIndex:0];
            [state.stickCommentLayouts insertObject:cellLayout atIndex:0];
            state.needMarkedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        } else {
            [state.allComments insertObject:replyCommentModel atIndex:0];
            [state.allCommentLayouts insertObject:cellLayout atIndex:0];
            state.needMarkedIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
        }
    }
    
    state.detailModel.commentCount += 1;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:replyCommentModel.qutoedCommentModel.commentID? :state.detailModel.commentID forKey:@"comment_id"];
    [params setValue:@(state.detailModel.groupSource).stringValue forKey:@"group_source"];
    [params setValue:[state.detailModel.authorID isEqualToString:[TTAccountManager userID]]? @"1": @"0" forKey:@"author"];
    [params setValue:@(state.isFromMessage).stringValue forKey:@"message"];
    [params setValue:state.detailModel.groupModel.groupID forKey:@"group_id"];
    [TTTrackerWrapper eventV3:@"comment_reply" params:[params copy]];
    
    return state;
}

- (TTMomentDetailIndependenceState *)handleRefreshCommentAction:(TTMomentDetailAction *)action withState:(TTMomentDetailIndependenceState *)state {
    NSArray<TTCommentDetailCellLayout *> *stickCommentLayouts = [TTCommentDetailCellLayout arrayOfLayoutsFromModels:state.stickComments containViewWidth:state.cellWidth];
    
    NSArray<TTCommentDetailCellLayout *> *hotCommentLayouts = [TTCommentDetailCellLayout arrayOfLayoutsFromModels:state.hotComments containViewWidth:state.cellWidth];
    
    NSArray<TTCommentDetailCellLayout *> *allCommentLayouts = [TTCommentDetailCellLayout arrayOfLayoutsFromModels:state.allComments containViewWidth:state.cellWidth];
    
    [state.stickCommentLayouts removeAllObjects];
    [state.hotCommentLayouts removeAllObjects];
    [state.allCommentLayouts removeAllObjects];
    [state.stickCommentLayouts addObjectsFromArray:stickCommentLayouts];
    [state.hotCommentLayouts addObjectsFromArray:hotCommentLayouts];
    [state.allCommentLayouts addObjectsFromArray:allCommentLayouts];
    return state;
}

- (TTMomentDetailIndependenceState *)handleDeleteCommentAction:(TTMomentDetailAction *)action withState:(TTMomentDetailIndependenceState *)state {
    
    if (action.source == TTMomentDetailActionSourceTypeHeader) {
        //        [[TTUIResponderHelper topNavigationControllerFor: nil] popViewControllerAnimated:YES];
        return state;
    }
    
    if (!action.replyCommentModel) {
        return state;
    }
    
    
    NSUInteger index = [state.allComments indexOfObject:action.replyCommentModel];
    if (index != NSNotFound) {
        [self.uniqueKeySet removeObject:action.replyCommentModel.commentID];
        [state.allComments removeObjectAtIndex:index];
        [state.allCommentLayouts removeObjectAtIndex:index];
        state.detailModel.commentCount = MAX(state.detailModel.commentCount - 1, 0);
        return state;
    }
    
    index = [state.hotComments indexOfObject:action.replyCommentModel];
    if (index != NSNotFound) {
        [self.uniqueKeySet removeObject:action.replyCommentModel.commentID];
        [state.hotComments removeObjectAtIndex:index];
        [state.hotCommentLayouts removeObjectAtIndex:index];
        state.detailModel.commentCount = MAX(state.detailModel.commentCount - 1, 0);
        return state;
    }
    
    index = [state.stickComments indexOfObject:action.replyCommentModel];
    if (index != NSNotFound) {
        [self.uniqueKeySet removeObject:action.replyCommentModel.commentID];
        [state.stickComments removeObjectAtIndex:index];
        [state.stickCommentLayouts removeObjectAtIndex:index];
        state.detailModel.commentCount = MAX(state.detailModel.commentCount - 1, 0);
        return state;
    }
    
    return state;
}

- (TTMomentDetailIndependenceState *)handleCommentDigAction:(TTMomentDetailAction *)action withState:(TTMomentDetailIndependenceState *)state {
    SSUserModel *userModel;
    if ([[TTAccountManager sharedManager] myUser]) {
        SSMyUserModel *myUserModel = [[TTAccountManager sharedManager] myUser];
        userModel = [[SSUserModel alloc] init];
        userModel.ID = myUserModel.ID;
        userModel.name = myUserModel.name;
        userModel.avatarURLString = myUserModel.avatarURLString;
        userModel.userDescription = myUserModel.userDescription;
        userModel.userAuthInfo = myUserModel.userAuthInfo;
        userModel.verifiedReason = myUserModel.verifiedReason;
        userModel.isOwner = [state.detailModel.user.ID isEqualToString:myUserModel.ID];
        //            [state.detailModel.digUsers insertObject:userModel atIndex:0];
        [state.detailModel.digUsers removeObject:userModel];
    }

    
    if (state.detailModel.userDigg) {
        //取消点赞
        state.detailModel.diggCount -= 1;
        state.detailModel.diggCount = MAX(0, state.detailModel.diggCount);
        state.detailModel.userDigg = NO;
        if (userModel) {
            [state.detailModel.digUsers removeObject:userModel];
        }
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:state.detailModel.commentID forKey:@"comment_id"];
        [params setValue:state.detailModel.user.ID forKey:@"user_id"];
        [TTTrackerWrapper eventV3:@"comment_undigg" params:params];
    } else {
        //点赞
        state.detailModel.diggCount += 1;
        state.detailModel.userDigg = YES;
        if (userModel) {
            [state.detailModel.digUsers insertObject:userModel atIndex:0];
        }
    }
    
    return state;
}

- (TTMomentDetailIndependenceState *)handleReplyCommentDigAction:(TTMomentDetailAction *)action withState:(TTMomentDetailIndependenceState *)state {
    if (action.replyCommentModel.userDigg) {
        //取消点赞
        action.replyCommentModel.diggCount -= 1;
        action.replyCommentModel.diggCount = MAX(0, action.replyCommentModel.diggCount);
        action.replyCommentModel.userDigg = NO;
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:state.detailModel.commentID forKey:@"comment_id"];
        [params setValue:action.replyCommentModel.user.ID forKey:@"user_id"];
        [TTTrackerWrapper eventV3:@"comment_undigg" params:params];
    } else {
        //点赞
        action.replyCommentModel.diggCount += 1;
        action.replyCommentModel.userDigg = YES;
        
        
        //可能显示appStore评分视图
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TTAppStoreStarManagerShowNotice" object:nil userInfo:@{@"trigger":@"like"}];
    }
    
    return state;
}

- (TTMomentDetailIndependenceState *)handleLoadDigAction:(TTMomentDetailAction *)action withState:(TTMomentDetailIndependenceState *)state {
    state.detailModel.digUsers = action.payload[@"diggUsers"];
    state.detailModel.diggCount = MAX(state.detailModel.diggCount, [action.payload tt_integerValueForKey:@"diggCount"]);
    return state;
}
- (TTMomentDetailIndependenceState *)handleReportAction:(TTMomentDetailAction *)action withState:(TTMomentDetailIndependenceState *)state {
    TTCommentDetailModel *commentDetailModel = state.detailModel;
    self.actionSheetController = [[TTActionSheetController alloc] init];
    
    [self.actionSheetController insertReportArray:[TTReportManager fetchReportUserOptions]];
    [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
        
        if (parameters[@"report"]) {
            TTReportUserModel *model = [[TTReportUserModel alloc] init];
            model.userID = commentDetailModel.user.ID;
            model.commentID = commentDetailModel.commentID;
            model.momentID = commentDetailModel.dongtaiID;
            model.groupID = commentDetailModel.groupModel.groupID;
            [[TTReportManager shareInstance] startReportUserWithType:parameters[@"report"] inputText:parameters[@"criticism"] message:nil source:@(TTReportSourceCommentMoment).stringValue userModel:model animated:YES];
        }
    }];
    return state;
}

- (TTMomentDetailIndependenceState *)handleBanEmojiInputAction:(TTMomentDetailAction *)action withState:(TTMomentDetailIndependenceState *)state {
    return state;
}

- (NSMutableSet *)uniqueKeySet {
    if (!_uniqueKeySet) {
        _uniqueKeySet = [[NSMutableSet alloc] init];
    }
    return _uniqueKeySet;
}
@end
