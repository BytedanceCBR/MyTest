//
//  FHAssociateFormReportModel.h
//  FHHouseBase
//
//  Created by 张静 on 2020/4/2.
//

#import "JSONModel.h"
#import "FHAssociateReportParams.h"
#import "FHHouseType.h"
#import <FHHouseBase/FHHouseContactDefines.h>

NS_ASSUME_NONNULL_BEGIN

@class FHFillFormAgencyListItemModel;

@interface FHAssociateFormReportModel : JSONModel

@property (nonatomic, strong) NSDictionary *associateInfo; // 线索相关参数
@property (nonatomic, strong) NSDictionary *reportParams; // 埋点参数

#pragma mark 必填
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, weak) UIViewController *topViewController;

#pragma mark 非必填
@property (nonatomic, copy) NSString *title; // 非必填
@property (nonatomic, copy) NSString *subtitle;// 非必填
@property (nonatomic, copy) NSString *btnTitle;// 非必填
@property (nonatomic, copy) NSString *leftBtnTitle;// 非必填

//@property (nonatomic, copy) NSString *phone;
@property (nonatomic, assign) FHFollowActionType actionType;
@property (nonatomic, strong , nullable) NSArray<FHFillFormAgencyListItemModel *> *chooseAgencyList;
@property (nonatomic, copy) NSString *toast;//提交成功后弹出的提示语

@end

NS_ASSUME_NONNULL_END
