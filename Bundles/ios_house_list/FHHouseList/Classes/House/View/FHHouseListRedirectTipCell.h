//
//  FHHouseListRedirectTipCell.h
//  FHHouseList
//
//  Created by 张静 on 2019/12/10.
//

#import "FHListBaseCell.h"
#import "FHHouseType.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHHouseListRedirectTipCell : FHListBaseCell

- (void)updateHeightByIsFirst:(BOOL)isFirst;

+ (CGFloat)heightForData:(id)data withIsFirst:(BOOL)isFirst;

- (void)refreshWithHouseType:(FHHouseType)houseType;

@end

NS_ASSUME_NONNULL_END
