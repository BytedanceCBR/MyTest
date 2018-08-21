//
//  TTUserServices.h
//  Article
//
//  Created by 杨心雨 on 2017/1/18.
//
//

#import <Foundation/Foundation.h>

@class TTUserData;

typedef void (^TTFetchUserDataCompletion)(TTUserData * _Nullable userData, BOOL success);
typedef void (^TTFetchUserDatasCompletion)(NSArray<TTUserData *> * _Nullable userDatas, BOOL success);

@interface TTUserServices : NSObject

/** 拉取单个用户信息 */
+ (void)fetchUserDataWithUserId:(NSString * _Nullable)userId completion:(TTFetchUserDataCompletion _Nullable)completion;

/** 拉取多个用户信息 */
+ (void)fetchUserDatasWithUserIds:(NSArray<NSString *> * _Nullable)userIds completion:(TTFetchUserDatasCompletion _Nullable)completion;

@end
