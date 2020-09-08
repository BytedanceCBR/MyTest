//
//  FHNewHouseDetailPropertyListCollectionCell.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseCoreInfoModel,FHDetailDisclaimerModel,FHDetailHouseNameModel;

@interface FHNewHouseDetailPropertyListCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void (^detailActionBlock)(void);

@end

@interface FHNewHouseDetailPropertyListCellModel : NSObject

@property (nonatomic, strong , nullable) NSArray<FHHouseCoreInfoModel> *baseInfo;
@property (nonatomic, copy, nullable) NSString *courtId;
@property (nonatomic, strong)   FHDetailHouseNameModel *houseName;
@property (nonatomic, strong, nullable) FHDetailDisclaimerModel *disclaimerModel;

@end

NS_ASSUME_NONNULL_END
