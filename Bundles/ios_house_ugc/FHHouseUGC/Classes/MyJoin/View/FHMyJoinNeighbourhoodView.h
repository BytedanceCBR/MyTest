//
//  FHMyJoinNeighbourhoodView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/12.
//

#import <UIKit/UIKit.h>
#import "FHUGCMessageView.h"
#import "FHPostUGCProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHMyJoinNeighbourhoodViewDelegate <NSObject>

- (void)gotoMore;

@end

@interface FHMyJoinNeighbourhoodView : UIView

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) FHUGCMessageView *messageView;
@property (nonatomic, weak)     FHPostUGCProgressView       *progressView;

@property(nonatomic , weak) id<FHMyJoinNeighbourhoodViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END