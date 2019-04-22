//
//  TTAdCanvasVC.h
//  Article
//
//  Created by yin on 2017/4/7.
//
//

#import <UIKit/UIKit.h>
#import "SSViewControllerBase.h"
#import "TTAdCanvasViewController.h"
#import "TTAdCanvasLayoutModel.h"
#import "TTAdCanvasTracker.h"
#import "TTAdCanvasViewModel.h"
#import "TTAdCanvasDefine.h"

@interface TTAdCanvasVC : SSViewControllerBase <TTAdCanvasViewController>

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj;
- (instancetype)initWithViewModel:(TTAdCanvasViewModel *)viewModel;

@property (nonatomic, weak) id<TTAdCanvasVCDelegate> delegate;
@property (nonatomic, strong) TTAdCanvasTracker *tracker;
@property (nonatomic, strong) TTAdCanvasViewModel *viewModel;

@end
