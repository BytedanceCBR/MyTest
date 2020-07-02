//
//  FHBuildingDetailViewController.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/2.
//

#import "FHBuildingDetailViewController.h"
#import "FHHouseDetailAPI.h"

@interface FHBuildingDetailViewController ()

@property (nonatomic, copy) NSString *houseId;

@end

@implementation FHBuildingDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if (self = [super initWithRouteParamObj:paramObj]) {
        if (paramObj.allParams[@"house_id"]) {
            self.houseId = paramObj.allParams[@"house_id"];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [FHHouseDetailAPI requestBuildingDetail:self.houseId completion:^(FHBuildingDetailModel * _Nullable model, NSError * _Nullable error) {
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
