//
//  TTLaunchManager.m
//  TTAppRuntime
//
//  Created by 春晖 on 2019/5/30.
//

#import "TTLaunchManager.h"

@implementation TTLaunchManager

+(instancetype)sharedInstance
{
    static TTLaunchManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTLaunchManager alloc]init];
    });
    return manager;
}

-(void)launch
{
    
}

@end
