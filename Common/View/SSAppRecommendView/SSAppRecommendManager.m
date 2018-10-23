//
//  SSAppRecommendManager.m
//  Essay
//
//  Created by Dianwei on 12-9-4.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSAppRecommendManager.h"
#import "SSOperation.h"
#import "CommonURLSetting.h"
#import "SSCommonLogic.h"

#define kAppInfoStorageKey  @"kAppInfoStorageKey"

@interface SSAppRecommendManager()
@property(nonatomic, retain)SSHttpOperation *infoOperation;
@property(nonatomic, retain)SSHttpOperation *countOperation;
@end

@implementation SSAppRecommendManager
@synthesize delegate, infoOperation, countOperation;

- (void)dealloc
{
    [infoOperation cancelAndClearDelegate];
    self.infoOperation = nil;
    
    [countOperation cancelAndClearDelegate];
    self.countOperation = nil;
    self.delegate = nil;
    [super dealloc];
}


- (void)startGetAppInfo
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:kAppInfoStorageKey])
    {
        id result = [[NSUserDefaults standardUserDefaults] objectForKey:kAppInfoStorageKey];
        if(delegate)
        {
            [delegate appRecommendManager:self getInfoRequestFinishedWithResult:result finished:NO];
        }
    }
    
    [infoOperation cancelAndClearDelegate];
    self.infoOperation = [SSHttpOperation httpOperationWithURLString:[CommonURLSetting recommendAppInfoURLString] getParameter:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[SSCommon isJailBroken]] forKey:@"jailbroken"]];
    [infoOperation setFinishTarget:self selector:@selector(infoOperation:finishedResult:error:userInfo:)];
    [SSOperationManager addOperation:infoOperation];
}


- (void)infoOperation:(SSHttpOperation*)operation finishedResult:(NSDictionary*)result error:(NSError*)error userInfo:(id)userInfo
{    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setValue:error forKey:@"error"];
    if(!error)
    {
        [dict setValue:[[result objectForKey:@"result"] objectForKey:@"data"] forKey:@"result"];
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kAppInfoStorageKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    if(delegate)
    {
        [delegate appRecommendManager:self getInfoRequestFinishedWithResult:dict finished:YES];
    }
}

- (void)startGetStatusForApps:(NSArray*)appNames
{
    NSMutableString *names = [NSMutableString stringWithCapacity:10];
    NSString *sep = @"";
    
    for(NSString *name in appNames)
    {
        [names appendFormat:@"%@%@", sep, name];
        sep = @",";
    }
    
    
    [countOperation cancelAndClearDelegate];
    self.countOperation = [SSHttpOperation httpOperationWithURLString:[CommonURLSetting recommendAppAcountURLString] getParameter:[NSDictionary dictionaryWithObject:names forKey:@"app_names"]];
    [countOperation setFinishTarget:self selector:@selector(countOperation:finishedResult:error:userInfo:)];
    [SSOperationManager addOperation:countOperation];
}

- (void)countOperation:(SSHttpOperation*)operation finishedResult:(NSDictionary*)result error:(NSError*)error userInfo:(id)userInfo
{
    NSError *processedError = [SSCommonLogic handleError:error responseResult:result exceptionInfo:nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setValue:processedError forKey:@"error"];
    if(!processedError)
    {
        [dict setValue:[[result objectForKey:@"result"] objectForKey:@"data"] forKey:@"result"];
    }
    
    if(delegate)
    {
        [delegate performSelector:@selector(appRecommendManager:getStatusCountRequestFinishedWithResult:) withObject:self withObject:dict];
    }   
}

@end
