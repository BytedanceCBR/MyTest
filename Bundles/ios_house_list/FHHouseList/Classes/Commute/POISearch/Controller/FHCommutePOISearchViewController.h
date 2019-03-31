//
//  FHCommutePOISearchViewController.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/21.
//

#import <FHHouseBase/FHBaseViewController.h>
#import <AMapSearchKit/AMapSearchKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const COMMUTE_POI_DELEGATE_KEY;

@protocol FHCommutePOISearchDelegate;
@interface FHCommutePOISearchViewController : FHBaseViewController

@property(nonatomic , weak)  id <FHCommutePOISearchDelegate> sugDelegate;

@end

@protocol FHCommutePOISearchDelegate <NSObject>

@required
-(void)userChoosePoi:(AMapAOI *)poi inViewController:(UIViewController *)viewController;

-(void)userCanced:(FHCommutePOISearchViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
