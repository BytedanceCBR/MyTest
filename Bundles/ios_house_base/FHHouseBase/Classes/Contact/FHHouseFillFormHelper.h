//
//  FHHouseFillFormHelper.h
//  FHHouseBase
//
//  Created by 张静 on 2019/4/23.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import <FHHouseBase/FHHouseType.h>
#import <FHHouseBase/FHHouseContactDefines.h>
#import "FHAssociateFormReportModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseFillFormConfigModel,FHFillFormAgencyListItemModel;

@interface FHHouseFillFormHelper : NSObject

typedef  void(^fillFormSubmitCallBack)();

#pragma mark - associate refactor
+ (void)fillFormActionWithAssociateReport:(NSDictionary *)associateReportDict;
+ (void)fillFormActionWithAssociateReportModel:(FHAssociateFormReportModel *)associateReport;

@end

NS_CLASS_DEPRECATED_IOS(2_0, 2_0, "use FHAssociateFormReportModel instead")
@interface FHHouseFillFormConfigModel : JSONModel

#pragma mark 必填
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, weak) UIViewController *topViewController;
@property (nonatomic, copy) NSNumber *targetType; // 线索类型

#pragma mark 非必填
@property (nonatomic, copy) NSString *title; // 非必填
@property (nonatomic, copy) NSString *subtitle;// 非必填
@property (nonatomic, copy) NSString *btnTitle;// 非必填
@property (nonatomic, copy) NSString *leftBtnTitle;// 非必填
@property (nonatomic, copy) NSString *from;// 非必填
@property (nonatomic, copy) NSString *customHouseId;// 非必填
@property (nonatomic, copy) NSString *realtorId; // 在线联系时必填
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, assign) FHFollowActionType actionType;
@property (nonatomic, strong , nullable) NSArray<FHFillFormAgencyListItemModel *> *chooseAgencyList;
@property (nonatomic, copy) NSString *toast;//提交成功后弹出的提示语

#pragma mark 埋点
// 必填
@property (nonatomic , copy) NSString *originSearchId;
@property (nonatomic , copy) NSString *originFrom;
@property (nonatomic , copy) NSString *elementFrom;
@property (nonatomic , copy) NSString *enterFrom;
@property (nonatomic , copy) NSString *pageType;
@property (nonatomic , copy) NSString *cardType;
@property (nonatomic , copy) NSString *rank; 
@property (nonatomic , strong) NSDictionary *logPb;
@property (nonatomic , copy) NSString *searchId;
@property (nonatomic , copy) NSString *imprId;
// 非必填
@property (nonatomic , copy) NSString *position;
@property (nonatomic , copy) NSString *realtorPosition;
@property (nonatomic , copy) NSString *itemId;
@property (nonatomic , strong) NSNumber *cluePage;
@property (nonatomic , strong) NSNumber *clueEndpoint;

- (void)setTraceParams:(NSDictionary *)params;
@end


NS_ASSUME_NONNULL_END
