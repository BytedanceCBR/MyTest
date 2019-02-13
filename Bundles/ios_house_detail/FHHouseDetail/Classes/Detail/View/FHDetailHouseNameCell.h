//
//  FHDetailHouseNameCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/13.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

// cell
@interface FHDetailHouseNameCell : FHDetailBaseCell

@end

// 模型

@interface FHDetailHouseNameModel : FHDetailBaseModel

@property (nonatomic, assign)   NSInteger         type;// 1：二手房，2：新房
@property (nonatomic, copy)     NSString       *name;
@property (nonatomic, copy)     NSString       *aliasName;
@property (nonatomic, strong)   NSArray       *tags;// FHSearchHouseDataItemsTagsModel item类型

@end


NS_ASSUME_NONNULL_END
