//
//  FHBrowsingHistoryCollectionViewCell.h
//  FHHouseMine
//
//  Created by xubinbin on 2020/7/12.
//

#import <UIKit/UIKit.h>
#import "FHHouseType.h"
#import "FHBrowsingHistoryViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHBrowsingHistoryCollectionViewCell : UICollectionViewCell

- (void)refreshData:(id)data andHouseType:(FHHouseType)houseType andVC:(FHBrowsingHistoryViewController *)vc;

- (void)updateTrackStatu;

@end

NS_ASSUME_NONNULL_END
