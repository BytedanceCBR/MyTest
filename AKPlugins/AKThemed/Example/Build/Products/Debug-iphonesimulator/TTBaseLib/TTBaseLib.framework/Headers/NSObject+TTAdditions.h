//
//  NSObject+TTAdditions.h
//  Pods
//
//  Created by zhaoqin on 8/19/16.
//
//

#import <Foundation/Foundation.h>

@protocol Singleton <NSObject>

@optional
//因为是在Category里实现了，所以这里用optional主要是避免报警
+ (instancetype)sharedInstance_tt;
+ (void)destorySharedInstance_tt;

@end

@interface NSObject (Singleton)

@end

@interface NSObject (Time)

/**
 *  获取Block执行的时间
 *
 *  @param block
 *
 *  @return
 */
+ (double)elapsedTimeBlock:(void (^)(void))block;

/**
 *  获取当前Mach绝对时间
 *
 *  @return
 */
+ (uint64_t)currentUnixTime;

/**
 *  将Mach时间转换为秒
 *
 *  @param time
 *
 *  @return 
 */
+ (double)machTimeToSecs:(uint64_t)time;

@end

@interface NSObject (TTSelector)

/**
 *  一个方法只在另一个方法中只执行一次
 *
 *  @param executeSelector 要调用的方法
 *  @param externSelector  调用executeSelector所在的方法
 *
 *  @return YES，executeSelector成功被调用；NO 没有调用
 
 比如：我们想要在第一次进入ViewWillAppera中调用refreshDada方法，可以这样做：
 - (void)viewWillAppear:(BOOL)animated
 {
 [super viewWillAppear:animated];
 [self tt_performSelector:@selector(refreshData) onlyOnceInSelector:_cmd];
 }
 */
- (BOOL)tt_performSelector:(SEL)executeSelector onlyOnceInSelector:(SEL)externSelector;

/// 注明： 如果返回值为基本类型，struct除外，其余都转换为NSNumber。 如果返回值是struct。则转为NSValue,
/// 如果selector不存在，则直接返回nil, 如果参数不足，则nil填充
- (id)performSelector:(SEL)aSelector withObjects:(id)object, ... __attribute__((sentinel(0, 1)));
@end


