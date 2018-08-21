//
//  VideoDownloadsManager.m
//  Video
//
//  Created by Tianhang Yu on 12-7-25.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoDownloadDataManager.h"
#import "SSModelManager.h"
#import "VideoData.h"
#import "VideoDownloaderManager.h"
#import "VideoDownloader.h"
#import "M3U8Parser.h"
#import "NetworkUtilities.h"
#import "M3U8VideoDownloader.h"
#import "MP4VideoDownloader.h"
#import "VIdeoMainViewController.h"
#import "ASIHTTPRequest.h"
#import "SSOperation.h"
#import "VideoURLSetting.h"
#import "VideoActivityIndicatorView.h"
#import "NetworkUtilities.h"
#import "VideoHistoryManager.h"
#import "AccountManager.h"

#define kRedirectConnectionUserInfoDownloadIndexKey @"kRedirectConnectionUserInfoDownloadIndexKey"


@interface VideoURLConnection : NSURLConnection
@property (nonatomic, retain) id userInfo;
@end

@implementation VideoURLConnection
@synthesize userInfo;
@end


static VideoDownloadDataManager *_sharedManager = nil;

@interface VideoDownloadDataManager () <VideoDownloaderProtocol, NSURLConnectionDataDelegate> {
    
    NSUInteger _currentDownloadIndex;
    BOOL _hasBrokenLinkRetry;
}

@property (nonatomic, retain) VideoDownloader *startDownloader;
@property (nonatomic, retain) VideoDownloader *stopDownloader;
@property (nonatomic, retain) VideoDownloader *removeDownloader;
@property (nonatomic, retain) NSArray *dataList;
@property (nonatomic, retain) NSArray *downloadingDataList;
@property (nonatomic, retain) NSMutableArray *waitingDataList;
@property (nonatomic, readwrite) VideoDownloadDataListType dataListType;
@property (nonatomic, readwrite) BOOL downloading;
@property (nonatomic, readwrite) BOOL batchStarted;

@property (nonatomic, retain) SSHttpOperation *feedbackOperation;
@property (nonatomic, retain) VideoURLConnection *redirectConn;

@end


@implementation VideoDownloadDataManager

@synthesize startDownloader = _startDownloader;
@synthesize stopDownloader = _stopDownloader;
@synthesize removeDownloader = _removeDownloader;

@synthesize delegate = _delegate;
@synthesize dataList = _dataList;
@synthesize downloadingDataList = _downloadingDataList;
@synthesize waitingDataList = _waitingDataList;
@synthesize dataListType = _dataListType;
@synthesize downloading = _downloading;
@synthesize batchStarted = _batchStarted;

@synthesize feedbackOperation = _feedbackOperation;
@synthesize redirectConn = _redirectConn;

+ (VideoDownloadDataManager *)sharedManager
{
    @synchronized(self) {
        if (_sharedManager == nil) {
            _sharedManager = [[VideoDownloadDataManager alloc] init];
        }
        return _sharedManager;
    }
}

- (void)dealloc
{
    self.delegate = nil;
    self.startDownloader = nil;
    self.removeDownloader = nil;
    self.dataList = nil;
    self.downloadingDataList = nil;
    self.waitingDataList = nil;
    
    [_feedbackOperation cancelAndClearDelegate];
    self.feedbackOperation = nil;
    self.redirectConn = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _currentDownloadIndex = 0;
        _downloading = NO;
        _batchStarted = videoDownloadDataManagerBatchStarted();
        _hasBrokenLinkRetry = NO;
    }
    return self;
}

+ (NSUInteger)downloadTabCount
{
    NSMutableArray *queries = [NSMutableArray arrayWithCapacity:5];
    NSArray *results = nil;
    NSError *error = nil;
    
    NSArray *statusList = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:VideoDownloadDataStatusWaiting],
                           [NSNumber numberWithInt:VideoDownloadDataStatusDownloading],
                           nil];
    
    for (NSNumber *status in statusList) {
        NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:5];
        [query setObject:[NSNumber numberWithBool:YES] forKey:@"userDownloaded"];
        [query setObject:status forKey:@"downloadDataStatus"];
        [queries addObject:query];
    }
   
    results = [[SSModelManager sharedManager] entitiesWithQueries:queries
                                                entityDescription:[VideoData entityDescription]
                                                            error:&error];
    
    if (!error) {
        SSLog(@"downloading count:%d", [results count]);
        return [results count];
    }
    else {
        return 0;
    }
}

