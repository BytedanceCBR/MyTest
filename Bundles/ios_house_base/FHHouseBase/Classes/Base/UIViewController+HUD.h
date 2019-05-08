//
//  UIViewController+HUD.h
//  Article
//
//  Created by 谷春晖 on 2018/11/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (HUD)

-(void)showLoadingAlert:(NSString *_Nullable)message;

-(void)showLoadingAlert:(NSString *_Nullable)message offset:(CGPoint)offset;

-(void)dismissLoadingAlert;

@end

NS_ASSUME_NONNULL_END
