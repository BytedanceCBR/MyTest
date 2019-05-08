//
//  TTAccountUserProfileTask.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/26/17.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import "TTAccountUserProfileTask.h"
#import "TTAModelling.h"
#import "TTAccountRespModel.h"
#import "TTAccountNetworkManager.h"
#import "TTAccount.h"
#import "TTAccountDraft.h"
#import "TTAccountMulticastDispatcher.h"
#import "TTAccountUserEntity_Priv.h"
#import "TTAccountURLSetting.h"



@implementation TTAccountUserProfileTask

#pragma mark - 获取用户信息

+ (id<TTAccountSessionTask>)startGetUserInfoWithCompletion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [TTAccountNetworkManager getRequestForJSONWithURL:[TTAccountURLSetting TTAGetUserInfoURLString] params:params needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAUserRespModel *respModel = [TTAUserRespModel tta_modelWithJSON:jsonObj];
        TTAccountUserEntity *userEntity = error ? nil : [[TTAccountUserEntity alloc] initWithUserModel:respModel.data];
        
        if (!error && userEntity) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if ([[TTAccount sharedAccount] respondsToSelector:@selector(setUser:)]) {
                [[TTAccount sharedAccount] performSelector:@selector(setUser:) withObject:userEntity];
            }
            [[TTAccount sharedAccount] persistence];
#pragma clang diagnostic pop
            
            [TTAccountMulticastDispatcher dispatchAccountGetUserInfoWithBisectBlock:^{
                if (completedBlock) {
                    completedBlock(userEntity, nil);
                }
            }];
            
        } else {
            if (completedBlock) {
                completedBlock(userEntity, error);
            }
        }
    }];
}

+ (id<TTAccountSessionTask>)startGetUserInfoIgnoreDispatchWithCompletion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    return [TTAccountNetworkManager requestNoDispatchForJSONWithURL:[TTAccountURLSetting TTAGetUserInfoURLString] method:@"GET" params:nil extraGetParams:nil needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAUserRespModel *respModel = [TTAUserRespModel tta_modelWithJSON:jsonObj];
        TTAccountUserEntity *userEntity = error ? nil : [[TTAccountUserEntity alloc] initWithUserModel:respModel.data];
        
        if (!error && userEntity) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if ([[TTAccount sharedAccount] respondsToSelector:@selector(setUser:)]) {
                [[TTAccount sharedAccount] performSelector:@selector(setUser:) withObject:userEntity];
            }
            [[TTAccount sharedAccount] persistence];
#pragma clang diagnostic pop
            
            [TTAccountMulticastDispatcher dispatchAccountGetUserInfoWithBisectBlock:^{
                if (completedBlock) {
                    completedBlock(userEntity, nil);
                }
            }];
            
        } else {
            if (completedBlock) {
                completedBlock(userEntity, error);
            }
        }
    }];
}

#pragma mark - 获取用户绑定的第三方平台连接信息

+ (id<TTAccountSessionTask>)startGetConnectedAccountsWithCompletion:(void(^)(NSArray<TTAccountPlatformEntity *> *connects, NSError *error))completedBlock
{
    return nil;
}

#pragma mark - 上传用户照片

