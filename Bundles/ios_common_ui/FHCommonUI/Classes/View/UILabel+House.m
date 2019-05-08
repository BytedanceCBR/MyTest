//
//  UILable+House.m
//  FHCommonUI
//
//  Created by 张元科 on 2019/2/15.
//

#import "UILabel+House.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>

@implementation UILabel (House)

+ (UILabel *)createLabel:(NSString *)text textColor:(NSString *)hexColor fontSize:(CGFloat)fontSize {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = [UIColor colorWithHexString:hexColor];
    label.font = [UIFont themeFontRegular:fontSize];
    return label;
}

@end
