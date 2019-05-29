//
//  FHMineViewController.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHBaseViewController.h"
#import "FHMineHeaderView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMineViewController : FHBaseViewController

@property (nonatomic , strong) FHMineHeaderView *headerView;

- (void)refreshContentOffset:(CGPoint)contentOffset;

@end

NS_ASSUME_NONNULL_END
