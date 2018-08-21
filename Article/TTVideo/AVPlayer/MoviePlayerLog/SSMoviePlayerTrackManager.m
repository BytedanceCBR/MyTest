//
//  SSMoviePlayerTrackManager.m
//  Article
//
//  Created by Zhang Leonardo on 15-3-19.
//
//

#import "SSMoviePlayerTrackManager.h"
#import "SSMoviePlayerLogConfig.h"

#ifndef isEmptyString
#define isEmptyString(str) (!str || ![str isKindOfClass:[NSString class]] || str.length == 0)
#endif

@interface SSMoviePlayerTrackManager()

//第一次点击播放的时间戳
@property(nonatomic, assign)NSTimeInterval playTime;
//第一次加载超时，重试播放时记录之前的playtime
@property(nonatomic, assign)NSTimeInterval retryPlayTime;
//视频id，请求api获取视频url
@property(nonatomic, copy)NSString * videoID;
//通过videoid获取视频URL的url
@property(nonatomic, copy)NSString * fetchURL;
//seek_time用户本次拖动结束的时间戳
@property(nonatomic, assign)NSTimeInterval seekTime;
//请求获取到videoUrl的时间戳
@property(nonatomic, assign)NSTimeInterval apiFetchedTime;
//是否未播放离开
@property(nonatomic, assign)BOOL leaveWithoutPlay;
//用户开始看到第一帧画面的时间戳
@property(nonatomic, assign)NSTimeInterval viewFirstVideoFrameTime;
//用户结束本次播放的时间戳
@property(nonatomic, assign)NSTimeInterval exitTime;
//用户卡顿的次数
@property(nonatomic, assign)NSUInteger bufferCounts;
//用户是否发生播放中断
@property(nonatomic, assign)NSUInteger brokenCounts;
@property(nonatomic, copy)NSString * mobileNetworkCode;
//服务器最终url
@property(nonatomic, copy)NSString * videoURL;
@property(nonatomic, copy)NSString * serverIP;
//从api拿到的原始videoUrl
@property(nonatomic, copy)NSString * originVideoURL;
//网络错误信息
@property(nonatomic, copy)NSString * networkError;
//api错误信息
@property(nonatomic, copy)NSDictionary * apiErrorDict;
//broken发生时间
@property(nonatomic, assign)NSTimeInterval brokenTime;
//broken时已播放时长(秒)
@property(nonatomic, assign)NSTimeInterval brokenPlaybackDuration;
//broken错误代码
@property(nonatomic, assign)NSInteger brokenErrorType;
//用户本次视频流加载结束的时间戳(毫秒)
@property(nonatomic,assign)NSTimeInterval bufferFinishTime;
//cdn地址的dns解析相关错误
@property(nonatomic, strong)NSDictionary *dnsErrorDict;
//视频时长
@property(nonatomic, assign) NSInteger movieDuration;
//视频大小
@property(nonatomic, assign) NSInteger movieSize;
//切换前视频清晰度
@property(nonatomic, copy) NSString *lastMoiveDefinition;
//视频清晰度
@property(nonatomic, copy) NSString *movieDefinition;
//视频预加载大小
@property(nonatomic, assign) NSInteger preloadSize;
//视频预加载最小步长
@property(nonatomic, assign) NSInteger preloadMinStep;
//视频预加载最大步长
@property(nonatomic, assign) NSInteger preloadMaxStep;
//视频类型
@property(nonatomic, assign) SSVideoType videoType;
//视频播放了多少bytes
@property(nonatomic, assign) NSInteger videoPlaySize;
//视频加载了多少bytes
@property(nonatomic, assign) NSInteger videoDownloadSize;

@property(nonatomic, strong) NSError *playerError;
@end

@implementation SSMoviePlayerTrackManager

- (void)dealloc
{
    // 未播放时离开
    if (_leaveWithoutPlay && _playTime > 0) {
        if (_exitTime > 0) {
            [self flushTrack];
        } else {
            [self sendEndTrack];
        }
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self clearAll];
    }
    return self;
}

- (void)setLogReceiver:(id<SSMovieLogReceiver>)logReceiver
{
    [SSMoviePlayerLogManager shareManager].logReceiver = logReceiver;
}

- (void)sendEndTrack
{
    self.exitTime = [[NSDate date] timeIntervalSince1970];
    [self flushTrack];
}

