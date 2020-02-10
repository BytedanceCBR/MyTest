//
//  FHCommunityViewModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCommunityViewModel : NSObject

@property(nonatomic, weak) UIButton *searchBtn;
@property(nonatomic , assign) NSInteger currentTabIndex;

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView controller:(UIViewController *)viewController;

- (void)segmentViewIndexChanged:(NSInteger)index;

- (void)viewWillAppear;

- (void)viewWillDisappear;

- (void)showUGC:(BOOL)isShow;

- (void)refreshCell:(BOOL)isHead;

- (void)changeTab:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
