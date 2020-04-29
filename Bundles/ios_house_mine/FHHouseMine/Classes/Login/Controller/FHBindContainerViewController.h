//
//  FHBindContainerViewController.h
//  Pods
//
//  Created by bytedance on 2020/4/22.
//

#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FHBindContainerViewNavigationType) {
    FHBindContainerViewNavigationTypeClose = 0,
    FHBindContainerViewNavigationTypePop = 1
}

@interface FHBindContainerViewController : FHBaseViewController

@end

NS_ASSUME_NONNULL_END
