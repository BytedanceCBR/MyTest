//
//  TTStrongPushAlertView.h
//  Article
//
//  Created by liuzuopeng on 02/07/2017.
//
//

#import <SSThemed.h>
#import "TTPushAlertViewProtocol.h"



typedef NS_ENUM(NSInteger, TTStrongAlertHideType) {
    TTStrongAlertHideTypeExternalCall = -2,
    TTStrongAlertHideTypeTapMask      = -1,
    TTStrongAlertHideTypeTapCancel    = 0,
    TTStrongAlertHideTypeTapOk        = 1,
    TTStrongAlertHideTypeTapContent   = 2,
};

@interface TTStrongPushAlertView : SSThemedView
<
TTPushAlertViewProtocol
>

- (instancetype)initWithAlertModel:(TTPushAlertModel *)aModel
                     willHideBlock:(TTPushAlertDismissBlock)willHideClk
                      didHideBlock:(TTPushAlertDismissBlock)didHideClk;

+ (instancetype)showWithAlertModel:(TTPushAlertModel *)aModel
                     willHideBlock:(TTPushAlertDismissBlock)willHideClk
                      didHideBlock:(TTPushAlertDismissBlock)didHideClk;

- (void)show;

- (void)showWithAnimated:(BOOL)animated
              completion:(TTPushAlertVoidParamBlock)didCompletedHandler;

- (void)hide;

- (void)hideWithAnimated:(BOOL)animated;

// 是否有弹窗正在显示中
+ (BOOL)isShowing;

@end


