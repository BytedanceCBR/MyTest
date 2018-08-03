//
//  TTUserPrivacyView.h
//  Pods
//
//  Created by liuzuopeng on 24/06/2017.
//
//

#import <SSThemed.h>



typedef void (^TTViewUserPrivacyActionHandler)();

@interface TTUserPrivacyView : SSThemedView

// 点击用户协议
@property (nonatomic, copy) TTViewUserPrivacyActionHandler viewUserAgreementHandler;

// 点击隐私政策
@property (nonatomic, copy) TTViewUserPrivacyActionHandler viewPrivacyHandler;

// 点击checkbox
@property (nonatomic, copy) TTViewUserPrivacyActionHandler viewCheckActionHandler;

// 当前checkbox的状态
- (BOOL)isChecked;

+ (CGFloat)topBottomMargin;

@end
