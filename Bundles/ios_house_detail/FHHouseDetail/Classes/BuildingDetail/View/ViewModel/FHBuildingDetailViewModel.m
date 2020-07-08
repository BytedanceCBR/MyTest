//
//  FHBuildingDetailViewModel.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/2.
//

#import "FHBuildingDetailViewModel.h"
#import <TTReachability/TTReachability.h>
#import "FHHouseDetailAPI.h"
#import "FHBuildingDetailModel.h"

@interface FHBuildingDetailViewModel ()

@property (nonatomic, weak) FHBuildingDetailViewController *buildingVC;

@end

@implementation FHBuildingDetailViewModel

-(instancetype)initWithController:(FHBuildingDetailViewController *)viewController {
    if (self = [super init]) {
        self.buildingVC = viewController;
//        [self startLoadData];
    }
    return self;
}

- (void)startLoadData {
    if (![TTReachability isNetworkConnected]) {
        [self.buildingVC.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        return;
    }
    [self.buildingVC startLoading];
    __weak typeof(self) weakSelf = self;
    [FHHouseDetailAPI requestBuildingDetail:self.houseId completion:^(FHBuildingDetailModel * _Nullable model, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (model.data && !error) {
            [strongSelf processDetailData:model];
            [strongSelf.buildingVC.emptyView hideEmptyView];
            strongSelf.buildingVC.hasValidateData = YES;
        } else {
            strongSelf.buildingVC.hasValidateData = NO;
            [strongSelf.buildingVC.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
        }
    }];
}

- (void)processDetailData:(FHBuildingDetailModel *)model {
    if (!model) {
        return;
    }
    self.buildingDetailModel = model;
    [self.buildingVC reloadData];
}

@end
