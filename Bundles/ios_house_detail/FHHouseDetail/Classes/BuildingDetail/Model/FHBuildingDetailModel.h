//
//  FHBuildingDetailModel.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/2.
//

#import "JSONModel.h"
#import "FHDetailBaseModel.h"
#import "FHHouseNewsSocialModel.h"
#import "FHHouseBaseInfoModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol FHBuildingDetailDataItemModel<NSObject>
@end

@interface FHBuildingDetailDataItemModel : JSONModel

//@property (nonatomic, strong , nullable) NSArray<FHImageModel> *images;
//@property (nonatomic, copy , nullable) NSString *type;
//@property (nonatomic, copy , nullable) NSString *name;
@end

@interface FHBuildingDetailDataModel : JSONModel

@property (nonatomic, strong , nullable) FHClueAssociateInfoModel *associateInfo;
@property (nonatomic, strong , nullable) NSArray<FHBuildingDetailDataItemModel> *buildingList
@end

@interface FHBuildingDetailModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHBuildingDetailDataModel *data ;

@end

NS_ASSUME_NONNULL_END
