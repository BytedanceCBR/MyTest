//
//  TTUserServices.m
//  Article
//
//  Created by 杨心雨 on 2017/1/18.
//
//

#import "TTUserServices.h"
#import "TTUserData.h"
#import "TTNetworkManager.h"

#ifndef isEmptyString
#define isEmptyString(str) (!str || ![str isKindOfClass:[NSString class]] || str.length == 0)
#endif
#ifndef isEmptyArray
#define isEmptyArray(arr) (!arr || ![arr isKindOfClass:[NSArray class]] || arr.count == 0)
#endif

@implementation TTUserServices

+ (void)fetchUserDataWithUserId:(NSString *)userId completion:(TTFetchUserDataCompletion)completion {
    if (isEmptyString(userId)) {
        return;
    }
    
    [self fetchUserDatasWithUserIds:@[userId] completion:^(NSArray<TTUserData *> * _Nullable userDatas, BOOL success) {
        if ([userDatas count] < 1 || !success) {
            if (completion) {
                completion(nil, NO);
            }
            return;
        }
        TTUserData *data = [userDatas objectAtIndex:0];
        if (completion) {
            completion(data, YES);
        }
    }];
}

+ (void)fetchUserDatasWithUserIds:(NSArray<NSString *> *)userIds completion:(TTFetchUserDatasCompletion)completion {
    if (isEmptyArray(userIds)) {
        return;
    }
//    if ([userIds count] > 20) {
//        LOGD(@"一次性获取用户数量过多，只取前20个");
//    }
    
//    NSMutableArray *users = [[NSMutableArray alloc] init];
//    [userIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (idx >= 20) {
//            *stop = YES;
//            return;
//        }
//        [users addObject:obj];
//    }];
    
    NSString *usersString = [userIds componentsJoinedByString:@","];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting userInfoURL] params:@{@"users" : usersString} method:@"GET" needCommonParams:NO callback:^(NSError *error, id jsonObj) {
        if (error) {
            LOGD(@"获取用户信息时返回错误");
            return;
        }
        __autoreleasing NSError *jsonError;
        TTUsersDataResponse *usersResponse = [[TTUsersDataResponse alloc] initWithDictionary:jsonObj error:&jsonError];
        NSMutableArray<TTUserData *> *userDatas = [[NSMutableArray<TTUserData *> alloc] init];
        for (TTUserDataResponse *userResponse in usersResponse.userInfos) {
            TTUserData *userData = [userResponse transformToUserData];
            [userData save];
            [userDatas addObject:userData];
        }
        if (completion) {
            completion(userDatas, YES);
        }
    }];
}

@end
