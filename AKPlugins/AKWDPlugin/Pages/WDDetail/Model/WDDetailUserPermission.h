//
//  WDDetailUserPermission.h
//  Article
//
//  Created by 延晋 张 on 16/4/27.
//
//

#import <Foundation/Foundation.h>

@class WDDetailPermStructModel;

@interface WDDetailUserPermission : NSObject

@property (nonatomic, readonly, assign) BOOL canForbidComment;
@property (nonatomic, readonly, assign) BOOL canDeleteAnswer;
@property (nonatomic, readonly, assign) BOOL canDeleteComment;
@property (nonatomic, readonly, assign) BOOL canPostAnswer;
@property (nonatomic, readonly, assign) BOOL canCommentAnswer;
@property (nonatomic, readonly, assign) BOOL canDiggAnswer;
@property (nonatomic, readonly, assign) BOOL canEditAnswer;

- (nonnull instancetype)initWithStructModel:(nonnull WDDetailPermStructModel *)perm;

@end
