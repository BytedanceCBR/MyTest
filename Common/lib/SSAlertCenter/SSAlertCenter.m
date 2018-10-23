//
//  SSAlertCenter.m
//  Essay
//
//  Created by Tianhang Yu on 12-5-7.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "SSAlertCenter.h"
#import "SSBaseAlertManager.h"
#import "SSBaseAlertModel.h"
#import "AppAlertModel.h"
#import "SSImageAlertView.h"
#import "TTDeviceHelper.h"

@interface SSAlertCenter ()<SSImageAlertViewDelegate> {
    BOOL _lockAlert;
}

@property (nonatomic, strong) NSMutableArray *alertViews;
@property (nonatomic, strong) NSMutableArray *alertManagers;
@property (nonatomic, strong) NSTimer *alertTimer;
@property (nonatomic, strong) SSBaseAlertModel *currentAlertModel;
@property (nonatomic, strong) SSBaseAlertManager *currentAlertManager;
@end


@implementation SSAlertCenter

@synthesize alertViews = _alertViews;
@synthesize alertManagers = _alertManagers;
@synthesize alertTimer=_alertTimer;
@synthesize currentAlertModel = _currentAlertModel;
@synthesize currentAlertManager = _currentAlertManager;

static SSAlertCenter *_defaultCenter = nil;

+ (SSAlertCenter *)defaultCenter
{
    @synchronized(self) {
        if (!_defaultCenter) {
            _defaultCenter = [[SSAlertCenter alloc] init];
        }
    }
    
    return _defaultCenter;
}

- (void)dealloc
{
    [_alertTimer invalidate];
}

- (id)init
{
    self = [super init];
    if (self) {
        _alertManagers = [[NSMutableArray alloc] init];
        self.alertViews = [[NSMutableArray alloc] init];
        _lockAlert = NO;
    }
    
    return self;
}

#pragma mark - private

- (void)clearAlert
{
    [_alertTimer invalidate];
    self.alertTimer = nil;
    
    if ([_alertManagers containsObject:_currentAlertManager]) {
        
        if ([_currentAlertManager.alertModels containsObject:_currentAlertModel]) {
            [_currentAlertManager.alertModels removeObject:_currentAlertModel];
        }
        
        if ([_currentAlertManager.alertModels count] == 0) {
            [[SSAlertCenter defaultCenter] removeAlert:_currentAlertManager];
        }
    }
    
    self.currentAlertManager = nil;
    self.currentAlertModel = nil;
    [self refresh];
}

- (void)showAlert
{
    SSBaseAlertModel *alertModel = _currentAlertModel;
    if (alertModel == nil) {
        return;
    }
    
    if([alertModel isKindOfClass:[AppAlertModel class]])
    {
        AppAlertModel *model = (AppAlertModel*)alertModel;
        if(!isEmptyString(model.imageURLString))
        {
            SSImageAlertView *alertView = [[SSImageAlertView alloc] init];
            alertView.alertModel = model;
            alertView.delegate = self;
            [alertView show];
            
            _lockAlert = YES;
            
            return;
        }
    }
    
    NSArray *buttonArray = [alertModel.buttons componentsSeparatedByString:@","];
    
    if([buttonArray count] > 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil     // add title in following code
                                                        message:alertModel.message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
        
        for (NSString *buttonTitle in buttonArray) {
            [alert addButtonWithTitle:buttonTitle];
        }
        
        if ([alertModel.title length] > 0) {
            [alert setTitle:alertModel.title];
        }
        
        [alert show];
        
        _lockAlert = YES;
        
        [_alertViews addObject:alert];
    }
}

- (void)startTimer
{
    [_alertTimer invalidate];
    self.alertTimer = nil;
    
    NSMethodSignature *signature = [self methodSignatureForSelector:@selector(showAlert)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:@selector(showAlert)];
    
    self.alertTimer = [NSTimer scheduledTimerWithTimeInterval:_currentAlertModel.delayTime.doubleValue
                                                   invocation:invocation
                                                      repeats:NO];
}

#pragma mark - public

- (void)pauseAlertCenter
{
    if (_alertTimer) {
        _lockAlert = YES;
        [_alertTimer invalidate];
        self.alertTimer = nil;
    }
}

- (void)resumeAlertCenter
{
    if (_lockAlert && !_alertTimer) {
        _lockAlert = NO;
        [self startTimer];
    }
}

- (BOOL)addAlert:(SSBaseAlertManager *)alert
{
    if (![_alertManagers containsObject:alert]) {
        [_alertManagers addObject:alert];        
        
        return YES;
    }
    
    return NO;
}

- (BOOL)removeAlert:(SSBaseAlertManager *)alert
{
    if (![_alertManagers containsObject:alert]) {
        [_alertManagers removeObject:alert];   
        
        return YES;
    }
    
    return NO;
}

- (BOOL)refresh
{
    if (!_lockAlert) {
        
        __block double delayTime = CGFLOAT_MAX;
        
        if ([_alertTimer isValid] && _currentAlertModel) {
            delayTime = _currentAlertModel.delayTime.doubleValue - [_alertTimer.fireDate timeIntervalSinceNow];
            
            SSLog(@"alert delay time:%f, alert time:%f", delayTime, [_alertTimer.fireDate timeIntervalSinceNow]);
        }
        
        __block BOOL needRestart = NO;
        __block NSUInteger tmpManagerIndex = 0;
        __block NSUInteger tmpModelIndex = 0;
        [_alertManagers enumerateObjectsUsingBlock:^(SSBaseAlertManager *manager, NSUInteger managerIndex, BOOL *managerStop){
            [manager.alertModels enumerateObjectsUsingBlock:^(SSBaseAlertModel *model, NSUInteger modelIndex, BOOL *modelStop){
                if (delayTime > model.delayTime.doubleValue ) {
                    if (manager.shouldAlertBlock(model)) {
                        needRestart = YES;
                        
                        tmpManagerIndex = managerIndex;
                        tmpModelIndex = modelIndex;
                        delayTime = model.delayTime.doubleValue;
                        
                        *modelStop = YES;
                        *managerStop = YES;
                    }
                }
            }];
        }];
        
        if (needRestart) {
            self.currentAlertManager = (SSBaseAlertManager *)[_alertManagers objectAtIndex:tmpManagerIndex];
            self.currentAlertModel = (SSBaseAlertModel *)[_currentAlertManager.alertModels objectAtIndex:tmpModelIndex];
            
            
            
            [self startTimer];
            
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        return NO;
    }
}

- (void)clearAllAlerts
{
    for (UIAlertView *alert in _alertViews) {
        [alert dismissWithClickedButtonIndex:0 animated:NO];
    }
    
    if ([_alertTimer isValid] && !_lockAlert) {
        // do nothing
    }
    else {
        [_alertTimer invalidate];
        self.alertTimer = nil;
        self.currentAlertModel = nil;
        self.currentAlertManager = nil;
        self.alertManagers = nil;
        
        if (_lockAlert) {
            _lockAlert = NO;
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_currentAlertManager clickedButtonAtIndex:buttonIndex alertModel:_currentAlertModel];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([_alertViews containsObject:alertView]) {
        [_alertViews removeObject:alertView];
    }
    
    _lockAlert = NO;
    [self clearAlert];
}

#pragma mark SSImageAlertViewDelegate
- (void)imageAlertView:(SSImageAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_currentAlertManager clickedButtonAtIndex:buttonIndex alertModel:_currentAlertModel];
    if ([_alertViews containsObject:alertView]) {
        [_alertViews removeObject:alertView];
    }
    
    _lockAlert = NO;
    [self clearAlert];
}

@end
