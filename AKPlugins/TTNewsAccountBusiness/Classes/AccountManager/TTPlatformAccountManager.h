//
//  TTPlatformAccountManager.h
//  Article
//
//  Created by liuzuopeng on 03/06/2017.
//
//

#import <Foundation/Foundation.h>
#import "TTThirdPartyAccountsHeader.h"



@interface TTPlatformAccountManager : NSObject

/**
 单例
 
 @return TTPlatformAccountManager单例
 */
+ (instancetype)sharedManager;


/**
 所有支持的平台账号信息
 
 @return 当前支持的账号信息
 */
- (NSArray<TTThirdPartyAccountInfoBase *> *)platformAccounts;


/**
 绑定/授权登录的第三方平台用户信息(将TTAccountPlatformEntity转化为TTThirdPartyAccountInfoBase结构)
 
 @return 绑定/授权登录的第三方平台用户信息
 */
- (NSArray<TTThirdPartyAccountInfoBase *> *)connectedPlatformAccountsInfo;


/**
 获取指定平台账号信息
 
 @param key 平台key
 @return    平台信息
 */
- (TTThirdPartyAccountInfoBase *)platformAccountInfoForKey:(NSString *)key;


/**
 获取指定平台账号显示名称
 
 @param key 平台key
 @return    平台显示名称
 */
- (NSString *)platformDisplayNameForKey:(NSString *)key;


/**
 判断指定平台是否绑定
 
 @param platformKey 平台key
 @return 是否绑定平台
 */
- (BOOL)isBoundedPlatformForKey:(NSString *)platformKey;


/**
 设置或更新平台账号信息
 
 @param types 账号类型数组
 */
- (void)setPlatformAccountsByTypes:(NSArray<NSNumber *> *)types;


/**
 设置第三方平台选中状态
 
 @param platformName 平台名称对应的key
 @param checked      是否选中
 */
- (void)setAccountPlatform:(NSString *)platformName checked:(BOOL)checked;


/**
 当授权的第三方平台过期时，清理过期平台账号信息
 
 @param accountNames 平台key数组
 */
- (void)cleanExpiredPlatformAccountsByNames:(NSArray *)accountNames;


/**
 用户平台账号发生变更时，更新第三方平台账号信息
 
 使用User.connects更新PlatformAccounts Info
 */
- (void)synchronizePlatformAccountsStatus;


#pragma mark - 以前分享相关Helper，业务也删除但业务代码没有删除，业务代码删除后这些也可以删除

/**
 分享到第三方平台已选中的平台数目
 
 @return  选中平台数目
 */
- (NSInteger)numberOfCheckedAccounts;


/**
 拼接的第三方平台字符串，不包括QQZone和WeChat
 
 @return 拼接的平台字符串
 */
- (NSString *)sharePlatformsJoinedString;

@end
