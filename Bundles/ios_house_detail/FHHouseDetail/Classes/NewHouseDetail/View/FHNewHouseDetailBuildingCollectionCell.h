//
//  FHNewHouseDetailBuildingCollectionCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/9.
//

#import "FHDetailBaseCell.h"
@class FHDetailNewBuildingInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailBuildingCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void (^addClickOptions)(NSString *);
@property (nonatomic, copy) void (^goBuildingDetail)(NSString *);

@end

@interface FHNewHouseDetailBuildingModel : NSObject

@property (nonatomic, strong, nullable) FHDetailNewBuildingInfoModel *buildingInfo;

@end

@interface FHNewHouseDetailBuildingInfoView : UIView

@property (nonatomic, strong) NSString *infoId;

@end

NS_ASSUME_NONNULL_END
