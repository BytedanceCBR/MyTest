//
//  FHUGCHotCommunityLayout.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/1/8.
//

#import <UIKit/UIKit.h>
#import "FHFeedContentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCHotCommunityLayout : UICollectionViewFlowLayout

@property(nonatomic , strong) NSArray<FHFeedContentRawDataHotCellListModel> *dataList;

@end

NS_ASSUME_NONNULL_END
