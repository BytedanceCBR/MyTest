//
//  FHUGCShortVideoListCell.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/11/24.
//

#import "FHUGCBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCShortVideoListCell : FHUGCBaseCell
- (void)refreshWithData:(id)data;
@end

#pragma mark -  CollectionCell

@interface FHUGCShortVideoListCollectionCell : UICollectionViewCell


- (void)refreshWithData:(id)data;

@end
NS_ASSUME_NONNULL_END
