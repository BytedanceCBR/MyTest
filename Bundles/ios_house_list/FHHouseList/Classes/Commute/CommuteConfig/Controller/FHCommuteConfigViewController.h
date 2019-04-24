//
//  FHCommuteConfigViewController.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/21.
//

#import "FHBaseViewController.h"
#import "FHCommuteConfigDelegate.h"


NS_ASSUME_NONNULL_BEGIN

@interface FHCommuteConfigViewController : FHBaseViewController

@property(nonatomic , weak) id<FHCommuteConfigDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
