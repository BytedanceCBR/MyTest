//
//  FHUGCVotePublishViewController.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/7.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCVotePublishViewController : FHBaseViewController
// 先把输入视图引用一下，等键盘弹起时再滚动
@property (nonatomic, weak) UIView *firstResponderView;

- (void)enablePublish: (BOOL)isEnable;
- (void)scrollToVisibleForFirstResponderView;
- (void)exitPage;
@end
NS_ASSUME_NONNULL_END