#pragma mark - feedback

- (void)videoFeedbackFailed:(VideoFeedbackFailedType)type video:(VideoData *)video
{
    NSUInteger failType = 0;
    switch (type) {
        case VideoFeedbackFailedTypeDownloadFailed:
            failType = 0;
            break;
        case VideoFeedbackFailedTypePlayFailed:
            failType = 1;
            break;
        default:
            break;
    }
    
    NSString *urlString = [VideoURLSetting videoFailedFeedbackURLString];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:video.groupID forKey:@"id"];
    [params setObject:video.downloadURL forKey:@"url"];
    [params setObject:[SSCommon OSVersion] forKey:@"os_version"];
    [params setObject:[SSCommon deviceType] forKey:@"device_type"];
    [params setObject:[SSCommon appName] forKey:@"app_name"];
    [params setObject:[SSCommon versionName] forKey:@"version_code"];
    [params setObject:getCurrentChannel() forKey:@"channel"];
    [params setObject:[SSCommon getUniqueIdentifier] forKey:@"uuid"];
    [params setObject:[SSCommon connectMethodName] forKey:@"network_type"];
    [params setObject:[NSNumber numberWithInt:failType] forKey:@"fail_type"];
    [params setObject:[SSCommon platformName] forKey:@"device_platform"];
    
    [_feedbackOperation cancelAndClearDelegate];
    self.feedbackOperation = nil;
    self.feedbackOperation = [SSHttpOperation httpOperationWithURLString:urlString getParameter:nil postParameter:params];
    [_feedbackOperation setFinishTarget:self selector:@selector(operation:result:error:userInfo:)];
    [SSOperationManager addOperation:_feedbackOperation];
    
    // use alt url
    if ([video.altDownloadURL length] > 0 && video.altFormat) {
        video.downloadURL = video.altDownloadURL;
        video.format = video.altFormat;
        [[SSModelManager sharedManager] save:nil];
    }
}

- (void)operation:(SSHttpOperation*)operation result:(NSDictionary*)result error:(NSError*)tError userInfo:(id)userInfo
{
    if (operation == _feedbackOperation) {
        if (tError) {
            SSLog(@"feedback error!");
        }
    }
}

#pragma mark - WaitingList

- (void)reloadWaitingDataList
{
    NSMutableArray *queries = [NSMutableArray arrayWithCapacity:5];
    
    NSArray *statusList = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:VideoDownloadDataStatusWaiting],
                           [NSNumber numberWithInt:VideoDownloadDataStatusDownloading],
                           nil];
    
    for (NSNumber *status in statusList) {
        NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithBool:YES], @"userDownloaded",
                               status, @"downloadDataStatus",
                               nil];
        [queries addObject:query];
    }
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"downloadTime" ascending:YES];
    NSError *error = nil;
    
    NSArray *results = [[SSModelManager sharedManager] entitiesWithQueries:queries
                                                       entityDescription:[VideoData entityDescription]
                                                              unFaulting:NO
                                                                  offset:0
                                                                   count:NSUIntegerMax
                                                         sortDescriptors:[NSArray arrayWithObject:sd]
                                                                   error:&error];

    if (!error) {
        self.waitingDataList = [[results mutableCopy] autorelease];
        
        NSUInteger idx = 0;
        
        for (VideoData *video in _waitingDataList) {
            if ([video.downloadDataStatus intValue] == VideoDownloadDataStatusDownloading) {
                _currentDownloadIndex = idx;
                break;
            }
            idx ++;
        }
    }
}

#pragma mark - DataList

