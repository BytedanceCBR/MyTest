//
//  TTVReduxAction.h
//  Created by lisa on 2018/7/20.
//

#import <Foundation/Foundation.h>
#import "TTVReduxProtocol.h"

#define TTVReduxAction_Type_init    @"TTVReduxAction_Type_init" // 初始化的 action，当遇到初始化 action，会默认

@interface TTVReduxAction : NSObject<TTVReduxActionProtocol>

- (BOOL)isValidAction;
+ (BOOL)isValidActon:(TTVReduxAction *)action;

+ (instancetype)actionWithType:(NSString *)type
                          info:(NSDictionary *)info;



/**
 可执行 action 的初始化方法

 @param target 实际执行的对象
 @param selector target 的方法
 @param params  selector 的参数
 @param type  action 的类型，由于额外信息不常用，经常是 nil，所以不在此处加入
 @return self
 */
- (instancetype)initWithTarget:(id)target
                      selector:(SEL)selector
                        params:(NSArray *)params
                    actionType:(NSString *)type;

- (instancetype)initWithType:(NSString *)type;
- (instancetype)initWithType:(NSString *)type info:(NSDictionary *)info;

@end

