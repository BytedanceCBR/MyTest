//
//  TTInstallResetDevicePage.h
//  TTDebugKit
//
//  Created by han yang on 2019/11/18.
//

#if INHOUSE

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTInstallResetDevicePage : UIViewController

@property (nonatomic, strong, readonly) UIView *centerBackgroundView;
@property (nonatomic, copy) void (^okButtonDidClicked)(NSString *gender, NSString *ageLevel, BOOL isAutoReset);
@property (nonatomic, copy) void (^cancelButtonDidClicked)(void);

@end

NS_ASSUME_NONNULL_END

#endif
