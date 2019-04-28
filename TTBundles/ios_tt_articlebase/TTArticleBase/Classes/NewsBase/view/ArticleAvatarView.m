//
//  ArticleAvatarView.m
//  Article
//
//  Created by Zhang Leonardo on 13-1-22.
//
//

#import "ArticleAvatarView.h"
#import "NewsUserSettingManager.h"
#import "NetworkUtilities.h"
#import "TTUserSettings/TTUserSettingsManager+NetworkTraffic.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "ExploreExtenstionDataHelper.h"

@interface ArticleAvatarView()

@property(nonatomic, assign)TTNetworkTrafficSetting settingType;

@end
@implementation ArticleAvatarView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _alwaysShow = NO;
        _settingType = [TTUserSettingsManager networkTrafficSetting];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkTrafficSettingChanged:) name:kNetworkTrafficSettingChangedNotification object:nil];

    }
    return self;
}


- (void)networkTrafficSettingChanged:(NSNotification*)notification
{
    _settingType = [TTUserSettingsManager networkTrafficSetting];
    
    //ugly code暂时写这里
    if (_settingType == TTNetworkTrafficSave) {
        [ExploreExtenstionDataHelper saveUserSetNoImgMode:YES];
    }
    else {
        [ExploreExtenstionDataHelper saveUserSetNoImgMode:NO];
    }
}

- (BOOL)shouldShowImage
{
    BOOL result = NO;
    if (_alwaysShow)
    {
        result = YES;
    }
    else
    {
        result = TTNetworkWifiConnected() || (_settingType != TTNetworkTrafficSave) || [self cached];
    }
    
    return result;
}

@end
