//
//  SSPrivateUtil.h
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-28.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//
//  注意：该类为私有API工具类!!!

#import <Foundation/Foundation.h>

@interface SSPrivateUtil : NSObject

+ (NSDictionary *)deviceInstallAppInfos;
+ (NSString *)appBundleVersionIfInstalled:(NSString *)appBundle;
+ (BOOL)isAppInstalled:(NSString *)appBundle;
@end
