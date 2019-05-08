//
//  TTVResolutionStore.m
//  Article
//
//  Created by panxiang on 2017/5/25.
//
//

#import "TTVResolutionStore.h"
#import "NetworkUtilities.h"
static NSString *const kLastResolution = @"kLastResolution";
static NSString *const kUserSelected = @"kResolutionUserSelected"; // 用户手动选择

@implementation TTVResolutionStore
static TTVResolutionStore *resolutionStore;
+ (TTVResolutionStore *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        resolutionStore = [[TTVResolutionStore alloc] init];
    });

    return resolutionStore;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lastResolution = TTVPlayerResolutionTypeSD;
        _autoResolution = _lastResolution;
        if ([[NSUserDefaults standardUserDefaults] integerForKey:kLastResolution]) {
            _lastResolution = [[NSUserDefaults standardUserDefaults] integerForKey:kLastResolution];
        }
        
        _userSelected = [[NSUserDefaults standardUserDefaults] boolForKey:kUserSelected];
    }
    return self;
}

- (void)setLastResolution:(TTVPlayerResolutionType)lastResolution
{
    _lastResolution = lastResolution;
    [[NSUserDefaults standardUserDefaults] setInteger:lastResolution forKey:kLastResolution];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)forceSelected
{
    return _forceSelected && !TTNetworkWifiConnected() && TTNetworkConnected();
}

- (void)setUserSelected:(BOOL)userSelected {
    
    _userSelected = userSelected;
    
    [[NSUserDefaults standardUserDefaults] setBool:userSelected forKey:kUserSelected];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)reset
{
    _clarity_change_time = 0;
    _actual_clarity = TTVPlayerResolutionTypeUnkown;
    _resolutionAlertClick = NO;
}

- (NSString *)stringWithDefination:(TTVPlayerResolutionType)defination
{
    NSString *str = @"360P";
    if (defination == TTVPlayerResolutionTypeHD) {
        str = @"480P";
    } else if (defination == TTVPlayerResolutionTypeFullHD) {
        str = @"720P";
    }else if (defination == TTVPlayerResolutionTypeAuto) {
        str = @"AUTO";
    }
    return str;
}

- (NSString *)lastDefinationStr
{
    return [self stringWithDefination:[TTVResolutionStore sharedInstance].lastResolution];
}

- (NSString *)actualDefinationtr
{
    return [self stringWithDefination:self.actual_clarity];
}

@end
