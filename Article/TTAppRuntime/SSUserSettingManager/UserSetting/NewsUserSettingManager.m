//
//  NewsUserSettingManager.m
//  Article
//
//  Created by Hu Dianwei on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsUserSettingManager.h"
#import "TTUserSettingsReporter.h"
#import "ExploreExtenstionDataHelper.h"
#import "SSCommonLogic.h"
#import "TTDeviceHelper.h"
#import <TTUsersettings/TTUserSettingsManager+FontSettings.h>

#define kForceLoadDataFromStartKey      @"kForceLoadDataFromStartKey"

#define kHasShownHelp                   @"kHasShownHelp"
#define kHasShownAutoRefresh            @"kHasShownAutoRefresh"
#define kCommentDisplaySettingKey       @"kCommentDisplaySettingKey"

static NSString *const kBrightnessStorageKey    = @"kBrightnessStorageKey";
static NSString *const kSystemBrightnessStorageKey = @"kSystemBrightnessStorageKey";

@implementation NewsUserSettingManager

static NewsUserSettingManager *s_manager;

+(id)sharedManager
{
    @synchronized(self)
    {
        if(!s_manager)
        {
            s_manager = [[NewsUserSettingManager alloc] init];
        }
        
        return s_manager;
    }
}

+ (void)setNeedLoadDataFromStart:(BOOL)fromStart
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:fromStart] forKey:kForceLoadDataFromStartKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)needLoadDataFromStart
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kForceLoadDataFromStartKey] boolValue];
}

+ (void)setHasShownHelp:(BOOL)shown
{
    [[NSUserDefaults standardUserDefaults] setBool:shown forKey:kHasShownHelp];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)hasShownHelp
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasShownHelp];
}

+ (BOOL)hasShownAutoRefresh
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasShownAutoRefresh];
}

+ (void)setHasShownAutoRefresh:(BOOL)shown
{
    [[NSUserDefaults standardUserDefaults] setBool:shown forKey:kHasShownAutoRefresh];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString*)settedFontShortString
{
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];
    NSString *result = @"m";
    switch (selectedIndex) {
        case TTFontSizeSettingTypeMin:
            result = @"s";
            break;
        case TTFontSizeSettingTypeNormal:
            result = @"m";
            break;
        case TTFontSizeSettingTypeBig:
            result = @"l";
            break;
        case TTFontSizeSettingTypeLarge:
            result = @"xl";
            break;
        default:
            break;
    }
    
    return result;
}


+ (NSArray*)fontSettings
{
    return [NSArray arrayWithObjects:NSLocalizedString(@"小", nil) ,NSLocalizedString(@"中", nil), NSLocalizedString(@"大", nil), NSLocalizedString(@"特大", nil), nil];
}

+ (CGFloat)fontSizeFromNormalSize:(CGFloat)normalSize isWidescreen:(BOOL)isWide
{
    CGFloat size;
    
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];
    switch (selectedIndex) {
        case TTFontSizeSettingTypeMin:
            size = normalSize - 2.f;
            break;
        case TTFontSizeSettingTypeNormal:
            size = normalSize;
            break;
        case TTFontSizeSettingTypeBig:
            size = normalSize + 2.f;
            break;
        case TTFontSizeSettingTypeLarge:
            size = normalSize + 5.f;
            break;
        default:
            size = normalSize;
            break;
    }
    
    if (isWide) {
        size += 1;
    }
    
    return size;
}

+ (float)settedEssayTextFontSize
{
    static float fontSizeArray[][4] = {
        {18.0f, 21.0f, 23.0f, 28.0f},
        {15.0f, 17.0f, 19.0f, 22.0f},
        {15.0f, 17.0f, 19.0f, 22.0f},
        {13.0f, 15.0f, 17.0f, 20.0f}
    };
    
    NSInteger type;
    
    if ([TTDeviceHelper isPadDevice]) {
        type = 0;//key = @"iPad";
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        type = 1;//key = @"iPhone667";
    } else if ([TTDeviceHelper is736Screen]) {
        type = 2;//key = @"iPhone736";
    } else {
        type = 3;//key = @"iPhone";
    }
    //NSArray *fonts = [fontSizes valueForKey:key];
    NSInteger index = 1;// 默认大
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];
    switch (selectedIndex) {
        case TTFontSizeSettingTypeMin:
            index = 0;
            break;
        case TTFontSizeSettingTypeNormal:
            index = 1;
            break;
        case TTFontSizeSettingTypeBig:
            index = 2;
            break;
        case TTFontSizeSettingTypeLarge:
            index = 3;
            break;
        default:
            break;
    }
    return fontSizeArray[type][index];
}

