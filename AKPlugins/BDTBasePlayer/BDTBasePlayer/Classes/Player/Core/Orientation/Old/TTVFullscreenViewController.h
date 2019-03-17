//
//  TTMovieLandscapeViewController.h
//  Article
//
//  Created by 徐霜晴 on 16/9/23.
//
//

#import <UIKit/UIKit.h>
#import "TTVFullscreenProtocol.h"

@interface TTVFullscreenViewController : UIViewController

@property (nonatomic, assign, readonly) UIInterfaceOrientation orientationBeforePresented;
@property (nonatomic, assign, readonly) UIInterfaceOrientation orientationAfterPresented;
@property (nonatomic, assign, readonly) UIInterfaceOrientationMask supportedOrientations;

@property (nonatomic, assign) BOOL animatedDuringTransition;

- (instancetype)initWithOrientationBeforePresented:(UIInterfaceOrientation)orientationBeforePresented
                         orientationAfterPresented:(UIInterfaceOrientation)orientationAfterPresented
                             supportedOrientations:(UIInterfaceOrientationMask)supportedOrientations;

+ (CGFloat)rotationRadianForInterfaceOrienationIniOS7:(UIInterfaceOrientation)interfaceOrientation;
+ (CGRect)windowBoundsForInterfaceOrientationIniOS7:(UIInterfaceOrientation)interfaceOrientation;

@end
