//
//  AWEVideoDetailFirstFrameConfig.m
//  Pods
//
//  Created by 王双华 on 2017/8/14.
//
//

#import "AWEVideoDetailFirstFrameConfig.h"

@implementation AWEVideoDetailFirstFrameConfig

static BOOL firstFrameEnabled;

+ (BOOL)firstFrameEnabled
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *key = @"kSSCommonLogicAWEVideoDetailFirstFrameKey";
        if ([[NSUserDefaults standardUserDefaults] objectForKey:key]) {
            NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            if ([value integerValue] == 1) {
                firstFrameEnabled = YES;
            } else {
                firstFrameEnabled = NO;
            }
        } else {
            firstFrameEnabled = YES;
        }
    });
    
    return firstFrameEnabled;
}

@end
