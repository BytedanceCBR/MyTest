//
//  FHHouseNeighborhoodDetailViewModel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import "FHHouseNeighborhoodDetailViewModel.h"
#import "FHDetailBaseCell.h"
#import "FHHouseDetailAPI.h"
#import "FHDetailPhotoHeaderCell.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHDetailRelatedNeighborhoodResponseModel.h"
#import "FHDetailRelatedHouseResponseModel.h"
#import "FHRentSameNeighborhoodResponse.h"
#import "FHDetailSameNeighborhoodHouseResponseModel.h"
#import "FHDetailNeighborPriceChartCell.h"

@interface FHHouseNeighborhoodDetailViewModel ()

@property (nonatomic, assign)   NSInteger       requestRelatedCount;
@property (nonatomic, strong , nullable) FHDetailRelatedNeighborhoodResponseDataModel *relatedNeighborhoodData;// 周边小区
@property (nonatomic, strong , nullable) FHDetailSameNeighborhoodHouseResponseDataModel *sameNeighborhoodErshouHouseData;// 同小区房源，二手房
@property (nonatomic, strong , nullable) FHRentSameNeighborhoodResponseDataModel *sameNeighborhoodRentHouseData;// 同小区房源，租房

@end

@implementation FHHouseNeighborhoodDetailViewModel

// 注册cell类型
- (void)registerCellClasses {
    [self.tableView registerClass:[FHDetailPhotoHeaderCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPhotoHeaderCell class])];
    [self.tableView registerClass:[FHDetailNeighborPriceChartCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborPriceChartCell class])];

}
// cell class
- (Class)cellClassForEntity:(id)model {
    if ([model isKindOfClass:[FHDetailPhotoHeaderModel class]]) {
        return [FHDetailPhotoHeaderCell class];
    }
    return [FHDetailBaseCell class];
}
// cell identifier
- (NSString *)cellIdentifierForEntity:(id)model {
    Class cls = [self cellClassForEntity:model];
    return NSStringFromClass(cls);
}
// 网络数据请求
- (void)startLoadData {
    // 详情页数据-Main
    //    NSDictionary *logpb = @{@"abc":@"vvv",@"def":@"cccc"};
    // add by zyk 记得logpb数据 传入
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestNeighborhoodDetail:self.houseId logPB:nil query:nil completion:^(FHDetailNeighborhoodModel * _Nullable model, NSError * _Nullable error) {
        if (model && error == NULL) {
            if (model.data) {
                [wSelf processDetailData:model];
                wSelf.detailController.hasValidateData = YES;
                NSString *neighborhoodId = model.data.neighborhoodInfo.id;
                // 周边数据请求
                [wSelf requestRelatedData:neighborhoodId];
            } else {
                wSelf.detailController.hasValidateData = NO;
                [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
            }
        } else {
            wSelf.detailController.hasValidateData = NO;
            [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
        }
    }];
}

// 处理详情页数据
- (void)processDetailData:(FHDetailNeighborhoodModel *)model {
    self.detailData = model;
    // 清空数据源
    [self.items removeAllObjects];
    // 添加头滑动图片
    if (model.data.neighborhoodImage) {
        FHDetailPhotoHeaderModel *headerCellModel = [[FHDetailPhotoHeaderModel alloc] init];
        headerCellModel.houseImage = model.data.neighborhoodImage;
        [self.items addObject:headerCellModel];
    }
    [self reloadData];
}

// 周边数据请求，当网络请求都返回后刷新数据
- (void)requestRelatedData:(NSString *)neighborhoodId {
    self.requestRelatedCount = 0;
    // 周边小区
    [self requestRelatedNeighborhoodSearch:neighborhoodId];
    // 同小区房源-二手房
    [self requestHouseInSameNeighborhoodSearchErShou:neighborhoodId];
    // 同小区房源-租房
    [self requestHouseInSameNeighborhoodSearchRent:neighborhoodId];
}

// 处理详情页周边请求数据
- (void)processDetailRelatedData {
    if (self.requestRelatedCount >= 3) {
        
    }
}

// 周边小区
- (void)requestRelatedNeighborhoodSearch:(NSString *)neighborhoodId {
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestRelatedNeighborhoodSearchByNeighborhoodId:neighborhoodId searchId:nil offset:@"0" query:nil count:5 completion:^(FHDetailRelatedNeighborhoodResponseModel * _Nullable model, NSError * _Nullable error) {
        wSelf.requestRelatedCount += 1;
        wSelf.relatedNeighborhoodData = model.data;
        [wSelf processDetailRelatedData];
    }];
}

// 同小区房源-二手房
- (void)requestHouseInSameNeighborhoodSearchErShou:(NSString *)neighborhoodId {
    NSString *houseId = self.houseId;
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestHouseInSameNeighborhoodSearchByNeighborhoodId:neighborhoodId houseId:houseId searchId:nil offset:@"0" query:nil count:5 completion:^(FHDetailSameNeighborhoodHouseResponseModel * _Nullable model, NSError * _Nullable error) {
        wSelf.requestRelatedCount += 1;
        wSelf.sameNeighborhoodErshouHouseData = model.data;
        [wSelf processDetailRelatedData];
    }];
}

// 同小区房源-租房
- (void)requestHouseInSameNeighborhoodSearchRent:(NSString *)neighborhoodId {
    NSString *houseId = self.houseId;
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestHouseRentSameNeighborhood:houseId withNeighborhoodId:neighborhoodId completion:^(FHRentSameNeighborhoodResponseModel * _Nonnull model, NSError * _Nonnull error) {
        wSelf.requestRelatedCount += 1;
        wSelf.sameNeighborhoodRentHouseData = model.data;
        [wSelf processDetailRelatedData];
    }];
}

@end
