//
//  TTVVideoDetailViewController_Private.h
//  Article
//
//  Created by pei yun on 2017/5/18.
//
//

#ifndef TTVVideoDetailViewController_Private_h
#define TTVVideoDetailViewController_Private_h

#import "TTVVideoDetailViewController.h"

@class TTVDetailPlayControl;
@class TTAlphaThemedButton;
@class TTVVideoDetailNatantADView;

@interface TTVVideoDetailViewController ()

@property (nonatomic, strong ,nullable) UIViewController *presentController;
@property (nonatomic, strong ,nullable) TTAlphaThemedButton *backButton;
@property (nonatomic, strong ,nullable) UIView *movieViewSuperView;
@property (nonatomic, assign) CGRect movieViewOriginFrame;
@property (nonatomic, strong ,nullable) TTVVideoDetailNatantADView *embededAD;
@property (nonatomic, assign) UIStatusBarStyle originalStatusBarStyle;

- (UIView * _Nullable)movieContainerView;
- (UIView * _Nullable)movieView;
- (TTVDetailStateStore *_Nullable)detailStateStore;
- (TTVDetailPlayControl *_Nullable)playControl;
- (void)backAction;
- (void)adTopShareActionFired;

- (void)playMovieIfNeeded;
- (void)pauseMovieIfNeeded;

@end

#endif /* TTVVideoDetailViewController_Private_h */
