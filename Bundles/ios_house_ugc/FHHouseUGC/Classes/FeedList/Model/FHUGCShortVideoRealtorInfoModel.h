//
//  FHUGCShortVideoRealtorInfoModel.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/7/30.
//

#import "JSONModel.h"
#import "FHBaseModelProtocol.h"
#import "FHDetailBaseModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface FHUGCShortVideoRealtorInfo : JSONModel
@property (nonatomic, copy, nullable) NSString *realtorId;
@property (nonatomic, copy, nullable) NSString *realtorName;
@property (nonatomic, copy, nullable) NSString *agencyName;
@property (nonatomic, copy, nullable) NSString *mainPageInfo;
@property (nonatomic, copy, nullable) NSString *firstBizType;
@property (nonatomic, copy, nullable) NSString *avatarUrl;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;
@property (nonatomic, copy, nullable) NSDictionary *realtorLogPb;
@property (nonatomic, copy, nullable) NSString *certificationIcon;
@property (nonatomic, copy, nullable) NSString *certificationPage;
@property (nonatomic, copy, nullable) NSString *chatOpenUrl;
@property (nonatomic, copy, nullable) NSString *desc;

@end

@interface FHUGCShortVideoRealtor : JSONModel
@property (strong, nonatomic, nullable) FHUGCShortVideoRealtorInfo *realtor;
@end

@interface FHUGCShortVideoRealtorInfoModel : JSONModel <FHBaseModelProtocol>
@property (strong, nonatomic, nullable) FHUGCShortVideoRealtor *data;
@property (nonatomic, copy, nullable) NSString *status;
@property (nonatomic, copy, nullable) NSString *message;
@end

NS_ASSUME_NONNULL_END
