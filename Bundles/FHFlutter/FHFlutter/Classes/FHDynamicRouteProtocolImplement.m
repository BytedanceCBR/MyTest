//
//  DynamicRouteProtocolImplement.m
//  Runner
//
//  Created by 白昆仑 on 2019/8/21.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "FHDynamicRouteProtocolImplement.h"
#import <BDPackageManagerService.h>
#import <BDFlutterPackageManager.h>

@implementation FHDynamicRouteProtocolImplement

- (NSInteger)maxPackageCount {
    return 3;
}

- (void)validPackageWithName:(NSString *)name completion:(void(^)(id<PackageRoutePackageProtocol> _Nullable package))completion {
    if (completion) {
        id<PackageRoutePackageProtocol> package = (id<PackageRoutePackageProtocol>)[[BDFlutterPackageManager sharedInstance] validPackageWithName:name];
        completion(package);
    }
}

- (BOOL)isDynamicEngine {
    return [BDFlutterPackageManager sharedInstance].isEnginePackageMode;
}

- (NSString *)dynamicEnginePath {
    return [BDFlutterPackageManager sharedInstance].enginePackagePath;
}

@end
