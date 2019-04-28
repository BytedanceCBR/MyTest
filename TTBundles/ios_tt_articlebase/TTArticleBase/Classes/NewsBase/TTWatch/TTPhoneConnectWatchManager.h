//
//  TTPhoneConnectWatchManager.h
//  TouTiao910Watch
//
//  Created by 邱鑫玥 on 16/9/11.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTPhoneConnectWatchManager : NSObject

+ (instancetype)sharedInstance;
- (void)initWCSession;
- (void)sendUserInfo:(NSDictionary *)dic;

@end
