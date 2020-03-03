//
//  TTPushServiceDelegate.h
//  FHCHousePush
//
//  Created by 张静 on 2020/3/3.
//

#import <Foundation/Foundation.h>
#import <BDUGPushSDK/BDUGPushService.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTPushServiceDelegate : NSObject <BDUGPushServiceDelegate, BDUGPushNotificationDelegate>

+ (BOOL)enable;

+ (instancetype)sharedInstance;

- (void)registerNotification;


@end

NS_ASSUME_NONNULL_END