+ (id<TTAccountSessionTask>)startUploadUserPhoto:(UIImage *)photo
                                        progress:(NSProgress * __autoreleasing *)progress
                                      completion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    if (!photo || ![photo isKindOfClass:[UIImage class]]) {
        if (completedBlock) {
            completedBlock(nil,
                           [NSError errorWithDomain:TTAccountErrorDomain
                                               code:TTAccountErrCodeClientParamsInvalid
                                           userInfo:@{NSLocalizedDescriptionKey: TTAccountGetErrorCodeDescription(TTAccountErrCodeClientParamsInvalid) ? : @"",
                                                      TTAccountErrMsgKey: TTAccountGetErrorCodeDescription(TTAccountErrCodeClientParamsInvalid) ? : @""}]);
        }
        return nil;
    }
    
    NSData *jpegData = UIImageJPEGRepresentation(photo, 0.f);
    NSDictionary *postData = jpegData ? @{@"photo" : jpegData} : nil;
    return [TTAccountNetworkManager uploadWithURL:[TTAccountURLSetting TTAUploadUserPhotoURLString] parameters:postData constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
        
        [formData appendPartWithFileData:jpegData name:@"photo" fileName:@"image.jpeg" mimeType:@"image.jpg"];
        
    } progress:progress needcommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAccountUserEntity *currentUser = [[TTAccount sharedAccount] user];
        
        TTAUserRespModel *respModel = [TTAUserRespModel tta_modelWithJSON:jsonObj];
        TTAccountUserEntity *newUserEntity = error ? nil : [[TTAccountUserEntity alloc] initWithUserModel:respModel.data];
        
        NSMutableDictionary *changedProfileFields = [NSMutableDictionary dictionaryWithCapacity:4];
        
        if (!error && newUserEntity && newUserEntity.avatarURL) {
            
            currentUser.avatarURL = newUserEntity.avatarURL;
            
            [changedProfileFields setObject:@(YES) forKey:@(TTAccountUserProfileTypeUserAvatar)];
            
            [TTAccountMulticastDispatcher dispatchAccountProfileChanged:changedProfileFields error:error bisectBlock:^{
                if (completedBlock) {
                    completedBlock(currentUser, error);
                }
            }];
        } else {
            
            [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserAvatar)];
            
            if (completedBlock) {
                completedBlock(currentUser, error);
            }
        }
    }];
}

+ (id<TTAccountSessionTask>)startUploadImage:(UIImage *)image
                                    progress:(NSProgress * __autoreleasing *)progress
                                  completion:(void(^)(TTAccountImageEntity *imageEntity, NSError *error))completedBlock
{
    if (!image || ![image isKindOfClass:[UIImage class]]) {
        if (completedBlock) {
            completedBlock(nil, [NSError errorWithDomain:TTAccountErrorDomain
                                                    code:TTAccountErrCodeClientParamsInvalid
                                                userInfo:@{NSLocalizedDescriptionKey: TTAccountGetErrorCodeDescription(TTAccountErrCodeClientParamsInvalid) ? : @"",
                                                           TTAccountErrMsgKey: TTAccountGetErrorCodeDescription(TTAccountErrCodeClientParamsInvalid) ? : @""}]);
        }
        return nil;
    }
    
    NSData *jpegData = UIImageJPEGRepresentation(image, 0.f);
    NSDictionary *postData = jpegData ? @{@"photo" : jpegData} : nil;
    return [TTAccountNetworkManager uploadWithURL:[TTAccountURLSetting TTAUploadUserImageURLString] parameters:postData constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
        
        [formData appendPartWithFileData:jpegData name:@"photo" fileName:@"image.jpeg" mimeType:@"image.jpg"];
        
    } progress:progress needcommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAccountImageEntity *imageEntity = nil;
        if (!error && [jsonObj isKindOfClass:[NSDictionary class]]) {
            imageEntity = [TTAccountImageEntity tta_modelWithJSON:jsonObj[@"data"]];
        } else if (!error && ![jsonObj isKindOfClass:[NSDictionary class]]) {
            error =
            [NSError errorWithDomain:TTAccountErrorDomain
                                code:TTAccountErrCodeServerDataFormatInvalid
                            userInfo:@{NSLocalizedDescriptionKey: TTAccountGetErrorCodeDescription(TTAccountErrCodeServerDataFormatInvalid) ? : @"",
                                       TTAccountErrMsgKey: TTAccountGetErrorCodeDescription(TTAccountErrCodeServerDataFormatInvalid) ? : @""}];
        }
        
        if (completedBlock) {
            completedBlock(imageEntity, error);
        }
    }];
}

