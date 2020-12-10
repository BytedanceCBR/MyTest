//
//  FHNeighborhoodDetailRecommendCell.h
//  FHHouseDetail
//
//  Created by xubinbin on 2020/10/14.
//

#import "FHDetailBaseCell.h"
#import "FHSearchHouseModel.h"
#import "FHHouseNewComponentView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailRecommendCell : FHDetailBaseCollectionCell

- (void)refreshWithData:(id)data withLast:(BOOL) isLast;

- (void)refreshIndexCorner:(BOOL)isFirst andLast:(BOOL)isLast;

@end

@interface FHNeighborhoodDetailRecommendCellModel : NSObject

@property (nonatomic, strong , nullable) FHSearchHouseDataModel *data;

@end

NS_ASSUME_NONNULL_END
