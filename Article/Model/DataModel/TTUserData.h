//
//  TTUserData.h
//  Article
//
//  Created by 杨心雨 on 2017/1/17.
//
//

#import "TTEntityBase.h"

/** 用户模型 */
@interface TTUserData : TTEntityBase

#pragma mark 持久化属性
/** 用户主键 */
@property (nonatomic, copy) NSString * _Nonnull userId;
/** 姓名 */
@property (nonatomic, copy) NSString * _Nullable name;
/** 头像地址 */
@property (nonatomic, copy) NSString * _Nullable avatarUrl;
/** 屏幕姓名 */
@property (nonatomic, copy) NSString * _Nullable screenName;
/** 拉黑状态 */
@property (nonatomic, copy) NSNumber * _Nullable isBlocking;
/** 认证信息 */
@property (nonatomic, copy) NSString * _Nullable userAuthInfo;
/** 佩饰 */
@property (nonatomic, copy) NSString * _Nullable userDecoration;
#pragma mark 非持久化属性

#pragma mark 模型方法

@end

@protocol TTUserDataResponse
@end

@interface TTUserDataResponse : JSONModel

@property (nonatomic, copy) NSString * _Nonnull userId;
@property (nonatomic, copy) NSString * _Nonnull name;
@property (nonatomic, copy) NSString * _Nonnull avatarUrl;
@property (nonatomic, copy) NSString * _Nonnull screenName;
@property (nonatomic, copy) NSNumber<Optional> * _Nullable isBlocking;
@property (nonatomic, copy) NSString<Optional> * _Nullable userAuthInfo;
@property (nonatomic, copy) NSString<Optional> * _Nullable userDecoration;

- (nonnull TTUserData *)transformToUserData;

@end

@interface TTUsersDataResponse : JSONModel

@property (nonatomic, copy) NSArray<TTUserDataResponse> * _Nullable userInfos;
@property (nonatomic, copy) NSString<Optional> * _Nullable message;

@end
