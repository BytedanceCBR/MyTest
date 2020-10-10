//
//  FHNeighborhoodDetailHeaderTitleCollectionCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailHeaderTitleCollectionCell : FHDetailBaseCollectionCell

@end

@interface FHNeighborhoodDetailHeaderTitleModel : NSObject
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *address;

@end

NS_ASSUME_NONNULL_END
