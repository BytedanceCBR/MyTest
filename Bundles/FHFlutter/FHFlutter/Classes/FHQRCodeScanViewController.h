//
//  FHQRCodeScanViewController.h
//  ABRInterface
//
//  Created by 谢飞 on 2020/8/25.
//

#import "SSViewControllerBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHQRCodeScanViewController : SSViewControllerBase
@property (nonatomic, assign) BOOL  continueWhenScaned;
@property (nonatomic, strong) void(^scanCompletionHandler)(FHQRCodeScanViewController *viewController, NSString *result, NSError *error);

- (void)dismissAnimated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
