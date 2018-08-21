//
//  UIMenuController+Extension.m
//  Article
//
//  Created by 杨心雨 on 2017/1/25.
//
//

#import "UIMenuController+Extension.h"

@implementation UIMenuController (Dismiss)

+ (void)dismissWithAnimated:(BOOL)animated {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController.isMenuVisible) {
        [menuController setMenuVisible:NO animated:animated];
    }
}

@end
