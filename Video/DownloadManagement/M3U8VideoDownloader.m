//
//  VideoDownloader.m
//  Video
//
//  Created by Dianwei on 12-7-19.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "M3U8VideoDownloader.h"
#import "VideoDataUtil.h"
#import "M3U8Parser.h"
#import "SSOperation.h"
#import "M3U8Parser.h"
#import "Segment.h"
#import "NSStringAdditions.h"
#import "NetworkUtilities.h"

// duration count for index file
#define kIndexFileDownloadQuota 10
#define kMaxContentLength       1024 * 1024

@interface M3U8VideoDownloader()<SSFileDownloadOperationDelegate>
@property(nonatomic, retain)SSFileDownloadOperation *downloadIndexOperation;
@property(nonatomic, retain)NSArray *segments;
@property(nonatomic, readwrite)float progress;
@property(nonatomic, retain)NSMutableArray *fileDownloadOperations;
@property(nonatomic, assign)NSOperationQueuePriority downloadPriority;
@end

@implementation M3U8VideoDownloader
{
    float _totalDuration;
    float _downloadedTotalDuration;
    BOOL _stopped;
}

@synthesize downloadIndexOperation, segments;
@synthesize fileDownloadOperations, downloadPriority, progress;
- (void)dealloc
{
//    NSLog(@"self:%@, ops:%@", self, fileDownloadOperations);
//    NSLog(@"%@",[NSThread callStackSymbols]);
    [downloadIndexOperation cancelAndClearDelegate];
    self.downloadIndexOperation = nil;
    self.segments = nil;
    for(SSFileDownloadOperation *op in fileDownloadOperations)
    {
        [op cancelAndClearDelegate];
    }
    
    self.fileDownloadOperations = nil;
    [super dealloc];
}

static int s_max = kDefaultMaxConcurrentNumber;
+ (void)setMaxConcurrentDownloadOperation:(int)max
{
    s_max = max;
    [[M3U8VideoDownloader videoDownloadQueue] setMaxConcurrentOperationCount:s_max];
}

+ (int)maxConcurrentDownloadOperation
{
    return s_max;
}

static NSOperationQueue *s_queue;
+ (NSOperationQueue*)videoDownloadQueue
{
    @synchronized(self)
    {
        if(!s_queue)
        {
            s_queue = [[NSOperationQueue alloc] init];
        }
        
        return s_queue;
    }
}


- (void)startWithPriority:(NSOperationQueuePriority)priority
{
    if(!SSNetworkConnected())
    {
        NSError *error = [NSError errorWithDomain:kVideoDownloaderErrorDomain
                                             code:kVideoDownloaderErrorNoNetworkCode
                                         userInfo:[NSDictionary dictionaryWithObject:@"No network available" forKey:@"reason"]];
        [self notifyWithError:error];
    }
    else 
    {
        _stopped = NO;
        self.downloadPriority = priority;
        self.currentStatus = [self latestStatus];
        [self handleNextStatus];
    }
}

- (DownloadStatus)latestStatus
{
    DownloadStatus _status = DownloadStatusNotStarted;
    self.segments = [[SSModelManager sharedManager] entitiesWithQuery:[NSDictionary dictionaryWithObjectsAndKeys:self.video.groupID, @"groupID", nil] 
                                                    entityDescription:[Segment entityDescription]
                                                           unFaulting:YES
                                                               offset:0
                                                                count:NSUIntegerMax
                                                      sortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"segmentID" ascending:YES] ]
                                                                error:nil];
    
    _totalDuration = 0;
    if([segments count] > 0 && self.video.localURL && self.video.localPath && [[NSFileManager defaultManager] fileExistsAtPath:self.video.localPath])
    {
        _totalDuration += kIndexFileDownloadQuota;
        _status = DownloadStatusIndexDownloaded;
        for(Segment *segment in segments)
        {
            _totalDuration += [segment.length floatValue];
        }
        
        float _progress = kIndexFileDownloadQuota / _totalDuration;
        
        for(Segment *segment in segments)
        {
            if([segment.downloadStatus intValue]== SegmentDownloadStatusFinished)
            {
                _progress += [segment.length floatValue] / _totalDuration;
            }
        }
        
        self.progress = _progress;
    }
    else
    {
        self.progress = .0f;
    }
    
    return _status;
}