+ (id<TTAccountSessionTask>)startUploadBgImage:(UIImage *)image
                                      progress:(NSProgress * __autoreleasing *)progress
                                    completion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    if (!image || ![image isKindOfClass:[UIImage class]]) {
        if (completedBlock) {
            completedBlock(nil, [NSError errorWithDomain:TTAccountErrorDomain
                                                    code:TTAccountErrCodeClientParamsInvalid
                                                userInfo:@{NSLocalizedDescriptionKey: TTAccountGetErrorCodeDescription(TTAccountErrCodeClientParamsInvalid) ? : @"",
                                                           TTAccountErrMsgKey: TTAccountGetErrorCodeDescription(TTAccountErrCodeClientParamsInvalid) ? : @""}]);
        }
        return nil;
    }
    
    NSData *jpegData = UIImageJPEGRepresentation(image, 0.f);
    NSDictionary *postData = jpegData ? @{@"photo" : jpegData} : nil;
    return [TTAccountNetworkManager uploadWithURL:[TTAccountURLSetting TTAUploadUserBgImageURLString] parameters:postData constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
        
        [formData appendPartWithFileData:jpegData name:@"photo" fileName:@"image.jpeg" mimeType:@"image.jpg"];
        
    } progress:progress needcommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        NSString *bgImageURL = nil;
        
        if (!error && [jsonObj isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *jsonDict = (NSDictionary *)jsonObj;
            NSString *msgString = jsonDict[@"message"];
            
            if ((!msgString || (msgString && [msgString isEqualToString:@"success"]))
                && [jsonDict objectForKey:@"bg_img_url"]) {
                bgImageURL = [jsonDict objectForKey:@"bg_img_url"];
            } else {
                NSString *errorDesp = [NSString stringWithFormat:@"%@-未能正确解析背景图片", TTAccountGetErrorCodeDescription(TTAccountErrCodeServerDataFormatInvalid)];
                error =
                [NSError errorWithDomain:TTAccountErrorDomain
                                    code:TTAccountErrCodeServerDataFormatInvalid
                                userInfo:@{NSLocalizedDescriptionKey: errorDesp ? : @"",
                                           TTAccountErrMsgKey: errorDesp ? : @""}];
            }
            
        } else if (!error && ![jsonObj isKindOfClass:[NSDictionary class]]) {
            NSString *errorDesp = TTAccountGetErrorCodeDescription(TTAccountErrCodeServerDataFormatInvalid);
            error =
            [NSError errorWithDomain:TTAccountErrorDomain
                                code:TTAccountErrCodeServerDataFormatInvalid
                            userInfo:@{NSLocalizedDescriptionKey: errorDesp ? : @"",
                                       TTAccountErrMsgKey: errorDesp ? : @""}];
        }
        
        TTAccountUserEntity *currentUser = nil;
        if ([bgImageURL length] > 0) {
            currentUser = [[TTAccount sharedAccount] user];
            currentUser.bgImgURL = bgImageURL;
        }
        
        NSMutableDictionary *changedProfileFields = [NSMutableDictionary dictionaryWithCapacity:4];
        
        if (!error && bgImageURL) {
            
            [changedProfileFields setObject:@(YES) forKey:@(TTAccountUserProfileTypeUserBgImage)];
            
            [TTAccountMulticastDispatcher dispatchAccountProfileChanged:changedProfileFields error:error bisectBlock:^{
                if (completedBlock) {
                    completedBlock(currentUser, error);
                }
            }];
        } else {
            
            [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserBgImage)];
            
            if (completedBlock) {
                completedBlock(currentUser, error);
            }
        }
    }];
}

#pragma mark - 检查用户名

+ (id<TTAccountSessionTask>)startCheckName:(NSString *)nameString
                                completion:(void(^)(NSString *availableName, NSError *error))completedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:nameString forKey:@"name"];
    
    return [TTAccountNetworkManager getRequestForJSONWithURL:[TTAccountURLSetting TTACheckNameURLString] params:params needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTACheckNameRespModel *aRespModel = [TTACheckNameRespModel tta_modelWithJSON:jsonObj];
        if (completedBlock) {
            completedBlock(aRespModel.data.available_name, error);
        }
    }];
}

#pragma mark - 获取用户审核信息

