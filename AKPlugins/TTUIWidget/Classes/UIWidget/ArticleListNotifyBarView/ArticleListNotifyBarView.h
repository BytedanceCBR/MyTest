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

typedef enum : NSUInteger {
    ArticleListNotifyBarViewAnimationType_Expand = 0,
    ArticleListNotifyBarViewAnimationType_ScrollUp = 1,
} ArticleListNotifyBarViewAnimationType;

@class ArticleListNotifyBarView;

typedef void (^XPNotifyBarButtonBlock)(UIButton * button);
typedef void (^XPNotifyBarHideBlock)(ArticleListNotifyBarView * barView);
typedef void (^XPNotifyBarWillBeginHideBlock)(CGFloat animationDuration, ArticleListNotifyBarViewAnimationType type);
typedef void (^XPNotifyBarWillHideBlock)(ArticleListNotifyBarView * barView, BOOL isImmediately);

@interface ArticleListNotifyBarView : SSViewBase <ErrorToastProtocal>

- (void)showMessage:(NSString *)message
actionButtonTitle:(NSString *)title
          delayHide:(BOOL)delayHide
           duration:(float)duration
bgButtonClickAction:(XPNotifyBarButtonBlock)bgButtonBlock
actionButtonClickBlock:(XPNotifyBarButtonBlock)actionButtonBlock
       didHideBlock:(XPNotifyBarHideBlock)hideBlock;

- (void)showMessage:(NSString *)message
  actionButtonTitle:(NSString *)title
          delayHide:(BOOL)delayHide
           duration:(float)duration
bgButtonClickAction:(XPNotifyBarButtonBlock)bgButtonBlock
actionButtonClickBlock:(XPNotifyBarButtonBlock)actionButtonBlock
       didHideBlock:(XPNotifyBarHideBlock)hideBlock
      willHideBlock:(XPNotifyBarWillHideBlock)willHideBlock;


- (void)hideImmediately;
- (void)hideIfNeeds;
- (void)clean;//invoke before self release

@property(nonatomic, retain) SSThemedButton * rightActionButton;
@property(nonatomic, assign) BOOL userClose; //userClose 如果是YES 是说过n秒后隐藏，NO 是说需要用户手动点关闭
@property(nonatomic, copy) XPNotifyBarWillBeginHideBlock willBeginHideBlock; // 在动画即将开始的block，跳过置顶需要明确知道这个view开始动画的时机，并且同步做外部动画

+ (UIView<ErrorToastProtocal>*)addErrorToastViewWithTop:(CGFloat)top width:(CGFloat)width height:(CGFloat)height;

@end
