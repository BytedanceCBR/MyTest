//
//  SSWebViewBackButtonView.h
//  Article
//
//  Created by Zhang Leonardo on 14-7-9.
//
//

#import "SSViewBase.h"
#import "TTAlphaThemedButton.h"

typedef NS_ENUM(NSInteger, SSWebViewBackButtonStyle){
    SSWebViewBackButtonStyleDefault          = 0, // 黑色
    SSWebViewBackButtonStyleLightContent     = 1, // 白色
} ;

@interface SSWebViewBackButtonView : SSViewBase

@property(nonatomic, assign) SSWebViewBackButtonStyle style;
@property(nonatomic, retain, readonly)TTAlphaThemedButton * closeButton;
@property(nonatomic, retain, readonly)TTAlphaThemedButton * backButton;

- (void)showCloseButton:(BOOL)show;
- (BOOL)isCloseButtonShowing;
@end
