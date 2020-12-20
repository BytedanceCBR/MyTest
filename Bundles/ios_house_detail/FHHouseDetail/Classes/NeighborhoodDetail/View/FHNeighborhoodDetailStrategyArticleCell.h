//
//  FHNeighborhoodDetailStrategyArticleCell.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/13.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNeighborhoodModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^lynxEndLoadBlock)(CGFloat cellHeight);
@interface FHNeighborhoodDetailStrategyArticleCell : FHDetailBaseCollectionCell
@property (nonatomic, strong) NSDictionary *tracerDic;
@property (copy, nonatomic)  lynxEndLoadBlock lynxEndLoadBlock;
@end

NS_ASSUME_NONNULL_END
