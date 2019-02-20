//
//  FHFloorPanDetailViewController.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHFloorPanDetailViewController.h"
#import "FHHouseDetailBaseViewModel.h"
#import "TTReachability.h"
#import "FHDetailBottomBarView.h"
#import "FHDetailNavBar.h"
#import "TTDeviceHelper.h"
#import "UIFont+House.h"
#import "FHHouseDetailContactViewModel.h"


@interface FHFloorPanDetailViewController ()
@property (nonatomic, copy)   NSString* floorPanId; // 房源id
@end

@implementation FHFloorPanDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _floorPanId = paramObj.allParams[@"floorpanid"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
