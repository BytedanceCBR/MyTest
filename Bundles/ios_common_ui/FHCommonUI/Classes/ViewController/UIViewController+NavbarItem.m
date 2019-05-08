//
//  UIViewController+NavbarItem.m
//  FHCommonUI
//
//  Created by 谷春晖 on 2018/11/13.
//

#import "UIViewController+NavbarItem.h"
#import <UIFont+House.h>
#import <UIColor+Theme.h>

@implementation UIViewController (NavbarItem)

-(UIBarButtonItem *)defaultBackItemWithTarget:(_Nullable id)target action:(_Nullable SEL)selector
{
    UIImage *image = [UIImage imageNamed:@"nav_back_light"];
    if (target == nil) {
        target = self;
    }
    if (selector == nil) {
        selector = @selector(_defaultBackAction);
    }
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:selector];
    return backItem;
}

-(void)_defaultBackAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(UILabel *)defaultTitleView
{
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont themeFontRegular:18];
    label.textColor = [UIColor themeGray1];
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}


@end
