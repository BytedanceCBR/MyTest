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

@property(nonatomic , weak) id<FHLoginViewDelegate> delegate;

- (void)updateMobileNumber:(NSString *)mobileNumber;

- (void)updateTimeCountDownValue:(NSInteger )countdownSeconds;

@end

NS_ASSUME_NONNULL_END
