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
- (void)enablePublish: (BOOL)isEnable;
- (void)scrollToVisibleForView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