- (void)startGetDownloadDataListByType:(VideoDownloadDataListType)dataListType
{
    self.dataListType = dataListType;
    
    NSMutableArray *queries = [NSMutableArray arrayWithCapacity:5];
    NSArray *results = nil;
    NSError *error = nil;
    
    switch (dataListType) {

        case VideoDownloadDataListTypeDownloading:
        {
            NSArray *statusList = [NSArray arrayWithObjects:
                                   [NSNumber numberWithInt:VideoDownloadDataStatusWaiting],
                                   [NSNumber numberWithInt:VideoDownloadDataStatusDownloading],
                                   [NSNumber numberWithInt:VideoDownloadDataStatusPaused],
                                   [NSNumber numberWithInt:VideoDownloadDataStatusDownloadFailed],
                                   [NSNumber numberWithInt:VideoDownloadDataStatusDeadLink],
                                   nil];
            
            for (NSNumber *status in statusList) {
                NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:5];
                [query setObject:[NSNumber numberWithBool:YES] forKey:@"userDownloaded"];
                [query setObject:status forKey:@"downloadDataStatus"];
                [queries addObject:query];
            }
        }
            break;
        case VideoDownloadDataListTypeHasDownload:
        {
            NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:5];
            [query setObject:[NSNumber numberWithBool:YES] forKey:@"userDownloaded"];
            [query setObject:[NSNumber numberWithInt:VideoDownloadDataStatusHasDownload] forKey:@"downloadDataStatus"];
            [queries addObject:query];
        }
            break;
            
        default:
            break;
    }
    
    results = [[SSModelManager sharedManager] entitiesWithQueries:queries
                                                entityDescription:[VideoData entityDescription]
                                                            error:&error];
    
    if (!error) {
        if (_dataListType == VideoDownloadDataListTypeDownloading) {
            NSSortDescriptor *downloadTime = [NSSortDescriptor sortDescriptorWithKey:@"downloadTime" ascending:YES];
            
            self.downloadingDataList = [results sortedArrayUsingDescriptors:[NSArray arrayWithObject:downloadTime]];
            self.dataList = [results sortedArrayUsingDescriptors:[NSArray arrayWithObject:downloadTime]];
        }
        else if (_dataListType == VideoDownloadDataListTypeHasDownload) {
            NSSortDescriptor *hasReadSd = [NSSortDescriptor sortDescriptorWithKey:@"hasRead" ascending:YES];
            NSSortDescriptor *downloadTime = [NSSortDescriptor sortDescriptorWithKey:@"downloadTime" ascending:NO];
            
            self.dataList = [results sortedArrayUsingDescriptors:[NSArray arrayWithObjects:hasReadSd, downloadTime, nil]];
        }
    }
    
    if (_delegate) {
        [_delegate downloadManager:self
       didReceivedDownloadDataList:_dataList
                      dataListType:_dataListType
                             error:error];
    }
}

#pragma mark - download actions

- (void)currentDownloadStart
{
    if (!_waitingDataList) {
        [self reloadWaitingDataList];
    }
    
    if ([_waitingDataList count] > 0) {
        if (_currentDownloadIndex >= [_waitingDataList count]) {
            _currentDownloadIndex = 0;
        }
        
        [self downloadStartAtIndex:_currentDownloadIndex];
    }
}

//- (void)nextDownloadStart
//{
//    _currentDownloadIndex ++;
//    [self currentDownloadStart];
//}

- (void)downloadStartAtIndex:(NSUInteger)index
{
    if (!_waitingDataList) {
        [self reloadWaitingDataList];
    }
    
    if (_downloading) {
        [self currentDownloadStop];
    }
    
    if ([_waitingDataList count] > index) {
        
        _downloading = YES;
        
        VideoData *video = [_waitingDataList objectAtIndex:index];
        
        if ([video.downloadDataStatus intValue] == VideoDownloadDataStatusDownloading
            || [video.downloadDataStatus intValue] == VideoDownloadDataStatusWaiting) {
            
            if (!SSNetworkConnected()) {
                [[VideoActivityIndicatorView sharedView] showWithMessage:@"没有网络连接" duration:0.5f];
            }
            else if (!SSNetworkWifiConnected() && notWifiAlertOn()) {
                [[VideoActivityIndicatorView sharedView] showWithMessage:@"您正在移动网络下载视频,将消耗较大流量" duration:0.5f];
            }
            
            if ([video.downloadDataStatus intValue] == VideoDownloadDataStatusWaiting) {
                video.downloadDataStatus = [NSNumber numberWithInt:VideoDownloadDataStatusDownloading];
                [[SSModelManager sharedManager] save:nil];
            }
            
            NSMutableString *downloadURLString = [[[SSCommon customURLStringFromString:video.downloadURL] mutableCopy] autorelease];
            [downloadURLString appendString:@"&action=download"];
            if ([[AccountManager sharedManager] loggedIn]) {
                [downloadURLString appendFormat:@"&session_key=%@", [[AccountManager sharedManager] sessionKey]];
            }
            self.redirectConn = [[[VideoURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:
                                                                             [NSURL URLWithString:[downloadURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]
                                                                    delegate:self] autorelease];
            _redirectConn.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:index]
                                                                 forKey:kRedirectConnectionUserInfoDownloadIndexKey];
        }
    }
}

