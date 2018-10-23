//
//  AWEUserModel.h
//  Aweme
//
//  Created by 01 on 16/8/10.
//  Copyright © 2016年 Bytedance. All rights reserved.
//  接口：https://wiki.bytedance.net/pages/viewpage.action?pageId=70851470#id-用户关系API文档-关注接口
//

#import <Mantle/Mantle.h>

@interface AWEUserModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSNumber *mediaId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSNumber *createTime;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSString *lastUpdate;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, assign) BOOL userVerified;
@end
