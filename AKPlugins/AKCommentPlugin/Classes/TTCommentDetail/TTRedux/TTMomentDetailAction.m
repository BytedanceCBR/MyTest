//
//  TTCommentAction.m
//  Article
//
//  Created by muhuai on 16/8/21.
//
//

#import "TTMomentDetailAction.h"


@implementation TTMomentDetailAction

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)actionWithType:(TTMomentDetailActionType)type payload:(id)payload {
    TTMomentDetailAction *action = [[TTMomentDetailAction alloc] init];
    action.type = type;
    action.payload = payload;
    return action;
}

+ (instancetype)actionWithType:(TTMomentDetailActionType)type comment:(id<TTCommentModelProtocol>)commentModel {
    TTMomentDetailAction *action = [[TTMomentDetailAction alloc] init];
    action.type = type;
    action.commentModel = commentModel;
    return action;
}

+ (instancetype)enterProfileActionWithUserID:(NSString *)userID {
    TTMomentDetailAction *action = [self actionWithType:TTMomentDetailActionTypeEnterProfile comment:nil];
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] initWithCapacity:1];
    [payload setValue:userID forKey:@"userID"];
    action.payload = payload;
    action.shouldMiddlewareHandle = NO;
    return action;
}

+ (instancetype)digActionWithReplyCommentModel:(TTCommentDetailReplyCommentModel *)model {
    TTMomentDetailAction *action = [[TTMomentDetailAction alloc] init];
    action.type = TTMomentDetailActionTypeReplyCommentDig;
    action.replyCommentModel = model;
    action.shouldMiddlewareHandle = YES;
    return action;
}

+ (instancetype)digActionWithCommentDetailModel:(TTCommentDetailModel *)model {
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    [payload setValue:model forKey:@"commentDetailModel"];

    TTMomentDetailAction *action = [[TTMomentDetailAction alloc] init];
    action.type = TTMomentDetailActionTypeCommentDig;
    action.commentDetailModel = model;
    action.payload = [payload copy];
    action.shouldMiddlewareHandle = YES;
    return action;
}

@end
