//
//  TTMovieLandscapeViewController.h
//  Article
//
//  Created by 徐霜晴 on 16/9/23.
//
//

#import <UIKit/UIKit.h>
#import "TTMovieFullscreenProtocol.h"
@class TTMovieFullscreenViewController;

@protocol TTMovieFullscreenViewControllerDelegate <NSObject>

@optional
- (void)movieFullscreenVC:(TTMovieFullscreenViewController *)vc willRotateToOrientation:(UIInterfaceOrientation)orientation;
- (void)movieFullscreenVC:(TTMovieFullscreenViewController *)vc didRotateFromOrientation:(UIInterfaceOrientation)orientation;

@end

@interface TTMovieFullscreenViewController : UIViewController

@property (nonatomic, assign, readonly) UIInterfaceOrientation orientationBeforePresented;
@property (nonatomic, assign, readonly) UIInterfaceOrientation orientationAfterPresented;
@property (nonatomic, assign, readonly) UIInterfaceOrientationMask supportedOrientations;
@property (nonatomic, weak) UIView<TTMovieFullscreenProtocol> *exploreMovieView;
@property (nonatomic, weak) id<TTMovieFullscreenViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL animatedDuringTransition;

- (instancetype)initWithOrientationBeforePresented:(UIInterfaceOrientation)orientationBeforePresented
                         orientationAfterPresented:(UIInterfaceOrientation)orientationAfterPresented
                             supportedOrientations:(UIInterfaceOrientationMask)supportedOrientations;

+ (CGFloat)rotationRadianForInterfaceOrienationIniOS7:(UIInterfaceOrientation)interfaceOrientation;
+ (CGRect)windowBoundsForInterfaceOrientationIniOS7:(UIInterfaceOrientation)interfaceOrientation;

@end