- (void)endTrack
{
    self.exitTime = [[NSDate date] timeIntervalSince1970];
}

- (void)clearAll
{
    self.playTime = 0;
    self.retryPlayTime = 0;
    self.videoID = nil;
    self.seekTime = 0;
    self.apiFetchedTime = 0;
    self.leaveWithoutPlay = YES;
    self.bufferCounts = 0;
    self.brokenCounts = 0;
    self.videoURL = nil;
    self.serverIP = nil;
    self.originVideoURL = nil;
    self.exitTime = 0;
    self.networkError = nil;
    self.dnsErrorDict = nil;
    self.apiErrorDict = nil;
    self.brokenTime = 0;
    self.brokenPlaybackDuration = 0;
    self.brokenErrorType = 0;
    self.bufferFinishTime = 0;
    self.fetchURL = nil;
    self.movieDuration = 0;
    self.movieSize = 0;
    self.movieDefinition = nil;
    self.lastMoiveDefinition = nil;
    self.preloadSize = 0;
    self.preloadMinStep = -1;
    self.preloadMaxStep = -1;
}

- (void)userClickPlayButtonForID:(NSString *)videoID fetchURL:(NSString *)fetchURL isClearALl:(BOOL)clearAll
{
    if (clearAll) {
        [self clearAll];
    }
    self.videoID = videoID;
    self.playTime = [[NSDate date] timeIntervalSince1970];
    self.fetchURL = fetchURL;
}

// 自动重试播放
- (void)autoRetryPlay
{
    self.retryPlayTime = self.playTime;
    self.playTime = [[NSDate date] timeIntervalSince1970];
    self.apiFetchedTime = 0;
}

- (void)fetchedVideoStartPlay
{
    self.apiFetchedTime = [[NSDate date] timeIntervalSince1970];
}

- (void)seekToTime:(NSTimeInterval)afterSeekTime cacheDuration:(NSTimeInterval)cacheDuration
{
    // 拖动时间超过缓冲时间时立即发送统计，下次统计发送
    if (afterSeekTime > cacheDuration) {
        // seek引起的一次卡顿不计入bufferCounts
        if (self.bufferCounts >= 1) {
            self.bufferCounts -= 1;
        }
        
        [self sendEndTrack];
        
        // 清空拖动进度前的统计参数
        self.playTime = 0;
        self.bufferCounts = 0;
        self.brokenCounts = 0;
        self.leaveWithoutPlay = YES;
        self.seekTime = [[NSDate date] timeIntervalSince1970];
    }
}

- (void)showedOnceFrame
{
    self.viewFirstVideoFrameTime = [[NSDate date] timeIntervalSince1970];
    self.leaveWithoutPlay = NO;
}

- (void)setMovieOriginVideoURL:(NSString *)uri
{
    self.videoURL = uri;
    self.originVideoURL = uri;
}

- (void)setMovieVideoURL:(NSString *)uri serverIP:(NSString *)si
{
    self.videoURL = uri;
    if (isEmptyString(_serverIP)) {
        self.serverIP = si;
    }
}

- (void)setMovieDuration:(NSInteger)duration
{
    _movieDuration = duration;
}

- (void)setMovieSize:(NSInteger)size
{
    _movieSize = size;
}

- (void)setMovieLastDefinition:(NSString *)definition
{
    _lastMoiveDefinition = definition;
}

- (void)setMovieDefinition:(NSString *)definition
{
    _movieDefinition = definition;
}

- (void)setMoviePreloadSize:(NSInteger)size
{
    _preloadSize = size;
}

- (void)setMoviePreloadMinStep:(NSInteger)step
{
    _preloadMinStep = step;
}

- (void)setMoviePreloadMaxStep:(NSInteger)step
{
    _preloadMaxStep = step;
}

- (void)setVideoType:(SSVideoType)type {
    _videoType = type;
}

- (void)setVideoPlaySize:(NSInteger)size {
    _videoPlaySize = size;
}

- (void)setVideoDownloadSize:(NSInteger)size {
    _videoDownloadSize = size;
}

- (void)movieStalled
{
    self.bufferCounts += 1;
}

- (void)movieBufferDidReachEnd
{
    if (self.bufferFinishTime == 0) {
        self.bufferFinishTime = [[NSDate date] timeIntervalSince1970];
    }
}

