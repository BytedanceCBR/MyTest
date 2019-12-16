//
//  SpringLoginView.h
//  FHHouseHome
//
//  Created by 谢思铭 on 2019/12/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SpringLoginViewDelegate <NSObject>

- (void)confirm;
- (void)sendVerifyCode;

@optional
- (void)goToUserProtocol;

@optional
- (void)goToSecretProtocol;

@optional
- (void)acceptCheckBoxChange:(BOOL)selected;

@optional
- (void)otherLoginAction;

@optional
- (void)oneKeyLoginAction;

@end


@interface SpringLoginAcceptButton : UIButton
@property (nonatomic, assign)UIEdgeInsets hotAreaInsets;
@property (nonatomic, assign)UIEdgeInsets hotAreaInsets2;
@end

@interface SpringLoginView : UIView

@property(nonatomic, strong) SpringLoginAcceptButton *acceptCheckBox;
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UITextField *phoneInput;
@property(nonatomic, strong) UITextField *varifyCodeInput;
@property(nonatomic, strong) UIButton *sendVerifyCodeBtn;
@property(nonatomic, assign, readonly) BOOL isOneKeyLogin;

@property(nonatomic , weak) id<SpringLoginViewDelegate> delegate;

- (void)setButtonContent:(NSString *)content font:(UIFont *)font color:(UIColor *)color state:(UIControlState)state btn:(UIButton *)btn;

- (void)enableConfirmBtn:(BOOL)enabled;

- (void)enableSendVerifyCodeBtn:(BOOL)enabled;
- (void)showOneKeyLoginView:(BOOL)isOneKeyLogin;
- (void)updateOneKeyLoginWithPhone:(NSString *)phoneNum service:(NSString *)service;
- (void)updateLoadingState:(BOOL)isLoading;
- (void)setAgreementContent:(NSAttributedString *)attrText showAcceptBox:(BOOL)showAcceptBox;

@end

NS_ASSUME_NONNULL_END
