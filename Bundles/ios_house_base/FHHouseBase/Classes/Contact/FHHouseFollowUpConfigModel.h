//
//  FHHouseFollowUpConfigModel.h
//  FHHouseDetail
//
//  Created by 张静 on 2019/4/22.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import <FHHouseBase/FHHouseType.h>
#import "FHHouseContactDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseFollowUpConfigModel : JSONModel

// 全部用search_id下划线这种格式
// 必填
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *followId;
@property (nonatomic, assign) FHFollowActionType actionType;

// 选填
@property (nonatomic, assign) BOOL showTip;
@property (nonatomic, weak) UIViewController *topVC;

#pragma mark 埋点
// 必填
@property (nonatomic , copy) NSString *originSearchId;
@property (nonatomic , copy) NSString *originFrom;
@property (nonatomic , copy) NSString *elementFrom;
@property (nonatomic , copy) NSString *enterFrom;
@property (nonatomic , copy) NSString *pageType;
@property (nonatomic , copy) NSString *cardType;
@property (nonatomic , copy) NSString *rank; //add by zjing for test confirm
@property (nonatomic , strong) NSDictionary *logPb;


@end

NS_ASSUME_NONNULL_END
