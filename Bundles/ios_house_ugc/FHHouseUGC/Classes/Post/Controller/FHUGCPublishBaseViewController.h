//
//  FHUGCPublishBaseViewController.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/22.
//

#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN


@protocol FHUGCPublishBaseViewControllerProtocol <NSObject>

- (void)publishAction: (UIButton *)publishBtn;

- (void)startLoading;

- (void)endLoading;

@optional

- (void)cancelAction: (UIButton *)cancelBtn;

@end

@interface FHUGCPublishBaseViewController : FHBaseViewController<FHUGCPublishBaseViewControllerProtocol>

- (void)enablePublish:(BOOL)isEnable;

- (void)exitPage;

- (void)startLoading;

- (void)endLoading;

@end

NS_ASSUME_NONNULL_END
