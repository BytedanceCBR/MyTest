//
//  FHNeighborhoodDetailHeaderTitleCollectionCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHDetailBaseCell.h"
#import <IGListKit/IGListKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailHeaderTitleCollectionCell : FHDetailBaseCollectionCell<IGListBindable>

@end

@interface FHNeighborhoodDetailHeaderTitleModel : NSObject<IGListDiffable>
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *address;

@end

NS_ASSUME_NONNULL_END
