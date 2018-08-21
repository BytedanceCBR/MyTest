//
//  UIImage+LocalImageTracker.m
//  Article
//
//  Created by xushuangqing on 06/09/2017.
//

#import "TTLocalImageTracker.h"
#import "TTMonitorStartupTask.h"
#import <RSSwizzle.h>
#import <TTMonitor.h>
#import "SSCommonLogic.h"

@interface TTLocalImageTracker()
{
    dispatch_queue_t _trackQueue;
    NSMutableArray *_imagesBeforeMonitorLaunched;
}
@end

@implementation TTLocalImageTracker

+ (instancetype)sharedTracker {
    static TTLocalImageTracker *sharedTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTracker = [[TTLocalImageTracker alloc] init];
    });
    return sharedTracker;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup {
    if (![SSCommonLogic shouldTrackLocalImage]) {
        return;
    }
    
    _trackQueue = dispatch_queue_create("com.bytdance.localImage.tracker", DISPATCH_QUEUE_SERIAL);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(monitorInitializedNotification) name:TTDebugrealInitializedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    /* swizzle imageNamed:方法 */
    RSSwizzleClassMethod(UIImage,
                         @selector(imageNamed:),
                         RSSWReturnType(UIImage *),
                         RSSWArguments(NSString *name),
                         RSSWReplacement(
    {
        [[TTLocalImageTracker sharedTracker] trackLocalImageNamed:name];
        return RSSWCallOriginal(name);
    }));
}

- (void)appWillResignActive {
    /*app退后台*/
    dispatch_async(_trackQueue, ^{
        if (_imagesBeforeMonitorLaunched.count == 0) {
            return;
        }
        [[TTMonitor shareManager] trackService:@"tt_local_image_usage" value:@{@"names" : [_imagesBeforeMonitorLaunched copy]} extra:nil];
        [_imagesBeforeMonitorLaunched removeAllObjects];
    });
}

- (void)monitorInitializedNotification {
    /*端监控初始化完成*/
    dispatch_async(_trackQueue, ^{
        if (_imagesBeforeMonitorLaunched.count == 0) {
            return;
        }
        [[TTMonitor shareManager] trackService:@"tt_local_image_usage" value:@{@"names" : [_imagesBeforeMonitorLaunched copy]} extra:nil];
        [_imagesBeforeMonitorLaunched removeAllObjects];
    });
}

- (void)trackLocalImageNamed:(NSString *)name {
    if (isEmptyString(name)) {
        return;
    }
    dispatch_async(_trackQueue, ^{
        if (!_imagesBeforeMonitorLaunched) {
            _imagesBeforeMonitorLaunched = [[NSMutableArray alloc] init];
        }
        if (![TTMonitorStartupTask debugrealInitialized]) {
            [_imagesBeforeMonitorLaunched addObject:name];
        }
        else {
            [_imagesBeforeMonitorLaunched addObject:name];
            if ([_imagesBeforeMonitorLaunched count] >= 50) {
                [[TTMonitor shareManager] trackService:@"tt_local_image_usage" value:@{@"names" : [_imagesBeforeMonitorLaunched copy]} extra:nil];
                [_imagesBeforeMonitorLaunched removeAllObjects];
            }
        }
    });
}

@end
