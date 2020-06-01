//
//  FHVerifyCodeInputView.h
//  Pods
//
//  Created by bytedance on 2020/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHLoginViewDelegate;

@interface FHVerifyCodeInputView : UIView

@property (nonatomic, copy) NSArray<UITextField *> *textFieldArray;

@property (nonatomic, weak) id<FHLoginViewDelegate> delegate;

/// 是否是绑定手机号的流程，默认为验证码登录路程
@property (nonatomic, assign) BOOL isForBindMobile;

/// 更新手机号
/// @param mobileNumber 手机号
- (void)updateMobileNumber:(NSString *)mobileNumber;

/// 发送验证码后，更新倒数计时
/// @param countdownSeconds 倒数计时
- (void)updateTimeCountDownValue:(NSInteger )countdownSeconds;

- (void)clearTextFieldText;

@end

NS_ASSUME_NONNULL_END
