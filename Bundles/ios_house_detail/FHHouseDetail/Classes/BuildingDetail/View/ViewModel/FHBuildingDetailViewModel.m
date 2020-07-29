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
    FHBuildingLocationModel *locationModel = [[FHBuildingLocationModel alloc] init];
    NSMutableArray *saleArray = [NSMutableArray array];
    NSMutableDictionary *saleDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSMutableDictionary *buildingDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSMutableArray *saleStatusContentArray = [[NSMutableArray alloc] initWithCapacity:3];
    for (FHBuildingDetailDataItemModel *building in model.data.buildingList) {
        building.beginWidth = model.data.buildingImage.width;
        building.beginHeight = model.data.buildingImage.height;
        FHSaleStatusModel *buildSaleStatus = building.saleStatus;
        [saleDic setObject:buildSaleStatus forKey:buildSaleStatus.content];
        NSMutableArray *array = [buildingDic objectForKey:buildSaleStatus.content];
        if (array == nil) {
            array = [NSMutableArray array];
            [saleStatusContentArray addObject:buildSaleStatus.content];
            [buildingDic setObject:array forKey:buildSaleStatus.content];
        }
        [array addObject:building];
    }
    NSArray *allPoint = @[@"在售",@"代售",@"售罄"];
    NSMutableArray *order = [NSMutableArray arrayWithCapacity:3];
    for (NSString *saleStr in allPoint) {
        if ([saleStatusContentArray containsObject:saleStr]) {
            [order addObject:saleStr];
        }
    }
    saleStatusContentArray = order.copy;

    for (NSUInteger i = 0; i < saleStatusContentArray.count; i++) {
        NSString *saleStatusContent = saleStatusContentArray[i];
        NSMutableArray *array = [buildingDic objectForKey:saleStatusContent];
        FHSaleStatusModel *saleStatus = [saleDic objectForKey:saleStatusContent];
        FHBuildingSaleStatusModel *saleStatusModel = [[FHBuildingSaleStatusModel alloc] init];
        for (NSUInteger j = 0; j < array.count; j++) {
            FHBuildingDetailDataItemModel *building = array[j];
            building.buildingIndex = [[FHBuildingIndexModel alloc] init];
            building.buildingIndex.saleStatus = i;
            building.buildingIndex.buildingIndex = j;
        }
        saleStatusModel.buildingList = array.copy;
        saleStatusModel.saleStatus = saleStatus;
        [saleArray addObject:saleStatusModel];
    }
    locationModel.saleStatusContents = saleStatusContentArray.copy;
    locationModel.saleStatusList = saleArray.copy;
    locationModel.buildingImage = model.data.buildingImage;
    self.locationModel = locationModel;
    [self.buildingVC reloadData];
}

@end
