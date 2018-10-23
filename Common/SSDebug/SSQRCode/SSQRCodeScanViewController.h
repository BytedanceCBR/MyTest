//
//  SSQRCodeScanViewController.h
//  Article
//
//  Created by SunJiangting on 14-12-9.
//
//

#if INHOUSE

#import "SSViewControllerBase.h"
#import <Foundation/Foundation.h>

@interface SSQRCodeScanViewController : SSViewControllerBase
@property (nonatomic, assign) BOOL  continueWhenScaned;
@property (nonatomic, strong) void(^scanCompletionHandler)(SSQRCodeScanViewController *viewController, NSString *result, NSError *error);

- (void)dismissAnimated:(BOOL)animated;

@end

#endif
