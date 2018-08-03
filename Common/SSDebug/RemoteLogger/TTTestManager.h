//
//  TestManager.h
//  Article
//
//  Created by carl on 2017/4/9.
//
//

#import <Foundation/Foundation.h>

/**
    UIApplicationDidFinishLaunchingNotification 时加载 mainbundle中的testjson
    的配置文件，对App进行必要的修改工作。
    该模块 只添加到 NewsInhouse Target，不影响非内测版本。
    其他模块（非NewsInhouse）请勿添加对此模块的引用
 */
@interface TTTestManager : NSObject
+ (void)buildUpTest;
+ (void)tearDown;
@end
