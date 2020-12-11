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

@property (nonatomic, copy) void(^clickAveragePriceblock)(void);
@property (nonatomic, copy) void(^clickSoldblock)(void);
@property (nonatomic, copy) void(^clickOnSaleblock)(void);

@end

@interface FHNeighborhoodDetailSubMessageModel : NSObject<IGListDiffable>

@property (nonatomic, copy) NSString *perSquareMetre;
@property (nonatomic, copy) NSString *monthUp;
@property (nonatomic, copy) NSString *subTitleText;

@property(nonatomic ,copy) NSString *onSale;
@property(nonatomic ,copy) NSString *sold;
@property(nonatomic ,copy) NSString *onSaleUrl;
@property(nonatomic ,copy) NSString *soldUrl;
@end

NS_ASSUME_NONNULL_END
