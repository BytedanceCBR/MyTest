//
//  ToastManager.h
//  Pods
//
//  Created by 张元科 on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define SHOW_TOAST(toast) [[ToastManager manager] showToast:toast]

typedef NS_ENUM(NSInteger, FHToastViewStyle)
{
    FHToastViewStyleDefault = 0,                //默认
    FHToastViewStyleOrange,                     //橘色
};

typedef NS_ENUM(NSInteger, FHToastViewPosition)
{
    FHToastViewPositionCenter = 0,              //居中
    FHToastViewPositionTop,                     //顶部
    FHToastViewPositionBottom,                  //底部
};

@interface ToastManager : NSObject

+ (instancetype)manager;

- (void)showToast:(NSString *)message;
- (void)showToast:(NSString *)message style:(FHToastViewStyle)style;
- (void)showToast:(NSString *)message style:(FHToastViewStyle)style position:(FHToastViewPosition)position verticalOffset:(CGFloat)verticalOffset;
- (void)showToast:(NSString *)message duration:(NSTimeInterval)duration isUserInteraction:(BOOL)isUserInteraction;

- (void)showCustomLoading:(NSString *)message;
- (void)showCustomLoading:(NSString *)message isUserInteraction:(BOOL)isUserInteraction;
- (void)dismissCustomLoading;

@end

@interface FHToastView : UIView

@end

@interface FHCycleIndicatorView : UIView

- (void)startAnimating;
- (void)stopAnimating;

@end


@interface FHLoadingView : UIView

@property (nonatomic, strong)   UILabel       *message;

@end

NS_ASSUME_NONNULL_END
