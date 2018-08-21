//
// AWEVideoCommentDataManager.h
//  LiveStreaming
//
//  Created by lym on 16/10/19.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import "AWECommentModel.h"

NS_ASSUME_NONNULL_BEGIN

@class AWEActionSheetModel;

typedef void(^AWEAwemeCommentDataBlock)(AWECommentResponseModel * _Nullable response, NSError * _Nullable error);
typedef void(^AWEAwemeAddCommentResponseBlock)(AWECommentModel * _Nullable model, NSError * _Nullable error);
typedef void(^AWEAwemeDetailDiggBlock)(AWECommentDiggStatus * _Nullable response, NSError * _Nullable error);
typedef void(^AWEAwemeDetailCommonBlock)(id _Nullable response, NSError * _Nullable error);

@interface AWEVideoCommentDataManager : NSObject

@property (nonatomic, strong) AWEActionSheetModel * _Nullable reportModel;
@property (nonatomic, strong) NSString * _Nullable criticismInput;

- (void)addActionSheetMode:(AWEActionSheetModel *)model;

- (BOOL)canLoadMore;

- (BOOL)isEmpty;

- (NSInteger)totalCommentCount;

- (NSInteger)currentCommentCount;

- (nullable AWECommentModel *)commentForIndexPath:(NSIndexPath *)indexPath;

- (void)commentAwemeItemWithID:(NSString *)itemID
                       groupID:(NSString *)groupID
                       content:(NSString *)content
                    completion:(nullable AWEAwemeAddCommentResponseBlock)block;

- (void)commentAwemeItemWithID:(NSString *)itemID
                       groupID:(NSString *)groupID
                       content:(NSString *)content
                replyCommentID:(nullable NSNumber *)commentID
                    completion:(nullable AWEAwemeAddCommentResponseBlock)block;

- (void)deleteCommentItemWithId:(NSNumber *)commentId
                     completion:(nullable AWEAwemeDetailCommonBlock)block;

- (void)diggCommentItemWithCommentId:(NSNumber *)commentID
                              itemID:(NSString *)itemID
                             groupID:(NSString *)groupID
                              userID:(nullable NSString *)userID
                          cancelDigg:(BOOL)cancelDigg
                          completion:(nullable AWEAwemeDetailDiggBlock)block;

- (void)requestCommentListWithID:(NSString *)itemID
                         groupID:(NSString *)groupID
                           count:(NSNumber *)count
                          offset:(NSNumber *)offset
                      completion:(nullable AWEAwemeCommentDataBlock)block;

- (void)reportCommentWithType:(NSString *)reportType
                userInputText:(nullable NSString *)inputText
                       userID:(NSString *)userID
                    commentID:(NSNumber *)commentID
                     momentID:(nullable NSString *)momentID
                      groupID:(NSString *)groupID
                       postID:(NSString *)postID
                   completion:(nullable AWEAwemeDetailCommonBlock)block;

@end

NS_ASSUME_NONNULL_END
