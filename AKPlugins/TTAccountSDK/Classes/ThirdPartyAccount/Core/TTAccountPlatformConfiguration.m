//
//  TTAccountPlatformConfiguration.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 13/12/2017.
//

#import "TTAccountPlatformConfiguration.h"
#import "TTAccountMacros.h"



@implementation TTAccountPlatformConfiguration

- (instancetype)init
{
    if ((self = [super init])) {
        _platformType       = -1;
        _useDefaultWAPLogin = YES;
        _tryCustomLoginWhenSDKFailure = YES;
        _snsBarHidden = NO;
        _bootOptimization = YES;
    }
    return self;
}

@end



#pragma mark - TTAccountCustomLoginConfiguration

@implementation TTAccountCustomLoginConfiguration

- (instancetype)init
{
    if ((self = [super init])) {
        _navBarBackgroundColor = [UIColor whiteColor];
        _navBarTintColor       = TTAccountUIColorFromHexRGB(0x464646);
        _navBarTitleTextColor  = TTAccountUIColorFromHexRGB(0x464646);
        _navBarBottomLineColor = TTAccountUIColorFromHexRGB(0xE8E8E8);
    }
    return self;
}

@end
