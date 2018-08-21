//
//  TTBusinessManager.m
//  Article
//
//  Created by zhaoqin on 8/11/16.
//
//

#import "TTBusinessManager.h"

@implementation TTBusinessManager

+ (TTBusinessManager *)sharedInstance {
    static TTBusinessManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTBusinessManager alloc] init];
    });
    return manager;
}

+ (void)load {
    [TTBusinessManager sharedInstance];
}

@end
