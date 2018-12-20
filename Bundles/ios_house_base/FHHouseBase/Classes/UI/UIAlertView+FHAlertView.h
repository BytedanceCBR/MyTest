//
//  UIAlertView+FHAlertView.h
//  AFgzipRequestSerializer
//
//  Created by leo on 2018/11/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^FHAlertViewDismissBlock)(NSInteger buttonIndex);
typedef void (^FHAlertViewCancelBlock)();
@interface UIAlertView (FHAlertView) <UIAlertViewDelegate>
+ (UIAlertView *)fh_showAlertViewWithTitle:(NSString *)title
                                    message:(NSString *)message
                          cancelButtonTitle:(NSString *)cancelButtonTitle
                          otherButtonTitles:(NSArray *)titleArray
                                  dismissed:(FHAlertViewDismissBlock)dismissBlock
                                   canceled:(FHAlertViewCancelBlock)cancelBlock;

+ (UIAlertView *)fh_showAlertViewWithTitle:(NSString *)message;
@end

NS_ASSUME_NONNULL_END
