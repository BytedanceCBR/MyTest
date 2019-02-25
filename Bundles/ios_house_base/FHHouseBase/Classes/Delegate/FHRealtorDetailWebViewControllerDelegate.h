//
//  FHRealtorDetailWebViewControllerDelegate.h
//  Pods
//
//  Created by 张静 on 2019/2/14.
//

#ifndef FHRealtorDetailWebViewControllerDelegate_h
#define FHRealtorDetailWebViewControllerDelegate_h
#import "FHHouseType.h"
@protocol FHRealtorDetailWebViewControllerDelegate <NSObject>

@optional;
- (void)followUpAction;
@optional;
- (void)followUpActionByFollowId:(NSString *)followId houseType:(FHHouseType)houseType;

@end

#endif /* FHRealtorDetailWebViewControllerDelegate_h */
