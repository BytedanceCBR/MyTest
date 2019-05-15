//
//  UIApplication+UserPrivacyPolicy.h
//  Article
//
//  Created by liuzuopeng on 26/01/2018.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN


@interface UIApplication (UserPrivacyPolicy)

// 打开用户协议
+ (void)openUserAgreement;

+ (void)openUserAgreementFromViewController:(UINavigationController * _Nullable)navVC
                               useBarHeight:(BOOL)useBarHeight;

// 打开隐私政策
+ (void)openPrivacyProtection;
+ (void)openPrivacyProtectionFromViewController:(UINavigationController * _Nullable)navVC
                                   useBarHeight:(BOOL)useBarHeight;

@end

NS_ASSUME_NONNULL_END
