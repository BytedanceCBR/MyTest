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

@class FHFillFormAgencyListItemModel;

@interface FHHouseFillFormHelper : NSObject

typedef  void(^fillFormSubmitCallBack)(void);

#pragma mark - associate refactor
+ (void)fillFormActionWithAssociateReport:(NSDictionary *)associateReportDict;
+ (void)fillFormActionWithAssociateReportModel:(FHAssociateFormReportModel *)associateReport;

@end

NS_ASSUME_NONNULL_END
