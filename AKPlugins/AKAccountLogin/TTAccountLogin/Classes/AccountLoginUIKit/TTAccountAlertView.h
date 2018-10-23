//
//  TTAccountAlertView.h
//  TTAccountLogin
//
//  Created by yuxin on 3/15/16.
//
//

#import <SSThemed.h>
#import "TTAccountLoginDefine.h"



#define kTTAccountAlertLeading      (22)
#define kTTAccountAlertMargin       (15)

#define kTTAccountAlertTitleHeight  (65)
#define kTTAccountAlertButtonHeight (44)



NS_ASSUME_NONNULL_BEGIN

typedef
NS_ENUM(NSInteger, TTAccountAlertCompletionEventType) {
    TTAccountAlertCompletionEventTypeCancel,
    TTAccountAlertCompletionEventTypeDone,
    TTAccountAlertCompletionEventTypeTip,
};
typedef
void(^TTAccountAlertCompletionBlock)(TTAccountAlertCompletionEventType type);


@class TTAlphaThemedButton;

@interface TTAccountAlertView : SSThemedView
// Default is NO
@property (nonatomic, assign) BOOL touchDismissEnabled;

@property (nonatomic, strong) SSThemedView  *centerView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *messageLabel;
@property (nonatomic, strong) TTAlphaThemedButton *tipBtn;
@property (nonatomic, strong) TTAlphaThemedButton *cancelBtn;
@property (nonatomic, strong) SSThemedButton *doneBtn;

// 点击TTAccountAlertView按钮触发
@property (nonatomic,   copy, nullable) TTAccountAlertCompletionBlock tapCompletedHandler;

@property (nonatomic,   copy, nullable) TTAccountAlertCompletionBlock didDismissCompletedHandler;

- (instancetype)initWithTitle:(NSString * _Nonnull)title
                      message:(NSString * _Nullable)message
               cancelBtnTitle:(NSString * _Nonnull)cancelTitle
              confirmBtnTitle:(NSString * _Nullable)confirmBtnTitle
                     animated:(BOOL)animated
                tapCompletion:(TTAccountAlertCompletionBlock _Nullable)tapCompletedHandler;

// overridable events
- (void)cancelBtnTouched:(id _Nullable)sender;
- (void)doneBtnTouched:(id _Nullable)sender;
- (void)tipBtnTouched:(id _Nullable)sender;

#pragma mark - show/hide

- (void)show;
- (void)showInView:(UIView * _Nullable)superView;
- (void)hide;

+ (nullable NSMutableAttributedString *)attributedStringWithString:(NSString * _Nonnull)string
                                                          fontSize:(CGFloat)fontSize
                                                       lineSpacing:(CGFloat)lineSpace
                                                     lineBreakMode:(NSLineBreakMode)lineBreakMode
                                                     textAlignment:(NSTextAlignment)alignment;
@end

NS_ASSUME_NONNULL_END
