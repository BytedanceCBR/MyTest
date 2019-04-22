//
//  TTAdCanvasViewController.h
//  Article
//
//  Created by yin on 2017/1/4.
//
//


#import "SSViewControllerBase.h"
#import "TTAdCanvasDefine.h"
#import "TTAdCanvasViewModel.h"

extern NSString * const kTTAdCanvasNotificationViewDidDisappear;

@class TTAdCanvasTracker;

@interface TTAdCanvasViewController : SSViewControllerBase <TTAdCanvasViewController>

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj;
- (instancetype)initWithViewModel:(TTAdCanvasViewModel *)viewModel;

@property (nonatomic, weak) id<TTAdCanvasVCDelegate> delegate;
@property (nonatomic, strong) TTAdCanvasViewModel *viewModel;
@property (nonatomic, strong) TTAdCanvasTracker *tracker;

@end
