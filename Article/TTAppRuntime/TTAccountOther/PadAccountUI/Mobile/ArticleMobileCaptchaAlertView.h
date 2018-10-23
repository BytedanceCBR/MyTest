//
//  ArticleMobileCaptchaAlertView.h
//  Article
//
//  Created by SunJiangting on 14-7-7.
//
//

#import <SSViewBase.h>



/// 0 代表取消
@class ArticleMobileCaptchaAlertView;
typedef void (^ ArticleMobileCaptchaBlock)(ArticleMobileCaptchaAlertView * alertView, NSInteger buttonIndex);

@interface ArticleMobileCaptchaAlertView : SSViewBase

- (instancetype) initWithCaptchaImage:(UIImage *) captchaImage;

@property (nonatomic, strong, readonly) UIImage  *captchaImage;
@property (nonatomic, copy, readonly)   NSString *captchaValue;

@property (nonatomic, assign) TTASMSCodeScenarioType scenario;

@property (nonatomic, copy)   NSError     *error;
@property (nonatomic, assign) BOOL        visible;
@property (nonatomic, assign) CGFloat     contentOffset;

- (void)showWithDismissBlock:(ArticleMobileCaptchaBlock) block;

- (void)dismissAnimated:(BOOL) animated;

@end
