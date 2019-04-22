//
//  TTWeakPushAlertView.h
//  Article
//
//  Created by liuzuopeng on 02/07/2017.
//
//

#import <SSThemed.h>
#import <TTDeviceUIUtils.h>
#import "TTPushAlertViewProtocol.h"



typedef NS_ENUM(NSInteger, TTWeakPushAlertHideType) {
    TTWeakPushAlertHideTypeAutoDismiss = 0,
    TTWeakPushAlertHideTypeTapClose,
    TTWeakPushAlertHideTypePanClose,
    TTWeakPushAlertHideTypeOpenContent,
    TTWeakPushAlertHideTypeExternalCall,
};


typedef NS_ENUM(NSInteger, TTWeakPushSlideDirection) {
    TTWeakPushSlideDirectionFromBottom      = 0,
    TTWeakPushSlideDirectionFromTop         = 1,
    TTWeakPushSlideDirectionFromLeftTop     = 2,
    TTWeakPushSlideDirectionFromLeftBottom  = 3,
    TTWeakPushSlideDirectionFromRightTop    = 4,
    TTWeakPushSlideDirectionFromRightBottom = 5,
};


@interface TTWeakPushAlertView : SSThemedView
<
TTPushAlertViewProtocol
>

/** 滑入方向 （default is TTWeakPushRollInDirectionBottom) */
@property (nonatomic, assign) TTWeakPushSlideDirection slipIntoDirection;

/** 显示在iPhoneX设备上，是否考虑indicatorHome高度, default is YES */
@property (nonatomic, assign) BOOL containsIndicatorHome;

- (instancetype)init __attribute__((unavailable("call initWithTitle:content:imageObject: instead")));

- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("call initWithTitle:content:imageObject: instead")));

- (instancetype)initWithCoder:(NSCoder *)aDecoder __attribute__((unavailable("call initWithTitle:content:imageObject: instead")));

- (instancetype)initWithAlertModel:(TTPushAlertModel *)aModel
                     willHideBlock:(TTPushAlertDismissBlock)willHideClk
                      didHideBlock:(TTPushAlertDismissBlock)didHideClk;

+ (instancetype)showWithAlertModel:(TTPushAlertModel *)aModel
                     willHideBlock:(TTPushAlertDismissBlock)willHideClk
                      didHideBlock:(TTPushAlertDismissBlock)didHideClk;

- (instancetype)initWithTitle:(NSString *)titleString
                      content:(NSString *)contentString
                  imageObject:(id)imageObject /* UIImage, NSString, NSURL */;
+ (instancetype)showWithTitle:(NSString *)titleString
                      content:(NSString *)contentString
                  imageObject:(id)imageObject /* UIImage, NSString, NSURL */;

- (void)show;

- (void)showWithAnimated:(BOOL)animated
              completion:(TTPushAlertVoidParamBlock)didCompletedHandler;

- (void)hide;

- (void)hideWithAnimated:(BOOL)animated;

// 当前是否有弹窗正在显示中
+ (BOOL)isShowing;

@end
