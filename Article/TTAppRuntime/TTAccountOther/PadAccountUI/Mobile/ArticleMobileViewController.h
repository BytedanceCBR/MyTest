//
//  ArticleMobileViewController.h
//  Article
//
//  Created by SunJiangting on 14-7-9.
//
//

#import <SSViewControllerBase.h>
#import <SSThemed.h>
#import <NetworkUtilities.h>
#import <SSNavigationBar.h>
#import "ArticleMobileCaptchaAlertView.h"
#import "ArticleMobileViewController.h"

/// 如果没有网络，则弹出提示框
#define ArticleTipAndReturnIFNetworkNotOK \
    autoreleasepool {\
        if (!TTNetworkConnected()) {\
            [self showNotifyBarMsg:NSLocalizedString(@"网络不给力，请稍后重试", nil)];\
            return;\
        }\
    }

typedef enum {
    ArticleLoginStateUserCancelled,
    ArticleLoginStatePlatformLogin,
    ArticleLoginStateMobileLogin,
    ArticleLoginStateMobileRegister,
    ArticleLoginStateMobileBind
} ArticleLoginState;

typedef enum {
    ArticleMobileViewSourceTypeSettings = 1,
    ArticleMobileViewSourceTypeUGCPost = 2
} ArticleMobileViewSourceType;

/// finished 表示完成该流程，unfinished表示用户取消或者push取消
/// @attention 目前只处理register和bind，如果有新增需求则会加参数type区分,其余情况均不回掉
typedef void (^ArticleMobilePiplineCompletion)(ArticleLoginState state);

extern const NSInteger ArticleRetrieveTimeoutInterval;

@interface ArticleMobileViewController : SSViewControllerBase <UITextFieldDelegate>

@property(nonatomic, strong) SSNavigationBar    *navigationBar;
@property(nonatomic, strong) SSThemedView       *containerView;
@property(nonatomic, strong, readonly) SSThemedView *backgroundView;

@property(nonatomic, strong) SSThemedView * inputContainerView;

@property(nonatomic, copy) NSString     *mobileNumber;
@property(nonatomic, strong) UIImage    *captchaImage;
@property(nonatomic, copy) NSError      *error;
@property(nonatomic, strong) NSString   *captchaValue;

@property(nonatomic, assign) NSInteger timeoutInterval;
@property(nonatomic, assign) NSInteger countdown;

@property(nonatomic, assign) ArticleLoginState state;

@property(nonatomic, assign) BOOL isBindingVC;


- (BOOL)isContentValid;
/// 点击back按钮
- (void)goBack;
- (void)backgroundTapActionFired:(UITapGestureRecognizer *)tapGestureRecognizer;

- (void)refreshMobileButtonIfNeeded;

@property(nonatomic, strong) ArticleMobilePiplineCompletion completion;

/// tintColor 是指 borderColor And titleColor
- (SSThemedButton *)mobileButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;
/// 是否自适应键盘
@property(nonatomic, assign) BOOL automaticallyAdjustKeyboardOffset;
@property(nonatomic, assign) CGFloat maximumHeightOfContent;

- (void)showNotifyBarMsg:(NSString *)msg;

#pragma mark - WaitingIndicator
/**
 *  显示waitingIndicator
 */
- (void)showWaitingIndicator;

/**
 *  移除indicator并根据需要显示提示语
 */
- (void)dismissWaitingIndicator;
- (void)dismissWaitingIndicatorWithError:(NSError *)error;
- (void)dismissWaitingIndicatorWithText:(NSString *)message;

#pragma mark - Indicator
- (void)showAutoDismissIndicatorWithError:(NSError *)error;
- (void)showAutoDismissIndicatorWithText:(NSString *)text;

- (void)backToMainViewControllerAnimated:(BOOL)animated;
- (void)backToMainViewControllerAnimated:(BOOL)animated completion:(ArticleMobilePiplineCompletion)completion;

- (BOOL)validateMobileNumber:(NSString *)mobileNumber;
- (void)alertInvalidateMobileNumberWithCompletionHandler:(void(^)(void))completionHandler;

+ (void)setPreviousMobileCodeInformation:(NSDictionary *)dictionary;
+ (NSDictionary *)previousMobileCodeInformation;

+ (CGFloat)heightOfInputField;
+ (CGFloat)fontSizeOfInputFiled;

@end

@interface UIImage (ArticleGIFImage)
/// name暂时不要加后缀，目前自动会加.gif
+ (UIImage *)gifImageNamed:(NSString *)gifName;
/// duration gif完成一次之后的完整时间
+ (UIImage *)gifImageNamed:(NSString *)gifName duration:(NSTimeInterval *)duration;

@end
