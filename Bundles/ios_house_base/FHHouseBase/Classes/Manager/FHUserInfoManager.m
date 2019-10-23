//
//  FHUserInfoManager.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/10/16.
//

#import "FHUserInfoManager.h"

@implementation FHUserInfoManager

+(instancetype)sharedInstance
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

@end