- (void)handleNextStatus
{
    // possible it's invoked by an asynchronous result, so we need to check whether it's already stopped.
    // we also need to check for each operation, since it's maybe stopped by value changed notification
    if(!_stopped)
    {
        switch (self.currentStatus) {
            case DownloadStatusNotStarted:
            {
                self.currentStatus = DownloadStatusDownloadingIndex;
                if(!_stopped)
                {
                    [self startDownloadIndexFile];
                }
            }
                break;
            case DownloadStatusDownloadingIndex:
            {
                self.currentStatus = DownloadStatusIndexDownloaded;
                self.progress = kIndexFileDownloadQuota / _totalDuration;
                if(!_stopped)
                {
                    [self handleNextStatus];
                }
            }
                break;
            case DownloadStatusIndexDownloaded:
            {
                self.currentStatus = DownloadStatusDownloadingFiles;
                if(!_stopped)
                {
                    [self startDownloadVideoFiles];
                }
            }
                break;
            case DownloadStatusDownloadingFiles:
            {
                self.currentStatus = DownloadStatusDownloadFinished;
                self.progress = 1.f;
            }
                break;
            default:
                break;
        }
    }
}

- (void)startDownloadIndexFile
{
    if(self.video.localURL)
    {
        [self handleNextStatus];
    }
    else 
    {
        NSString *destBasePath = [VideoDataUtil destinationBasePathForGroupID:[self.video.groupID intValue]];
        NSString *tempBasePath = [VideoDataUtil temporaryBasePathForGroupID:[self.video.groupID intValue]];
        if(![[NSFileManager defaultManager] fileExistsAtPath:destBasePath])
        {
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:destBasePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil 
                                                            error:&error];
            if(error)
            {
                [self notifyWithError:[NSError errorWithDomain:kVideoDownloaderErrorDomain
                                                          code:kVideoDownloaderErrorFileManagementFailedCode
                                                      userInfo:error.userInfo]];
                return;
            }
        }
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:tempBasePath])
        {
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:tempBasePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil 
                                                            error:&error];
            if(error)
            {
                [self notifyWithError:[NSError errorWithDomain:kVideoDownloaderErrorDomain
                                                          code:kVideoDownloaderErrorFileManagementFailedCode
                                                      userInfo:error.userInfo]];
                return;
            } 
        }
        
        NSURL *downloadURL = [NSURL URLWithString:self.video.downloadURL];
        NSString *hashedFileName = [downloadURL.path MD5HashString];
        NSString *destPath = [[VideoDataUtil destinationBasePathForGroupID:[self.video.groupID intValue]] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m3u8", hashedFileName]];
        NSString *tempPath = [[VideoDataUtil temporaryBasePathForGroupID:[self.video.groupID intValue]] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m3u8", hashedFileName]];
        
        [downloadIndexOperation cancelAndClearDelegate];
        self.downloadIndexOperation = [SSFileDownloadOperation fileDownloaderWithURLString:self.video.downloadURL
                                                                             temporaryPath:tempPath
                                                                           destinationPath:destPath
                                                                            reportProgress:NO];
        downloadIndexOperation.queuePriority = downloadPriority;
        downloadIndexOperation.delegate = self;
        [[M3U8VideoDownloader videoDownloadQueue] addOperation:downloadIndexOperation];
    }
}

- (void)stop
{
    _stopped = YES;
    _totalDuration = 0;
    self.progress = .0f;
    [downloadIndexOperation cancelAndClearDelegate];
    self.downloadIndexOperation = nil;
    for(SSFileDownloadOperation *op in fileDownloadOperations)
    {
        [op cancelAndClearDelegate];
    }
    
    self.fileDownloadOperations = nil;
    self.segments = nil;
    self.currentStatus = DownloadStatusNotStarted;
}

- (void)remove
{
    self.currentStatus = DownloadStatusNotStarted;
    [[NSFileManager defaultManager] removeItemAtPath:[VideoDataUtil destinationBasePathForGroupID:[self.video.groupID intValue]] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[VideoDataUtil temporaryBasePathForGroupID:[self.video.groupID intValue]] error:nil];
    self.video.localPath = nil;
    self.video.localURL = nil;

    [[SSModelManager sharedManager] removeEntitiesWithConditions:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:self.video.groupID forKey:@"groupID"]]
                                               entityDescription:[Segment entityDescription] 
                                                           error:nil];
    
    [[SSModelManager sharedManager] save:nil];
}