- (void)currentDownloadStop
{
    if (_downloading) {
        if (!_waitingDataList) {
            [self reloadWaitingDataList];
        }
        
        VideoData *video = [_waitingDataList objectAtIndex:_currentDownloadIndex];
        video.downloadDataStatus = [NSNumber numberWithInt:VideoDownloadDataStatusWaiting];
        [[SSModelManager sharedManager] save:nil];
        
        self.stopDownloader = _startDownloader;
        [_stopDownloader stop];
        _downloading = NO;
        _hasBrokenLinkRetry = NO;
    }
}

- (void)currentDownloadRemove
{
    if (_downloading) {
        if (!_waitingDataList) {
            [self reloadWaitingDataList];
        }
        
        self.removeDownloader = _startDownloader;
        [_removeDownloader remove];
        _downloading = NO;
    }
}

- (void)handleHeaderField:(NSHTTPURLResponse *)response atIndex:(int)index
{
    VideoData *video = [_waitingDataList objectAtIndex:index];
    NSDictionary *headerFields = [response allHeaderFields];
    NSString *ffContentType = [headerFields objectForKey:VideoDownloadURLHeaderFFContentType];
    if ([ffContentType isEqualToString:VideoDownloadURLHeaderFFContentTypeMP4]
        && ![video.format isEqualToString:VideoDataFormatMP4])
    {
        video.format = VideoDataFormatMP4;
        [[SSModelManager sharedManager] save:nil];
        SSLog(@"format change to mp4 when download");
    }
    else if ([ffContentType isEqualToString:VideoDownloadURLHeaderFFContentTypeM3U8]
             && ![video.format isEqualToString:VideoDataFormatM3U8])
    {
        video.format = VideoDataFormatM3U8;
        [[SSModelManager sharedManager] save:nil];
        SSLog(@"format change to m3u8 when download");
    }
}

- (void)downloadAfterRedirectAtIndex:(int)index
{
    VideoData *video = [_waitingDataList objectAtIndex:index];
    
    VideoDownloader *downloader = nil;
    if ([video.format isEqualToString:VideoDataFormatM3U8]) {
        downloader = [VideoDownloaderManager downloaderForType:VideoDownloaderTypeM3U8 video:video];
    }
    else if ([video.format isEqualToString:VideoDataFormatMP4]) {
        downloader = [VideoDownloaderManager downloaderForType:VideoDownloaderTypeMP4 video:video];
    }
    
    if (downloader) {
        self.startDownloader = downloader;
        downloader.delegate = self;
        [downloader start];
    }
}

#pragma mark - NSURLConnectionDataDelegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if ([connection isKindOfClass:[VideoURLConnection class]]) {
        int index = [[((VideoURLConnection *)connection).userInfo objectForKey:kRedirectConnectionUserInfoDownloadIndexKey] intValue];
        if (response) {
            NSMutableURLRequest *redirectRequest = [[request mutableCopy] autorelease]; // original request
            [self handleHeaderField:(NSHTTPURLResponse *)response atIndex:index];
            [redirectRequest setURL:[request URL]];
            [self downloadAfterRedirectAtIndex:index];
            [connection cancel];
            
            return redirectRequest;
        }
        else {
            return request;
        }
    }
    else {
        return request;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([connection isKindOfClass:[VideoURLConnection class]]) {
        int index = [[((VideoURLConnection *)connection).userInfo objectForKey:kRedirectConnectionUserInfoDownloadIndexKey] intValue];
        [self downloadAfterRedirectAtIndex:index];
        [connection cancel];
    }
}

#pragma mark - batch control actions

- (void)batchStart
{
    if (_batchStarted) {
        return;
    }
    
    if (!_downloadingDataList) {
        [self startGetDownloadDataListByType:VideoDownloadDataListTypeDownloading];
    }
    
    for (VideoData *video in _downloadingDataList) {
        [self startWithVideoData:video sync:NO];
    }
    
    [self reloadWaitingDataList];
    [self currentDownloadStart];
    
    _batchStarted = YES;
    setVideoDownloadDataManagerBatchStarted(_batchStarted);
}

