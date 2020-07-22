//
//  BDTFPSBar.m
//  Article
//
//  Created by pei yun on 2018/4/8.
//

#if INHOUSE

#import "BDTFPSBar.h"
#import <BDALog/BDAgileLog.h>
#import "TTDeviceHelper.h"
#import "UIViewAdditions.h"

#define default_timeConsumeLimit 0.3

@interface BDTFPSBar ()
{
    // fps
    CATextLayer *_fpsLayer;
    CADisplayLink *_displayLink;
    
    CFTimeInterval *_intervalArray; // 存储时间间隔的数组
    NSUInteger _intervalLength;
    
    NSUInteger _intervalCursor;
    CFTimeInterval _longestInterval;
    
    CFTimeInterval _lastInterval;
    CFTimeInterval _lastRefreshFPSInterval;
}

// time consum
@property (nonatomic, assign) NSTimeInterval timeConsumeStartTime;
@property (nonatomic, assign) CFRunLoopObserverRef observerRef;
@property (nonatomic, strong) CATextLayer *timeConsumeLayer;

@end

@implementation BDTFPSBar

#pragma mark life cycle

+ (instancetype)sharedInstance
{
    static BDTFPSBar *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BDTFPSBar alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    CGFloat top = 0;
    CGFloat safeTop = 0;
    if (@available(iOS 13.0 , *)) {
        safeTop = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
    } else if (@available(iOS 11.0, *)) {
        safeTop = self.tt_safeAreaInsets.top;
    }
    if (safeTop > 0) {
        top += safeTop;
    } else {
        if([[UIApplication sharedApplication] statusBarFrame].size.height > 0){
            top += [[UIApplication sharedApplication] statusBarFrame].size.height;
        }else{
            if([TTDeviceHelper isIPhoneXSeries]){
                top += 44;
            }else{
                top += 20;
            }
        }
    }
    self = [super initWithFrame:CGRectMake(0, 0, rect.size.width, top + 10)];
    if (self) {
        [self setWindowLevel:UIWindowLevelStatusBar + 1.0f];
        [self setBackgroundColor:[UIColor blackColor]];
    }
    return self;
}

- (void)dealloc
{
    [self closeFPS];
    [self closetimeConsume];
}

- (void)setHidden:(BOOL)hidden
{
    if (self.hidden != hidden) {
        [super setHidden:hidden];
        if (hidden) {
            [self closeFPS];
            [self closetimeConsume];
        } else {
            [self openFPS];
            [self opentimeConsume];
        }
    }
}

#pragma mark fps

- (void)openFPS
{
    if (!_fpsLayer) {
        _fpsLayer = [CATextLayer layer];
        [_fpsLayer setFrame:CGRectMake(5.0f, self.frame.size.height - 20, self.frame.size.width / 2 - 5, 20)];
        [_fpsLayer setFontSize:14.0f];
        [_fpsLayer setForegroundColor:[UIColor redColor].CGColor];
        [_fpsLayer setContentsScale:[UIScreen mainScreen].scale];
        _fpsLayer.isAccessibilityElement = YES;
        _fpsLayer.accessibilityLabel = @"fps";
        if ([_fpsLayer respondsToSelector:@selector(setDrawsAsynchronously:)]) {
            [_fpsLayer setDrawsAsynchronously:YES];
        }
        [self.layer addSublayer:_fpsLayer];
    }
    
    self.avgCount = 60 * 1;         // 1秒钟平均
    _refreshInterval = 0.5;         // 0.5秒刷新一次
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActiveNotification)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)closeFPS
{
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_intervalArray) {
        free(_intervalArray);
        _intervalArray = nil;
    }
    [_fpsLayer removeFromSuperlayer];
    _fpsLayer = nil;
    _intervalLength = 0;
    _intervalCursor = 0;
    _longestInterval = 0;
    _lastRefreshFPSInterval = 0;
}

- (void)setAvgCount:(NSUInteger)avgCount
{
    if (_intervalLength != avgCount) {
        if (_intervalArray) {
            free(_intervalArray);
            _intervalArray = nil;
        }
        _intervalLength = avgCount;
        _intervalArray = calloc(_intervalLength, sizeof(CFTimeInterval));
        _intervalCursor = 0;
        _longestInterval = 0;
        _lastRefreshFPSInterval = 0;
    }
}

