//
//  FHPersonalHomePageProfileInfoModel.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface FHPersonalHomePageProfileInfoDataModel : JSONModel

@property (nonatomic, copy , nullable) NSString *userId;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, copy , nullable) NSString *bigAvatarUrl;
@property (nonatomic, copy , nullable) NSString *verifiedContent;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@end

@interface FHPersonalHomePageProfileInfoModel : JSONModel
@property (nonatomic, copy , nullable) NSString *errorCode;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHPersonalHomePageProfileInfoDataModel *data; 
@end

NS_ASSUME_NONNULL_END
