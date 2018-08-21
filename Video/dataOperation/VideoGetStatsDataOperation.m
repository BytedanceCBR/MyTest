//
//  EssayGetStatsDataOperation.m
//  Essay
//
//  Created by 于天航 on 12-8-30.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoGetStatsDataOperation.h"
#import "ListDataHeader.h"
#import "VideoListDataHeader.h"
#import "SSOperation.h"
#import "VideoURLSetting.h"
#import "AccountManager.h"
#import "SSModelManager.h"
#import "VideoStatsModel.h"
#import "VideoData.h"
#import "OrderedVideoData.h"
#import "NetworkUtilities.h"

@interface VideoGetStatsDataOperation ()

@property (nonatomic, retain) SSHttpOperation *statsOperation;

@end


@implementation VideoGetStatsDataOperation

@synthesize statsOperation = _statsOperation;

- (void)dealloc
{
    [_statsOperation cancelAndClearDelegate];
    self.statsOperation = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.shouldExecuteBlock = ^(id dataContext){
            BOOL needGet = [[dataContext objectForKey:kVideoDataOperationGetStatsKey] boolValue];
            
            if(needGet)
            {
                if(!SSNetworkConnected())
                {
                    [dataContext setObject:[NSNumber numberWithBool:YES] forKey:kSSDataOperationLoadFinishedKey];
                    [self notifyWithData:nil
                                   error:[NSError errorWithDomain:kListDataErrorDomain code:kListDataNetworkError userInfo:nil]
                                userInfo:dataContext];
                    needGet = NO;
                }
                
            }
            
            return needGet;
        };
    }
    return self;
}

- (void)execute:(id)operationContext
{
    if (!self.shouldExecuteBlock(operationContext)) {
        [self executeNext:operationContext];
        return;
    }
    
    NSMutableString *groupIDString = [NSMutableString string];
    
    NSArray *dataList = [operationContext objectForKey:kSSDataOperationOriginalListKey];
    NSMutableArray *itemIDs = [NSMutableArray arrayWithCapacity:[dataList count]];
    for (VideoData *essay in dataList) {
        if (essay.groupID) {
            [itemIDs addObject:[essay.groupID stringValue]];
        }
        else {
            SSLog(@"groupID is nil");
        }
    }
    [itemIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [groupIDString appendString:obj];
        if (idx < [itemIDs count] - 1) {
            [groupIDString appendString:@"_"];
        }
    }];
    
//    NSLog(@"itemIDs string:%@", groupIDString);
    
    NSString *urlString = [VideoURLSetting getStatsURLString];
    
    NSMutableDictionary *getParams = [NSMutableDictionary dictionaryWithCapacity:5];
    [getParams setObject:[SSCommon getUniqueIdentifier] forKey:@"uuid"];
    
    if ([[AccountManager sharedManager] sessionKey]) {
        [getParams setObject:[[AccountManager sharedManager] sessionKey] forKey:@"session_key"];
    }
    
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithCapacity:5];
    [postParams setObject:groupIDString forKey:@"group_ids"];
    
    [_statsOperation cancelAndClearDelegate];
//    self.statsOperation = [SSHttpOperation httpOperationWithURLString:urlString
//                                                         getParameter:getParams
//                                                             userInfo:operationContext];
    
    self.statsOperation = [SSHttpOperation httpOperationWithURLString:urlString
                                                         getParameter:getParams
                                                        postParameter:postParams
                                                             userInfo:operationContext];
    
    [_statsOperation setFinishTarget:self selector:@selector(operation:result:error:userInfo:)];
    
    [SSOperationManager addOperation:_statsOperation];
}

- (BOOL)updateStats:(NSArray **)statsList
{
    BOOL hasDeadLink = NO;
    
    for (NSDictionary *statsDict in *statsList) {
        
        VideoStatsModel *stats = [[VideoStatsModel alloc] initWithDictionary:statsDict];
        
        NSError *videoError = nil;
        NSArray *videos = [[SSModelManager sharedManager] entitiesWithQuery:[NSDictionary dictionaryWithObject:stats.groupID forKey:@"groupID"]
                                                          entityDescription:[VideoData entityDescription]
                                                                      error:&videoError];
        if (!videoError && [videos count] > 0) {
            for (VideoData *video in videos) {
                
                video.userDigged = stats.userDigg;
                if ([stats.userRepin boolValue]) {
                    video.userRepined = stats.userRepin;
                }
                video.userBuried = stats.userBury;
                video.diggCount = stats.diggCount;
                video.buryCount = stats.buryCount;
                video.repinCount = stats.repinCount;
                video.commentCount = stats.commentCount;
                
                if (![stats.linkStatus boolValue] && [video.downloadDataStatus intValue] != VideoDownloadDataStatusHasDownload) {
                    
                    NSError *orderedVideoError = nil;
                    NSArray *orderedVideos = [[SSModelManager sharedManager] entitiesWithQuery:[NSDictionary dictionaryWithObject:video.groupID forKey:@"originalData.groupID"]
                                                                             entityDescription:[OrderedVideoData entityDescription]
                                                                                         error:&orderedVideoError];
                    if (!orderedVideoError && [orderedVideos count] > 0) {
                        
                        hasDeadLink = YES;
                        for (OrderedVideoData *orderedVideo in orderedVideos) {
                            orderedVideo.sortType = [NSNumber numberWithInt:DataSortTypeNone];
                            video.downloadDataStatus = [NSNumber numberWithInt:VideoDownloadDataStatusDeadLink];
                        }
                    }
                }
            }
        }
        
        [stats release];
    }
    
    [[SSModelManager sharedManager] save:nil];
    
    return hasDeadLink;
}


- (void)operation:(SSHttpOperation*)operation result:(NSDictionary*)result error:(NSError*)tError userInfo:(id)userInfo
{
    if (operation == _statsOperation) {
        if (tError) {
            SSLog(@"get stats error!");
            [userInfo setObject:[NSNumber numberWithBool:YES] forKey:kSSDataOperationLoadFinishedKey];
            NSError *newError = nil;
            
            if ([tError.domain isEqualToString:NetworkRequestErrorDomain]) {
                newError = [NSError errorWithDomain:kListDataErrorDomain code:kVideoListDataASINetworkError userInfo:nil];
            }
            else {
                newError = [NSError errorWithDomain:kListDataErrorDomain code:kListDataUnkownError userInfo:nil];
            }
            [self notifyWithData:nil error:newError userInfo:userInfo];
            self.hasFinished = YES;
        }
        else {
            NSArray *dataList = [[result objectForKey:@"result"] objectForKey:@"data"];
            BOOL hasDeadLink = [self updateStats:&dataList];
            [userInfo setObject:[NSNumber numberWithBool:YES] forKey:kSSDataOperationLoadFinishedKey];
            
            NSMutableDictionary *newUserInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
            [newUserInfo setObject:[NSNumber numberWithBool:hasDeadLink] forKey:kVideoDataOperationGetStatsHasDeadLinkKey];
            [self notifyWithData:nil error:tError userInfo:newUserInfo];
        }
    }
}

@end
