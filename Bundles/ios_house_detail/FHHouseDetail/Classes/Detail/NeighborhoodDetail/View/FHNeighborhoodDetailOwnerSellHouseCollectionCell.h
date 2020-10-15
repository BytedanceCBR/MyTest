//
//  FHNeighborhoodDetailOwnerSellHouseCollectionCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/14.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailOwnerSellHouseCollectionCell : FHDetailBaseCollectionCell
@property (nonatomic, copy) void (^sellHouseButtonClickBlock)(void);

@end

@interface FHNeighborhoodDetailOwnerSellHouseModel : NSObject
@property(nonatomic,copy) NSString *questionText;
@property(nonatomic,copy) NSString *hintText;
@property(nonatomic,copy) NSString *helpMeSellHouseText;
@property(nonatomic,copy) NSString *helpMeSellHouseOpenUrl;
@end


NS_ASSUME_NONNULL_END
