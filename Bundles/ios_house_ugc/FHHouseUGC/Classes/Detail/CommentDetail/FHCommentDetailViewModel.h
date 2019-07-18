//
//  FHCommentDetailViewModel.h
//  Pods
//
//  Created by 张元科 on 2019/7/16.
//

#import <Foundation/Foundation.h>
#import "FHCommentDetailViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommentDetailViewModel : NSObject

-(instancetype)initWithController:(FHCommentDetailViewController *)viewController tableView:(UITableView *)tableView;

- (void)startLoadData;

@property (nonatomic, copy)     NSString       *comment_id;

@property (nonatomic, assign)   int64_t       comment_count;// 评论数
@property (nonatomic, assign)   int64_t       digg_count;// 点赞数
@property (nonatomic, assign)   NSInteger       user_digg;// 当前用户是否点赞

@end

NS_ASSUME_NONNULL_END
