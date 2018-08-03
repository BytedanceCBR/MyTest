//
//  TTInstallProvider.h
//  Pods
//
//  Created by fengyadong on 2017/3/5.
//
//

#import <Foundation/Foundation.h>

@protocol TTInstallProvider <NSObject>

@required
/**
 获取installID

 @return installID
 */
- (NSString *)getInstallID;


/**
 获取deviceID

 @return deviceID
 */
- (NSString *)getDeviceID;

@end
