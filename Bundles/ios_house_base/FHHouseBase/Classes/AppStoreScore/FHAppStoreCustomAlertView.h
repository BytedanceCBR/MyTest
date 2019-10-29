//
//  FHAppStoreCustomAlertView.h
//  Pods
//
//  Created by 张静 on 2019/10/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHAppStoreCustomAlertView : UIView

+ (FHAppStoreCustomAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray<NSString *>*)buttons tapBlock:(void(^)(NSInteger index))tapBlock;

- (void)show;

@end

NS_ASSUME_NONNULL_END
