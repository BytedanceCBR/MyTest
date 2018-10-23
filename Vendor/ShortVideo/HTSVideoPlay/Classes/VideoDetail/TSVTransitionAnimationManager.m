//
//  TSVTransitionAnimationManager.m
//  HTSVideoPlay
//
//  Created by 王双华 on 2017/11/15.
//

#import "TSVTransitionAnimationManager.h"

@implementation TSVTransitionAnimationManager

static TSVTransitionAnimationManager *manager;

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

@end
