//
//  TTVReplyViewModel.h
//  Article
//
//  Created by lijun.thinker on 2017/6/1.
//
//

#import <Foundation/Foundation.h>
#import "TTVCommentModelProtocol.h"
#import "TTCommentDetailModelProtocol.h"

@protocol TTVReplyModelProtocol;
@class TTVReplyListItem;
@interface TTVReplyViewModel : NSObject

@property (nonatomic, strong) id <TTVCommentModelProtocol, TTCommentDetailModelProtocol> commentModel;

@property(nonatomic, assign) CGFloat containViewWidth;
@property(nonatomic, assign, readwrite,getter = isLoading)BOOL loading;
@property(nonatomic, assign)BOOL hasMore;
@property (nonatomic, strong) NSIndexPath *needMarkedIndexPath;

- (instancetype)initWithCommentModel:(id <TTVCommentModelProtocol, TTCommentDetailModelProtocol>)commentModel containViewWidth:(CGFloat)width;

- (NSArray <TTVReplyListItem *> *)curAllReplyItems;

- (NSArray <TTVReplyListItem *> *)curHotReplyItems;

- (NSUInteger)totalReplyItemsCount;

- (void)removeReplyItemWithReplyModel:(id <TTVReplyModelProtocol>)model;

- (void)removeReplyItemWithCommentID:(NSString *)commentID;

- (TTVReplyListItem *)hotReplyItemAtIndex:(NSUInteger)index;

- (TTVReplyListItem *)allReplyItemAtIndex:(NSUInteger)index;

- (TTVReplyListItem *)curReplyItemWithCommentID:(NSString *)commentID;

- (void)addToTopWithReplyModel:(id <TTVReplyModelProtocol>)model;

- (void)refreshLayoutsWithWidth:(CGFloat)width;

#pragma mark - request
// 加载评论
- (void)startLoadReplyListFinishBlock:(void(^)(NSError *error))finishBlock;
// 回复二级评论
- (void)handleReplyCommentDigWithCommentID:(NSString *)commentID replayID:(NSString *)replayID finishBlock:(void(^)(NSError *error))finishBlock;
- (void)handleReplyCommentDigWithCommentID:(NSString *)commentID replayID:(NSString *)replayID ifDigg:(BOOL)ifDigg finishBlock:(void(^)(NSError *error))finishBlock;
// 删除评论
- (void)deleteReplyedComment:(NSString *)replyCommentID InHostComment:(NSString *)hostCommentID;

@end
