//
//  FHCommunityCollectionCell.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import <UIKit/UIKit.h>
#import "FHHouseUGCHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommunityCollectionCell : UICollectionViewCell

@property(nonatomic , assign) FHCommunityCollectionCellType type;

@property(nonatomic , strong) NSString *enterType;

- (UIViewController *)contentViewController;

- (void)refreshData;

- (void)cellDisappear;

@end

NS_ASSUME_NONNULL_END
