//
//  FHHouseDetailFollowUpViewModel.h
//  Pods
//
//  Created by 张静 on 2019/2/14.
//

#import <Foundation/Foundation.h>
#import "FHHouseType.h"
#import "FHHouseDetailAPI.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kFHDetailFollowUpNotification;

@interface FHHouseDetailFollowUpViewModel : NSObject

- (void)silentFollowHouseByFollowId:(NSString *)followId houseType:(FHHouseType)houseType actionType:(FHFollowActionType)actionType showTip:(BOOL)showTip;
- (void)followHouseByFollowId:(NSString *)followId houseType:(FHHouseType)houseType actionType:(FHFollowActionType)actionType;
- (void)cancelFollowHouseByFollowId:(NSString *)followId houseType:(FHHouseType)houseType actionType:(FHFollowActionType)followAction;

@end

NS_ASSUME_NONNULL_END
