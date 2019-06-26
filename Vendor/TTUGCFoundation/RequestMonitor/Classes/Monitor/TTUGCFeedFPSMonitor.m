//
//  TTUGCFeedFPSMonitor.m
//  Article
//
//  Created by 柴淞 on 18/5/17.
//
//

#import "TTUGCFeedFPSMonitor.h"
#import <TTBaseLib/TTBaseMacro.h>

@interface TTUGCFeedFPSMonitor ()

@property (nonatomic, strong) NSMutableArray<NSNumber *> *fpsArray;

@end

@implementation TTUGCFeedFPSMonitor {
    NSString *_currentCategoryName;
    NSTimeInterval _monitorTime;
    
    CADisplayLink *_link;
    NSUInteger _count;
    NSTimeInterval _lastTime;
}

- (instancetype)init {
    if (self) {
        self = [super init];
        _lastTime = 0;
        _count = 0;
        _monitorTime = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (NSMutableArray<NSNumber *> *)fpsArray {
    if (!_fpsArray) {
        _fpsArray = [NSMutableArray array];
    }
    return _fpsArray;
}

- (void)willDisplayCategory:(NSString *)categoryName {
    if (![NSThread isMainThread]) {
        return;
    }

    _currentCategoryName = categoryName;
    if (_link == nil && [self isEnabled]) {
        _lastTime = 0;
        _count = 0;
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)endDisplayCategory:(NSString *)categoryName {
    if ([_currentCategoryName isEqualToString:categoryName]) {
        [self stopMonitor];
    }
}

- (void)appWillResignActive {
    [self stopMonitor];
}

- (void)appDidBecomeActive {
    if ([self isEnabled] && !isEmptyString(_currentCategoryName) && _link == nil) {
        _lastTime = 0;
        _count = 0;
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopMonitor {
    if (_link) {
        [_link invalidate];
        _link = nil;
    }
    _lastTime = 0;
    _count = 0;
}

- (void)tick:(CADisplayLink *)link {
    if (isEmptyString(_currentCategoryName)) {
        [self stopMonitor];
        return;
    }
    
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    if (_monitorTime > self.duration) { // 时间太长自动停止
        [self monitorDidComplete];
        return;
    }
    
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    
    if (delta < 0.1) return;
    _lastTime = link.timestamp;
    float fps = _count / delta;
    _count = 0;
    _monitorTime += delta;
    
    if ([NSRunLoop currentRunLoop].currentMode == UITrackingRunLoopMode) {
        [self.fpsArray addObject:[NSNumber numberWithFloat:fps]];
    }
}

- (void)monitorDidComplete {
    if (self.completeBlock) {
        NSArray *fpsArray = [self.fpsArray copy];
        NSString *categoryName = _currentCategoryName;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSNumber *result = nil;
            if (fpsArray.count > self.minCount) {
                long long sum = 0;
                for (NSNumber *fps in fpsArray) {
                    sum += [fps intValue];
                }
                float finnalFps = sum / (float)fpsArray.count;
                //对于ipad pro，120帧率的，不上报
                if (finnalFps < 61) {
                    result = [NSNumber numberWithFloat:finnalFps];
                }
            }
            self.completeBlock(categoryName, result);
        });
    }

    [self stopMonitor];
    _fpsArray = nil;
    _monitorTime = 0;
    _currentCategoryName = nil;
}

- (BOOL)isEnabled {
#if DEBUG
    return NO;
#endif
    if (self.isEnable) {
        return self.isEnable(_currentCategoryName);
    }
    return NO;
}

@end


