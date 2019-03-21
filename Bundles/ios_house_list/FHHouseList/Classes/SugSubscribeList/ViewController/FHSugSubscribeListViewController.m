//
//  FHSugSubscribeListViewController.m
//  FHHouseList
//
//  Created by 张元科 on 2019/3/19.
//

#import "FHSugSubscribeListViewController.h"

@interface FHSugSubscribeListViewController ()

@end

@implementation FHSugSubscribeListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.houseType = [paramObj.allParams[@"house_type"] integerValue];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    [self setupDefaultNavBar:YES];
}

@end
