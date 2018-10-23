//
//  Tracker.m
//  Base
//
//  Created by Tu Jianfeng on 6/23/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "Tracker.h"

static Tracker * _sharedTracker = nil;

@implementation Tracker

+ (Tracker *)sharedTracker
{
    @synchronized(self) {
        if (_sharedTracker == nil) 
            _sharedTracker = [[Tracker alloc] init];
    }
    
    return _sharedTracker;
}

+ (void)event:(NSString *)eventName label:(NSString *)labelName
{
    
}

@end
