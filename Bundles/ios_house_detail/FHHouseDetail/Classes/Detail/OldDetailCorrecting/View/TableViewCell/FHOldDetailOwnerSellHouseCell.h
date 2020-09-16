//
//  FHOldDetailOwnerSellHouseCell.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/9/6.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN


@interface FHOldDetailOwnerSellHouseCell : FHDetailBaseCell

@end

@interface FHOldDetailOwnerSellHouseModel : FHDetailBaseModel
@property(nonatomic,copy) NSString *questionText;
@property(nonatomic,copy) NSString *hintText;
@property(nonatomic,copy) NSString *helpMeSellHouseText;
@property(nonatomic,copy) NSString *helpMeSellHouseOpenUrl;
@end

NS_ASSUME_NONNULL_END
