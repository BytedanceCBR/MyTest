//
//  WDAccountService.m
//  TTWenda
//
//  Created by 延晋 张 on 2017/10/29.
//

#import "WDAccountService.h"

@implementation WDAccountService

+ (void)load
{
    [WDAccountService sharedInstance];
}

+ (instancetype)sharedInstance
{
    static WDAccountService *shareService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareService = [[WDAccountService alloc] init];
    });
    
    return shareService;
}

- (instancetype)init
{
    if (self = [super init]) {
        [TTAccount addMulticastDelegate:self];
    }
    return self;
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountLogout
{
    
}

@end
