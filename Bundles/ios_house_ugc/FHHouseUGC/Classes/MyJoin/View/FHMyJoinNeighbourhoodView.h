//
//  FHMyJoinNeighbourhoodView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/12.
//

#import <UIKit/UIKit.h>
#import "FHUGCSearchView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHMyJoinNeighbourhoodViewDelegate <NSObject>

- (void)gotoMore;

@end

@interface FHMyJoinNeighbourhoodView : UIView

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) FHUGCSearchView *searchView;
@property(nonatomic , weak) id<FHMyJoinNeighbourhoodViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