+ (id<TTAccountSessionTask>)startGetUserAuditInfoWithCompletion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setValue:[[TTAccount sharedAccount] userIdString] forKey:@"user_id"];
    
    return [TTAccountNetworkManager getRequestForJSONWithURL:[TTAccountURLSetting TTAGetUserAuditInfoURLString] params:params needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAUpdateUserProfileRespModel *respMdl = [TTAUpdateUserProfileRespModel tta_modelWithJSON:jsonObj];
        
        TTAccountUserEntity *currentUser = [[TTAccount sharedAccount] user];
        
        if (!error && ([respMdl.data.error_description length] > 0 ||
                       [respMdl.data.tip length] > 0)) {
            
            TTAccountErrCode errcode = TTAccountErrCodeUnknown;
            if ([respMdl.data.existed_name length] > 0) {
                errcode = TTAccountErrCodeNameExisted;
            }
            
            NSMutableDictionary *errorUserInfo = [NSMutableDictionary dictionary];
            [errorUserInfo setValue:respMdl.data.error_description forKey:@"error_description"];
            [errorUserInfo setValue:TTAccountGetErrorCodeDescription(errcode) forKey:TTAccountErrMsgKey];
            
            if ([jsonObj isKindOfClass:[NSDictionary class]] &&
                [jsonObj[@"data"] isKindOfClass:[NSDictionary class]]) {
                [errorUserInfo addEntriesFromDictionary:jsonObj[@"data"]];
            }
            
            error = [NSError errorWithDomain:TTAccountErrorDomain code:errcode userInfo:errorUserInfo];
        }
        
        if (!error && [respMdl isRespSuccess]) {
            
            // 持久化用户审核相关信息
            TTAccountUserAuditSet *auditEntitySet = [[TTAccountUserAuditSet alloc] initWithUserModel:respMdl.data];
            currentUser.auditInfoSet = auditEntitySet;
            
            if (auditEntitySet.pgcUserAuditEntity.name && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.name = auditEntitySet.pgcUserAuditEntity.name;
            } else if (auditEntitySet.currentUserEntity.name) {
                currentUser.name = auditEntitySet.currentUserEntity.name;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.userDescription && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.userDescription = auditEntitySet.pgcUserAuditEntity.userDescription;
            } else if (auditEntitySet.currentUserEntity.userDescription) {
                currentUser.userDescription = auditEntitySet.currentUserEntity.userDescription;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.avatarURL && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.avatarURL = auditEntitySet.pgcUserAuditEntity.avatarURL;
            } else if (auditEntitySet.currentUserEntity.avatarURL) {
                currentUser.avatarURL = auditEntitySet.currentUserEntity.avatarURL;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.gender && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.gender = auditEntitySet.pgcUserAuditEntity.gender;
            } else if (auditEntitySet.currentUserEntity.gender) {
                currentUser.gender = auditEntitySet.currentUserEntity.gender;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.birthday && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.birthday = auditEntitySet.pgcUserAuditEntity.birthday;
            } else if (auditEntitySet.currentUserEntity.birthday) {
                currentUser.birthday = auditEntitySet.currentUserEntity.birthday;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.industry && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.industry = auditEntitySet.pgcUserAuditEntity.industry;
            } else if (auditEntitySet.currentUserEntity.industry) {
                currentUser.industry = auditEntitySet.currentUserEntity.industry;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.area && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.area = auditEntitySet.pgcUserAuditEntity.area;
            } else if (auditEntitySet.currentUserEntity.area) {
                currentUser.area = auditEntitySet.currentUserEntity.area;
            }
            
            if (completedBlock) {
                completedBlock(currentUser, nil);
            }
            
        } else {
            if (completedBlock) {
                completedBlock(nil, error);
            }
        }
    }];
}

