//
//  TTPlatformShareMessageBase.h
//  Article
//
//  Created by 王霖 on 15/9/9.
//
//

#import <Foundation/Foundation.h>
#import "TTShareMacros.h"

typedef void(^TTPlatformShareMessageCompletion)(id response, NSError *error);

/**
 *  TTPlatformShareMessageBase是各平台分享message的基类。目前平台有：头条、话题插件
 */
@interface TTPlatformShareMessageBase : NSObject

/**
 *  分享message函数，默认不做任何事情，需要子类重载
 *
 *  @param platformType 分享来自的平台
 *  @param condition    分享内容及其他
 *  @param completion   分享完成block
 */
- (void)shareMessageFromPlatform:(TTSharePlatformType)platformType condition:(NSDictionary *)condition withCompletion:(TTPlatformShareMessageCompletion)completion;

@end
