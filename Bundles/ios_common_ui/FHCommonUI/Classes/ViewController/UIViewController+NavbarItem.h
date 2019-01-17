//
//  UIViewController+NavbarItem.h
//  FHCommonUI
//
//  Created by 谷春晖 on 2018/11/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (NavbarItem)

-(UIBarButtonItem *)defaultBackItemWithTarget:(_Nullable id)target action:(_Nullable SEL)action;

-(UILabel *)defaultTitleView;

@end

NS_ASSUME_NONNULL_END