#pragma mark - SSFileDownloadOperationDelegate
- (void)downloadOperation:(SSFileDownloadOperation *)operation error:(NSError *)error context:(id)context
{
    // retain self in order to avoid relase by the invoker, possibly by the status change or progress change
    [self retain];
    NSLog(@"url:%@", operation.request.url);
    if(error)
    {
        [self notifyWithError:error];
    }
    else 
    {   
        if(operation == downloadIndexOperation)
        {     
            NSURL *destPathURL = [NSURL fileURLWithPath:operation.destPath];
            self.video.localURL = [[VideoDataUtil localBaseURLString] stringByAppendingFormat:@"/%d/%@",self.video.groupID.intValue, destPathURL.lastPathComponent];
            self.video.localPath = operation.destPath;
            [[SSModelManager sharedManager] save:nil];
            NSError *error = [self saveLocalIndexFileFromSourcePath:operation.destPath sourceRemoteURL:operation.request.url];
            if(!error)
            {
                [self handleNextStatus];
            }
        }
        else
        {
            Segment *segment = (Segment*)context;
            [fileDownloadOperations removeObject:operation];
//            NSLog(@"self:%@, current op count:%d", self, [fileDownloadOperations count]);
            _downloadedTotalDuration += [segment.length intValue];
            if([fileDownloadOperations count] == 0)
            {
                // finsihed
                [self handleNextStatus];
                SSLog(@"_total:%f, downloaded total:%f, self:%@", _totalDuration, _downloadedTotalDuration, self);
            }
            
            [[SSModelManager sharedManager] save:nil];
            
            segment.downloadStatus = [NSNumber numberWithInt:SegmentDownloadStatusFinished];
            
            self.progress += [segment.length intValue] / _totalDuration;
        }
    }
    
    [self release];
}

- (void)downloadOperation:(SSFileDownloadOperation *)operation progress:(NSNumber *)tProgress context:(id)context
{
//    Segment *segment = (Segment*)context;
//    float _progress = self.progress + [segment.duration intValue] * [tProgress floatValue];
//    if(_progress <= 1.0f)
//    {
//        self.progress = _progress;
//    }
//    else
//    {
//        self.progress = .99f;
//    }
}


// sourceURL: used to add base url if the URI in m3u8 is relative url
- (NSError*)saveLocalIndexFileFromSourcePath:(NSString*)sourcePath sourceRemoteURL:(NSURL*)sourceURL
{
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:&error];
    if(error)
    {
        if(error.code == NSFileReadUnknownStringEncodingError || error.code == NSFileReadInapplicableStringEncodingError)
        {
            // the m3u8 is not UTF8 format, it should be invalid format such as input is a mp4 file
            [self notifyWithError:[NSError errorWithDomain:kVideoDownloaderErrorDomain
                                                      code:kVideoDownloaderErrorInvalidFormatCode 
                                                  userInfo:[NSDictionary dictionaryWithObject:@"Invalid index file format" forKey:@"reason"]]];
        }
        else 
        {   
            [self notifyWithError:[NSError errorWithDomain:kVideoDownloaderErrorDomain
                                                      code:kVideoDownloaderErrorFileManagementFailedCode 
                                                  userInfo:[NSDictionary dictionaryWithObject:@"Read original index file failed" forKey:@"reason"]]];
        }
        return error;
    }
    
    M3U8Parser *parser = [[M3U8Parser alloc] initWithVideo:self.video];
    [parser parse:content sourceURL:sourceURL];
    
    if(parser.error)
    {
        [self notifyWithError:parser.error];
        return parser.error;
    }
    
    // 1. save local m3u8 file
    NSString *parsedContent = parser.localContent;
    
    [parsedContent writeToFile:sourcePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(error)
    {
        [self notifyWithError:[NSError errorWithDomain:kVideoDownloaderErrorDomain
                                                  code:kVideoDownloaderErrorFileManagementFailedCode 
                                              userInfo:[NSDictionary dictionaryWithObject:@"Write local index file failed" forKey:@"reason"]]];
        return error;
    }
    
    
    
    // 2. save segments
    NSArray *m3u8Segments = parser.segments;
    NSMutableArray *segmentsData = [NSMutableArray arrayWithCapacity:segments.count];
    [m3u8Segments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        M3U8Segment *segment = (M3U8Segment*)obj;
        
        
        NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[segment dictionaryPresentation]];
        [mDict setObject:self.video.groupID forKey:@"group_id"];
        [mDict setObject:[NSNumber numberWithInt:idx] forKey:@"segment_id"];
        [mDict setObject:[NSNumber numberWithInt:SegmentDownloadStatusNotStarted] forKey:@"download_status"];
        [segmentsData addObject:mDict];
    }];
    
    [parser release];
    
    self.segments = [Segment insertEntitiesWithDataArray:segmentsData];
    [[SSModelManager sharedManager] save:nil];
    
    for(Segment *segment in segments)
    {
        _totalDuration += [segment.length intValue];
    }
    
    return nil;
}

