//
//  UIViewController+Refresh_ErrorHandler.h
//  Article
//
//  Created by yuxin on 4/20/15.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

#import "UIViewController+Refresh_ErrorHandler.h"

typedef void (^TipTouchBlock)(void);

extern CGFloat const kTipDefaultDuration;

extern CGFloat const kTipDurationInfinite;


@interface UIView(Refresh_ErrorHandler)  

@property (nonatomic,strong) IBOutlet UIView * ttLoadingView;
@property (nonatomic,strong) IBOutlet UIView<ErrorViewProtocal> * ttErrorView;

@property (nonatomic,strong) IBOutlet UIView<ErrorToastProtocal>  * ttErrorToastView;

@property (nonatomic,strong) IBOutlet UIActivityIndicatorView * ttIndicator;

@property (nonatomic,strong) UIView * ttTargetView;

@property (nonatomic,assign) BOOL ttNeedShowIndicator;
@property (nonatomic,assign) BOOL ttDisableNotifyBar;
@property (nonatomic,assign) BOOL ttHasLoadCachedData;
@property (nonatomic,assign) UIEdgeInsets ttContentInset;

@property (nonatomic,assign) TTFullScreenErrorViewType ttViewType;
@property (nonatomic,copy) TTCustomEmptyErrorMsgBlock customEmptyErrorMsgBlock;
@property (nonatomic,copy) TTCustomEmptyErrorImageNameBlock customEmptyErrorImageNameBlock;
@property (nonatomic,copy) TTCustomFullScreenErrorViewBlock customFullScreenErrorViewBlock;

//用来给提示条 做展位处理的
@property (nonatomic,strong) IBOutlet UIScrollView * ttAssociatedScrollView;

@property (nonatomic) CGFloat ttMessagebarHeight;


- (void)tt_registerLoadingViewWithNib:(UINib *)nib;
- (void)tt_registerLoadingViewWithClass:(Class)className;

- (void)tt_registerErrorViewWithNib:(UINib *)nib;
- (void)tt_registerErrorViewWithClass:(Class)className;

//开始loading
- (void)tt_startUpdate;

//简单的去除loading效果
- (void)tt_endUpdataData;

//去除loading效果 并加上error 处理和 tip处理
- (void)tt_endUpdataData:(BOOL)isCache error:(NSError *)error;

- (void)tt_endUpdataData:(BOOL)isCache error:(NSError *)error tip:(NSString*)tip tipTouchBlock:(TipTouchBlock)block;

- (void)tt_ShowTip:(NSString*)tip duration:(CGFloat)duration tipTouchBlock:(TipTouchBlock)block;

- (void)tt_endUpdataData:(BOOL)isCache error:(NSError *)error tip:(NSString*)tip duration:(CGFloat)duration tipTouchBlock:(TipTouchBlock)block;

@end
