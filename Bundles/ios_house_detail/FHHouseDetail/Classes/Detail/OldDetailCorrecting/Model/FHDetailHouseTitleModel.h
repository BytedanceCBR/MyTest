//
//  FHDetailHouseTitleModel.h
//  FHHouseDetail
//
//  Created by liuyu on 2019/11/26.
//

#import <Foundation/Foundation.h>
#import "FHNeighborhoodDetailSubMessageCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHDetailHouseTitleModel : FHDetailBaseModel
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, strong) NSArray *tags;// FHHouseTagsModel item类型
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) void(^mapImageClick)(void);
@property (nonatomic, assign) BOOL showMapBtn;
@property (nonatomic, strong) FHDetailNeighborhoodSubMessageModel *neighborhoodInfoModel;
@property (nonatomic, assign) FHHouseType housetype;
@property (nonatomic, copy , nullable) NSString *businessTag;
@property (nonatomic, copy , nullable) NSString *advantage;

@property (nonatomic, assign) BOOL isFloorPan;
@property (nonatomic, copy) NSString *totalPicing;
@end

NS_ASSUME_NONNULL_END
