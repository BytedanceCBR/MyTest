//
//  TTDetailWebContainerDebugger.h
//  TTWebViewBundle
//
//  Created by muhuai on 2017/10/17.
//  Copyright © 2017年 muhuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TTRexxar/TTRexxarEngine.h>

@interface TTDetailWebContainerDebugger : NSObject

/**
 打开vConsole开关

 @param enable 开关
 */
+ (void)vConsoleEnable:(BOOL)enable;

/**
 vConsole是否打开

 @return 开关
 */
+ (BOOL)isvConsoleEnable;

/**
 注入vConsole

 @param engine 所在engine
 */
+ (void)injectvConsoleIfNeed:(id<TTRexxarEngine>)engine;

/**
 改变vConsole状态. 如果开则变为关, 反之亦然

 @param engine 所在engine
 */
+ (void)triggervConsoleIfNeed:(id<TTRexxarEngine>)engine;
@end
