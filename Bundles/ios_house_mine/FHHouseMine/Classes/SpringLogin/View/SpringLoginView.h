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
- (void)close;

@optional
- (void)goToUserProtocol;

@optional
- (void)goToSecretProtocol;

@optional
- (void)acceptCheckBoxChange:(BOOL)selected;

@end


@interface SpringLoginAcceptButton : UIButton
@property (nonatomic, assign)UIEdgeInsets hotAreaInsets;
@property (nonatomic, assign)UIEdgeInsets hotAreaInsets2;
@end

@interface SpringLoginScrollView : UIScrollView
@end

@interface SpringLoginView : UIView

@property(nonatomic, strong) SpringLoginAcceptButton *acceptCheckBox;
@property(nonatomic, strong) SpringLoginScrollView *scrollView;
@property(nonatomic, strong) UITextField *phoneInput;
@property(nonatomic, strong) UITextField *varifyCodeInput;
@property(nonatomic, strong) UIButton *sendVerifyCodeBtn;
@property(nonatomic, assign, readonly) BOOL isOneKeyLogin;

@property(nonatomic , weak) id<SpringLoginViewDelegate> delegate;

- (void)setButtonContent:(NSString *)content font:(UIFont *)font color:(UIColor *)color state:(UIControlState)state btn:(UIButton *)btn;
- (void)enableConfirmBtn:(BOOL)enabled;
- (void)enableSendVerifyCodeBtn:(BOOL)enabled;
- (void)setAgreementContent:(NSAttributedString *)attrText showAcceptBox:(BOOL)showAcceptBox;
- (void)showTipView:(BOOL)isShow;
- (void)startAnimation;
@end

NS_ASSUME_NONNULL_END
