//
//  FHMonkeyUtil.m
//  F101iOSInHouse
//
//  Created by 春晖 on 2020/7/10.
//  Copyright © 2020 linlin.leo. All rights reserved.
//

#import "FHMonkeyUtil.h"
#import <Heimdallr/HMDSwizzle.h>
#import <FHHouseMine/FHLoginViewModel.h>


@implementation FHMonkeyUtil

+(void)load
{
    [self loginSwizzle];
    
    
//    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"IS_MONKEY"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IS_MONKEY"]) {
            [self doForMonkey];
        }
        
    });
}

+(void)loginSwizzle
{
    hmd_swizzle_instance_method([FHLoginViewModel class], @selector(shouldShowDouyinIcon), @selector(monkey_shouldShowDouyinIcon));
    hmd_swizzle_instance_method([FHLoginSharedModel class], @selector(douyinCanQucikLogin), @selector(monkey_douyinCanQucikLogin));
}

+(void)doForMonkey
{

}


@end