+ (id<TTAccountSessionTask>)startGetUserAuditInfoIgnoreDispatchWithCompletion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setValue:[[TTAccount sharedAccount] userIdString] forKey:@"user_id"];
    
    return [TTAccountNetworkManager requestNoDispatchForJSONWithURL:[TTAccountURLSetting TTAGetUserAuditInfoURLString] method:@"GET" params:params extraGetParams:nil needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAUpdateUserProfileRespModel *respMdl = [TTAUpdateUserProfileRespModel tta_modelWithJSON:jsonObj];
        
        TTAccountUserEntity *currentUser = [[TTAccount sharedAccount] user];
        
        if (!error && ([respMdl.data.error_description length] > 0 ||
                       [respMdl.data.tip length] > 0)) {
            
            TTAccountErrCode errcode = TTAccountErrCodeUnknown;
            if ([respMdl.data.existed_name length] > 0) {
                errcode = TTAccountErrCodeNameExisted;
            }
            
            NSMutableDictionary *errorUserInfo = [NSMutableDictionary dictionary];
            [errorUserInfo setValue:respMdl.data.error_description forKey:@"error_description"];
            [errorUserInfo setValue:TTAccountGetErrorCodeDescription(errcode) forKey:TTAccountErrMsgKey];
            
            if ([jsonObj isKindOfClass:[NSDictionary class]] &&
                [jsonObj[@"data"] isKindOfClass:[NSDictionary class]]) {
                [errorUserInfo addEntriesFromDictionary:jsonObj[@"data"]];
            }
            
            error = [NSError errorWithDomain:TTAccountErrorDomain code:errcode userInfo:errorUserInfo];
        }
        
        if (!error && [respMdl isRespSuccess]) {
            
            // 持久化用户审核相关信息
            TTAccountUserAuditSet *auditEntitySet = [[TTAccountUserAuditSet alloc] initWithUserModel:respMdl.data];
            currentUser.auditInfoSet = auditEntitySet;
            
            if (auditEntitySet.pgcUserAuditEntity.name && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.name = auditEntitySet.pgcUserAuditEntity.name;
            } else if (auditEntitySet.currentUserEntity.name) {
                currentUser.name = auditEntitySet.currentUserEntity.name;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.userDescription && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.userDescription = auditEntitySet.pgcUserAuditEntity.userDescription;
            } else if (auditEntitySet.currentUserEntity.userDescription) {
                currentUser.userDescription = auditEntitySet.currentUserEntity.userDescription;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.avatarURL && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.avatarURL = auditEntitySet.pgcUserAuditEntity.avatarURL;
            } else if (auditEntitySet.currentUserEntity.avatarURL) {
                currentUser.avatarURL = auditEntitySet.currentUserEntity.avatarURL;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.gender && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.gender = auditEntitySet.pgcUserAuditEntity.gender;
            } else if (auditEntitySet.currentUserEntity.gender) {
                currentUser.gender = auditEntitySet.currentUserEntity.gender;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.birthday && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.birthday = auditEntitySet.pgcUserAuditEntity.birthday;
            } else if (auditEntitySet.currentUserEntity.birthday) {
                currentUser.birthday = auditEntitySet.currentUserEntity.birthday;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.industry && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.industry = auditEntitySet.pgcUserAuditEntity.industry;
            } else if (auditEntitySet.currentUserEntity.industry) {
                currentUser.industry = auditEntitySet.currentUserEntity.industry;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.area && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.area = auditEntitySet.pgcUserAuditEntity.area;
            } else if (auditEntitySet.currentUserEntity.area) {
                currentUser.area = auditEntitySet.currentUserEntity.area;
            }
            
            if (completedBlock) {
                completedBlock(currentUser, error);
            }
            
        } else {
            if (completedBlock) {
                completedBlock(nil, error);
            }
        }
    }];
}

#pragma mark - 更新用户Profile

