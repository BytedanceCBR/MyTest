//
//  WDDetailUserPermission.m
//  Article
//
//  Created by 延晋 张 on 16/4/27.
//
//

#import "WDDetailUserPermission.h"
#import "WDDefines.h"

@interface WDDetailUserPermission ()

@property (nonatomic, assign) BOOL canForbidComment;
@property (nonatomic, assign) BOOL canDeleteAnswer;
@property (nonatomic, assign) BOOL canDeleteComment;
@property (nonatomic, assign) BOOL canPostAnswer;
@property (nonatomic, assign) BOOL canCommentAnswer;
@property (nonatomic, assign) BOOL canDiggAnswer;
@property (nonatomic, assign) BOOL canEditAnswer;

@end

@implementation WDDetailUserPermission

- (instancetype)initWithStructModel:(WDDetailPermStructModel *)perm
{
    if (self = [super init]) {
        _canForbidComment = [perm.can_ban_comment boolValue];
        _canDeleteAnswer = [perm.can_delete_answer boolValue];
        _canDeleteComment = [perm.can_delete_comment boolValue];
        _canPostAnswer = [perm.can_post_answer boolValue];
        _canCommentAnswer = [perm.can_comment_answer boolValue];
        _canDiggAnswer = [perm.can_digg_answer boolValue];
        _canEditAnswer = [perm.can_edit_answer boolValue];
    }
    return self;
}

@end
