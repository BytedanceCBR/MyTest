//
//  FHHouseOldHomeViewController.m
//  Pods
//
//  Created by 张静 on 2019/3/3.
//

#import "FHHouseOldHomeViewController.h"

@interface FHHouseOldHomeViewController ()<TTRouteInitializeProtocol>

@end

@implementation FHHouseOldHomeViewController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.paramObj = paramObj;
        self.tracerModel.categoryName = [self categoryName];
        self.ttTrackStayEnable = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
