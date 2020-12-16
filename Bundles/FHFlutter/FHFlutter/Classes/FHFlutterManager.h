//
//  FHFlutterManager.h
//  ABRInterface
//
//  Created by 谢飞 on 2020/8/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHFlutterManager : NSObject

+(instancetype)sharedInstance;

+(void)registerFHFlutterPackageInfo;

+ (void)alertWithMessage:(NSString *)message;

+(void)jumpToCustomerDetail:(NSDictionary *)params;

+(BOOL)isCanJumpFlutterForCustomerDetail;

+(BOOL)isCanFlutterPreload;

+(BOOL)isCanFlutterDynamicart;

@end

NS_ASSUME_NONNULL_END
