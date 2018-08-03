//
//  WatchConnectPhoneManager.h
//  Article
//
//  Created by 邱鑫玥 on 16/8/19.
//
//

#import <Foundation/Foundation.h>

@interface TTWatchConnectPhoneManager : NSObject


+ (instancetype)sharedInstance;

- (void)initWCSession;

- (void)openParentApplication:(NSDictionary *)userInfo reply:(void (^)(NSError *error))replyBlock;

@end
