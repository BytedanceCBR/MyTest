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
@property (nonatomic, copy)NSString *titleStr;
@property (nonatomic, strong)NSArray *tags;// FHHouseTagsModel item类型
@property (nonatomic, copy)NSString *address;
@property (nonatomic, copy) void(^mapImageClick)(void);
@property (nonatomic, strong) FHDetailNeighborhoodSubMessageModel *neighborhoodInfoModel;
@end

NS_ASSUME_NONNULL_END
