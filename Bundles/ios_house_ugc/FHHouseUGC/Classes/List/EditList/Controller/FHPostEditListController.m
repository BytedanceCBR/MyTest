//
//  FHPostEditListController.m
//
//  Created by zhangyuanke on 2019/12/19.
//

#import "FHPostEditListController.h"
#import "TTBaseMacro.h"
#import "UIScrollView+Refresh.h"
#import "UIViewAdditions.h"
#import <TTUIWidget/UIViewController+Track.h>
#import <FHUserTracker.h>

@interface FHPostEditListController ()

@end

@implementation FHPostEditListController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ttTrackStayEnable = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

@end
