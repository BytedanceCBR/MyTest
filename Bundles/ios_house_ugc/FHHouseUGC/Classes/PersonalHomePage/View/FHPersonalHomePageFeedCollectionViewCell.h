//
//  FHPersonalHomePageFeedCollectionViewCell.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/7.
//

#import <UIKit/UIKit.h>
#import "FHPersonalHomePageFeedViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHPersonalHomePageFeedCollectionViewCell : UICollectionViewCell
- (void)updateTabName:(NSString *)tabName index:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
