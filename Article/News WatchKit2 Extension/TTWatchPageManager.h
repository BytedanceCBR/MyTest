//
//  TTWatchPageManager.h
//
//  Created by 邱鑫玥 on 16/9/11.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <WatchKit/WatchKit.h>

@interface TTWatchPageManager : NSObject

+ (void)loadCachedData;
+ (void)loadRemoteData;

@end
