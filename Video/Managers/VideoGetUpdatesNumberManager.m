//
//  VideoGetUpdateNumberManager.m
//  Video
//
//  Created by 于 天航 on 12-8-16.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoGetUpdatesNumberManager.h"
#import "SSOperation.h"
#import "VideoURLSetting.h"
#import "ListDataHeader.h"
#import "AccountManager.h"

@interface VideoGetUpdatesNumberManager ()

@property (nonatomic, retain) SSHttpOperation *updatesOperation;
@property (nonatomic, retain) NSTimer *updateTimer;

@end


@implementation VideoGetUpdatesNumberManager

@synthesize delegate = _delegate;
@synthesize timestamps = _timestamps;
@synthesize updatesOperation = _updatesOperation;
@synthesize updateTimer = _updateTimer;

static VideoGetUpdatesNumberManager *_sharedManager;

+ (VideoGetUpdatesNumberManager *)sharedManager
{
    @synchronized(self) {
        if (!_sharedManager) {
            _sharedManager = [[VideoGetUpdatesNumberManager alloc] init];
        }
    }
    return _sharedManager;
}

- (void)dealloc
{
    [_updateTimer invalidate];
    self.updateTimer = nil;

    [_updatesOperation cancelAndClearDelegate];
    self.updatesOperation = nil;
    self.timestamps = nil;
    
    [super dealloc];
}

// get_updates
- (void)timingGetUpdatesNumber
{
    [self startgetUpdatesNumber];
    
    [_updateTimer invalidate];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:300
                                                        target:self
                                                      selector:@selector(startgetUpdatesNumber)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void)startgetUpdatesNumber
{
    if (_timestamps) {
        __block NSMutableString *timestampsString = [NSMutableString string];
        
        [_timestamps enumerateObjectsUsingBlock:^(NSDictionary *timestampDict, NSUInteger idx, BOOL *stop) {
            
            [timestampsString appendFormat:@"%@-%@", [timestampDict objectForKey:kVideoGetUpdatesTagKey], [timestampDict objectForKey:kVideoGetUpdatesTimestampKey]];
            if (idx < [_timestamps count] - 1) {
                [timestampsString appendString:@"|"];
            }
        }];
        
        NSString *urlString = [VideoURLSetting getUpdatesString];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
        
        [params setObject:[NSNumber numberWithInt:ListDataTypeVideo] forKey:@"item_type"];
        [params setObject:timestampsString forKey:@"tag_timestamp"];
        [params setObject:[SSCommon getUniqueIdentifier] forKey:@"uuid"];
        
        if ([[AccountManager sharedManager] sessionKey]) {
            [params setObject:[[AccountManager sharedManager] sessionKey] forKey:@"session_key"];
        }
        
        [_updatesOperation cancelAndClearDelegate];
        self.updatesOperation = [SSHttpOperation httpOperationWithURLString:urlString getParameter:params userInfo:nil];
        [_updatesOperation setFinishTarget:self selector:@selector(operation:result:error:userInfo:)];
        
        [SSOperationManager addOperation:_updatesOperation];
    }
}

- (void)operation:(SSHttpOperation*)operation result:(NSDictionary*)result error:(NSError*)tError userInfo:(id)userInfo
{
    if (operation == _updatesOperation) {
        
        NSDictionary *updateNumberList = nil;
        if (tError) {
            SSLog(@"get updates error!");
        }
        else {
            updateNumberList = [[[result objectForKey:@"result"] objectForKey:@"data"] objectForKey:@"updates"];
        }
        
        if (updateNumberList) {
            if (_delegate && [_delegate respondsToSelector:@selector(videoGetUpdatesNumberManager:didGetUpdatesNumber:error:)]) {
                [_delegate videoGetUpdatesNumberManager:self didGetUpdatesNumber:updateNumberList error:tError];
            }
        }
    }
}

@end