+ (id<TTAccountSessionTask>)startUpdateUserProfileWithDict:(NSDictionary *)dict
                                                completion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    NSString *nameString      = [dict valueForKey:TTAccountUserNameKey];
    NSString *despString      = [dict valueForKey:TTAccountUserDescriptionKey];
    NSString *avatarUriString = [dict valueForKey:TTAccountUserAvatarKey];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:nameString forKey:@"name"];
    [params setValue:despString forKey:@"description"];
    [params setValue:avatarUriString forKey:@"avatar"];
    
    if (!TTAccountIsEmptyString(nameString)) {
        [TTAccountDraft setNickname:nameString];
    }
    
    if (!TTAccountIsEmptyString(despString)) {
        [TTAccountDraft setUserSignature:despString];
    }
    
    return [TTAccountNetworkManager postRequestForJSONWithURL:[TTAccountURLSetting TTAUpdateUserProfileURLString] params:params needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAccountUserEntity *currentUser = [[TTAccount sharedAccount] user];
        
        TTAUpdateUserProfileRespModel *respMdl = [TTAUpdateUserProfileRespModel tta_modelWithJSON:jsonObj];
        
        if (!error && ([respMdl.data.error_description length] > 0 ||
                       [respMdl.data.tip length] > 0)) {
            
            TTAccountErrCode errcode = TTAccountErrCodeUnknown;
            if ([respMdl.data.existed_name length] > 0) {
                errcode = TTAccountErrCodeNameExisted;
            }
            
            NSMutableDictionary *errorUserInfo = [NSMutableDictionary dictionary];
            [errorUserInfo setValue:respMdl.data.error_description forKey:@"error_description"];
            [errorUserInfo setValue:TTAccountGetErrorCodeDescription(errcode) forKey:TTAccountErrMsgKey];
            
            if ([jsonObj isKindOfClass:[NSDictionary class]] &&
                [jsonObj[@"data"] isKindOfClass:[NSDictionary class]]) {
                [errorUserInfo addEntriesFromDictionary:jsonObj[@"data"]];
            }
            
            error = [NSError errorWithDomain:TTAccountErrorDomain code:errcode userInfo:errorUserInfo];
        }
        
        NSMutableDictionary *changedProfileFields = [NSMutableDictionary dictionaryWithCapacity:4];
        
        if (!error && [respMdl isRespSuccess]) {
            
            // 持久化用户审核相关信息
            TTAccountUserAuditSet *auditEntitySet = [[TTAccountUserAuditSet alloc] initWithUserModel:respMdl.data];
            currentUser.auditInfoSet = auditEntitySet;
            
            if (auditEntitySet.pgcUserAuditEntity.name && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.name = auditEntitySet.pgcUserAuditEntity.name;
            } else if (auditEntitySet.currentUserEntity.name) {
                currentUser.name = auditEntitySet.currentUserEntity.name;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.userDescription && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.userDescription = auditEntitySet.pgcUserAuditEntity.userDescription;
            } else if (auditEntitySet.currentUserEntity.userDescription) {
                currentUser.userDescription = auditEntitySet.currentUserEntity.userDescription;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.avatarURL && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.avatarURL = auditEntitySet.pgcUserAuditEntity.avatarURL;
            } else if (auditEntitySet.currentUserEntity.avatarURL) {
                currentUser.avatarURL = auditEntitySet.currentUserEntity.avatarURL;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.gender && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.gender = auditEntitySet.pgcUserAuditEntity.gender;
            } else if (auditEntitySet.currentUserEntity.gender) {
                currentUser.gender = auditEntitySet.currentUserEntity.gender;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.birthday && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.birthday = auditEntitySet.pgcUserAuditEntity.birthday;
            } else if (auditEntitySet.currentUserEntity.birthday) {
                currentUser.birthday = auditEntitySet.currentUserEntity.birthday;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.industry && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.industry = auditEntitySet.pgcUserAuditEntity.industry;
            } else if (auditEntitySet.currentUserEntity.industry) {
                currentUser.industry = auditEntitySet.currentUserEntity.industry;
            }
            
            if (auditEntitySet.pgcUserAuditEntity.area && !auditEntitySet.pgcUserAuditEntity.auditing) {
                currentUser.area = auditEntitySet.pgcUserAuditEntity.area;
            } else if (auditEntitySet.currentUserEntity.area) {
                currentUser.area = auditEntitySet.currentUserEntity.area;
            }
            
            if (!TTAccountIsEmptyString(nameString)) {
                if (respMdl.data.pgc_audit_info.audit_info.name ||
                    respMdl.data.verified_audit_info.audit_info.name ||
                    respMdl.data.current_info.name) {
                    [TTAccountDraft setNickname:nil];
                    [changedProfileFields setObject:@(YES) forKey:@(TTAccountUserProfileTypeUserName)];
                } else {
                    [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserName)];
                }
            }
            
            if (!TTAccountIsEmptyString(despString)) {
                if (respMdl.data.pgc_audit_info.audit_info.user_description ||
                    respMdl.data.verified_audit_info.audit_info.user_description ||
                    respMdl.data.current_info.user_description) {
                    [TTAccountDraft setUserSignature:nil];
                    [changedProfileFields setObject:@(YES) forKey:@(TTAccountUserProfileTypeUserDesp)];
                } else {
                    [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserDesp)];
                }
            }
            
            if (!TTAccountIsEmptyString(avatarUriString)) {
                if (respMdl.data.pgc_audit_info.audit_info.avatar_url ||
                    respMdl.data.verified_audit_info.audit_info.avatar_url ||
                    respMdl.data.current_info.avatar_url) {
                    [changedProfileFields setObject:@(YES) forKey:@(TTAccountUserProfileTypeUserAvatar)];
                } else {
                    [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserAvatar)];
                }
            }
            
            [TTAccountMulticastDispatcher dispatchAccountProfileChanged:changedProfileFields error:error bisectBlock:^{
                if (completedBlock) {
                    completedBlock(currentUser, error);
                }
            }];
        } else {
            
            if (!TTAccountIsEmptyString(nameString)) {
                [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserName)];
            }
            
            if (!TTAccountIsEmptyString(despString)) {
                [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserDesp)];
            }
            
            if (!TTAccountIsEmptyString(avatarUriString)) {
                [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserAvatar)];
            }
            
            if (completedBlock) {
                completedBlock(currentUser, error);
            }
        }
    }];
}

