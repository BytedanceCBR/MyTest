//
//  TTMomentDetailReducer.m
//  Article
//
//  Created by muhuai on 16/8/21.
//
//

#import "TTMomentDetailReducer.h"
#import "TTMomentDetailUserReducer.h"
#import "TTMomentDetailCommentReducer.h"
#import "TTMomentDetailLifeCycleReducer.h"
#import "TTMomentDetailStore.h"


@interface TTMomentDetailReducer()
@property (nonatomic, strong) TTMomentDetailUserReducer *userReducer;
@property (nonatomic, strong) TTMomentDetailCommentReducer *commentReducer;
@property (nonatomic, strong) TTMomentDetailLifeCycleReducer *lifeCycleReducer;
@end

@implementation TTMomentDetailReducer
@synthesize store = _store;

- (instancetype)init {
    self = [super init];
    if (self) {
        _userReducer = [[TTMomentDetailUserReducer alloc] init];
        _commentReducer = [[TTMomentDetailCommentReducer alloc] init];
        _lifeCycleReducer = [[TTMomentDetailLifeCycleReducer alloc] init];
    }
    return self;
}

- (State *)handleAction:(Action *)action withState:(State *)state {
    if (![action isKindOfClass:[TTMomentDetailAction class]] || ![state isKindOfClass:[TTMomentDetailIndependenceState class]]) {
        return state;
    }
    TTMomentDetailAction *detailAction = (TTMomentDetailAction *)action;
    TTMomentDetailIndependenceState *independenceState = (TTMomentDetailIndependenceState *)state;
    switch (detailAction.type) {
        case TTMomentDetailActionTypeCommentDig:
        case TTMomentDetailActionTypeReplyCommentDig:
        case TTMomentDetailActionTypeReport:
        case TTMomentDetailActionTypePublishComment:
        case TTMomentDetailActionTypeDeleteComment:
        case TTMomentDetailActionTypeLoadComment:
        case TTMomentDetailActionTypeShare:
        case TTMomentDetailActionTypeLoadDig:
        case TTMomentDetailActionTypeRefreshComment:
            independenceState = (TTMomentDetailIndependenceState *)[_commentReducer handleAction:detailAction withState:independenceState];
            break;
            
        case TTMomentDetailActionTypeFollow:
        case TTMomentDetailActionTypeUnfollow:
        case TTMomentDetailActionTypeUnblock:
        case TTMomentDetailActionTypeEnterProfile:
        case TTMomentDetailActionTypeEnterDiggList:
        case TTMomentDetailActionTypeFollowNotify:
            independenceState = (TTMomentDetailIndependenceState *)[_userReducer handleAction:detailAction withState:independenceState];
            break;
        case TTMomentDetailActionTypeInit:
        case TTMomentDetailActionTypeWillAppear:
        case TTMomentDetailActionTypeDidAppear:
        case TTMomentDetailActionTypeWillDisappear:
            independenceState = (TTMomentDetailIndependenceState *)[_lifeCycleReducer handleAction:detailAction withState:independenceState];
            break;
        default:
            break;
    }
    return state;
}

- (void)setStore:(Store *)store {
    _store = store;
    self.userReducer.store = store;
    self.commentReducer.store = store;
    self.lifeCycleReducer.store = store;
}
@end
