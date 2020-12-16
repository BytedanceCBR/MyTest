//
//  FHPersonalHomePageFeedViewModel.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/7.
//

#import <Foundation/Foundation.h>
#import "FHPersonalHomePageFeedViewController.h"
#import "FHPersonalHomePageTabListModel.h"
#import "FHPersonalHomePageManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHPersonalHomePageFeedViewModel : NSObject
@property(nonatomic,weak) FHPersonalHomePageManager *homePageManager;
- (instancetype)initWithController:(FHPersonalHomePageFeedViewController *)viewController collectionView:(UICollectionView *)collectionView;
- (void)updateWithHeaderViewMdoel:(FHPersonalHomePageTabListModel *)model;
- (void)updateSelectCell:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
