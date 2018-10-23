//
//  UIImage+TTThemeExtension.m
//  Zhidao
//
//  Created by Nick Yu on 15/1/26.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#import "UIImage+TTThemeExtension.h"
#import "TTThemeManager.h"
#import "TTBaseMacro.h"
#import "TTDeviceHelper.h"


#define nightModelSuffixStr @"_night"
#define explorePrefixStr @"ex_"

@implementation UIImage (TTThemeExtension)

- (instancetype)tt_themedImage {
    return self;
}

+ (instancetype)tt_themedImageForKey:(NSString *)key {
    return [[TTThemeManager sharedInstance_tt] themedImageForKey:key];
}

static NSMutableSet * noNightModeFileNameSet = nil;//保存没有夜间模式的图片的名字

+ (UIImage *)themedImageNamed:(NSString *)name
{
    if (isEmptyString(name)) {
        return nil;
    }
    
    NSString * fixedName = name;
    
    BOOL widthScreen = ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen]);
    
    NSString * (^ hdImageNamed)(NSString *, BOOL) = ^(NSString * name, BOOL nightMode){
        NSRange dot = [name rangeOfString:@"." options:NSBackwardsSearch];
        if (widthScreen) {
            NSString * prefix = name;
            NSString * suffix = @"";
            if (dot.location != NSNotFound) {
                prefix = [name substringToIndex:dot.location];
                suffix = [name substringFromIndex:dot.location + 1];
            }
            NSString * dayExtension = [TTDeviceHelper is667Screen] ? @"-667h":@"-736h";
            NSString * nightExtension = [TTDeviceHelper is667Screen] ? @"_night-667h":@"_night-736h";
            if ([suffix isEqualToString:@"png"]) {
                suffix = @"";
            }
            if (suffix.length > 0) {
                suffix = [@"." stringByAppendingString:suffix];
            }
            if (!nightMode) {
                return [NSString stringWithFormat:@"%@%@%@", prefix, dayExtension, suffix];
            }
            return [NSString stringWithFormat:@"%@%@%@", prefix, nightExtension, suffix];
        }
        return name;
    };
    
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        if (noNightModeFileNameSet == nil) {
            noNightModeFileNameSet = [[NSMutableSet alloc] initWithCapacity:100];
        }
        if ([noNightModeFileNameSet containsObject:fixedName]) {
            return [UIImage imageNamed:fixedName];
        }
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen]) {
            NSString * name = hdImageNamed(fixedName, YES);
            UIImage * image = [UIImage imageNamed:name];
            if (image) {
                [noNightModeFileNameSet addObject:name];
                return image;
            }
            name = hdImageNamed(fixedName, NO);
            image = [UIImage imageNamed:name];
            if (image) {
                [noNightModeFileNameSet addObject:name];
                return image;
            }
        }
        
        NSString * fileNameWithNightModelSuffix = [self fileNameAddNightModelSuffix:fixedName];
        
        UIImage * img = [UIImage imageNamed:fileNameWithNightModelSuffix];
        if (img != nil) {
            return img;
        }
        [noNightModeFileNameSet addObject:fixedName];
        return [UIImage imageNamed:fixedName];
        
    }
    else {//日间模式，及其他
        if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen]) {
            NSString * name = hdImageNamed(fixedName, NO);
            UIImage * image = [UIImage imageNamed:name];
            if (image) {
                return image;
            }
        }
        return [UIImage imageNamed:fixedName];
    }
    
    return nil;
}

#pragma mark - private

+ (NSString *)fileNameAddExploreModelPrefix:(NSString *)originName
{
    NSString * result = [NSString stringWithFormat:@"%@%@", explorePrefixStr, originName];
    return result;
}

+ (NSString * )fileNameAddNightModelSuffix:(NSString *)originName
{
    NSMutableString *resultName = [NSMutableString stringWithString:originName];
    
    NSRange lastPoint = [resultName rangeOfString:@"." options:NSBackwardsSearch];
    if(lastPoint.location != NSNotFound) {
        [resultName insertString:nightModelSuffixStr atIndex:lastPoint.location];
    } else {
        [resultName appendString:nightModelSuffixStr];
    }
    
    return resultName;
}


@end
