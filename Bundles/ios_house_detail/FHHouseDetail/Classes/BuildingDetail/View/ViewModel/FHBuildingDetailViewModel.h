//
//  FHBuildingDetailViewModel.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/2.
//

#import <Foundation/Foundation.h>
#import "FHBuildingDetailViewController.h"
#import "FHBuildingSectionModel.h"
@class FHBuildingDetailModel;
NS_ASSUME_NONNULL_BEGIN

@interface FHBuildingDetailViewModel : NSObject

-(instancetype)initWithController:(FHBuildingDetailViewController *)viewController;

@property (nonatomic, copy) NSString *houseId;

@property (nonatomic, strong) FHBuildingDetailModel *buildingDetailModel;

@property (nonatomic, copy) NSArray <FHBuildingSectionModel *>*items;

- (void)startLoadData;

@end

NS_ASSUME_NONNULL_END