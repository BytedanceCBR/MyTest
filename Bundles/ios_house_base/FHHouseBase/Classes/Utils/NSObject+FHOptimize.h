//
//  NSObject+FHOptimize.h
//  FHHouseBase
//
//  Created by 张元科 on 2020/5/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define FHExecuteOnceUniqueTokenForCurrentContext ([NSString stringWithFormat:@"FHExecuteOnceUniqueToken_%s_Line%d",__PRETTY_FUNCTION__,__LINE__])

@interface NSObject (FHOptimize)

//具有相同 token 的 Code 里的代码只在对象生命周期中执行一次；
//如果 token 不能为 nil

- (void)executeOnce:(void (^)(void))code token:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
