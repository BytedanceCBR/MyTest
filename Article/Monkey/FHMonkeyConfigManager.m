//
//  FHMonkeyConfigManager.m
//  F101iOSInHouse
//
//  Created by 春晖 on 2020/7/10.
//  Copyright © 2020 linlin.leo. All rights reserved.
//

#import "FHMonkeyConfigManager.h"

//#define MONKEY 1

@implementation FHMonkeyConfigManager

+(void)load
{
#if MONKEY
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IS_MONKEY"];
    
#endif
    
}

@end
