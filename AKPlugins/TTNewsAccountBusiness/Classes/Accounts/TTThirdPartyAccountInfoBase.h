//
//  TTThirdPartyAccountInfoBase.h
//  ShareOne
//
//  Created by Dianwei Hu on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAccountManagerDefine.h"



typedef
NS_ENUM(NSInteger, TTThirdPartyAccountStatus)  {
    TTThirdPartyAccountStatusNone    = 0,
    TTThirdPartyAccountStatusBounded = 1,
    TTThirdPartyAccountStatusChecked __attribute__((deprecated)) __deprecated_enum_msg("TTOpenPlatformAccountStatusChecked曾经在做评论的时候，如果登录并选中的时候可以转发到第三方平台.") = 2,
};



@interface TTThirdPartyAccountInfoBase : NSObject

@property (nonatomic, assign) TTThirdPartyAccountStatus accountStatus;
@property (nonatomic,   copy) NSString *screenName;
@property (nonatomic,   copy) NSString *platformUid;
@property (nonatomic,   copy) NSString *profileImageURLString;
// 还有多长时间过期, 服务端命名
@property(nonatomic, assign) NSTimeInterval expiredIn;

#pragma mark - protected method

/**
 获取平台名称，不为nil，不存在返回""

 @return 平台名称
 */
+ (NSString *)platformName;  // equal to keyName string now, but this is a class method

//同displayName,为实例方法，方便调用
+ (NSString *)platformDisplayName;

- (NSString *)keyName;
- (NSString *)displayName;
- (NSString *)iconImageName;
- (NSString *)drawerDisplayImage;

- (BOOL)logined;

- (void)save;

- (void)clear;

@end
