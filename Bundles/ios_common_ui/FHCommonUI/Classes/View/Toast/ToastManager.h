//
//  ToastManager.h
//  Pods
//
//  Created by 张元科 on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToastManager : NSObject

+ (instancetype)manager;

- (void)showToast:(NSString *)message;
- (void)showToast:(NSString *)message duration:(NSTimeInterval)duration isUserInteraction:(BOOL)isUserInteraction;

@end

@interface FHToastView : UIView

@end

NS_ASSUME_NONNULL_END