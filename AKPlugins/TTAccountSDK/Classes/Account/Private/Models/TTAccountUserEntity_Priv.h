//
//  TTAccountUserEntity_Priv.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 com.bytedance.news. All rights reserved.
//

#import "TTAccountUserEntity.h"



NS_ASSUME_NONNULL_BEGIN


/**
 *  媒体(PGC)用户信息
 */
@class TTAMediaUserModel;
@interface TTAccountMediaUserEntity (tta_internal)

- (instancetype)initWithMediaUserModel:(TTAMediaUserModel *)aMdl;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end



/**
 *  用户审核信息
 */
@interface TTAccountUserAuditEntity (tta_internal)

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

@interface TTAccountVerifiedUserAuditEntity (tta_internal)

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

@interface TTAccountMediaUserAuditEntity (tta_internal)

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end



@class TTAUpdateUserProfileModel;
@interface TTAccountUserAuditSet (tta_internal)

- (instancetype)initWithUserModel:(TTAUpdateUserProfileModel *)userMdl;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end



/**
 *  绑定的第三方平台账号信息
 */
@interface TTAccountPlatformEntity (tta_internal)

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end



@class TTAUserModel;
@interface TTAccountUserEntity ()

@property (nonatomic, strong) NSMutableArray<NSString *> *observedKeyPaths;

@end

@interface TTAccountUserEntity (tta_internal)

- (instancetype)initWithUserModel:(TTAUserModel *)userMdl;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

/** 存储一些基本信息，connects和auditInfoSet不存储 */
- (NSDictionary *)toKeyChainDictionary;

- (NSDictionary *)toSharingKeyChainDictionary;

#pragma mark - observer helper

- (void)checkAndAvoidHittingTheObservedValues;

- (void)observeValueDidChangeHandler:(void (^)(NSString *keyPath, NSDictionary *change))observedBlock;

@end



@interface TTAccountImageEntity (tta_internal)

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (NSDictionary *)toDictionary;

@end


NS_ASSUME_NONNULL_END
