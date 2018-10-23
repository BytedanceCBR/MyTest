//
//  TTAccountLoginInputView.h
//  TTAccountLogin
//
//  Created by huic on 16/3/14.
//
//

#import "SSThemed.h"



@interface TTAccountLoginInputView : SSThemedView

@property (nonatomic, strong) SSThemedTextField *field;
@property (nonatomic, strong) SSThemedLabel *errorLabel;

@property (nonatomic, strong) SSThemedView *resendView;
@property (nonatomic, strong) SSThemedView *resendSeparatorView;
@property (nonatomic, strong) SSThemedButton *resendButton;
@property (nonatomic, strong) SSThemedView *bottomSeparatorView;

- (instancetype)initWithFrame:(CGRect)frame rightText:(NSString *)text;

- (void)showError;

- (void)recover;

- (void)updateRightText:(NSString *)text;

@end



@interface TTAccountLoginUserAgreement : SSThemedView

@property (nonatomic, strong) SSThemedButton *radioButton;
@property (nonatomic, strong) SSThemedLabel  *leftLabel;
@property (nonatomic, strong) SSThemedButton *termButton;

@end


