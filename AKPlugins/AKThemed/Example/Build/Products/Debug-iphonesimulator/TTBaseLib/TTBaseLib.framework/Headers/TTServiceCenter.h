//
//  TTServiceCenter.h
//  LiveStreaming
//
//  Created by denggang on 16/7/13.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 使用：
   1、如果要使用TTService，需要在应用启动时就初始化
         AppDelegate中的 -application:didFinishLaunchingWithOptions:中进行
      AppDelegate生命周期的回调函数中同步TTService的回调函数
         e.g. onServiceEnterBackground,onServiceEnterForeground etc
   2、要实现应用中的服务对象，必须继承于TTService，并实现协议TTService
        服务对象的命名规范：xxxService，必须以Service结尾
 */


// 一系列协议，回调服务对象的状态并处理
@protocol TTService <NSObject>

@optional
// 服务对象初始化成功
- (void)onServiceInit;
// 进入后台运行
- (void)onServiceEnterBackground;
// 进入前台运行
- (void)onServiceEnterForeground;
//程序 将要进入非激活状态
- (void)onAppWillResignActive;
//程序 将要进入激活状态
- (void)onAppWillBecomeActive;
// 程序退出
- (void)onServiceTerminate;
// 内存警告
- (BOOL)onServiceMemoryWarning;
// 退出登录时调用 用于清理资源.
- (void)onServiceClearData;
// 可继续添加 TODO

@end

// 服务对象的基类
@interface TTService : NSObject<TTService>

@property (assign) BOOL isServiceRemoved;
@property (assign) BOOL isServicePersistent;//注销或者退出,是否还需要驻留内存

@end


/*
 * 服务对象中心：
 * 用来存放为全局服务的对象
 */
@interface TTServiceCenter : NSObject

{
    NSMutableDictionary *m_dicService;
    NSRecursiveLock	*m_lock;
}

+ (TTServiceCenter *)defaultCenter;

/*
 * 获取服务对象
 * cls：必须继承自MMService，并实现协议MMService
 * 如果对象不存在，会自动创建一个
 */
- (id)getService:(Class)cls;

// 移除服务对象
- (void)removeService:(Class)cls;

// event
- (void)callEnterBackground;
- (void)callEnterForeground;
- (void)callAppWillResignActive;
- (void)callAppWillBecomeActive;
- (void)callTerminate;
- (void)callServiceMemoryWarning;
- (void)callClearData;
// 可继续添加 TODO

#define GET_SERVICE(obj) ((obj*)[[TTServiceCenter defaultCenter] getService:[obj class]])

#define REMOVE_SERVICE(obj) [[TTServiceCenter defaultCenter] removeService:[obj class]]


@end
