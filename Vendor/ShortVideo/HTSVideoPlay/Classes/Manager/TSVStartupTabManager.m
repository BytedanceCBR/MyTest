//
//  TSVStartupTabManager.m
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/10/29.
//

#import "TSVStartupTabManager.h"
#import "TTSettingsManager.h"
#import <ReactiveObjC/ReactiveObjC.h>

/*
 两个策略：
 1.终止app的时候停留在tab或者详情页
 2.在tab里面浏览小视频或者进入个人主页等
 */

@interface TSVStartupTabManager()

@end

@implementation TSVStartupTabManager

static NSString * const kTSVStartupTabManagerFirstStrategyKey = @"kTSVStartupTabManagerFirstStrategyKey";
static NSString * const kTSVStartupTabManagerSecondStrategyKey = @"kTSVStartupTabManagerSecondStrategyKey";

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static TSVStartupTabManager *manager;
    
    dispatch_once(&onceToken, ^{
        manager = [[TSVStartupTabManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        [[[[[RACSignal combineLatest:@[RACObserve(self, shortVideoTabViewControllerVisibility), RACObserve(self, detailViewControllerVisibility)]
                             reduce:^id(NSNumber *shortVideoTabViewControllerVisibility, NSNumber *detailViewControllerVisibility){
                                 return @([shortVideoTabViewControllerVisibility boolValue] || [detailViewControllerVisibility boolValue]);
                             }]
            skip:1]
           distinctUntilChanged]
          filter:^BOOL(id value) {
              return !([UIApplication sharedApplication].applicationState == UIApplicationStateBackground);
          }]
         subscribeNext:^(NSNumber *value) {
             [[NSUserDefaults standardUserDefaults] setBool:[value boolValue] forKey:kTSVStartupTabManagerFirstStrategyKey];
             [[NSUserDefaults standardUserDefaults] synchronize];
         }];
        
        [[[RACObserve(self, inShortVideoTabViewController) skip:1]
          distinctUntilChanged]
         subscribeNext:^(NSNumber *value) {
            [[NSUserDefaults standardUserDefaults] setBool:[value boolValue] forKey:kTSVStartupTabManagerSecondStrategyKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }
    return self;
}

- (BOOL)shouldEnterShortVideoTabWhenStartup
{
    NSInteger strategy = [[[TTSettingsManager sharedManager] settingForKey:@"tt_short_video_default_tab" defaultValue:@0 freeze:YES] integerValue];
    
    if (strategy == 1) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:kTSVStartupTabManagerFirstStrategyKey];
    } else if (strategy == 2) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:kTSVStartupTabManagerSecondStrategyKey];
    } else {
        return NO;
    }
}

@end
