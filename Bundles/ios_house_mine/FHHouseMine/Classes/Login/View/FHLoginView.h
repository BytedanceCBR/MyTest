//
//  FHLoginView.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/2/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHLoginViewDelegate <NSObject>

- (void)goToUserProtocol;

- (void)goToSecretProtocol;

- (void)confirm;

- (void)acceptCheckBoxChange:(BOOL)selected;

- (void)sendVerifyCode;

@end


@interface FHLoginView : UIView

@property(nonatomic, strong) UIButton *acceptCheckBox;
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UITextField *phoneInput;
@property(nonatomic, strong) UITextField *varifyCodeInput;
@property(nonatomic, strong) UIButton *sendVerifyCodeBtn;

@property(nonatomic , weak) id<FHLoginViewDelegate> delegate;

- (void)setButtonContent:(NSString *)content font:(UIFont *)font color:(UIColor *)color state:(UIControlState)state btn:(UIButton *)btn;

- (void)enableConfirmBtn:(BOOL)enabled;

- (void)enableSendVerifyCodeBtn:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
