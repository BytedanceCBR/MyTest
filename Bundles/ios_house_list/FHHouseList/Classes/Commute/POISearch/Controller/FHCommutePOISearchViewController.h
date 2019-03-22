//
//  FHCommutePOISearchViewController.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/21.
//

#import <FHHouseBase/FHBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const COMMUTE_POI_DELEGATE_KEY;

@protocol FHCommutePOISearchDelegate <NSObject>



@end

@interface FHCommutePOISearchViewController : FHBaseViewController

@property(nonatomic , weak)  id <FHCommutePOISearchDelegate> sugDelegate;

@end



NS_ASSUME_NONNULL_END
