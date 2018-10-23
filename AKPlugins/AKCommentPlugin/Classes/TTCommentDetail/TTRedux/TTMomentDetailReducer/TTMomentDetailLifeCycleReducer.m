//
//  TTMomentDetailLifeCycleReducer.m
//  Article
//
//  Created by muhuai on 16/8/21.
//
//

#import "TTMomentDetailLifeCycleReducer.h"
#import "TTMomentDetailStore.h"
#import <TTBaseLib/TTBaseMacro.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>



@implementation TTMomentDetailLifeCycleReducer
@synthesize store = _store;

- (TTMomentDetailIndependenceState *)handleAction:(Action *)action withState:(TTMomentDetailIndependenceState *)state {
    if (![action isKindOfClass:[TTMomentDetailAction class]] || ![state isKindOfClass:[TTMomentDetailIndependenceState class]]) {
        return state;
    }
    TTMomentDetailAction *detailAction = (TTMomentDetailAction *)action;
    switch (detailAction.type) {
        case TTMomentDetailActionTypeInit:
            state = [self handleInitAction:detailAction withState:state];
            break;
        case TTMomentDetailActionTypeWillDisappear:
            state = [self handleWillDisappearAction:detailAction withState:state];
        default:
            break;
    }
    return state;
}

- (TTMomentDetailIndependenceState *)handleInitAction:(TTMomentDetailAction *)action withState:(TTMomentDetailIndependenceState *)state {

    DetailActionRequestManager *commentActionManager = [[DetailActionRequestManager alloc] init];
    [commentActionManager setContext:({
        TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
        context.groupModel = action.commentModel.groupModel;
        if (state.commentID? :action.commentModel.commentID) {
            context.itemCommentID = [NSString stringWithFormat:@"%@", state.commentID? :action.commentModel.commentID];
        }
        context;
    })];
    id<TTCommentModelProtocol> commentModel = action.commentModel;
    NSMutableOrderedSet *origDigUsers = state.detailModel.digUsers;
    NSInteger origCommentCount = state.detailModel.commentCount;
    state.commentModel = action.commentModel;
    if ([action.payload[@"commentDetail"] isKindOfClass:[TTCommentDetailModel class]]) {
        NSString *origCommentPlaceholder = state.detailModel.commentPlaceholder;
        NSInteger origDiggCount = state.detailModel.diggCount;
        //下面更新和替换逻辑超级超级恶心~Orz
        //先更新下老的detailModel，确保其他页面使用该detailModel的相关字段得到更新（比如评论框使用了该detailModel）
        [state.detailModel mergeFromDictionary:[action.payload[@"commentDetail"] toDictionary]
                                 useKeyMapping:YES];
        //然后再替换评论详情页使用的detailModel
        //有人可能疑惑了：为什么上面已经对detailModel merge了接口下发的最新数据，这里又直接替换了？
        //因为detailModel（jsonModel）的有些字段没有映射key，所以merge的时候，老的detailModel的一些字段会丢失（比如qutoedCommentModel和groupModel，Orz）
        state.detailModel = action.payload[@"commentDetail"];

        state.detailModel.commentPlaceholder = origCommentPlaceholder;
        state.detailModel.diggCount = MAX(origDiggCount, state.detailModel.diggCount);
        //评论数以reply_list接口为准, 这里不进行刷新
        state.detailModel.commentCount = origCommentCount;
        [commentActionManager setContext:({
            TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
            context.groupModel = state.detailModel.groupModel;
            if (state.detailModel.commentID? :state.commentID) {
                context.itemCommentID = [NSString stringWithFormat:@"%@", state.detailModel.commentID? :state.commentID];
            }
            context;
        })];
    } else {
        state.detailModel = ({
            TTCommentDetailModel *detailModel = [[TTCommentDetailModel alloc] init];
            detailModel.user = ({
                SSUserModel *user = [[SSUserModel alloc] init];
                user.ID = [commentModel.userID stringValue];
                user.name = [commentModel.userName copy];
                user.userAuthInfo = commentModel.userAuthInfo;
                user.verifiedReason = [commentModel.verifiedInfo copy];
                user.avatarURLString = [commentModel.userAvatarURL copy];
                user.isFollowing = commentModel.isFollowing;
                user.isFollowed  = commentModel.isFollowed;
                user.isBlocking = commentModel.isBlocking;
                user;
            });
            detailModel.groupModel = commentModel.groupModel;
            detailModel.createTime = [commentModel.commentCreateTime stringValue];
            detailModel.commentID = isEmptyString([commentModel.commentID stringValue])? state.commentID: [commentModel.commentID stringValue]; //通过scheme进入时只有 commentID 没有 commentModel..
            detailModel.commentCount = commentModel.replyCount.integerValue;
            detailModel.content = [commentModel.commentContent copy];
            detailModel.contentRichSpanJSONString = [commentModel.commentContentRichSpanJSONString copy];
            detailModel.diggCount = [commentModel.digCount integerValue];
            detailModel.userDigg = commentModel.userDigged;
            detailModel.qutoedCommentModel = commentModel.quotedComment;
            //非常非常恶心的逻辑，如果从帖子列表进入，手动设置group source，保证后续用到group source的时候，取到的是正确的数值
            //比如空回复的帖子评论，进入详情页需要立马弹起评论框，评论框会使用group source做些逻辑判断
            if (TTCommentDetailSourceTypeThread == state.from) {
                detailModel.groupSource = TTCommentDetailGroupSourceForum;
            }
            detailModel;
        });
    }
    
    state.stickComments = state.stickComments? :@[].mutableCopy;
    state.hotComments = state.hotComments? :@[].mutableCopy;
    state.allComments = state.allComments? :@[].mutableCopy;
    state.stickCommentLayouts = state.stickCommentLayouts? :@[].mutableCopy;
    state.hotCommentLayouts = state.hotCommentLayouts? :@[].mutableCopy;
    state.allCommentLayouts = state.allCommentLayouts? :@[].mutableCopy;
    
    state.totalComments = @[state.stickComments, state.hotComments, state.allComments];
    state.totalCommentLayouts = @[state.stickCommentLayouts, state.hotCommentLayouts, state.allCommentLayouts];
    state.detailModel.digUsers = origDigUsers;
    state.commentActionManager = commentActionManager;

    if ([action.payload tt_boolValueForKey:@"commentDetailError"] && (isEmptyString(state.detailModel.content) || isEmptyString(state.detailModel.user.name))) {
        state.needShowNetworkErrorPage = YES;
    }
    return state;
}

- (TTMomentDetailIndependenceState *)handleWillDisappearAction:(TTMomentDetailAction *)action withState:(TTMomentDetailIndependenceState *)state {
    id<TTCommentModelProtocol> commentModel = state.commentModel;

    NSInteger digCount = MAX([commentModel.digCount integerValue], state.detailModel.diggCount);
    NSInteger commentCount = state.detailModel.commentCount;
    BOOL userDigged = state.detailModel.userDigg;
    BOOL isFollowing = state.detailModel.user.isFollowing;

    commentModel.digCount = @(digCount);
    commentModel.userDigged = userDigged;
    commentModel.isFollowing = isFollowing;
    commentModel.replyCount = @(commentCount);

    return state;
}

@end
