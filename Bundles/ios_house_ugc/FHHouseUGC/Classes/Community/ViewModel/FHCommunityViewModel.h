//
//  FHCommunityViewModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCommunityViewModel : NSObject

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView controller:(UIViewController *)viewController;

- (void)segmentViewIndexChanged:(NSInteger)index;

- (void)viewWillAppear;

- (void)showUGC:(BOOL)isShow;

- (void)refreshCell;

@end

NS_ASSUME_NONNULL_END
