//
//  TTAccountService.h
//  Article
//
//  Created by liuzuopeng on 27/05/2017.
//
//

#import <Foundation/Foundation.h>
#import <TTAccountSDK.h>



/**
 *  该类的处理时机非常早（在账号相关接口的block回调之前且同步执行），仅适合做一些用户信息同步相关的必要操作（如清理cookie，用户老的用户信息），以便在block回调中使用能取到正确的结果；其他关注账号消息的地方自己实现TTAccountMulticast回调
 */
@interface TTAccountService : NSObject
<
TTAccountMessageFirstResponder
>

+ (instancetype)sharedAccountService;

@end
