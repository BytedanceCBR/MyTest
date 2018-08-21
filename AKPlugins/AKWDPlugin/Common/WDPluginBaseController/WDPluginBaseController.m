//
//  WDPluginBaseController.m
//  Article
//
//  Created by ZhangLeonardo on 16/1/5.
//
//

#import "WDPluginBaseController.h"

@interface WDPluginBaseController ()
{
    BOOL _isAppearing;
}

@property(nonatomic, assign)NSTimeInterval initTime;
@property(nonatomic, assign)NSTimeInterval appearTime;

@end

@implementation WDPluginBaseController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];

    [self trySendPageStayTime];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.initTime = [[NSDate date] timeIntervalSince1970];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    }
    return self;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _isAppearing = YES;
    
    self.appearTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _isAppearing = NO;
    [self trySendCurrentPageStayTime];
}

- (void)trySendCurrentPageStayTime
{
    if (_appearTime == 0) {//当前页面没有在展示过
        return;
    }
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval duration = (now - _appearTime) * 1000.0;
    if (duration <= 200) {//低于200毫秒，忽略
        self.appearTime = 0;
        return;
    }
    [self _sendCurrentPageStayTime:duration];
    self.appearTime = 0;
}

- (void)trySendPageStayTime
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval duration = (now - _initTime) * 1000.0;
    if (_initTime == 0 || duration <= 200) {//低于200毫秒， 忽略
        return;
    }
    [self _sendPageStayTime:duration];
}


- (void)_sendCurrentPageStayTime:(NSTimeInterval)duration
{
    //subview implements
}

- (void)_sendPageStayTime:(NSTimeInterval)duration
{
    //subview implements
}

#pragma mark -- notification

- (void)_willEnterForeground:(NSNotification *)notification
{
    if (_isAppearing) {
        self.appearTime = [[NSDate date] timeIntervalSince1970];
    }
    self.initTime = [[NSDate date] timeIntervalSince1970];
}

- (void)_didEnterBackground:(NSNotification *)notification
{
    [self trySendCurrentPageStayTime];
    [self trySendPageStayTime];
}

@end
