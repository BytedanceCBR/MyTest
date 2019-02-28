//
//  UILable+House.h
//  FHCommonUI
//
//  Created by 张元科 on 2019/2/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (House)

+ (UILabel *)createLabel:(NSString *)text textColor:(NSString *)hexColor fontSize:(CGFloat)fontSize;

@end

NS_ASSUME_NONNULL_END
