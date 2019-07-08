//
//  FHHouseContactBaseModel.h
//  FHHouseBase
//
//  Created by 张静 on 2019/4/25.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "FHBaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN


@interface  FHDetailResponseModel  : JSONModel <FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;

@end

@interface  FHDetailVirtualNumModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *realtorId;
@property (nonatomic, copy , nullable) NSString *virtualNumber;
@property (nonatomic, assign) NSInteger isVirtual;

@end

@interface  FHDetailVirtualNumResponseModel  : JSONModel <FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailVirtualNumModel *data;

@end

@interface  FHDetailUserFollowStatusModel  : JSONModel

@property (nonatomic, assign) NSInteger followStatus;
@property (nonatomic, assign) NSInteger socialGroupFollowStatus;
@property (nonatomic, copy) NSString* socialGroupId;

@end

@interface  FHDetailUserFollowResponseModel  : JSONModel <FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailUserFollowStatusModel *data;

@end


@interface FHHouseContactBaseModel : JSONModel

@end

NS_ASSUME_NONNULL_END
