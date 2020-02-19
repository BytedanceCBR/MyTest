//
//  TTAccountMobileCaptchaAlertView.h
//  TTNewsAccountBusiness
//
//  Created by bytedance on 2018/5/21.
//

#import "SSViewBase.h"
#import <TTAccountSDK/TTAccountSMSCodeDef.h>

/// 0 代表取消
@class TTAccountMobileCaptchaAlertView;
typedef void (^ TTAccountMobileCaptchaBlock)(TTAccountMobileCaptchaAlertView * alertView, NSInteger buttonIndex);

@interface TTAccountMobileCaptchaAlertView : SSViewBase

- (instancetype) initWithCaptchaImage:(UIImage *) captchaImage;

@property (nonatomic, strong, readonly) UIImage  *captchaImage;
@property (nonatomic, copy, readonly)   NSString *captchaValue;

@property (nonatomic, assign) TTASMSCodeScenarioType scenario;

@property (nonatomic, copy)   NSError     *error;
@property (nonatomic, assign) BOOL        visible;
@property (nonatomic, assign) CGFloat     contentOffset;

- (void)showWithDismissBlock:(TTAccountMobileCaptchaBlock) block;

- (void)dismissAnimated:(BOOL) animated;

@end
