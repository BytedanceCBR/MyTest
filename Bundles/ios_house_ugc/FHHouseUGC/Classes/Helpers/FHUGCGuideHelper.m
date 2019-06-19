//
//  FHUGCGuideHelper.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/19.
//

#import "FHUGCGuideHelper.h"

@implementation FHUGCGuideHelper

+ (NSDictionary *)ugcGuideSetting {
    NSDictionary *guideDic = [[NSUserDefaults standardUserDefaults] objectForKey:kFHUGCGuideKey];
    //设置初始值
    if(!guideDic){
        guideDic = @{
                     kFHUGCShowFeedGuide:@(1),
                     kFHUGCShowFeedGuideCount:@(0),
                     kFHUGCShowSecondTabGuide:@(1),
                     kFHUGCShowSearchGuide:@(1)
                     };
        [[NSUserDefaults standardUserDefaults] setObject:guideDic forKey:kFHUGCGuideKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return guideDic;
}

+ (BOOL)shouldShowFeedGuide {
    NSDictionary *guideDic = [self ugcGuideSetting];
    
    BOOL showFeedGuide = [guideDic[kFHUGCShowFeedGuide] boolValue];
    NSInteger showFeedGuideCount = [guideDic[kFHUGCShowFeedGuideCount] integerValue];
    
    if(!showFeedGuide || showFeedGuideCount > 3){
        return NO;
    }
    return YES;
}

+ (void)addFeedGuideCount {
    //显示以后次数加1
    NSDictionary *guideDic = [self ugcGuideSetting];
   
    NSMutableDictionary *dic = [guideDic mutableCopy];
    NSInteger showFeedGuideCount = [dic[kFHUGCShowFeedGuideCount] integerValue];
    showFeedGuideCount++;
    dic[kFHUGCShowFeedGuideCount] = @(showFeedGuideCount);
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kFHUGCGuideKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)hideFeedGuide {
    //设置key值为0
    NSDictionary *guideDic = [self ugcGuideSetting];
    
    NSMutableDictionary *dic = [guideDic mutableCopy];
    dic[kFHUGCShowFeedGuide] = @(0);
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kFHUGCGuideKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (BOOL)shouldShowSecondTabGuide {
    NSDictionary *guideDic = [self ugcGuideSetting];
    BOOL showGuide = [guideDic[kFHUGCShowSecondTabGuide] boolValue];
    if(!showGuide){
        return NO;
    }
    return YES;
}

+ (void)hideSecondTabGuide {
    //设置key值为0
    NSDictionary *guideDic = [self ugcGuideSetting];
    
    NSMutableDictionary *dic = [guideDic mutableCopy];
    dic[kFHUGCShowSecondTabGuide] = @(0);
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kFHUGCGuideKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
