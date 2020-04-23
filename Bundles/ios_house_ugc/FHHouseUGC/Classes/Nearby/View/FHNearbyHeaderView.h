//
//  FHNearbyHeaderView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/1/7.
//

#import <UIKit/UIKit.h>
#import "FHPostUGCProgressView.h"
#import "FHUGCSearchView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNearbyHeaderView : UIView

@property (nonatomic, weak) FHPostUGCProgressView *progressView;
@property (nonatomic, strong) FHUGCSearchView *searchView;

@end

NS_ASSUME_NONNULL_END
