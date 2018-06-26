//
//  TTNetworkSettingTask.m
//  TTDemo
//
//  Created by jialei on 05/18/2018.
//  Copyright (c) 2018 jialei. All rights reserved.
//

#import "TTNetworkSettingTask.h"
#import "BDStartUpManager.h"

#if __has_include("TTNetworkManager.h")
#import "TTNetworkManager.h"
#endif

@implementation TTNetworkSettingTask

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
#if __has_include("TTNetworkManager.h")
//    [TTNetworkManager setLibraryImpl:TTNetworkManagerImplTypeLibChromium];
//
//    //初始化代码
//    [TTNetworkManager shareInstance].defaultJSONResponseSerializerClass = NSClassFromString(@"TTJSONResponseSerializer");
//    [TTNetworkManager shareInstance].defaultResponseModelResponseSerializerClass = NSClassFromString(@"TTResponseModelResponseSerializer");
//    [TTNetworkManager shareInstance].defaultBinaryResponseSerializerClass = NSClassFromString(@"TTBinaryResponseSerializer");
//    [[TTNetworkManager shareInstance] start];
#endif
}

@end

