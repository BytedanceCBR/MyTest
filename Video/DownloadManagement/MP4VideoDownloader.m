//
//  MP4VideoDownloader.m
//  Video
//
//  Created by Dianwei on 12-7-24.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "MP4VideoDownloader.h"
#import "NSStringAdditions.h"
#import "VideoDataUtil.h"
#import "SSOperation.h"
#import "Segment.h"
#import "NetworkUtilities.h"

/*
 For single file, the header counts for index file
 */

// length count for get header
#define kIndexFileDownloadQuota 10

@interface MP4VideoDownloader()<SSFileDownloadOperationDelegate, NSURLConnectionDelegate>
@property(nonatomic, assign)NSOperationQueuePriority downloadPriority;
@property(nonatomic, readwrite) CGFloat progress;
@property(nonatomic, retain)NSMutableArray *fileDownloadOperations;
// have segments if this file support concurrent downloads
@property(nonatomic, retain)NSArray *segments;
@end

@implementation MP4VideoDownloader
{
    int _totalLength;
    BOOL _stopped;
    int _headerRetryTime;
    int _headerRetriedTime;
    CGFloat _downloadedTotalLength;
}
@synthesize downloadPriority, progress, segments, fileDownloadOperations;

- (void)dealloc
{
    [self stop];
    self.segments = nil;
    for(SSFileDownloadOperation *op in fileDownloadOperations)
    {
        [op cancelAndClearDelegate];
    }
    
    self.fileDownloadOperations = nil;
    [super dealloc];    
}

- (id)initWithVideo:(VideoData *)video
{
    self = [super initWithVideo:video];
    if(self)
    {
        _headerRetryTime = 3;
    }
    
    return self;
}

static int s_max = kDefaultMaxConcurrentNumber;
+ (void)setMaxConcurrentDownloadOperation:(int)max
{
    s_max = max;
    [[MP4VideoDownloader videoDownloadQueue] setMaxConcurrentOperationCount:s_max];
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
    _totalLength = 0;
    if([segments count] > 0)
    {
        _totalLength += kIndexFileDownloadQuota;
        _status = DownloadStatusIndexDownloaded;
        for(Segment *segment in segments)
        {
            _totalLength += [segment.end intValue] - [segment.start intValue];
        }
        
        float _progress = kIndexFileDownloadQuota / _totalLength;
        
        for(Segment *segment in segments)
        {
            if([segment.downloadStatus intValue]== SegmentDownloadStatusFinished)
            {
                _progress += ([segment.end intValue] - [segment.start intValue]) / _totalLength;
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
                    [self startGetHeader];
                }
            }
                break;
            case DownloadStatusDownloadingIndex:
            {
                self.currentStatus = DownloadStatusIndexDownloaded;
                self.progress = kIndexFileDownloadQuota / _totalLength;
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

- (void)startDownloadVideoFiles
{    
    if([segments count] == 0)
    {
        NSError *error = [NSError errorWithDomain:kVideoDownloaderErrorDomain
                                             code:kVideoDownloaderErrorInvalidLogicCode
                                         userInfo:[NSDictionary dictionaryWithObject:@"No segments when try to download segment files" forKey:@"reason"]];
        [self notifyWithError:error];
    }
    else
    {
        self.fileDownloadOperations = [NSMutableArray arrayWithCapacity:segments.count];
        
        // create path
        NSError *error = [self prepareFilePath:[VideoDataUtil temporaryBasePathForGroupID:[self.video.groupID intValue]]];
        if(error)
        {
            [self notifyWithError:error];
            return;
        }
        
        error = [self prepareFilePath:[VideoDataUtil destinationBasePathForGroupID:[self.video.groupID intValue]]];
        if(error)
        {
            [self notifyWithError:error];
            return;
        }
        
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
                op.queuePriority = downloadPriority;
                op.delegate = self;
                op.partialDownloadEnd = segment.end.intValue;
                [op addRequestHeader:@"Range" value:[NSString stringWithFormat:@"bytes=%d-%d", segment.start.intValue, segment.end.intValue]];
                [fileDownloadOperations addObject:op];
                [[MP4VideoDownloader videoDownloadQueue] addOperation:op];
            }
        }
    }
}

- (NSError*)prepareFilePath:(NSString*)path
{
    NSError *error = nil;
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return error;
}

- (void)startGetHeader
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.video.downloadURL]];
    [request setHTTPMethod:@"HEAD"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    [request release];
    [connection release];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSError *error = [self saveHeaderInfo:(NSHTTPURLResponse*)response];
    if(!error)
    {
        [self handleNextStatus];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if(++_headerRetriedTime < _headerRetryTime)
    {
        [self startGetHeader];
    }
    else 
    {
        [self notifyWithError:error];
    }
}

- (NSError*)saveHeaderInfo:(NSHTTPURLResponse*)response
{
    NSDictionary *headerFields = [response allHeaderFields];
    NSString *type = [headerFields objectForKey:@"Content-Type"];
    
    if(type && [type rangeOfString:@"mp4" options:NSCaseInsensitiveSearch].location == NSNotFound)
    {
        NSError *error = [NSError errorWithDomain:kVideoDownloaderErrorDomain
                                             code:kVideoDownloaderErrorInvalidFormatCode
                                         userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"expect mp4 type, but the content type is %@", type] forKey:@"reason"]];
        [self notifyWithError:error];
        return error;
    }
    
    _totalLength = [[headerFields objectForKey:@"Content-Length"] longLongValue];
    self.video.totalLength = [NSNumber numberWithLong:_totalLength];
    NSMutableArray *data = [NSMutableArray arrayWithCapacity:s_max];
    
    if([headerFields objectForKey:@"Content-Range"] && _totalLength > 1024 * 1024 && s_max > 1) //only concurrent download if file size larger than 1M
    {
        int length = _totalLength / s_max;
        int offset = 0;
        
        for(int idx = 0; idx < s_max - 1; idx ++)
        {
            offset = idx * length;
            NSDictionary *dict = [self segmentDictionaryForStartOffset:offset endOffset:offset + length - 1 segmentID:idx];
            [data addObject:dict];
        }
        
        offset += length;
        if(offset < _totalLength)
        {
            NSDictionary *dict = [self segmentDictionaryForStartOffset:offset endOffset:_totalLength segmentID:s_max];
            [data addObject:dict];
        }
    }
    else 
    {
        NSDictionary *dict = [self segmentDictionaryForStartOffset:0 endOffset:_totalLength segmentID:0];
        [data addObject:dict];
    }
    
    self.segments = [Segment insertEntitiesWithDataArray:data];
    [[SSModelManager sharedManager] save:nil];
    
    return nil;
}

