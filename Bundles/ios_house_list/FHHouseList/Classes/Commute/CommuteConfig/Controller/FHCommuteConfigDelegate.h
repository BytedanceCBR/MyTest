//
//  FHCommuteConfigDelegate.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/31.
//

#ifndef FHCommuteConfigDelegate_h
#define FHCommuteConfigDelegate_h

#import "FHCommuteType.h"

@protocol FHCommuteConfigDelegate <NSObject>

-(void)commuteWithDest:(NSString *)location type:(FHCommuteType)type duration:(NSString *)duration;

@end

extern NSString *const COMMUTE_CONFIG_DELEGATE;

#endif /* FHCommuteConfigDelegate_h */
