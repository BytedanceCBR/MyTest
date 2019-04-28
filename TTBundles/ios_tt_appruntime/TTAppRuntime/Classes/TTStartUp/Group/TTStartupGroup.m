//
//  TTStartupGroup.m
//  Article
//
//  Created by fengyadong on 17/1/16.
//
//

#import "TTStartupGroup.h"

@implementation TTStartupGroup

- (instancetype)init {
    if (self = [super init]) {
        _tasks = [NSMutableArray array];
    }
    return self;
}

-(BOOL)isConcurrent {
    return NO;
}

@end
