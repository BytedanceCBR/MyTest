//
//  FHHouseIMClueHelper.h
//  FHHouseBase
//
//  Created by 张静 on 2020/3/26.
//

#import <Foundation/Foundation.h>
#import "FHHouseContactDefines.h"
#import <JSONModel/JSONModel.h>
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseIMClueConfigModel;

@interface FHHouseIMClueHelper : NSObject

+ (void)jump2SessionPageWithConfigModel:(FHHouseIMClueConfigModel *)configModel;
+ (void)jump2SessionPageWithConfig:(NSDictionary *)configDict;


@end

@interface FHHouseIMClueConfigModel : JSONModel

#pragma mark 必填
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId;


#pragma mark 非必填
@property (nonatomic, copy) NSString *from;// 非必填
@property (nonatomic, copy) NSString *targetId;// 非必填
@property (nonatomic , strong) NSNumber *targetType;

@property (nonatomic, copy) NSString *realtorId; // 在线联系时必填
//@property (nonatomic, copy) NSString *phone;

#pragma mark 埋点
// 必填
@property (nonatomic , copy) NSString *originSearchId;
@property (nonatomic , copy) NSString *originFrom;
@property (nonatomic , copy) NSString *elementFrom;
@property (nonatomic , copy) NSString *enterFrom;
@property (nonatomic , copy) NSString *pageType;
@property (nonatomic , copy) NSString *cardType;
@property (nonatomic , copy) NSString *rank;
@property (nonatomic , strong, nullable) NSDictionary *logPb;
@property (nonatomic , copy) NSString *searchId;
@property (nonatomic , copy) NSString *imprId;
// 非必填
@property (nonatomic , copy) NSString *position;
@property (nonatomic , copy) NSString *realtorPosition;
@property (nonatomic , copy) NSString *itemId;
@property (nonatomic , strong) NSNumber *cluePage;
@property (nonatomic , strong) NSNumber *clueEndpoint;
@property (nonatomic , copy) NSString *realtorRank;
@property (nonatomic , copy) NSString *conversationId;
@property (nonatomic , copy) NSDictionary *realtorLogpb;
@property (nonatomic , copy) NSString *source;
@property (nonatomic , copy) NSString *imOpenUrl;
@property (nonatomic , copy) NSString *sourceFrom;
@property (nonatomic , copy) NSDictionary *extra;

- (void)setTraceParams:(NSDictionary *)params;

@end


NS_ASSUME_NONNULL_END
