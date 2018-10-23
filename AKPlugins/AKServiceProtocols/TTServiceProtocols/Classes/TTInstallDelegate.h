//
//  TTInstallDelegate.h
//  Pods
//
//  Created by fengyadong on 2017/3/5.
//
//

#import <Foundation/Foundation.h>

@protocol TTInstallDelegate <NSObject>

@optional
/**
 将用户信息共享

 @param dic 形如@{@"deviceID":deviceID}
 */
- (void)willSendUserInfo:(NSDictionary *)dic;

/**
 即将保存installID

 @param ID installID
 */
- (void)willSaveSharedInstallID:(NSString *)ID;

/**
 即将保存deviceID

 @param ID deviceID
 */
- (void)willSaveSharedDeviceID:(NSString *)ID;

@end