- (NSDictionary*)segmentDictionaryForStartOffset:(int)start endOffset:(int)end segmentID:(int)segmentID
{
    NSString *fileName = [[NSString stringWithFormat:@"%@_%d", self.video.downloadURL, start] MD5HashString];
    NSString *localPath = [VideoDataUtil destinationBasePathForGroupID:self.video.groupID.intValue];
    localPath = [localPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", fileName]];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.video.groupID, @"group_id", 
                          [NSNumber numberWithInt:segmentID], @"segment_id",  
                          [NSNumber numberWithInt:start], @"start",
                          [NSNumber numberWithInt:end], @"end",
                          [NSNumber numberWithInt:end - start], @"length",
                          self.video.downloadURL, @"original_url",
                          [NSNumber numberWithInt:SegmentDownloadStatusNotStarted], @"download_status",
                          localPath, @"local_path", nil];
    return dict;
}

- (void)stop
{
    _stopped = YES;
    _totalLength = 0;
    self.progress = .0f;
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
    if(error)
    {
        self.currentStatus = DownloadStatusNotStarted;
        [self notifyWithError:error];
    }
    else
    {
        Segment *segment = (Segment*)context;
        [fileDownloadOperations removeObject:operation];
        segment.downloadStatus = [NSNumber numberWithInt:SegmentDownloadStatusFinished];
        
//        self.progress += [segment.length intValue] / (_totalLength*1.0);
//        _downloadedTotalLength += [segment.length intValue];
        if([fileDownloadOperations count] == 0)
        {
            // finsihed
            [self combineFiles];
//            NSLog(@"_total:%d, downloaded total:%d", _totalLength, _downloadedTotalLength);
        }
        
        [[SSModelManager sharedManager] save:nil];
    }
    
    [self release];
}

- (void)combineFiles
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *finalFileName = [NSString stringWithFormat:@"%@.mp4", [self.video.downloadURL MD5HashString]];
        NSString *finalPath = [[VideoDataUtil destinationBasePathForGroupID:[self.video.groupID intValue]] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", finalFileName]];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:finalPath])
        {
            [[NSFileManager defaultManager] createFileAtPath:finalPath contents:nil attributes:nil];
        }
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:finalPath];
        for(Segment *segment in self.segments)
        {
            NSData *data = [NSData dataWithContentsOfMappedFile:segment.localPath];
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:data];
        }
        
        [fileHandle closeFile];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.video.localPath = finalPath;
            NSString *fileName = [[[NSURL fileURLWithPath:finalPath] pathComponents] lastObject];
            self.video.localURL = [[VideoDataUtil localBaseURLString] stringByAppendingFormat:@"/%d/%@", [self.video.groupID intValue], fileName];
            [[SSModelManager sharedManager] save:nil];
            [self handleNextStatus];
        });
    });
}

static NSMutableDictionary *_downloadLengths;
- (CGFloat)downloadedTotalLength:(Segment *)tSegment progress:(NSNumber *)tProgress
{
    __block CGFloat ret = 0.f;
    if (!_downloadLengths) {
        _downloadLengths = [[NSMutableDictionary alloc] initWithCapacity:[segments count]];
        for (Segment *segment in segments) {
            [_downloadLengths setObject:[NSNumber numberWithFloat:0.f] forKey:segment.segmentID];
        }
    }
    [_downloadLengths setObject:[NSNumber numberWithFloat:[tSegment.length intValue]*[tProgress floatValue]]
                         forKey:tSegment.segmentID];
    
    [segments enumerateObjectsUsingBlock:^(Segment *segment, NSUInteger idx, BOOL *stop) {
        ret += [[_downloadLengths objectForKey:segment.segmentID] floatValue];
    }];
    
    return ret;
}

- (void)downloadOperation:(SSFileDownloadOperation *)operation progress:(NSNumber *)tProgress context:(id)context
{
    Segment *segment = (Segment*)context;
    
    if ([segments count] > 0) {
        _downloadedTotalLength = [self downloadedTotalLength:segment progress:tProgress];
        self.progress = _downloadedTotalLength / _totalLength;
        NSLog(@"progress:%f, segment:%@", progress, segment.segmentID);
    }
}

- (void)notifyWithError:(NSError*)error
{
    self.currentStatus = DownloadStatusNotStarted;
    if(self.delegate && [self.delegate respondsToSelector:@selector(videoDownloader:failedWithError:)])
    {
        [self.delegate performSelector:@selector(videoDownloader:failedWithError:) withObject:self withObject:error];
    }
}

@end
