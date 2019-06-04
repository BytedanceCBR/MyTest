//
//  FHCommentDetailViewController.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/2.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

// UGC 评论详情页 类型
typedef NS_ENUM (NSInteger , FHUGCPostType){
    FHUGCPostTypePost       = 1, // 帖子
    FHUGCPostTypeWenDa      = 2, // 问答
};

// 带有评论的 详情页基类
@interface FHCommentDetailViewController : FHBaseViewController

@property (nonatomic, assign)   FHUGCPostType       postType;

@end

NS_ASSUME_NONNULL_END
