//
//  AWEVideoCommentCell.h
//  LiveStreaming
//
//  Created by willorfang on 16/7/11.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWECommentModel.h"
#import <SSThemed.h>

@class AWEVideoCommentCell;
@protocol AWEVideoCommentCellOperateDelegate<NSObject>
- (void)commentCell:(AWEVideoCommentCell *)cell didClickDeleteWithModel:(AWECommentModel *)commentModel;
- (void)commentCell:(AWEVideoCommentCell *)cell didClickReportWithModel:(AWECommentModel *)commentModel;
- (void)commentCell:(AWEVideoCommentCell *)cell didClickLikeWithModel:(AWECommentModel *)commentModel;
- (void)commentCell:(AWEVideoCommentCell *)cell didClickUserWithModel:(AWECommentModel *)commentModel;
- (void)commentCell:(AWEVideoCommentCell *)cell didClickUserNameWithModel:(AWECommentModel *)commentModel;
@end


@interface AWEVideoCommentCell : SSThemedTableViewCell

@property (nonatomic, strong, readonly) NSNumber *videoId;
@property (nonatomic, strong, readonly) AWECommentModel *commentModel;
@property (nonatomic, weak) id<AWEVideoCommentCellOperateDelegate> delegate;

- (void)configCellWithCommentModel:(AWECommentModel *)model
                           videoId:(NSString *)videoId
                          authorId:(NSString *)authorId;

- (void)refreshCellWithDiggModel:(AWECommentModel *)model cancelDigg:(BOOL)cancelDigg;

+ (CGFloat)heightForTableView:(UITableView *)tableView
             withCommentModel:(AWECommentModel *)model;


@end
