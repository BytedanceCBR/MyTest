//
//  TTBlockManager.m
//  Article
//
//  Created by Huaqing Luo on 5/3/15.
//
//

#import "TTBlockManager.h"
#import "TTBlockApiModels.h"
#import "TTNetworkManager.h"
#import "TTBaseMacro.h"

@implementation TTBlockManager
- (void)blockUser:(NSString *)userID
{
    TTBlockRequestModel* req = [[TTBlockRequestModel alloc] init];
    req.block_user_id = userID;
    
    [[TTNetworkManager shareInstance] requestModel:req callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHasBlockedUnblockedUserNotification object:nil userInfo:@{kBlockedUnblockedUserIDKey:userID, kIsBlockingKey:@(YES)}];
            TTBlockResponseModel* response = (TTBlockResponseModel*)responseModel;
            if (response) {
                if (!isEmptyString(response.data.desc) || response.data.blockUserID == nil) {
                    if ([self.delegate respondsToSelector:@selector(blockUserManager:blocResult:blockedUserID:error:errorTip:)]) {
                        [self.delegate blockUserManager:self blocResult:NO blockedUserID:nil error:error errorTip:response.data.desc];
                    }
                } else {
                    if ([self.delegate respondsToSelector:@selector(blockUserManager:blocResult:blockedUserID:error:errorTip:)]) {
                        [self.delegate blockUserManager:self blocResult:YES blockedUserID:response.data.blockUserID.stringValue error:nil errorTip:nil];
                    }
                }
                
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(blockUserManager:blocResult:blockedUserID:error:errorTip:)]) {
                [self.delegate blockUserManager:self blocResult:NO blockedUserID:nil error:error errorTip:nil];
            }
        }
    }];
}

- (void)unblockUser:(NSString *)userID
{
    TTUnBlockRequestModel* req = [[TTUnBlockRequestModel alloc] init];
    req.block_user_id = userID;
    
    [[TTNetworkManager shareInstance] requestModel:req callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHasBlockedUnblockedUserNotification object:nil userInfo:@{kBlockedUnblockedUserIDKey:userID, kIsBlockingKey:@(NO)}];
            TTBlockResponseModel* response = (TTBlockResponseModel*)responseModel;
            if (response) {
                if (!isEmptyString(response.data.desc) || response.data.blockUserID == nil) {
                    if ([self.delegate respondsToSelector:@selector(blockUserManager:blocResult:blockedUserID:error:errorTip:)]) {
                        [self.delegate blockUserManager:self unblockResult:NO unblockedUserID:nil error:error errorTip:response.data.desc];
                    }
                } else {
                    if ([self.delegate respondsToSelector:@selector(blockUserManager:blocResult:blockedUserID:error:errorTip:)]) {
                        [self.delegate blockUserManager:self unblockResult:YES unblockedUserID:response.data.blockUserID.stringValue error:nil errorTip:nil];
                    }
                }
                
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(blockUserManager:blocResult:blockedUserID:error:errorTip:)]) {
                [self.delegate blockUserManager:self unblockResult:NO unblockedUserID:nil error:error errorTip:nil];
            }
        }
    }];
}

- (void)getBlockedUsersWithOffset:(NSInteger)offset count:(NSInteger)count
{
    TTBlockUserListRequestModel* req = [[TTBlockUserListRequestModel alloc] init];
    req.offset = offset;
    req.count = count;
    [[TTNetworkManager shareInstance] requestModel:req callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        TTBlockUserListResponseModel* response = (TTBlockUserListResponseModel*)responseModel;
        if (self.delegate && [self.delegate respondsToSelector:@selector(blockUserManager:getBlockedUsersResult:error:)]) {
            [self.delegate blockUserManager:self getBlockedUsersResult:response.data error:error];
        }
    }];
}
@end