+ (id<TTAccountSessionTask>)startUpdateUserExtraProfileWithDict:(NSDictionary *)dict
                                                     completion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    NSString *genderString   = [dict valueForKey:TTAccountUserGenderKey];
    NSString *birthdayString = [dict valueForKey:TTAccountUserBirthdayKey];
    NSString *provinceString = [dict valueForKey:TTAccountUserProvinceKey];
    NSString *cityString     = [dict valueForKey:TTAccountUserCityKey];
    NSString *industryString = [dict valueForKey:TTAccountUserIndustryKey];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:genderString forKey:@"gender"];
    [params setValue:birthdayString forKey:@"birthday"];
    [params setValue:provinceString forKey:@"province"];
    [params setValue:cityString forKey:@"city"];
    [params setValue:industryString forKey:@"industry"];
    
    if (!TTAccountIsEmptyString(genderString)) {
        [TTAccountDraft setUserGender:genderString];
    }
    
    if (!TTAccountIsEmptyString(birthdayString)) {
        [TTAccountDraft setBirthday:birthdayString];
    }
    
    return [TTAccountNetworkManager postRequestForJSONWithURL:[TTAccountURLSetting TTAUpdateUserExtraProfileURLString] params:params needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTAccountUserEntity *currentUser = [[TTAccount sharedAccount] user];
        
        TTAUpdateUserProfileRespModel *respMdl = [TTAUpdateUserProfileRespModel tta_modelWithJSON:jsonObj];
        
        if (!error && [respMdl.data.error_description length] > 0) {
            
            TTAccountErrCode errcode = TTAccountErrCodeUnknown;
            
            NSMutableDictionary *errorUserInfo = [NSMutableDictionary dictionary];
            [errorUserInfo setValue:respMdl.data.error_description forKey:@"error_description"];
            [errorUserInfo setValue:respMdl.data.error_description ? : TTAccountGetErrorCodeDescription(errcode) forKey:TTAccountErrMsgKey];
            
            if ([jsonObj isKindOfClass:[NSDictionary class]] &&
                [jsonObj[@"data"] isKindOfClass:[NSDictionary class]]) {
                [errorUserInfo addEntriesFromDictionary:jsonObj[@"data"]];
            }
            
            error = [NSError errorWithDomain:TTAccountErrorDomain code:errcode userInfo:errorUserInfo];
        }
        
        NSMutableDictionary *changedProfileFields = [NSMutableDictionary dictionaryWithCapacity:4];
        
        if (!error && [respMdl isRespSuccess]) {
            
            if (respMdl.data.attrs.gender) {
                if (currentUser.auditInfoSet.currentUserEntity.gender)
                    currentUser.auditInfoSet.currentUserEntity.gender = respMdl.data.attrs.gender;
                if (currentUser.auditInfoSet.verifiedUserAuditEntity.gender)
                    currentUser.auditInfoSet.verifiedUserAuditEntity.gender = respMdl.data.attrs.gender;
                if (currentUser.auditInfoSet.pgcUserAuditEntity.gender)
                    currentUser.auditInfoSet.pgcUserAuditEntity.gender = respMdl.data.attrs.gender;
                
                currentUser.gender = respMdl.data.attrs.gender;
            }
            
            if (respMdl.data.attrs.birthday) {
                if (currentUser.auditInfoSet.currentUserEntity.birthday)
                    currentUser.auditInfoSet.currentUserEntity.birthday = respMdl.data.attrs.birthday;
                if (currentUser.auditInfoSet.verifiedUserAuditEntity.birthday)
                    currentUser.auditInfoSet.verifiedUserAuditEntity.birthday = respMdl.data.attrs.birthday;
                if (currentUser.auditInfoSet.pgcUserAuditEntity.birthday)
                    currentUser.auditInfoSet.pgcUserAuditEntity.birthday = respMdl.data.attrs.birthday;
                
                currentUser.birthday = respMdl.data.attrs.birthday;
            }
            
            if (respMdl.data.attrs.area) {
                if (currentUser.auditInfoSet.currentUserEntity.area)
                    currentUser.auditInfoSet.currentUserEntity.area = respMdl.data.attrs.area;
                if (currentUser.auditInfoSet.verifiedUserAuditEntity.area)
                    currentUser.auditInfoSet.verifiedUserAuditEntity.area = respMdl.data.attrs.area;
                if (currentUser.auditInfoSet.pgcUserAuditEntity.area)
                    currentUser.auditInfoSet.pgcUserAuditEntity.area = respMdl.data.attrs.area;
                
                currentUser.area = respMdl.data.attrs.area;
            }
            
            if (respMdl.data.attrs.industry) {
                if (currentUser.auditInfoSet.currentUserEntity.industry)
                    currentUser.auditInfoSet.currentUserEntity.industry = respMdl.data.attrs.industry;
                if (currentUser.auditInfoSet.verifiedUserAuditEntity.industry)
                    currentUser.auditInfoSet.verifiedUserAuditEntity.industry = respMdl.data.attrs.industry;
                if (currentUser.auditInfoSet.pgcUserAuditEntity.industry)
                    currentUser.auditInfoSet.pgcUserAuditEntity.industry = respMdl.data.attrs.industry;
                
                currentUser.industry = respMdl.data.attrs.industry;
            }
            
            if (!TTAccountIsEmptyString(genderString)) {
                if (respMdl.data.attrs.gender) {
                    [TTAccountDraft setUserGender:nil];
                    [changedProfileFields setObject:@(YES) forKey:@(TTAccountUserProfileTypeUserGender)];
                } else {
                    [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserGender)];
                }
            }
            
            if (!TTAccountIsEmptyString(birthdayString)) {
                if (respMdl.data.attrs.birthday) {
                    [TTAccountDraft setBirthday:nil];
                    [changedProfileFields setObject:@(YES) forKey:@(TTAccountUserProfileTypeUserBirthday)];
                } else {
                    [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserBirthday)];
                }
            }
            
            if (!TTAccountIsEmptyString(provinceString) || !TTAccountIsEmptyString(cityString)) {
                if (respMdl.data.attrs.area) {
                    [changedProfileFields setObject:@(YES) forKey:@(TTAccountUserProfileTypeUserProvince)];
                    [changedProfileFields setObject:@(YES) forKey:@(TTAccountUserProfileTypeUserCity)];
                } else {
                    [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserProvince)];
                    [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserCity)];
                }
            }
            
            if (!TTAccountIsEmptyString(industryString)) {
                if (respMdl.data.attrs.industry) {
                    [changedProfileFields setObject:@(YES) forKey:@(TTAccountUserProfileTypeUserIndustry)];
                } else {
                    [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserIndustry)];
                }
            }
            
            [TTAccountMulticastDispatcher dispatchAccountProfileChanged:changedProfileFields error:error bisectBlock:^{
                if (completedBlock) {
                    completedBlock(currentUser, error);
                }
            }];
        } else {
            
            if (!TTAccountIsEmptyString(genderString)) {
                [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserGender)];
            }
            
            if (!TTAccountIsEmptyString(birthdayString)) {
                [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserBirthday)];
            }
            
            if (!TTAccountIsEmptyString(provinceString) || !TTAccountIsEmptyString(cityString)) {
                [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserProvince)];
                [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserCity)];
            }
            
            if (!TTAccountIsEmptyString(industryString)) {
                [changedProfileFields setObject:@(NO) forKey:@(TTAccountUserProfileTypeUserIndustry)];
            }
            
            if (completedBlock) {
                completedBlock(currentUser, error);
            }
        }
    }];
}

@end
