//
//  TTEditUserProfileViewModel+Network.m
//  Article
//
//  Created by liuzuopeng on 8/25/16.
//
//

#import "TTEditUserProfileViewModel+Network.h"



@implementation TTEditUserProfileViewModel (Network)

- (void)uploadUserPhoto:(UIImage *)image
             startBlock:(void (^)())aCallback
             completion:(void (^)(NSString *imageURIString, NSError *error))completion {
    if (aCallback) aCallback();
    
    [TTAccountManager startUploadUserImage:image completion:^(TTAccountImageEntity *imageEntity, NSError *error) {
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            
            // 如果不是网络或图片数据格式问题，重传图片
            // if (error.code == kNoNetworkErrorCode || error.code == kInvalidDataFormatErrorCode) {
            //     if (completion) completion(nil, error);
            // } else {
            //     if (completion) completion(nil, error);
            // }
        } else {
            if (completion) {
                completion(imageEntity.web_uri, nil);
            }
        }
    }];
}

- (void)uploadAllUserProfileInfoWithStartBlock:(void (^)())aCallback
                                    completion:(void (^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    [self uploadUserProfileInfo:[self.editableAuditInfo toUploadedParameters] startBlock:aCallback completion:completedBlock];
}

- (void)uploadUserProfileInfo:(NSDictionary *)params startBlock:(void (^)())aCallback
                   completion:(void (^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    if (aCallback) aCallback();
    
    [TTAccount updateUserProfileWithDict:params completion:^(TTAccountUserEntity *userEntity, NSError * _Nullable error) {
        if (!error) {
            if (completedBlock) completedBlock(userEntity, nil);
        } else {
            if (completedBlock) completedBlock(nil, error);
        }
    }];
}

@end
