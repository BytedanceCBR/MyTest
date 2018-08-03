//
//  TTPersonModel+FRUser.h
//  Forum
//
//  Created by zhaopengwei on 15/4/15.
//
//

#import "TTPersonModel.h"
#import "SSMyUserModel.h"
#import "SSUserModel.h"

@class FRUserInfoStructModel;
@class FRMessageListUserInfoStructModel;
@class FRUserStructModel;
@interface TTPersonModel (FRUser)

- (instancetype)initWithUserModel:(FRUserInfoStructModel *)userInfo;
- (instancetype)initWithMessageListUserModel:(FRMessageListUserInfoStructModel *)userInfo;
- (instancetype)initWithUserStructModel:(FRUserStructModel *)userInfo;

+ (NSArray<TTPersonModel> *)genPersonModelsFromUserStruct:(NSArray<FRUserStructModel *> *)userStructs;

+ (TTPersonModel *)genTTPersonModelFromMyUserModel:(SSMyUserModel *)model;

+ (SSMyUserModel *)genMyUserModelFromTTPersonModel:(TTPersonModel *)ttModel;

+ (TTPersonModel *)genTTPersonModelFromUserModel:(SSUserModel *)model;

+ (SSUserModel *)genUserModelFromTTPersonModel:(TTPersonModel *)ttModel;

+ (FRUserStructModel *)genUserStructModelFrom:(TTPersonModel *)ttModel;

@end
