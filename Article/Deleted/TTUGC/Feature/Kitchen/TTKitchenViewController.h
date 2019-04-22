//
//  TTKitchenViewController.h
//  Article
//
//  Created by SongChai on 2017/8/21.
//

#import "SSDebugViewControllerBase.h"

#if INHOUSE

@interface TTKitchenViewController : SSDebugViewControllerBase

+ (void)showInViewController:(UIViewController *)viewController;
+ (UIButton *)kitchenShowButton;
@end

#endif
