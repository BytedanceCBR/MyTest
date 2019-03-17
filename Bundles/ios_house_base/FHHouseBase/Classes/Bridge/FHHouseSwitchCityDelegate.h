//
//  FHHouseSwitchCityDelegate.h
//  FHHouseBase
//
//  Created by 张元科 on 2019/3/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef FHHouseSwitchCityDelegate_h
#define FHHouseSwitchCityDelegate_h

@protocol FHHouseSwitchCityDelegate <NSObject>

@optional
- (void)switchCityByOpenUrlSuccess;

@end

#endif /* FHHouseSwitchCityDelegate_h */