- (void)batchStop
{
    if (_batchStarted) {
        
        if (_downloadingDataList) {
            [self startGetDownloadDataListByType:VideoDownloadDataListTypeDownloading];
        }
        
        [self currentDownloadStop];
        
        for (VideoData *video in _downloadingDataList) {
            [self stopWithVideoData:video sync:NO];
        }
        
        [self reloadWaitingDataList];
        
        _batchStarted = NO;
        setVideoDownloadDataManagerBatchStarted(_batchStarted);
    }
}

#pragma mark - control actions

- (void)startWithVideoData:(VideoData *)video sync:(BOOL)sync
{
    if ([video.userDownloaded boolValue] == NO) {
        [self addDownloadData:video];
    }
    
    if ([video.downloadDataStatus intValue] == VideoDownloadDataStatusPaused
        || [video.downloadDataStatus intValue] == VideoDownloadDataStatusDownloadFailed) {
        
        video.downloadDataStatus = [NSNumber numberWithInt:VideoDownloadDataStatusWaiting];
        [[SSModelManager sharedManager] save:nil];
    }
    
    [[VideoHistoryManager sharedManager] addHistory:video];
    
    if (sync) {
        [self reloadWaitingDataList];
        
        if (!_downloading) {
            [self currentDownloadStart];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VideoDownloadTabUpdateBadgeNotification object:nil];
    }
}

- (void)stopWithVideoData:(VideoData *)video sync:(BOOL)sync
{
    if ([video.downloadDataStatus intValue] == VideoDownloadDataStatusDownloading
        || [video.downloadDataStatus intValue] == VideoDownloadDataStatusWaiting) {
        
        BOOL isDownloadingVideo = NO;
        
        if ([video.downloadDataStatus intValue] == VideoDownloadDataStatusDownloading) {
            isDownloadingVideo = YES;
            [self currentDownloadStop];
        }
        
        video.downloadDataStatus = [NSNumber numberWithInt:VideoDownloadDataStatusPaused];
        [[SSModelManager sharedManager] save:nil];
        
        if (sync) {
            [self reloadWaitingDataList];
            if (!_downloading && isDownloadingVideo) {
                [self currentDownloadStart];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:VideoDownloadTabUpdateBadgeNotification object:nil];
        }
    }
}

- (void)removeWithVideoData:(VideoData *)video sync:(BOOL)sync
{
    BOOL isDownloadingVideo = NO;
    if ([video.downloadDataStatus intValue] == VideoDownloadDataStatusDownloading) {
        isDownloadingVideo = YES;
        [self currentDownloadStop];
    }
    
    [self removeDownloadData:video];
    
    if (sync) {
        [self reloadWaitingDataList];
        [self startGetDownloadDataListByType:_dataListType];
        if (!_downloading && isDownloadingVideo) {
            [self currentDownloadStart];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VideoDownloadTabUpdateBadgeNotification object:nil];
    }
}

// instance method
- (void)startWithVideoData:(VideoData *)video
{
    [self startWithVideoData:video sync:YES];
}

- (void)stopWithVideoData:(VideoData *)video
{
    [self stopWithVideoData:video sync:YES];
}

- (void)retryWithVideoData:(VideoData *)video
{
    [self removeDownloadData:video];
    [self startWithVideoData:video];
}

- (void)removeWithVideoData:(VideoData *)video
{
    [self removeWithVideoData:video sync:YES];
}

#pragma mark - database actions

- (void)addDownloadData:(VideoData *)video
{
    video.userDownloaded = [NSNumber numberWithBool:YES];
    video.downloadTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    video.downloadDataStatus = [NSNumber numberWithInt:VideoDownloadDataStatusWaiting];
    [[SSModelManager sharedManager] save:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VideoDownloadTabAddOneNotification object:nil];
}

