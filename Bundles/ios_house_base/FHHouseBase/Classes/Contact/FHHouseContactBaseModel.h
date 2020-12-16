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

@interface FHFormAssociateInfoControlInfoDialogModel : JSONModel

@property (nonatomic, copy , nullable) NSString *cancelBtnText;
@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *confirmBtnText;
@property (nonatomic, copy , nullable) NSString *title;
@end

@interface FHFormAssociateInfoControlInfoModel : JSONModel

@property (nonatomic, assign) BOOL enable;
@property (nonatomic, copy , nullable) NSString *verifyType; //3 需要二次弹框确认
@property (nonatomic, copy , nullable) NSString *showType;
@property (nonatomic, copy , nullable) NSString *submitType;
@property (nonatomic, strong , nullable) FHFormAssociateInfoControlInfoDialogModel *dialog ;
@property (nonatomic, strong , nullable) NSArray *associateTypes;
@end

@interface FHFormAssociateInfoControlModel : JSONModel

@property (nonatomic, strong , nullable) FHFormAssociateInfoControlInfoModel *controlInfo ;

@end

@interface FHFormAssociateInfoModel : JSONModel

@property (nonatomic, strong , nullable) FHFormAssociateInfoControlModel *associateInfo ;
@property (nonatomic, copy, nullable) NSString *associateId;
@end

@interface  FHDetailFillFormResponseModel  : JSONModel <FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHFormAssociateInfoModel *data;

@end

@interface  FHDetailVirtualNumModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *realtorId;
@property (nonatomic, copy , nullable) NSString *virtualNumber;
@property (nonatomic, copy , nullable) NSString *requestId;
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
