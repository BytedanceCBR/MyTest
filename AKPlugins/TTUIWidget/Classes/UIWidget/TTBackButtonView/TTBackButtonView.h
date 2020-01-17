//
//  TTBackButtonView.h
//  Article
//
//  Created by Zhang Leonardo on 14-7-9.
//
//

#import "SSViewBase.h"
#import "TTAlphaThemedButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TTBackButtonStyle){
    TTBackButtonStyleDefault          = 0, // 黑色
    TTBackButtonStyleLightContent     = 1, // 白色
} ;

@interface TTBackButtonView : SSViewBase

@property(class, readonly) NSBundle *resourceBundle; // 获取返回按钮<和X图标，对应的NSBundle，跨Pod用来取图片

@property(nonatomic, assign) TTBackButtonStyle style;
@property(nonatomic, retain, readonly)TTAlphaThemedButton * closeButton;
@property(nonatomic, retain, readonly)TTAlphaThemedButton * backButton;

- (void)showCloseButton:(BOOL)show;
- (BOOL)isCloseButtonShowing;
@end

NS_ASSUME_NONNULL_END
