//
//  UIViewController+Refresh_ErrorHandler.h
//  Article
//
//  Created by yuxin on 4/20/15.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

typedef void (^NotifyBarButtonBlock)(UIButton * button);
typedef void (^NotifyBarHideBlock)(id barView);
typedef NSString* (^TTCustomEmptyErrorMsgBlock)(void);
typedef NSString* (^TTCustomEmptyErrorImageNameBlock)(void);
typedef UIView* (^TTCustomFullScreenErrorViewBlock)(void);

typedef NS_ENUM(NSUInteger, TTFullScreenErrorViewType)
{
    TTFullScreenErrorViewTypeEmpty = 0,
    TTFullScreenErrorViewTypeNoFriends = 1,   // 没有关注好友
    TTFullScreenErrorViewTypeNoFollowers = 2, // 没有粉丝
    TTFullScreenErrorViewTypeSessionExpired = 3,
    TTFullScreenErrorViewTypeNetWorkError = 4,
    TTFullScreenErrorViewTypeBlacklistEmpty = 5,
    TTFullScreenErrorViewTypeLocationServiceDisabled = 6,
    TTFullScreenErrorViewTypeLocationServiceError = 7,
    TTFullScreenErrorViewTypeDeleted = 8,
    TTFullScreenErrorViewTypeFollowEmpty = 9,
    TTFullScreenErrorViewTypeOtherNoFriends = 10,   // TA没有关注好友
    TTFullScreenErrorViewTypeOtherNoFollowers = 11, // TA没有粉丝
    TTFullScreenErrorViewTypeNoInterests = 12,      // 自己没有兴趣
    TTFullScreenErrorViewTypeOtherNoInterests = 13, // TA没有兴趣
    TTFullScreenErrorViewTypeNoVisitor = 14,        // 没有访客
    TTFullScreenErrorViewTypeCustomView = 15,       // 使用自定义的视图覆盖原有的控件
    
};

typedef void (^TipTouchBlock)(void);

@protocol UIViewControllerErrorHandler <NSObject>

- (BOOL)tt_hasValidateData;

@optional

- (void)refreshData;

- (void)emptyViewBtnAction;

- (void)sessionExpiredAction;

- (void)handleError:(NSError *)error;

@end


@protocol ErrorToastProtocal <NSObject>

- (void)showMessage:(NSString *)message
  actionButtonTitle:(NSString *)title
          delayHide:(BOOL)delayHide
           duration:(float)duration
bgButtonClickAction:(NotifyBarButtonBlock)bgButtonBlock
actionButtonClickBlock:(NotifyBarButtonBlock)actionButtonBlock
       didHideBlock:(NotifyBarHideBlock)hideBlock;

- (void)hideImmediately;
- (void)hideIfNeeds;
- (BOOL)needResetScrollView;

@property(nonatomic, retain) SSThemedButton * rightActionButton;

@end

@protocol ErrorViewProtocal <NSObject>

@property (nonatomic,strong) SSThemedLabel * errorMsg;
@property (nonatomic,strong) SSThemedImageView * errorImage;

@property (nonatomic,assign) TTFullScreenErrorViewType viewType;
@property (nonatomic,copy) TTCustomEmptyErrorMsgBlock customEmptyErrorMsgBlock;
@property (nonatomic,copy) TTCustomEmptyErrorImageNameBlock customEmptyErrorImageNameBlock;
@property (nonatomic,copy) TTCustomFullScreenErrorViewBlock customFullScreenErrorViewBlock;
@end

@interface UIViewController (Refresh_ErrorHandler)  

@property (nonatomic,strong) IBOutlet UIView * ttLoadingView;
@property (nonatomic,strong) IBOutlet UIView<ErrorViewProtocal> * ttErrorView;

@property (nonatomic,strong) IBOutlet UIView * ttErrorToastView;

@property (nonatomic,assign) BOOL ttNeedShowIndicator;

@property (nonatomic,assign) BOOL ttHasLoadCachedData;
@property (nonatomic,assign) UIEdgeInsets ttContentInset;

@property (nonatomic,assign) TTFullScreenErrorViewType ttViewType;
@property (nonatomic,copy) TTCustomEmptyErrorMsgBlock customEmptyErrorMsgBlock;
@property (nonatomic,copy) TTCustomEmptyErrorImageNameBlock customEmptyErrorImageNameBlock;
@property (nonatomic,copy) TTCustomFullScreenErrorViewBlock customFullScreenErrorViewBlock;

@property (nonatomic,strong) UIView * ttTargetView;

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
