//
//  UIViewController+BDTAccountModalPresentor.m
//  Article
//
//  Created by zuopengliu on 14/9/2017.
//
//

#import "UIViewController+BDTAccountModalPresentor.h"
#import "TTModalContainerController.h"



@implementation UIViewController (BDTAccountModalPresentor)

- (void)bdta_presentModalViewController:(UIViewController *)viewController
                               animated:(BOOL)animated
                             completion:(void (^)())completion
{
    TTModalContainerController *modalContainerVC = [[TTModalContainerController alloc] initWithRootViewController:(id)viewController];
    
    modalContainerVC.containerDelegate = (id)viewController;
    
    if ([TTDeviceHelper OSVersionNumber] < 8.0f) {
        self.view.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:modalContainerVC animated:NO completion:nil];
        self.view.window.rootViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    } else {
        [self presentViewController:modalContainerVC animated:YES completion:completion];
    }
}

@end

