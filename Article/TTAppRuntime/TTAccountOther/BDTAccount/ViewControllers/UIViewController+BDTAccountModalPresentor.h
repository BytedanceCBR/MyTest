//
//  UIViewController+BDTAccountModalPresentor.h
//  Article
//
//  Created by zuopengliu on 14/9/2017.
//
//

#import <UIKit/UIKit.h>



@interface UIViewController (BDTAccountModalPresentor)

- (void)bdta_presentModalViewController:(UIViewController *)viewController
                               animated:(BOOL)animated
                             completion:(void (^)())completion;

@end
