//
//  TTWatchCommonInfoManager.h
//  Article
//
//  Created by 邱鑫玥 on 16/10/12.
//
//

#import <Foundation/Foundation.h>

@interface TTWatchCommonInfoManager : NSObject

+ (void)saveDeviceID:(NSString *)deviceID;

+ (NSString *)deviceID;

@end
