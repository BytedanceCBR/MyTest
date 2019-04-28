//
//  TTMemoryMonitor.m
//  Article
//
//  Created by 冯靖君 on 16/10/18.
//
//
#import "TTMemoryMonitor.h"
#import <mach/mach.h>
#import "SSThemed.h"
#import "TTDeviceHelper.h"
#import "iConsole.h"
#import "TTSystemInfoManager.h"

static const CGFloat timerUpdateInterval = .5f;
static const CGFloat warningIncrease = 10.f;
static const CGFloat alertIncrease = 20.f;
@interface TTMemoryMonitorWindow : UIWindow
@end
@implementation TTMemoryMonitorWindow
- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.width, 20.f)];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar + 1;
        self.backgroundColor = [UIColor blackColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyBecomeKeyWindowNotification:) name:UIWindowDidBecomeKeyNotification object:nil];
        
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    self.frame = CGRectMake(0, 0, keyWindow.width, 20);
    self.rootViewController.view.frame = self.frame;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notifyBecomeKeyWindowNotification:(NSNotification *)notification
{
    if ([notification.object isEqual:self]) {
        [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
    }
}
@end
@implementation TTMemoryMonitor
static NSTimer *_innerTimer = nil;
static TTMemoryMonitorWindow *_innerMemoryMonitorWindow = nil;
static SSThemedLabel *_infoLabel = nil;
static CGFloat _lastUsage = 0;
+ (void)showMemoryMonitor
{
    if ([_innerTimer isValid]) {
        return;
    }
    if (!_innerMemoryMonitorWindow) {
        _innerMemoryMonitorWindow = [[TTMemoryMonitorWindow alloc] init];
        _innerMemoryMonitorWindow.windowLevel = UIWindowLevelStatusBar + 1;
        _innerMemoryMonitorWindow.rootViewController = [UIViewController new];
        _innerMemoryMonitorWindow.rootViewController.view.frame = _innerMemoryMonitorWindow.frame;
        _innerMemoryMonitorWindow.userInteractionEnabled = YES;
        _innerMemoryMonitorWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        [_innerMemoryMonitorWindow makeKeyAndVisible];
        UITapGestureRecognizer * tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
        [_innerMemoryMonitorWindow addGestureRecognizer:tapGest];
        _infoLabel = [[SSThemedLabel alloc] init];
        _infoLabel.frame = _innerMemoryMonitorWindow.frame;
        _infoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.font = [UIFont systemFontOfSize:13.f];
        _infoLabel.textColor = [UIColor greenColor];
        _infoLabel.numberOfLines = 1;
        [_innerMemoryMonitorWindow.rootViewController.view addSubview:_infoLabel];
    }
    [TTSystemInfoManager sharedInstance].sysInfoFlags = TTTopBarShowSysInfoMemory | TTTopBarShowSysInfoNetwork | TTTopBarShowSysInfoCPU;
    [[TTSystemInfoManager sharedInstance] startWithUpdateBlock:^(NSString *content) {
        [_infoLabel setText:content];
    }];
    
//    if ([[UIDevice currentDevice] systemVersion].floatValue < 10.f) {
//        _innerTimer = [NSTimer scheduledTimerWithTimeInterval:timerUpdateInterval target:self selector:@selector(updateInfoLabel) userInfo:nil repeats:YES];
//        [_innerTimer fire];
//    }
//    else {
//        _innerTimer = [NSTimer scheduledTimerWithTimeInterval:timerUpdateInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
//            [self updateInfoLabel];
//        }];
//    }
//    [[NSRunLoop mainRunLoop] addTimer:_innerTimer forMode:NSRunLoopCommonModes];
    [_innerMemoryMonitorWindow setHidden:NO];
}


+(void)click:(id)sender{
    [iConsole show];
}

+ (void)hideMemoryMonitor
{
    [_innerTimer invalidate];
    //如果开启内存监测则隐藏，使全屏旋转走新逻辑
    if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"kTTAppMemoryMonitorKey"]) {
        [_innerMemoryMonitorWindow setHidden:YES];
    }else{
        _innerMemoryMonitorWindow = nil;
    }
//    [_innerMemoryMonitorWindow setHidden:YES];
  //  _innerMemoryMonitorWindow = nil;
}
//推出全屏后，显示内存监测
+ (void)NoHideMemoryMonitor
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kTTAppMemoryMonitorKey"]) {
        [_innerMemoryMonitorWindow setHidden:NO];
    }
}

+ (CGFloat)currentMemoryUsageInMBytes {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if(kerr == KERN_SUCCESS) {
        CGFloat memInUseMBytes = info.resident_size / (1024.f * 1024.f);
        return memInUseMBytes;
    } else {
        return 0.0f;
    }
}

+ (NSString *)currentMemoryUsageByString
{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if(kerr == KERN_SUCCESS) {
        CGFloat memInUseMBytes = info.resident_size / (1024.f * 1024.f);
        NSString *showInfo = [NSString stringWithFormat:@"当前内存使用量 : %.1f m", memInUseMBytes];
        NSString *appendString = [self appendIncreasementInfo:memInUseMBytes];
        if (!isEmptyString(appendString)) {
            showInfo = [showInfo stringByAppendingString:appendString];
        }
        return showInfo;
    } else {
        return [NSString stringWithFormat:@"无法获取当前内存使用量，错误描述: %s", mach_error_string(kerr)];
    }
}
+ (NSString *)appendIncreasementInfo:(CGFloat)current
{
    NSString *infoString = nil;
    if (current - _lastUsage >= warningIncrease && current - _lastUsage < alertIncrease) {
        infoString = [NSString stringWithFormat:@"    \u2191%.1f m", current - _lastUsage];
        _infoLabel.textColor = [UIColor orangeColor];
    }
    else if (current - _lastUsage >= alertIncrease) {
        infoString = [NSString stringWithFormat:@"    \u2191%.1f m", current - _lastUsage];
        _infoLabel.textColor = [UIColor redColor];
    }
    else if (fabs(current - _lastUsage) >= .1f) {
        if (current > _lastUsage) {
            infoString = [NSString stringWithFormat:@"    \u2191%.1f m", current - _lastUsage];
            _infoLabel.textColor = [UIColor yellowColor];
        }
        else {
            infoString = [NSString stringWithFormat:@"    \u2193%.1f m", _lastUsage - current];
            _infoLabel.textColor = [UIColor greenColor];
        }
    }
    else {
        infoString = [NSString stringWithFormat:@"    --------"];
    }
    _lastUsage = current;
    return infoString;
}
+ (void)updateInfoLabel
{
    [_infoLabel setText:[self currentMemoryUsageByString]];
}

@end
