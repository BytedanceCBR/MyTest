//
//  TTJSBAuthManager.h
//  Article
//
//  Created by muhuai on 2017/6/27.
//
//

#import <Foundation/Foundation.h>
#import "JSAuthInfoModel.h"
#import <TTRexxar/TTRJSBAuthorization.h>

//TTRexxar 授权器
@interface TTJSBAuthManager : NSObject<TTRJSBAuthorization>

+ (instancetype)sharedManager;

- (void)startGetAuthConfigWithPartnerClientKey:(NSString*)clientKey
                                 partnerDomain:(NSString*)domain
                                     secretKey:(NSString*)secretKey
                                   finishBlock:(void(^)(JSAuthInfoModel *infoModel))finishBlock;

- (BOOL)engine:(id<TTRexxarEngine>)engine isAuthorizedMeta:(NSString *)meta domain:(NSString *)domain;

// 从settings获取动态添加的白名单域名，与本地白名单取并集
- (void)updateInnerDomainsFromRemote:(NSArray<NSString *> *)domains;
@end
