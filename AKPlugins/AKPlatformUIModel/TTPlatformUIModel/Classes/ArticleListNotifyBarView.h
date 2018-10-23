//
//  ArticleListNotifyBarView.h
//  Article
//
//  Created by Zhang Leonardo on 14-4-2.
//
//

#import "SSViewBase.h"
#import "SSThemed.h"
#import "UIViewController+Refresh_ErrorHandler.h"

#define kDefaultDismissDuration 2.0f

@class ArticleListNotifyBarView;

typedef void (^XPNotifyBarButtonBlock)(UIButton * button);
typedef void (^XPNotifyBarHideBlock)(ArticleListNotifyBarView * barView);

@interface ArticleListNotifyBarView : SSViewBase <ErrorToastProtocal>

- (void)showMessage:(NSString *)message
actionButtonTitle:(NSString *)title
          delayHide:(BOOL)delayHide
           duration:(float)duration
bgButtonClickAction:(XPNotifyBarButtonBlock)bgButtonBlock
actionButtonClickBlock:(XPNotifyBarButtonBlock)actionButtonBlock
       didHideBlock:(XPNotifyBarHideBlock)hideBlock;


- (void)hideImmediately;
- (void)hideIfNeeds;
- (void)clean;//invoke before self release

@property(nonatomic, retain) SSThemedButton * rightActionButton;
@property(nonatomic, assign) BOOL userClose; //userClose 如果是YES 是说过n秒后隐藏，NO 是说需要用户手动点关闭

+ (UIView<ErrorToastProtocal>*)addErrorToastViewWithTop:(CGFloat)top width:(CGFloat)width height:(CGFloat)height;

@end
