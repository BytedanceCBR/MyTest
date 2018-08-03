//
//  TTAdCanvasContainerViewModel.h
//  Article
//
//  Created by carl on 2017/7/16.
//
//

#import "SSViewControllerBase.h"
#import "TTAdCanvasDefine.h"
#import "TTAdCanvasViewModel.h"
#import <Foundation/Foundation.h>
#import <TTRoute.h>

@interface TTAdCanvasContainerViewModel : NSObject <TTRouteInitializeProtocol>

@property (nonatomic, strong) TTAdCanvasViewModel *detailViewModel;
@property (nonatomic, assign) TTAdCanvasDetailViewStyle openDetailViewStyle;

- (SSViewControllerBase<TTAdCanvasViewController> *)detailViewController;
- (void)fetchCanvasInfomationWithComplete:(void(^)())completion;

@end
