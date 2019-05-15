//
//  TTRNKitViewWrapper+Private.h
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/16.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTRNKitViewWrapper.h"

@interface TTRNKitViewWrapper (Private)
- (void)reloadData;
- (void)createWebViewOrFallbackForUrl:(NSString *)url resultType:(TTRNKitViewWraperResultType)resultType params:(NSDictionary *)params;
- (void)renderJsBundleSucceed;
- (void)reloadDataForDebugWith:(NSDictionary *)initParams bundleURL:(NSURL *)jsCodeLocation moduleName:(NSString *)moduleName;
@end
