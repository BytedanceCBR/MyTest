//
//  FHCommentDetailViewController.h
//  Pods
//
//  Created by 张元科 on 2019/7/16.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"
#import "TTCommentDetailReplyCommentModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

// 评论详情
@interface FHCommentDetailViewController : FHBaseViewController

- (void)refreshUI;
- (void)openWriteCommentViewWithReplyCommentModel:(id<TTCommentDetailReplyCommentModelProtocol>)replyCommentModel;

@end

extern CGFloat FHExploreDetailGetToolbarHeight(void);

NS_ASSUME_NONNULL_END
