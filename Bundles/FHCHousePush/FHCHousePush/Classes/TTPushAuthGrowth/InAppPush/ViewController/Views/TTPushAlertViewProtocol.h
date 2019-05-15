//
//  TTPushAlertViewProtocol.h
//  Article
//
//  Created by liuzuopeng on 17/07/2017.
//
//

#import <Foundation/Foundation.h>



typedef void (^TTPushAlertVoidParamBlock)();
typedef void (^TTPushAlertDismissBlock)(NSInteger hideReason);


@class TTPushAlertModel;
@protocol TTPushAlertViewProtocol <NSObject>
@required
/** 是否支持旋转 (Default is iPad(YES), iPhone(NO)) */
@property (nonatomic, assign) BOOL shouldAutorotate;
@property (nonatomic, strong) TTPushAlertModel *alertModel;

@required
@property (nonatomic,   copy) TTPushAlertDismissBlock didTapHandler;
@property (nonatomic,   copy) TTPushAlertDismissBlock willHideHandler;
@property (nonatomic,   copy) TTPushAlertDismissBlock didHideHandler;

@required
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

@end
