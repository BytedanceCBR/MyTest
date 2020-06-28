//
//  FHDetailHouseTitleModel.h
//  FHHouseDetail
//
//  Created by liuyu on 2019/11/26.
//

#import <Foundation/Foundation.h>
#import "FHNeighborhoodDetailSubMessageCell.h"
#import "FHDetailFloorPanDetailInfoModel.h"
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
//增加是否跳转，默认不支持
@property (nonatomic, assign) BOOL isCanClick;
@property (nonatomic, copy , nullable) NSString *clickUrl;

@property (nonatomic, assign) BOOL isFloorPan;
@property (nonatomic, copy) NSString *Picing;
@property (nonatomic, copy) NSString *displayPrice;

//099 户型详情查看大图补充内容
@property (nonatomic, copy) NSString *squaremeter; //面积
@property (nonatomic, copy) NSString *facingDirection; //朝向
@property (nonatomic, copy) NSString *saleStatus;//售卖状态

//100 户型详情增加咨询样式
@property (nonatomic, strong , nullable) FHFloorPanDetailInfoModelPriceConsultModel *priceConsult;
@end

NS_ASSUME_NONNULL_END
