//
//  FHNeighborhoodDetailSubMessageCollectionCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNeighborhoodModel.h"
#import <IGListKit/IGListKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailSubMessageCollectionCell : FHDetailBaseCollectionCell<IGListBindable>

@end

@interface FHNeighborhoodDetailSubMessageModel : NSObject<IGListDiffable>

@property (nonatomic, copy) NSString *perSquareMetre;
@property (nonatomic, copy) NSString *monthUp;
@property (nonatomic, copy) NSString *subTitleText;
@end

NS_ASSUME_NONNULL_END
