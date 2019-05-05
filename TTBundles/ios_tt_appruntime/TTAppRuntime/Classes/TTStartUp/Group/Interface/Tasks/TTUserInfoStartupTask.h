//
//  TTUserInfoStartupTask.h
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTStartupTask.h"



@interface TTUserInfoStartupTask : TTStartupTask<UIApplicationDelegate>

+ (void)getAccountUserInfoWithContext:(id)context;

/**
 *  获取并同步用户信息
 *
 *  @param  displayExpirationError 过期时是否显示过期提示
 *  @param  context                上下文环境
 */
+ (void)getAccountUserInfoWithExpirationError:(BOOL)displayExpirationError
                                      context:(id)context;

@end
