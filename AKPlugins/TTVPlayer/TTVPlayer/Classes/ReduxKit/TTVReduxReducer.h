//
//  TTVReduxReducer.h
//  Created by panxiang on 2018/7/20.
//

#import <Foundation/Foundation.h>
#import "TTVReduxProtocol.h"

/**
 实现一个根的reducer, 外界想使用来初始化 store，可以继承此类进行调用, 也可以直接使用这个类
 */
@interface TTVReduxReducer : NSObject<TTVReduxReducerProtocol>

@end
