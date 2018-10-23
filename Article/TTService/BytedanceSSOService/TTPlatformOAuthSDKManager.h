//
//  TTPlatformOAuthSDKManager.h
//  Article
//
//  Created by zuopengliu on 27/9/2017.
//  Copyright © 2017 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN
 
@interface TTPlatformOAuthSDKManager : NSObject

+ (void)startConfiguration;

+ (BOOL)handleOpenURL:(NSURL * _Nonnull)url;

@end

NS_ASSUME_NONNULL_END
