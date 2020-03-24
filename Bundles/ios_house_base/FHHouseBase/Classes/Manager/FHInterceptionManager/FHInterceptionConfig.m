//
//  FHInterceptionConfig.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2020/3/24.
//

#import "FHInterceptionConfig.h"

@implementation FHInterceptionConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isContinue = YES;
        self.maxInterceptTime = 5.0f;
        self.compareTime = 1.0f;
        self.category = @{};
    }
    return self;
}

@end
