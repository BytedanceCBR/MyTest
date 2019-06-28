//
//  FHMyJoinViewModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/12.
//

#import <Foundation/Foundation.h>
#import "FHMyJoinViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMyJoinViewModel : NSObject

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView controller:(FHMyJoinViewController *)viewController;

- (void)requestData;

@end

NS_ASSUME_NONNULL_END
