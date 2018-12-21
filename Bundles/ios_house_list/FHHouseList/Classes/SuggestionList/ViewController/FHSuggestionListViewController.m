//
//  FHSuggestionListViewController.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import "FHSuggestionListViewController.h"

@interface FHSuggestionListViewController ()

@end

@implementation FHSuggestionListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
//        self.neighborhoodId = paramObj.userInfo.allInfo[@"neighborhoodId"];
//        self.houseId = paramObj.userInfo.allInfo[@"houseId"];
//        self.searchId = paramObj.userInfo.allInfo[@"searchId"];
//        self.houseType = [paramObj.userInfo.allInfo[@"house_type"] integerValue];
//        self.relatedHouse = [paramObj.userInfo.allInfo[@"related_house"] boolValue];
//        self.neighborListVCType = [paramObj.userInfo.allInfo[@"list_vc_type"] integerValue];
//
//        NSLog(@"%@\n", self.searchId);
        NSLog(@"%@\n",paramObj.userInfo.allInfo);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
}

- (void)setupUI {
    
}

@end
