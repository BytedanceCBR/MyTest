//
//  FHCommentDetailViewModel.h
//  Pods
//
//  Created by 张元科 on 2019/7/16.
//

#import <Foundation/Foundation.h>
#import "FHCommentDetailViewController.h"
#import "TTCommentDetailModel.h"
#import "TTCommentDetailReplyCommentModel.h"
#import "FHPostDetailHeaderCell.h"

NS_ASSUME_NONNULL_BEGIN

// 删除评论中回复成功通知 数据放在userinfo中
static NSString *const kFHUGCDelCommentDetailReplyNotification = @"k_fh_ugc_del_comment_detail_reply";

@interface FHCommentDetailViewModel : NSObject

-(instancetype)initWithController:(FHCommentDetailViewController *)viewController tableView:(UITableView *)tableView;

- (void)startLoadData;

@property (nonatomic, strong)   TTCommentDetailModel *       commentDetailModel;// 详情数据
@property (nonatomic, copy)     NSString       *comment_id;

@property (nonatomic, assign)   int64_t       comment_count;// 评论数
@property (nonatomic, assign)   int64_t       digg_count;// 点赞数
@property (nonatomic, assign)   NSInteger       user_digg;// 当前用户是否点赞

@property (nonatomic, weak)   FHPostDetailHeaderModel *detailHeaderModel;

// 插入新回复的数据
- (void)insertReplyData:(TTCommentDetailReplyCommentModel *)model;

@end

NS_ASSUME_NONNULL_END