- (void)movieFinishError:(NSError *)error currentPlaybackTime:(NSTimeInterval)currentPlaybackTime
{
    // 播放中断
    if (self.viewFirstVideoFrameTime > 0) {
        self.brokenCounts += 1;
        self.brokenTime = [[NSDate date] timeIntervalSince1970];
        self.brokenPlaybackDuration = currentPlaybackTime;
        self.brokenErrorType = error.code;
    }
    
    NSString *errorStr = error.description;
    [self setError:(errorStr?:@"playback finish with error")];
}

- (void)setError:(NSString *)errorStr
{
    self.networkError = errorStr;
}

- (void)setDNSErrorDict:(NSDictionary *)dnsErrorDict {
    self.dnsErrorDict = dnsErrorDict;
}

- (void)setPlayError:(NSError *)error
{
    self.playerError = error;
}

- (NSString *)statVersion
{
    if ([SSCommonLogic isVideoOwnPlayerEnabled]) {
        return @"3.0";
    }
    return @"1.0";
}

+ (NSString *)buildVersion
{
    NSString *buildTime = [NSString stringWithFormat:@"%s %s", __DATE__ ,__TIME__];
    return buildTime;
}

- (NSDictionary *)trackDict
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:[self statVersion] forKey:@"sv"];
    
    [dict setValue:_videoID forKey:@"v"];
    
    // st与pt互斥，发pt时同时发at
    if ([SSMoviePlayerTrackManager valideForInterval:_seekTime]) {
        [dict setValue:@((long long)(_seekTime * 1000.)) forKey:@"st"];
    } else if ([SSMoviePlayerTrackManager valideForInterval:_playTime]) {
        [dict setValue:@((long long)(_playTime * 1000.)) forKey:@"pt"];
        if ([SSMoviePlayerTrackManager valideForInterval:_apiFetchedTime]) {
            [dict setValue:@((long long)(_apiFetchedTime * 1000.)) forKey:@"at"];
        }
    }
    
    if ([SSMoviePlayerTrackManager valideForInterval:_exitTime]) {
        // lt与et互斥
        if (_leaveWithoutPlay) {
            [dict setValue:@((long long)(_exitTime * 1000.)) forKey:@"lt"];
        } else {
            [dict setValue:@((long long)(_exitTime * 1000.)) forKey:@"et"];
            
            if ([SSMoviePlayerTrackManager valideForInterval:_viewFirstVideoFrameTime]) {
                [dict setValue:@((long long)(_viewFirstVideoFrameTime * 1000.)) forKey:@"vt"];
                _viewFirstVideoFrameTime = 0;
            }
        }
    }
    
    if ([SSMoviePlayerTrackManager valideForInterval:_bufferFinishTime]) {
        [dict setValue:@((long long)(_bufferFinishTime * 1000.)) forKey:@"bft"];
        _bufferFinishTime = 0;
    }

    if ([SSMoviePlayerTrackManager valideForInterval:_bufferCounts]) {
        [dict setValue:@(_bufferCounts) forKey:@"bc"];
        _bufferCounts = 0;
    }
    
    if ([SSMoviePlayerTrackManager valideForInterval:_brokenCounts]) {
        [dict setValue:@(_brokenCounts) forKey:@"br"];
        _brokenCounts = 0;
    }
    
    if (self.brokenErrorType != 0) {
        [dict setValue:@(self.brokenErrorType) forKey:@"errt"];
        self.brokenErrorType = 0;
    }
    
    if (self.trackDelegate) {
        if ([self.trackDelegate respondsToSelector:@selector(connectMethodName)]) {
            NSString *n = [self.trackDelegate connectMethodName];
            [dict setValue:n forKey:@"n"];
        }
        
        if ([self.trackDelegate respondsToSelector:@selector(carrierMNC)]) {
            NSString *m = [self.trackDelegate carrierMNC];
            [dict setValue:m forKey:@"m"];
        }
    }
    
    [dict setValue:_videoURL forKey:@"vu"];
    [dict setValue:_serverIP forKey:@"si"];
    [dict setValue:@(_movieDuration) forKey:@"vd"];
    [dict setValue:@(_movieSize) forKey:@"vs"];
    [dict setValue:_lastMoiveDefinition forKey:@"lf"];
    [dict setValue:_movieDefinition forKey:@"df"];
    [dict setValue:@(_preloadSize) forKey:@"vpls"];
    [dict setValue:@(_preloadMinStep) forKey:@"vmin"];
    [dict setValue:@(_preloadMaxStep) forKey:@"vmax"];
    [dict setValue:@(_videoType) forKey:@"type"];
    [dict setValue:@(_videoPlaySize) forKey:@"vps"];
    [dict setValue:@(_videoDownloadSize) forKey:@"vds"];

    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
    
    [extraDict setValue:[SSMoviePlayerTrackManager buildVersion] forKey:@"bv"];

    if (!isEmptyString(self.networkError)) {
        [extraDict setValue:_networkError forKey:@"network_error"];
        self.networkError = nil;
    }
    
    if (self.brokenTime > 0) {
        [extraDict setValue:@(self.brokenTime) forKey:@"complete_time"];
        self.brokenTime = 0;
        
        if (self.brokenPlaybackDuration > 0) {
            [extraDict setValue:@(self.brokenPlaybackDuration) forKey:@"duration"];
            self.brokenPlaybackDuration = 0;
        }
    }
    
    if (self.apiErrorDict) {
        [extraDict setValue:_apiErrorDict forKey:@"api_error"];
        self.apiErrorDict = nil;
    }
    
    if (self.dnsErrorDict) {
        [extraDict setValue:self.dnsErrorDict forKey:@"cdn_info"];
        self.dnsErrorDict = nil;
    }

    if (self.playerError) {
        [extraDict setValue:[self.playerError description] forKey:@"player_error"];
        self.playerError = nil;
    }

    if ([SSMoviePlayerTrackManager valideForInterval:_retryPlayTime]) {
        [extraDict setValue:@((long long)(_retryPlayTime * 1000.)) forKey:@"retry_pt"];
        _retryPlayTime = 0;
    }
    
    if (!isEmptyString(self.fetchURL)) {
        [extraDict setValue:self.fetchURL forKey:@"fetch_url"];
        self.fetchURL = nil;
    }
    
    if (extraDict.count > 0) {
        [dict setValue:[extraDict copy] forKey:@"ex"];
    }
    
    return dict;
}

