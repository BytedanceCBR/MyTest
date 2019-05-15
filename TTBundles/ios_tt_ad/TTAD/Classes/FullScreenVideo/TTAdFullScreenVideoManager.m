//
//  TTAdFullScreenVideoManager.m
//  Article
//
//  Created by matrixzk on 24/07/2017.
//
//

#import "TTAdFullScreenVideoManager.h"

@implementation TTAdFullScreenVideoManager

+ (instancetype)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

@end
