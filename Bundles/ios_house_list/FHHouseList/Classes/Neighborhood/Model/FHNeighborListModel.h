//
//  FHNeighborListModel.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/12.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "FHSearchHouseModel.h"
#import "FHBaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

// 同小区房源
@interface FHSameNeighborhoodHouseDataModel : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *searchId;
@end

@interface FHSameNeighborhoodHouseResponse : JSONModel <FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHSameNeighborhoodHouseDataModel *data;

@end

// 周边房源
@interface FHRelatedHouseResponse : JSONModel <FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHSameNeighborhoodHouseDataModel *data;

@end

NS_ASSUME_NONNULL_END

