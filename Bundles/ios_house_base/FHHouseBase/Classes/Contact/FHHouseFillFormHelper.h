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

typedef void(^FillFormSubmitCallBack)(void);

#pragma mark - associate refactor
+ (void)fillFormActionWithAssociateReport:(NSDictionary *)associateReportDict completion:(FillFormSubmitCallBack )completion;
+ (void)fillFormActionWithAssociateReportModel:(FHAssociateFormReportModel *)associateReport completion:(FillFormSubmitCallBack )completion;

@end

NS_ASSUME_NONNULL_END
