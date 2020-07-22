//
//  FHChildBrowsingHistoryViewController.h
//  FHHouseMine
//
//  Created by xubinbin on 2020/7/13.
//

#import "FHBaseViewController.h"
#import "FHHouseType.h"
#import "FHBrowsingHistoryViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHChildBrowsingHistoryViewController : FHBaseViewController

@property (nonatomic, assign) FHHouseType houseType;
@property (nonatomic, weak) FHBrowsingHistoryViewController *fatherVC;
@property (nonatomic, assign) BOOL isCanTrack; //是否可以埋点

@end

NS_ASSUME_NONNULL_END
