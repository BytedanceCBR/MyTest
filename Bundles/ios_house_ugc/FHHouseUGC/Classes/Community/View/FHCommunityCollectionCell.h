//
//  FHCommunityCollectionCell.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FHCommunityCollectionCellType)
{
    FHCommunityCollectionCellTypeNone = -1,
    FHCommunityCollectionCellTypeNearby = 0,
    FHCommunityCollectionCellTypeMyJoin,
    FHCommunityCollectionCellTypeDiscovery,
};

@interface FHCommunityCollectionCell : UICollectionViewCell

@property(nonatomic , assign) FHCommunityCollectionCellType type;

@end

NS_ASSUME_NONNULL_END
