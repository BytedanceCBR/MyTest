//
//  FHTrackingManager.h
//  FHHouseBase
//
//  Created by wangxinyu on 2020/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHTrackingManager : NSObject

+ (instancetype)sharedInstance;

- (void)showTrackingServicePopup;

@end

NS_ASSUME_NONNULL_END
