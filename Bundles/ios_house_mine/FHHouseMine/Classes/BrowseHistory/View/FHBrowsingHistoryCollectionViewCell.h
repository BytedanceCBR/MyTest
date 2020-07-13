//
//  FHBrowsingHistoryCollectionViewCell.h
//  FHHouseMine
//
//  Created by xubinbin on 2020/7/12.
//

#import <UIKit/UIKit.h>
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHBrowsingHistoryCollectionViewCell : UICollectionViewCell

- (void)refreshData:(id)data andHouseType:(FHHouseType)houseType;

@end

NS_ASSUME_NONNULL_END
