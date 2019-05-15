//
//  TTBridgeAuthManager.h
//  BridgeUnifyDemo
//
//  Created by renpeng on 2018/10/9.
//  Copyright © 2018年 tt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTBridgeAuthorization.h"

@interface TTBridgeAuthManager : NSObject<TTBridgeAuthorization>

+ (instancetype)sharedManager;

// 从settings获取动态添加的白名单域名，与本地白名单取并集
- (void)updateInnerDomainsFromRemote:(NSArray<NSString *> *)domains;

- (void)startGetAuthConfigWithPartnerClientKey:(NSString*)clientKey
                                 partnerDomain:(NSString*)domain
                                     secretKey:(NSString*)secretKey
                                   finishBlock:(void(^)(BOOL success))finishBlock;

/**
 Default YES.
 */
@property (nonatomic, assign) BOOL authEnabled;

@end 
