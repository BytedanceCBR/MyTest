//
//  FHUGCGuideHelper.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kFHUGCGuideKey @"kFHUGCGuideKey"

#define kFHUGCShowFeedGuide @"kFHUGCShowFeedGuide"
#define kFHUGCShowFeedGuideCount @"kFHUGCShowFeedGuideCount"
#define kFHUGCShowSecondTabGuide @"kFHUGCShowSecondTabGuide"
#define kFHUGCShowSearchGuide @"kFHUGCShowSearchGuide"
#define kFHUGCShowUgcDetailGuide @"kFHUGCShowUgcDetailGuide"

@interface FHUGCGuideHelper : NSObject

//用于存储引导状态的设置
+ (NSDictionary *)ugcGuideSetting;
//是否需要显示feed中的引导
+ (BOOL)shouldShowFeedGuide;
//feed中引导显示次数+1
+ (void)addFeedGuideCount;
//设置feed引导不在显示
+ (void)hideFeedGuide;

+ (BOOL)shouldShowSecondTabGuide;

+ (void)hideSecondTabGuide;

+ (BOOL)shouldShowSearchGuide;

+ (void)hideSearchGuide;

+ (BOOL)shouldShowUgcDetailGuide;

+ (void)hideUgcDetailGuide;

@end

NS_ASSUME_NONNULL_END