- (void)removeDownloadData:(VideoData *)video
{
    if ([video.userDownloaded boolValue] == YES) {
        VideoDownloader *downloader = nil;
        if ([video.format isEqualToString:VideoDataFormatM3U8]) {
            downloader = [VideoDownloaderManager downloaderForType:VideoDownloaderTypeM3U8 video:video];
        }
        else if ([video.format isEqualToString:VideoDataFormatMP4]) {
            downloader = [VideoDownloaderManager downloaderForType:VideoDownloaderTypeMP4 video:video];
        }
        
        if (downloader) {
            self.removeDownloader = downloader;
            downloader.delegate = self;
            [downloader remove];
        }
        
        video.userDownloaded = [NSNumber numberWithInt:NO];
        video.downloadTime = [NSNumber numberWithDouble:0.f];
        video.downloadDataStatus = [NSNumber numberWithInt:VideoDownloadDataStatusNone];
        video.downloadProgress = [NSNumber numberWithFloat:0.f];
        [[SSModelManager sharedManager] save:nil];
    }
}

#pragma mark - VideoDownloaderProtocol

- (void)videoDownloader:(VideoDownloader *)downloader downloadStatusChangedTo:(NSNumber *)newStatus
{
    if (downloader == self.startDownloader) {
        
        VideoData *video = downloader.video;
        
        if ([newStatus intValue] == DownloadStatusDownloadFinished) {
            // download success
            _downloading = NO;
            _hasBrokenLinkRetry = NO;
            
            video.downloadDataStatus = [NSNumber numberWithInt:VideoDownloadDataStatusHasDownload];
            [[SSModelManager sharedManager] save:nil];
            
            [self reloadWaitingDataList];
            [self startGetDownloadDataListByType:_dataListType];
            
            [self currentDownloadStart];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:VideoDownloadTabCompleteNotification
                                                                object:[NSDictionary dictionaryWithObject:video
                                                                                                   forKey:kVideoDownloadTabCompleteNotificationVideoDataKey]];
        }
    }
}

- (void)videoDownloader:(VideoDownloader *)downloader failedWithError:(NSError *)error
{
    if (downloader == self.startDownloader) {
        
        VideoData *video = downloader.video;
        _downloading = NO;
        
        if (error) {
            
            BOOL isNoConnect = error.domain == kVideoDownloaderErrorDomain && error.code == kVideoDownloaderErrorNoNetworkCode;
//            BOOL isFormatError = (error.domain == kVideoDownloaderErrorDomain && error.code == kVideoDownloaderErrorInvalidFormatCode) || (error.domain == kM3U8ErrorDomain && error.code == kM3U8FileFormatErrorCode);
            BOOL isBrokenLinkError = (error.domain == kVideoDownloaderErrorDomain && (error.code != kVideoDownloaderErrorNoNetworkCode && error.code != kVideoDownloaderErrorInvalidFormatCode)) || (error.domain == kM3U8ErrorDomain && error.code != kM3U8FileFormatErrorCode) || error.domain == NetworkRequestErrorDomain;
            
            if (isNoConnect) {
                _hasBrokenLinkRetry = NO;
                
                SSLog(@"download failed cause by no connected!");
            }
            else if (!_hasBrokenLinkRetry && isBrokenLinkError) {
                
                // broken link fault-tolerent processing
                SSLog(@"broken link fault-tolerent processing");
                
                _hasBrokenLinkRetry = YES;
                
                [self currentDownloadRemove];
                [self currentDownloadStart];
            }
            else {
                _hasBrokenLinkRetry = NO;
                
                video.downloadDataStatus = [NSNumber numberWithInt:VideoDownloadDataStatusDownloadFailed];
                [[SSModelManager sharedManager] save:nil];
                
                trackEvent([SSCommon appName], @"downloading_tab", @"download_fail");
                
                [[NSNotificationCenter defaultCenter] postNotificationName:VideoDownloadTabUpdateBadgeNotification object:nil];
                
                [self videoFeedbackFailed:VideoFeedbackFailedTypeDownloadFailed video:video];
                
                [self currentDownloadStop];
                self.startDownloader = nil;
                
                [self reloadWaitingDataList];
                [self currentDownloadStart];
            }
        }
    }
}

- (void)videoDownloader:(VideoDownloader*)downloader progressChangedTo:(NSNumber*)newProgress
{
    if (downloader == _startDownloader) {
        
        VideoData *video = downloader.video;
        video.downloadProgress = newProgress;
        [[SSModelManager sharedManager] save:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VideoDownloadDataManagerNewProgressNotification
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObject:newProgress
                                                            forKey:kVideoDownloadDataManagerNewProgressNumberKey]];
    }
}

@end


