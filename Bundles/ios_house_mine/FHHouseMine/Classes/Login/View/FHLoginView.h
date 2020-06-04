//
//  FHLoginView.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/2/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHLoginViewDelegate;

@interface FHLoginAcceptButton : UIButton
@property (nonatomic, assign)UIEdgeInsets hotAreaInsets;
@property (nonatomic, assign)UIEdgeInsets hotAreaInsets2;
@end

@interface FHLoginView : UIView

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UITextField *phoneInput;
@property(nonatomic, strong) UITextField *varifyCodeInput;
@property(nonatomic, strong) UIButton *sendVerifyCodeBtn;
@property(nonatomic, assign, readonly) BOOL isOneKeyLogin;

@property(nonatomic , weak) id<FHLoginViewDelegate> delegate;

- (void)setButtonContent:(NSString *)content font:(UIFont *)font color:(UIColor *)color state:(UIControlState)state btn:(UIButton *)btn;

- (void)enableConfirmBtn:(BOOL)enabled;

- (void)enableSendVerifyCodeBtn:(BOOL)enabled;
- (void)showOneKeyLoginView:(BOOL)isOneKeyLogin;
- (void)updateOneKeyLoginWithPhone:(NSString *)phoneNum service:(NSString *)service;
- (void)setAgreementContent:(NSAttributedString *)attrText showAcceptBox:(BOOL)showAcceptBox;

@end

NS_ASSUME_NONNULL_END
