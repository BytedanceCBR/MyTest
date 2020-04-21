//
//  FHCommunityBaseViewModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/4/20.
//

#import <Foundation/Foundation.h>
#import "FHCommunityViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommunityBaseViewModel : NSObject

@property(nonatomic , strong) UICollectionView *collectionView;
@property(nonatomic , weak) FHCommunityViewController *viewController;
@property(nonatomic , assign) BOOL isFirstLoad;
@property(nonatomic , assign) NSInteger currentTabIndex;

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView controller:(FHCommunityViewController *)viewController;

- (void)viewWillAppear;

- (void)viewWillDisappear;

- (void)refreshCell:(BOOL)isHead;

- (void)segmentViewIndexChanged:(NSInteger)index;

- (void)changeTab:(NSInteger)index;

- (NSArray *)getSegmentTitles;

@end

NS_ASSUME_NONNULL_END
