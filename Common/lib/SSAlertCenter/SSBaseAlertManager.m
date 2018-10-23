//
//  SSBaseAlert.m
//  Essay
//
//  Created by Tianhang Yu on 12-5-7.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "SSBaseAlertManager.h"
#import "SSAlertCenter.h"
#import "SSBaseAlertModel.h"
#import "TTNetworkManager.h"

@interface SSBaseAlertManager () <UIAlertViewDelegate> {
    
    BOOL _isConcurrency;
}

@property (nonatomic, strong) TTHttpTask *alertOperation;
@property (nonatomic, strong) NSTimer *delayRequestTimer;
@end

@implementation SSBaseAlertManager

@synthesize alertModels=_alertModels;
@synthesize isConcurrency=_isConcurrency;
@synthesize shouldAlertBlock = _shouldAlertBlock;
@synthesize alertOperation=_alertOperation;
@synthesize delayRequestTimer=_delayRequestTimer;

- (void)dealloc
{
    [_alertOperation cancel];
    [_delayRequestTimer invalidate];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.alertModels = [[NSMutableArray alloc] init];
        _isConcurrency = YES;
        
        self.shouldAlertBlock = ^(id context){
            return YES;
        };
    }
    return self;
}

#pragma mark - public

+ (id)alertManager
{
    // should be extended
    return nil;
}

- (void)startAlert
{
    [[SSAlertCenter defaultCenter] addAlert:self];
    
    if (_isConcurrency) {
        [self requestAlert];
    }
    else {
        NSArray *result = [self handleAlert:nil];
        if ([result count] > 0) {
            
            [_alertModels addObjectsFromArray:result];
            BOOL success = [[SSAlertCenter defaultCenter] refresh];
            
            if (!success) {
                [_alertModels removeObjectsInArray:result];
                if ([_alertModels count] == 0) {
                    [[SSAlertCenter defaultCenter] removeAlert:self];
                }
            }
        }
    }
}

- (void)startAlertAfterDelay:(NSTimeInterval)delay concurrency:(BOOL)isConcurrency
{
    _isConcurrency = isConcurrency;
    
    self.delayRequestTimer = [NSTimer scheduledTimerWithTimeInterval:delay
                                                         target:self 
                                                       selector:@selector(startAlert)
                                                       userInfo:nil
                                                        repeats:NO];
}

#pragma mark - extend methods

- (NSString *)urlPrefix
{
    // should be extended 
    return nil;
}

- (NSDictionary *)parameterDict
{
    // should be extended 
    return nil;
}

- (NSArray *)handleAlert:(NSDictionary *)result
{
    // should be extended
    // create alertModel
    return nil;
}

- (void)handleError:(NSError *)error
{
    // could be extended
}

- (void)clickedButtonAtIndex:(NSInteger)buttonIndex alertModel:(SSBaseAlertModel *)alertModel
{
    // should be extended
}

- (void)requestAlert
{
    NSString *urlPrefix = [self urlPrefix];
    
    if ([urlPrefix length] > 0) {
        if (_alertOperation) {
            [_alertOperation cancel];
        }
        
        WeakSelf;
        self.alertOperation = [[TTNetworkManager shareInstance] requestForJSONWithURL:urlPrefix params:[self parameterDict] method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
            StrongSelf;
            
            if (error) {
                [self handleError:error];
            }
            else {
                NSDictionary *dict = jsonObj;
                
                NSArray *result = [self handleAlert:dict];
                if ([result count] > 0) {
                    
                    [_alertModels addObjectsFromArray:result];
                    BOOL success = [[SSAlertCenter defaultCenter] refresh];
                    
                    if (!success) {
                        [_alertModels removeObjectsInArray:result];
                        if ([_alertModels count] == 0) {
                            [[SSAlertCenter defaultCenter] removeAlert:self];
                        }
                    }
                }
                
                // added by SF activity，获取是否为满足特定渠道的新用户，是则申请新人红包
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kAppAlertSuccessNotification" object:self userInfo:nil];
            }
        }];
    }
}

@end
