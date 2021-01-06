//
//  FHFloorPanListCollectionCell.h
//  FHHouseDetail
//
//  Created by bytedance on 2021/1/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanListCollectionCell : UICollectionViewCell
-(void)refreshDataWithItemArray:(NSArray *)itemArray subPageParams:(NSDictionary *)subPageParams;
@end

NS_ASSUME_NONNULL_END
