//
//  PGCAccount.h
//  Article
//
//  Created by Dianwei on 13-9-18.
//
//

#import <Foundation/Foundation.h>



@interface PGCAccount : NSObject<NSCoding>

@property (nonatomic,   copy) NSString *screenName;         //名字
@property (nonatomic,   copy) NSString *userDesc;           //简介
@property (nonatomic,   copy) NSString *avatarURLString;    //媒体logo
@property (nonatomic,   copy) NSString *verifiedDesc;       //认证介绍
@property (nonatomic,   copy) NSString *shareURL;           //分享链接
@property (nonatomic,   copy) NSString *mediaID;            //pgc account ID
@property (nonatomic, assign) BOOL      liked;              //当前用户对该用户是否感兴趣，如果是用户自己，忽略该字段
@property (nonatomic,   copy) NSString *userAuthInfo;       //头条认证展现

@property (nonatomic, strong) NSString *enterItemId;

- (instancetype)initWithDictionary:(NSDictionary*)dict;

- (BOOL)isLoginUser;

@end
