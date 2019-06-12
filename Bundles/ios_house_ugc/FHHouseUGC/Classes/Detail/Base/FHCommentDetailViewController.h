//
//  FHCommentDetailViewController.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/2.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"
#import "Article.h"

NS_ASSUME_NONNULL_BEGIN

// UGC 评论详情页 类型
typedef NS_ENUM (NSInteger , FHUGCPostType){
    FHUGCPostTypePost       = 1, // 帖子
    FHUGCPostTypeWenDa      = 2, // 问答
};

@class FHCommentDetailViewModel;

// 带有评论的 详情页基类
@interface FHCommentDetailViewController : FHBaseViewController

@property (nonatomic, assign)   FHUGCPostType       postType;
@property (nonatomic, strong)   UITableView       *tableView;
@property (nonatomic, strong)   FHCommentDetailViewModel       *viewModel;
@property (nonatomic, strong)   TTGroupModel       *groupModel;
@property (nonatomic, assign)   NSInteger       comment_count;// 评论数
@property (nonatomic, assign)   NSInteger       digg_count;// 点赞数
@property (nonatomic, assign)   NSInteger       user_digg;// 当前用户是否点赞

@end

NS_ASSUME_NONNULL_END
