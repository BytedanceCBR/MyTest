//
//  FHHouseContactConfigModel.h
//  FHHouseDetail
//
//  Created by 张静 on 2019/4/22.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import <FHHouseBase/FHHouseType.h>


NS_ASSUME_NONNULL_BEGIN

@interface FHHouseContactConfigModel : JSONModel

// 全部用search_id下划线这种格式
// 必填
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *realtorId;
@property (nonatomic, copy) NSString *searchId;
@property (nonatomic, copy) NSString *imprId;


// 选填
@property (nonatomic , strong) NSDictionary *reportParams;

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

// 选填
@property (nonatomic , strong) NSNumber *realtorRank;
@property (nonatomic , copy) NSString *realtorPosition;
@property (nonatomic , copy) NSString *conversationId;

@end

NS_ASSUME_NONNULL_END