- (void)displayLinkTick:(CADisplayLink *)displayLink
{
    if (_intervalArray == NULL || _intervalLength == 0) {
        return;
    }
    CFTimeInterval cuTime = CACurrentMediaTime();
    if (_lastInterval == 0) {
        _lastInterval = cuTime;
        return;
    }
    CFTimeInterval newInterval = cuTime - _lastInterval;
    _lastInterval = cuTime;
    if (newInterval > 1.0 || newInterval <= 0) {
        return;
    }
    
    if (_intervalCursor + 1 >= _intervalLength) {
        _longestInterval = 0;
        _intervalCursor = 0;
    } else {
        _intervalCursor++;
    }
    
    _intervalArray[_intervalCursor] = newInterval;
    _longestInterval = MAX(newInterval, _longestInterval);
    
    CFTimeInterval totalTime = 0;
    NSUInteger count = 0;
    for (int i = 0; i < _intervalLength; i++) {
        CFTimeInterval temp = _intervalArray[i];
        if (temp != 0) {
            totalTime += temp;
            count++;
        }
    }
    if (count == 0) {
        return;
    }
    CFTimeInterval avgDT = totalTime / count;
    NSString *text = [NSString stringWithFormat:@"fps-low:%2.f | fps-avg:%2.f", round(1.0 / _longestInterval), round(1.0 / avgDT)];
    if (_lastRefreshFPSInterval == 0) {
        [_fpsLayer setString:text];
        _lastRefreshFPSInterval = cuTime;
    } else {
        if (cuTime - _lastRefreshFPSInterval > _refreshInterval) {
            [_fpsLayer setString:text];
            _lastRefreshFPSInterval = cuTime;
        }
    }
}

- (void)applicationDidBecomeActiveNotification
{
    [_displayLink setPaused:NO];
}

- (void)applicationWillResignActiveNotification
{
    [_displayLink setPaused:YES];
}

#pragma mark timeConsume

- (void)opentimeConsume
{
    if (self.timeConsumeLimit == 0) {
        self.timeConsumeLimit = default_timeConsumeLimit;
    }
    if (!_timeConsumeLayer) {
        _timeConsumeLayer = [CATextLayer layer];
        _timeConsumeLayer.isAccessibilityElement = YES;
        _timeConsumeLayer.accessibilityLabel = @"timeConsume";
        [_timeConsumeLayer setFrame:CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.height)];
        [_timeConsumeLayer setFontSize:14.0f];
        [_timeConsumeLayer setForegroundColor:[UIColor whiteColor].CGColor];
        [_timeConsumeLayer setContentsScale:[UIScreen mainScreen].scale];
        [self.layer addSublayer:_timeConsumeLayer];
    }
    
    _timeConsumeStartTime = CACurrentMediaTime();
    
    __weak typeof(self) weakSelf = self;
    if (!_observerRef) {
        CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(NULL, kCFRunLoopBeforeWaiting | kCFRunLoopAfterWaiting, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
            if (activity == kCFRunLoopAfterWaiting) {
                weakSelf.timeConsumeStartTime = CACurrentMediaTime();
            } else if (activity == kCFRunLoopBeforeWaiting) {
                if (weakSelf.timeConsumeStartTime == 0) {
                    return;
                }
                NSTimeInterval now = CACurrentMediaTime();
                NSTimeInterval timeDiff = now - weakSelf.timeConsumeStartTime;
                if (timeDiff >= weakSelf.timeConsumeLimit) {
                    BDALOG_INFO(@"上一次操作耗时:%f秒", timeDiff);
                    NSString *text = [NSString stringWithFormat:@"操作耗时:%f秒", timeDiff];
                    [weakSelf.timeConsumeLayer setString:text];
                    if ([weakSelf.fpsDelegate respondsToSelector:@selector(FPSBarDidReceiveTimeConsumeInterval:)]) {
                        [weakSelf.fpsDelegate FPSBarDidReceiveTimeConsumeInterval:timeDiff];
                    }
                }
                weakSelf.timeConsumeStartTime = 0;
            } else {
                BDALOG_INFO(@"Runloop type:%lu", activity);
            }
        });
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
        _observerRef = observer;
    }
}

- (void)closetimeConsume
{
    if (_observerRef) {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observerRef, kCFRunLoopDefaultMode);
        CFRelease(_observerRef);
        _observerRef = nil;
    }
    [_timeConsumeLayer removeFromSuperlayer];
    _timeConsumeLayer = nil;
}

@end

#endif
