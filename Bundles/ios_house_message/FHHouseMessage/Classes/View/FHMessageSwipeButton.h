//
//  Created by xubinbin on 2020/8/14.
//

#import <UIKit/UIKit.h>

typedef void(^TouchSwipeButtonBlock)(void);

@interface FHMessageSwipeButton : UIButton

@property (nonatomic, strong) TouchSwipeButtonBlock touchBlock;

+ (FHMessageSwipeButton *)createSwipeButtonWithTitle:(NSString *)title font:(CGFloat)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor touchBlock:(TouchSwipeButtonBlock)block;

@end