+ (float)settedEssayDetailViewTextFontSize{
    static float fontSizeArray[][4] = {
        {20.0f, 23.0f, 25.0f, 30.0f},
        {17.0f, 19.0f, 21.0f, 24.0f},
        {17.0f, 19.0f, 21.0f, 24.0f},
        {15.0f, 17.0f, 19.0f, 22.0f}
    };
    
    NSInteger type;
    
    if ([TTDeviceHelper isPadDevice]) {
        type = 0;//key = @"iPad";
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        type = 1;//key = @"iPhone667";
    } else if ([TTDeviceHelper is736Screen]) {
        type = 2;//key = @"iPhone736";
    } else {
        type = 3;//key = @"iPhone";
    }
    //NSArray *fonts = [fontSizes valueForKey:key];
    NSInteger index = 1;// 默认大
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];
    switch (selectedIndex) {
        case TTFontSizeSettingTypeMin:
            index = 0;
            break;
        case TTFontSizeSettingTypeNormal:
            index = 1;
            break;
        case TTFontSizeSettingTypeBig:
            index = 2;
            break;
        case TTFontSizeSettingTypeLarge:
            index = 3;
            break;
        default:
            break;
    }
    return fontSizeArray[type][index];
}

+ (float)settedEssayTextFontLineHeight
{
    static float lineHeightArray[][4] = {
        {24.0f, 27.0f, 29.0f, 34.0f},
        {21.0f, 23.0f, 25.0f, 28.0f},
        {21.0f, 23.0f, 25.0f, 28.0f},
        {19.0f, 21.0f, 23.0f, 26.0f}
    };
    
    NSInteger type;
    
    if ([TTDeviceHelper isPadDevice]) {
        type = 0;//key = @"iPad";
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        type = 1;//key = @"iPhone667";
    } else if ([TTDeviceHelper is736Screen]) {
        type = 2;//key = @"iPhone736";
    } else {
        type = 3;//key = @"iPhone";
    }
    //NSArray *fonts = [fontSizes valueForKey:key];
    NSInteger index = 1;// 默认大
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];
    switch (selectedIndex) {
        case TTFontSizeSettingTypeMin:
            index = 0;
            break;
        case TTFontSizeSettingTypeNormal:
            index = 1;
            break;
        case TTFontSizeSettingTypeBig:
            index = 2;
            break;
        case TTFontSizeSettingTypeLarge:
            index = 3;
            break;
        default:
            break;
    }
    return lineHeightArray[type][index];
}

+ (float)settedEssayDetailViewTextFontLineHeight{
    static float lineHeightArray[][4] = {
        {31.0f, 34.0f, 36.0f, 41.0f},
        {28.0f, 30.0f, 32.0f, 35.0f},
        {28.0f, 30.0f, 32.0f, 35.0f},
        {26.0f, 28.0f, 30.0f, 33.0f}
    };
    
    NSInteger type;
    
    if ([TTDeviceHelper isPadDevice]) {
        type = 0;//key = @"iPad";
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        type = 1;//key = @"iPhone667";
    } else if ([TTDeviceHelper is736Screen]) {
        type = 2;//key = @"iPhone736";
    } else {
        type = 3;//key = @"iPhone";
    }
    //NSArray *fonts = [fontSizes valueForKey:key];
    NSInteger index = 1;// 默认大
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];
    switch (selectedIndex) {
        case TTFontSizeSettingTypeMin:
            index = 0;
            break;
        case TTFontSizeSettingTypeNormal:
            index = 1;
            break;
        case TTFontSizeSettingTypeBig:
            index = 2;
            break;
        case TTFontSizeSettingTypeLarge:
            index = 3;
            break;
        default:
            break;
    }
    return lineHeightArray[type][index];
}


+ (float)settedMomentDiggCommentFontSize
{
    float result = 13;
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];
    switch (selectedIndex) {
        case TTFontSizeSettingTypeMin:
            result = 11;
            break;
        case TTFontSizeSettingTypeNormal:
            result = 13;
            break;
        case TTFontSizeSettingTypeBig:
            result = 15;
            break;
        case TTFontSizeSettingTypeLarge:
            result = 17;
        default:
            break;
    }
    
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        result += 1;
    }
    
    return result;
}

@end
