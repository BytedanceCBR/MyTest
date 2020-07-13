//
//  FHHouseRealtorDetailInfoModel.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/13.
//

#import "JSONModel.h"
#import "FHHouseRealtorDetailProtocol.h"
#import "FHDetailBaseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRealtorDetailInfoModel : JSONModel<FHHouseRealtorDetailProtocol>

@end

@interface FHHouseRealtorDetailUserEvaluationModel : JSONModel<FHHouseRealtorDetailProtocol>

@end

@interface FHHouseRealtorDetailrRgcModel: NSObject<FHHouseRealtorDetailProtocol>

@end

@interface FHHouseRealtorTitleModel : NSObject<FHHouseRealtorDetailProtocol>
@property (copy, nonatomic)NSString *title;

@end

@interface FHHouseRealtorDetailDataDataModel : JSONModel
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;
@end

@interface FHHouseRealtorDetailModel : JSONModel
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHouseRealtorDetailDataDataModel *data ;
@end

NS_ASSUME_NONNULL_END
