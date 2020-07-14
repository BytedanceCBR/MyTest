//
//  FHChildBrowsingHistoryViewController.h
//  FHHouseMine
//
//  Created by xubinbin on 2020/7/13.
//

#import "FHBaseViewController.h"
#import "FHHouseType.h"
#import "FHChildBrowsingHistoryViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHChildBrowsingHistoryViewController : FHBaseViewController

@property (nonatomic, assign) FHHouseType houseType;
@property (nonatomic, weak) FHChildBrowsingHistoryViewController *fatherVC;

@end

NS_ASSUME_NONNULL_END
