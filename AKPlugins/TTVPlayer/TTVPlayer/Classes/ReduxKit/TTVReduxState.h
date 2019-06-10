//
//  TTVReduxState.h
//  Created by panxiang on 2018/7/20.
//

#import <Foundation/Foundation.h>
#import "TTVReduxProtocol.h"

/**
 实现一个根的state, 外界想使用 来初始化 store，可以继承此类进行调用, 也可以直接使用这个类
 */
@interface TTVReduxState : NSObject<TTVReduxStateProtocol, NSCopying>

@end
