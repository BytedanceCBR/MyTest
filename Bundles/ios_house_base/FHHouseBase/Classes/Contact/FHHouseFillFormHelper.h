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

NS_ASSUME_NONNULL_BEGIN

@class FHHouseFillFormConfigModel;

@interface FHHouseFillFormHelper : NSObject

+ (void)fillFormActionWithConfigModel:(FHHouseFillFormConfigModel *)configModel; // 填表单
+ (void)fillFormActionWithConfig:(NSDictionary *)config;
+ (void)fillOnlineFormActionWithConfigModel:(FHHouseFillFormConfigModel *)configModel; // 在线联系
+ (void)fillOnlineFormActionWithConfig:(NSDictionary *)config;

@end


@interface FHHouseFillFormConfigModel : JSONModel

#pragma mark 必填
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, weak) UIViewController *topViewController;

#pragma mark 非必填
@property (nonatomic, copy) NSString *title; // 非必填
@property (nonatomic, copy) NSString *subtitle;// 非必填
@property (nonatomic, copy) NSString *btnTitle;// 非必填
@property (nonatomic, copy) NSString *leftBtnTitle;// 非必填
@property (nonatomic, copy) NSString *fromStr;// 非必填
@property (nonatomic, copy) NSString *customHouseId;// 非必填
@property (nonatomic, copy) NSString *realtorId; // 在线联系时必填
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, assign) FHFollowActionType actionType;

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

- (void)setTraceParams:(NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
