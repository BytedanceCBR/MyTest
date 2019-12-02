//
//  FHCommentBaseDetailViewController.h
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
    FHUGCPostTypeVote       = 3, // 投票
};

@class FHCommentBaseDetailViewModel;

// 带有评论的 详情页基类
@interface FHCommentBaseDetailViewController : FHBaseViewController

@property (nonatomic, assign)   FHUGCPostType       postType;
@property (nonatomic, strong)   UITableView       *tableView;
@property (nonatomic, strong)   FHCommentBaseDetailViewModel       *viewModel;
@property (nonatomic, strong)   TTGroupModel       *groupModel;
@property (nonatomic, assign)   int64_t       comment_count;// 评论数
@property (nonatomic, assign)   int64_t       digg_count;// 点赞数
@property (nonatomic, assign)   NSInteger       user_digg;// 当前用户是否点赞
@property (nonatomic, assign) BOOL beginShowComment;// 点击评论按钮
@property (nonatomic, assign)  BOOL fromUGC;//来源是ugc模块新功能，区别以前的评论部分
@property (nonatomic, copy)     NSDictionary       *report_params_dic;

- (void)commentCountChanged;
- (void)headerInfoChanged;
- (void)refreshToolbarView;

- (void)becomeFirstResponder_comment;

- (void)remove_comment_vc;
- (void)re_add_comment_vc;
- (void)show_comment_view;
- (void)refresh_page_view;

@end

NS_ASSUME_NONNULL_END