- (void)startGetHeader
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.video.downloadURL]];
    [request setHTTPMethod:@"HEAD"];
    [request setValue:@"bytes=0-" forHTTPHeaderField:@"Range"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    [request release];
    [connection release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSDictionary *headerFields = [(NSHTTPURLResponse*)response allHeaderFields];
    long long contentLength = [[headerFields objectForKey:@"Content-Length"] longLongValue];
    if(contentLength > kMaxContentLength)
    {
        NSError *error = [NSError errorWithDomain:kVideoDownloaderErrorDomain
                                             code:kVideoDownloaderErrorInvalidFormatCode 
                                         userInfo:[NSDictionary dictionaryWithObject:@"m3u8 file is too large. " forKey:@"reason"]];
        [self notifyWithError:error];
    }
    else
    {
        [self startDownloadIndexFile];
    }
}

- (void)startDownloadVideoFiles
{
    if([segments count] == 0)
    {
        //TODO: handle error
        NSError *error = [NSError errorWithDomain:kVideoDownloaderErrorDomain
                                             code:kVideoDownloaderErrorInvalidLogicCode
                                         userInfo:[NSDictionary dictionaryWithObject:@"No segments when try to download ts files" forKey:@"reason"]];
        [self notifyWithError:error];
    }
    else
    {
        for(SSFileDownloadOperation *op in fileDownloadOperations)
        {
            [op cancelAndClearDelegate];
        }
        
        self.fileDownloadOperations = [NSMutableArray arrayWithCapacity:segments.count];
        for(Segment *segment in segments)
        {
            if([segment.downloadStatus intValue] != SegmentDownloadStatusFinished)
            {
                NSURL *localURL = [NSURL fileURLWithPath:segment.localPath];
                NSString *fileName = [[localURL pathComponents] lastObject];
                NSString *tempPath = [[VideoDataUtil temporaryBasePathForGroupID:[self.video.groupID intValue]] stringByAppendingPathComponent:fileName];
                
//                NSLog(@"ts url:%@", segment.remoteURLString);
                SSFileDownloadOperation *op = [SSFileDownloadOperation fileDownloaderWithURLString:segment.remoteURLString
                                                                                     temporaryPath:tempPath
                                                                                   destinationPath:segment.localPath
                                                                                    reportProgress:YES 
                                                                                            isSync:NO 
                                                                                           context:segment];
// test code
//                [op addRequestHeader:@"User-Agent" value:@"AppleCoreMedia/1.0.0.9A406 (iPhone; U; CPU OS 5_0_1 like Mac OS X; zh_cn)"];
                op.queuePriority = downloadPriority;
                op.delegate = self;
                [fileDownloadOperations addObject:op];
                [[M3U8VideoDownloader videoDownloadQueue] addOperation:op];
            }
            
        }
        
//        NSLog(@"self:%@, total op count:%d", self, [fileDownloadOperations count]);
    }
}

- (void)notifyWithError:(NSError*)error
{
    self.currentStatus = DownloadStatusNotStarted;
    _stopped = YES;
    if(self.delegate && [self.delegate respondsToSelector:@selector(videoDownloader:failedWithError:)])
    {
        [self.delegate performSelector:@selector(videoDownloader:failedWithError:) withObject:self withObject:error];
    }
}





@end
