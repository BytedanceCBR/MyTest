//
//  FHCustomerServicePage.h
//  FHHouseMine
//
//  Created by wangzhizhou on 2020/9/24.
//

#import "FHBaseViewController.h"
#import "FHUserTracker.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCustomerServicePage : FHBaseViewController

/// 跳转到linkChat客服页面
+ (void)jumpToLinkChatPage:(nullable NSDictionary *)params;

/// 拨打客服电话
+ (void)callCustomerService;

@end

NS_ASSUME_NONNULL_END
