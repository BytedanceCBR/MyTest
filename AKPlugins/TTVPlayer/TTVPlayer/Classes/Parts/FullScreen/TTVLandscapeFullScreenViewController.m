//
//  TTVLandscapeFullScreenViewController.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/6.
//

#import "TTVLandscapeFullScreenViewController.h"

@interface TTVLandscapeFullScreenViewController ()

@end

@implementation TTVLandscapeFullScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)prefersStatusBarHidden{
    return NO;
}

-(BOOL)shouldAutorotate{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return (UIInterfaceOrientationMaskLandscape);
}

//-(void)screenRotate:(NSNotification*)notification{
//    UIDevice* device = notification.object;
//    NSLog(@"notification:::%@", @(device.orientation));
//
//    if (device.orientation == UIDeviceOrientationPortrait) {
//
//        __weak typeof(self) weakSelf = self;
//        [self dismissViewControllerAnimated:YES completion:^{
//            if (weakSelf.didDismiss) {
//                weakSelf.didDismiss();
//            }
//        }];
//    }
//}

@end
