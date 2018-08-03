//
//  TTDynamicDetailDigReducer.m
//  Article
//
//  Created by muhuai on 16/8/21.
//
//

#import "TTMomentDetailUserReducer.h"
#import "TTCommentDetailReplyCommentModel.h"
#import "TTMomentDetailAction.h"
#import "TTMomentDetailStore.h"
#import <TTNetworkUtil.h>
#import <TTRoute/TTRoute.h>
#import <TTEntry/TTFollowNotifyServer.h>


@implementation TTMomentDetailUserReducer
@synthesize store = _store;

- (State *)handleAction:(Action *)action withState:(State *)state {
    if (![action isKindOfClass:[TTMomentDetailAction class]] || ![state isKindOfClass:[TTMomentDetailIndependenceState class]]) {
        return state;
    }
    TTMomentDetailAction *detailAction = (TTMomentDetailAction *)action;
    TTMomentDetailIndependenceState *independenceState = (TTMomentDetailIndependenceState *)state;
    switch (detailAction.type) {
        case TTMomentDetailActionTypeFollow:
            independenceState = [self handleFollowAction:detailAction withState:independenceState];
            break;
        case TTMomentDetailActionTypeUnfollow:
            independenceState = [self handleUnFollowAction:detailAction withState:independenceState];
            break;
        case TTMomentDetailActionTypeUnblock:
            independenceState = [self handleUnBlockAction:detailAction withState:independenceState];
            break;
        case TTMomentDetailActionTypeEnterProfile:
            independenceState = [self handleEnterProfileAction:detailAction withState:independenceState];
            break;
        case TTMomentDetailActionTypeEnterDiggList:
            independenceState = [self handleEnterDiggListAction:detailAction withState:independenceState];
            break;
        case TTMomentDetailActionTypeFollowNotify:
            independenceState = [self handleFollowNotifyAction:detailAction withState:independenceState];
        default:
            break;
    }
    return independenceState;
}

- (TTMomentDetailIndependenceState *)handleEnterProfileAction:(TTMomentDetailAction *)action withState:(TTMomentDetailIndependenceState *)state {
    NSString *userID = action.payload[@"userID"];
    NSString *source = action.payload[@"source"];

    NSMutableDictionary *baseCondition = [[NSMutableDictionary alloc] init];
    [baseCondition setValue:userID forKey:@"uid"];
    [baseCondition setValue:source forKey:@"source"];
    [baseCondition setValue:action.payload[@"categoryName"] forKey:@"category_name"];
    [baseCondition setValue:action.payload[@"fromPage"] forKey:@"from_page"];
    [baseCondition setValue:action.payload[@"groupId"] forKey:@"group_id"];
    [[TTRoute sharedRoute] openURLByPushViewController:[TTNetworkUtil URLWithURLString:@"sslocal://profile"] userInfo:TTRouteUserInfoWithDict(baseCondition)];
    return state;
}

- (TTMomentDetailIndependenceState *)handleEnterDiggListAction:(TTMomentDetailAction *)action withState:(TTMomentDetailIndependenceState *)state {
    [[TTRoute sharedRoute] openURLByPushViewController:[TTNetworkUtil URLWithURLString:@"sslocal://comment_digg_list"] userInfo:TTRouteUserInfoWithDict(action.payload)];
    return state;
}

- (TTMomentDetailIndependenceState *)handleUnBlockAction:(TTMomentDetailAction *)action withState:(TTMomentDetailIndependenceState *)state {
    state.detailModel.user.isBlocking = NO;
    return state;
}

- (TTMomentDetailIndependenceState *)handleUnFollowAction:(TTMomentDetailAction *)action withState:(TTMomentDetailIndependenceState *)state {
    state.detailModel.user.isFollowing = NO;
    return state;
}

- (TTMomentDetailIndependenceState *)handleFollowAction:(TTMomentDetailAction *)action withState:(TTMomentDetailIndependenceState *)state {
    state.detailModel.user.isFollowing = YES;
    return state;
}

- (TTMomentDetailIndependenceState *)handleFollowNotifyAction:(TTMomentDetailAction *)action withState:(TTMomentDetailIndependenceState *)state {
    TTFollowNotify *notify = action.payload[@"notify"];
    if ([state.detailModel.user.ID isEqualToString:notify.ID]) {
        if (notify.actionType == TTFollowActionTypeFollow) {
            state.detailModel.user.isFollowing = YES;
        }
        if (notify.actionType == TTFollowActionTypeUnfollow) {
            state.detailModel.user.isFollowing = NO;
        }
    }
    [state.hotComments enumerateObjectsUsingBlock:^(TTCommentDetailReplyCommentModel   * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([notify.ID isEqualToString:model.user.ID]) {
            if (notify.actionType == TTFollowActionTypeFollow) {
                model.user.isFollowing = YES;
            }
            if (notify.actionType == TTFollowActionTypeUnfollow) {
                model.user.isFollowing = NO;
            }
        }
    }];
    [state.allComments enumerateObjectsUsingBlock:^(TTCommentDetailReplyCommentModel   * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([notify.ID isEqualToString:model.user.ID]) {
            if (notify.actionType == TTFollowActionTypeFollow) {
                model.user.isFollowing = YES;
            }
            if (notify.actionType == TTFollowActionTypeUnfollow) {
                model.user.isFollowing = NO;
            }
        }
    }];
    return state;
}
@end