+ (BOOL)valideForInterval:(NSTimeInterval)interval
{
    if (interval > 0 && interval < NSIntegerMax) {
        return YES;
    }
    return NO;
}

- (void)flushTrack
{
    if (isEmptyString(self.videoID)) {
        return;
    }
    
    BOOL needDNS = NO;
    if (_bufferCounts > 0 || _leaveWithoutPlay) {
        needDNS = YES;
    }
    
    if (isEmptyString(self.serverIP) && !isEmptyString(self.originVideoURL)) {
        // 未播放离开时播放器还未获取到视频si和vu，需要使用HEAD方式请求后再发送log
        NSMutableDictionary *dict = [[self trackDict] mutableCopy];
        
        [SSMoviePlayerTrackManager requestHeadForURL:self.originVideoURL completionHandler:^(NSString *ipStr, NSString *videoURL, NSError *error) {
            if (!isEmptyString(ipStr)) {
                [dict setValue:ipStr forKey:@"si"];
            }
            if (!isEmptyString(videoURL)) {
                [dict setValue:videoURL forKey:@"vu"];
            }
            if (error) {
                NSMutableDictionary *ex = [[dict objectForKey:@"ex"] mutableCopy];
                if (ex) {
                    [ex setValue:error.description forKey:@"request_head_error"];
                } else {
                    ex = [NSMutableDictionary dictionaryWithObject:error.description forKey:@"request_head_error"];
                 }
                [dict setValue:[ex copy] forKey:@"ex"];
            }
                
            [[SSMoviePlayerLogManager shareManager] addMovieTrackerToLog:dict needDNSInfo:needDNS];
        }];
    }
    else {
        [[SSMoviePlayerLogManager shareManager] addMovieTrackerToLog:[self trackDict] needDNSInfo:needDNS];
    }
}

+ (void)requestHeadForURL:(NSString *)urlStr completionHandler:(void (^)(NSString * ipStr, NSString *videoURL, NSError *error))handler
{
    if (![SSMoviePlayerLogConfig fetchServerIPFromHead]) {
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(nil, nil, nil);
            });
        }
        return;
    }
    NSURL * url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString * ipStr = nil;
        NSString * videoURL = nil;
        if (connectionError) {
            // do nothing..
        }
        else {
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
                videoURL = httpResponse.URL.absoluteString;
                ipStr = httpResponse.URL.host;
            }
        }
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(ipStr, videoURL, connectionError);
            });
        }
    }];
}

@end
