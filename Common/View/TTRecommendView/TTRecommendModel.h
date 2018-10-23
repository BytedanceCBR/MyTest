//
//  TTRecommendModel.h
//  Article
//
//  Created by zhaoqin on 18/12/2016.
//
//

#import <Foundation/Foundation.h>

@interface TTRecommendModel : JSONModel
@property (nonatomic, strong) NSString *avatarUrlString;//用户头像
@property (nonatomic, strong) NSString *nameString;//用户名称
@property (nonatomic, strong) NSString *reasonString;//推荐原因
@property (nonatomic, strong) NSNumber *reason;//推荐type，用于关注的时候透传
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, copy) NSString<Optional> *userAuthInfo;//头条认证展现
@property (nonatomic, assign) BOOL isFollowing;//关注
@property (nonatomic, assign) BOOL isFollowed;//被关注

//@property (nonatomic, assign) BOOL isTracked;//监测是否已经出现，用于埋点统计
@property (nonatomic, assign) BOOL isDisplay;//监测是否在visible Cells中

- (instancetype)initWithUserInfoDict:(NSDictionary *)dict;
@end
