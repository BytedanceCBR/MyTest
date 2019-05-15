//
//  TTAdCanvasContinerViewController.h
//  Article
//
//  Created by carl on 2017/7/14.
//
//

#import "SSViewControllerBase.h"
#import "TTAdCanvasContainerViewModel.h"
#import "TTAdCanvasDefine.h"
#import <TTRoute.h>

@interface TTAdCanvasContinerViewController : SSViewControllerBase <TTRouteInitializeProtocol>

@property (nonatomic, strong, nullable) TTAdCanvasContainerViewModel *containerViewModel;
@property (nonatomic, strong, nullable) SSViewControllerBase<TTAdCanvasViewController> *detailViewController;
@property (nonatomic, strong, nullable) UIView *shotScreenView;

@end
