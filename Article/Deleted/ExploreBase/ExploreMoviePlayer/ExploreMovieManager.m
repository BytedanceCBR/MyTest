//
//  ExploreMovieManager.m
//  Article
//
//  Created by Zhang Leonardo on 15-3-5.
//
//

#import "ExploreMovieManager.h"
#import "ArticleURLSetting.h"
#import "NSStringAdditions.h"
#import "ExploreVideoSP.h"

#import <TTNetworkManager/TTNetworkManager.h>
#import "NSDictionary+TTAdditions.h"
#import "TTVideoPasterADModel.h"

#import "TTVideoInfoModel.h"
#import "TTStringHelper.h"

#define kSuccessCodeInt 0
#define kNetworkErrorTip @"网络异常，请稍后再试"

#define kLeTVUserKey @"kLeTVUserKey"
#define kLeTVSecretKey @"kLeTVSecretKey"

#define kToutiaoVideoUserKey @"kToutiaoVideoUserKey"
#define kToutiaoVideoSecretKey @"kToutiaoVideoSecretKey"
#define kVideoPlayRetryIntervalKey @"kVideoPlayRetryIntervalKey"
#define kVideoPlayRetryPolicyKey @"kVideoPlayRetryPolicyKey"
#define kVideoPlayAPITimeoutKey @"kVideoPlayAPITimeoutKey"
#define kVideoRetryLoadWhenFailedKey @"kVideoRetryLoadWhenFailedKey"

#define kDefaultRetryInterval 15
#define kDefaultRetryPolicy TTVideoPlayRetryPolicyRetryOne
#define kRetryCountKey @"retryCount"
#define kDefalutTimeoutInterval 10

@interface ExploreMovieManager()

@property(nonatomic, strong) TTHttpTask *videoUrlRequest;
@property(nonatomic, copy)NSString *videoRequestUrl;
//@property(nonatomic, copy)NSString *videoID;
//@property(nonatomic, assign)ExploreVideoSP sp;
@property(nonatomic, strong) TTVideoURLRequestInfo *requestInfo;

@property(nonatomic, strong)NSMutableDictionary *retryErrorDict;
@property(nonatomic, assign)int retryCount;

@end

@implementation ExploreMovieManager

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkLoadingTimeout) object:nil];
    self.delegate = nil;
    [_videoUrlRequest cancel];
}

- (void)fetchURLInfoWithRequestInfo:(TTVideoURLRequestInfo *)info;
{
    [self fetchURLInfoWithRequestInfo:info retryInfex:0];
}

- (void)fetchURLInfoWithRequestInfo:(TTVideoURLRequestInfo *)info retryInfex:(int)retryIndex
{
    if (isEmptyString(info.videoID)) {
        return;
    }
    
    if (retryIndex == 0) {
        self.requestInfo = info;
        
        self.retryCount = 0;
        self.retryErrorDict = [NSMutableDictionary dictionary];
    }
    
    long long ts = [ExploreMovieManager currentTs];
    NSString * sign = [ExploreMovieManager leTVSignFromVideoID:info.videoID ts:ts sp:info.sp];
    
    NSString * userStr = [ExploreMovieManager userForSP:info.sp];
    NSString * videoType = [ExploreMovieManager videoTypeForSP:info.sp];
    NSString * apiPrefix = [self apiForSP:info.sp];
    
    NSString * url;
    
    if (info.sp == ExploreVideoSPToutiao) {
        url = [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@",
               apiPrefix,
               userStr,
               @(ts),
               sign,
               videoType,
               info.videoID];
    }
    else {
        url = [NSString stringWithFormat:@"%@?sign=%@&ts=%@&user=%@&video=%@&vtype=%@",
               apiPrefix,
               sign,
               @(ts),
               userStr,
               info.videoID,
               videoType];
    }
    
    [self performSelector:@selector(checkLoadingTimeout) withObject:nil afterDelay:[[self class] videoPlayTimeoutInterval] inModes:@[NSRunLoopCommonModes]];
    
    self.videoRequestUrl = url;
    
    __weak typeof (self) wself = self;
    
    if (info.sp == ExploreVideoSPToutiao) {
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:3];
        [parameters setValue:info.categoryID forKey:@"category"];
        [parameters setValue:info.itemID forKey:@"item_id"];
        [parameters setValue:@(info.playType) forKey:@"play_type"];
        if (!isEmptyString(info.adID)) {
            [parameters setValue:info.adID forKey:@"ad_id"];
        }
        self.videoUrlRequest = [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:parameters.copy method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
            __strong ExploreMovieManager *sself = wself;
            if (!sself) {
                return;
            }
            
            if (!error) {
                [NSObject cancelPreviousPerformRequestsWithTarget:sself selector:@selector(checkLoadingTimeout) object:nil];
                
                [wself handleLeTVRequestFinished:jsonObj forPlayType:info.playType];
                wself.retryErrorDict = nil;
            } else {
                if (error.code != NSURLErrorCancelled) {
                    [NSObject cancelPreviousPerformRequestsWithTarget:sself selector:@selector(checkLoadingTimeout) object:nil];
                    
                    if (jsonObj) {
                        NSDictionary *videoInfo = [jsonObj valueForKey:@"video_info"];
                        if ([videoInfo isKindOfClass:[NSDictionary class] ]) {
                            NSDictionary *resultJson = [videoInfo valueForKeyPath:@"data"];
                            [wself retryFetchRequestIfNeeded:error.description andURLStatus:[NSString stringWithFormat:@"%@",[resultJson valueForKey:@"status"]]];
                        }else{
                            [wself retryFetchRequestIfNeeded:error.description andURLStatus:nil];
                        }
                    }else
                    {
                        [wself retryFetchRequestIfNeeded:error.description andURLStatus:nil];
                    }
                }
            }
        }];
    }
    else {
        
        self.videoUrlRequest = [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id jsonObj) {
            
            __strong ExploreMovieManager *sself = wself;
            if (!sself) {
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    [NSObject cancelPreviousPerformRequestsWithTarget:sself selector:@selector(checkLoadingTimeout) object:nil];
                    
                    if (jsonObj) {
                        [sself handleLeTVRequestFinished:jsonObj forPlayType:info.playType];
                        sself.retryErrorDict = nil;
                    } else {
                        [sself retryFetchRequestIfNeeded:@"data_parse_error" andURLStatus:nil];
                    }
                } else {
                    if (error.code != NSURLErrorCancelled) {
                        [NSObject cancelPreviousPerformRequestsWithTarget:sself selector:@selector(checkLoadingTimeout) object:nil];
                        
                        if (jsonObj) {
                            NSDictionary *videoInfo = [jsonObj valueForKey:@"video_info"];
                            if ([videoInfo isKindOfClass:[NSDictionary class] ]) {
                                NSDictionary *resultJson = [videoInfo valueForKeyPath:@"data"];
                                [wself retryFetchRequestIfNeeded:error.description andURLStatus:[NSString stringWithFormat:@"%@",[resultJson valueForKey:@"status"]]];
                            }else{
                                [wself retryFetchRequestIfNeeded:error.description andURLStatus:nil];
                            }
                        }else
                        {
                            [wself retryFetchRequestIfNeeded:error.description andURLStatus:nil];
                        }
                    }
                }
            });

        }];
//        NSURLRequest *request = [NSURLRequest requestWithURL:[TTStringHelper URLWithURLString:url]];
//        self.videoUrlRequest = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//            __strong ExploreMovieManager *sself = wself;
//            if (!sself) {
//                return;
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (!error) {
//                    [NSObject cancelPreviousPerformRequestsWithTarget:sself selector:@selector(checkLoadingTimeout) object:nil];
//                    
//                    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//                    if (responseDict) {
//                        [sself handleLeTVRequestFinished:responseDict forPlayType:info.playType];
//                        sself.retryErrorDict = nil;
//                    } else {
//                        [sself retryFetchRequestIfNeeded:@"data_parse_error"];
//                    }
//                } else {
//                    if (error.code != NSURLErrorCancelled) {
//                        [NSObject cancelPreviousPerformRequestsWithTarget:sself selector:@selector(checkLoadingTimeout) object:nil];
//                        
//                        [sself retryFetchRequestIfNeeded:error.description];
//                    }
//                }
//            });
//        }];
        
        [self.videoUrlRequest resume];
    }

}

- (void)retryFetchRequestIfNeeded:(NSString *)errorMsg andURLStatus:(NSString *)URLStatus{
    if (_retryCount < 1) {
        _retryCount += 1;
        
        // api请求url
        [self.retryErrorDict setValue:self.videoRequestUrl forKey:@"url"];
        
        // api第一次失败描述
        [self.retryErrorDict setValue:errorMsg forKey:@"error1"];
        [self.retryErrorDict setValue:URLStatus forKey:@"status"];
        
        // 重试api请求
        [self fetchURLInfoWithRequestInfo:self.requestInfo retryInfex:_retryCount];
    } else if (_retryCount == 1) {
        // api第二次失败描述
        [self.retryErrorDict setValue:errorMsg forKey:@"error2"];
        [self.retryErrorDict setValue:URLStatus forKey:@"status"];
        
        [self notifyError:self.retryErrorDict];
        
        self.retryErrorDict = nil;
        
        _retryCount += 1; 
    }
}

- (void)cancelOperation
{
    [_videoUrlRequest cancel];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkLoadingTimeout) object:nil];
}

- (void)checkLoadingTimeout {
    [_videoUrlRequest cancel];
    
    NSString *errorMsg = [NSString stringWithFormat:@"timeout %ld", (long)[[self class] videoPlayTimeoutInterval]];

    [self retryFetchRequestIfNeeded:errorMsg andURLStatus:nil];
}

/**
 sign⽣生成规则可以分为4个步骤:
 1.把其它所有参数按key升序排序。
 2.把key和它对应的value拼接成⼀一个字符串。按步骤1中顺序,把所有键值对字符串拼接成⼀一个字符串。
 3.把分配给的secretkey拼接在第2步骤得到的字符串后⾯面。 
 4.计算第3步骤字符串的md5值,使⽤用md5值的16进制字符串作为sign的值。
 */
+ (NSString *)leTVSignFromVideoID:(NSString *)videoID ts:(long long)ts sp:(ExploreVideoSP)sp
{
    if (isEmptyString(videoID)) {
        return nil;
    }
    NSMutableString * string = [NSMutableString stringWithCapacity:40];
    [string appendFormat:@"ts%lli", ts];
    [string appendFormat:@"user%@",[ExploreMovieManager userForSP:sp]];
    if (sp == ExploreVideoSPToutiao) {
        [string appendFormat:@"version%@", [ArticleURLSetting toutiaoVideoAPIVersion]];
    }
    [string appendFormat:@"video%@",videoID];
    [string appendFormat:@"vtype%@", [ExploreMovieManager videoTypeForSP:sp]];
    [string appendString:[self secertForSP:sp]];
    NSString * sign = [string MD5HashString];
    return sign;
}

+ (NSString *)leTVVideoType
{
    return @"mp4";
}

+ (NSString *)toutiaoVideoType
{
    return @"mp4";
}

+ (long long)currentTs
{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    return (long long)interval;
}

- (NSDictionary *)requestUserInfo {
    return @{kRetryCountKey:@(_retryCount)};
}

- (void)notifyError:(NSDictionary *)errorDict
{
    if (_delegate && [_delegate respondsToSelector:@selector(manager:errorDict:videoModel:)]) {
        [_delegate manager:self errorDict:errorDict videoModel:nil];
    }
}

- (NSString *)handleVideoPlayTypeNormalWithVideoInfo:(NSDictionary *)videoInfo videoADList:(NSArray *)videoADList
{
    NSString *failMessage;

    int code = [videoInfo intValueForKey:@"code" defaultValue:-1];
    if (code != kSuccessCodeInt) {
        NSString * msg = [videoInfo stringValueForKey:@"message" defaultValue:nil];
        failMessage = isEmptyString(msg) ? [NSString stringWithFormat:@"errorCode=%d", code] : [NSString stringWithFormat:@"errorCode=%d, %@", code, msg];
    }
    else
    {
        NSDictionary *resultData = [videoInfo dictionaryValueForKey:@"data" defalutValue:nil];
        TTVideoInfoModel *info = [[TTVideoInfoModel alloc] initWithDictionary:resultData error:nil];
        if (info) {

            [self.retryErrorDict setValue:[NSString stringWithFormat:@"%@", [resultData valueForKey:@"status"]] forKey:@"status"];
            ExploreVideoModel *model = [[ExploreVideoModel alloc] init];
            model.videoInfo = info;
            [self parseVideoADList:videoADList forVideoModel:model];
            
            if (_delegate && [_delegate respondsToSelector:@selector(manager:errorDict:videoModel:)]) {
                [_delegate manager:self errorDict:self.retryErrorDict videoModel:model];
            }
            
        } else {
            failMessage = @"video_info not exit";
        }
    }
    
    return failMessage;
}

//- (NSString *)handleVideoPlayTypeLiveWithLiveInfo:(NSDictionary *)liveInfo
//{
//    if (liveInfo.allKeys.count == 0) {
//        return @"live_info is not a dict";
//    }
//
//    NSString *failMessage;
//    ExploreVideoModel *model = [[ExploreVideoModel alloc] init];
//    model.liveInfo = [[TTLiveInfo alloc] initWithDictionary:liveInfo error:nil];
//    if (model.liveInfo) {
//        if (_delegate && [_delegate respondsToSelector:@selector(manager:errorDict:videoModel:)]) {
//            [_delegate manager:self errorDict:self.retryErrorDict videoModel:model];
//        }
//    } else {
//        failMessage = @"live_info is not match";
//    }
//
//    return failMessage;
//}

- (void)handleLeTVRequestFinished:(NSDictionary *)result forPlayType:(TTVideoPlayType)playType {
    NSString * failMessage = nil;
    
    int code = [result intValueForKey:@"code" defaultValue:-1];
    if (code != 0) {
        return;
    }
    
    if (TTVideoPlayTypeNormal == playType || TTVideoPlayTypePasterAD == playType)
    {
        NSDictionary *videoInfo = [result dictionaryValueForKey:@"video_info" defalutValue:nil];
        NSArray <NSDictionary *> *videoADList = [result arrayValueForKey:@"video_ad_list" defaultValue:nil];
        if (videoInfo.allKeys.count > 0) {
            failMessage = [self handleVideoPlayTypeNormalWithVideoInfo:videoInfo videoADList:videoADList];
        } else {
            failMessage = @"video_info is not a dic";
        }
    }
//    else if (TTVideoPlayTypeLive == playType  || TTVideoPlayTypeLivePlayback == playType)
//    {
//        NSDictionary *liveInfo = [result dictionaryValueForKey:@"live_info" defalutValue:nil];
//        int codeStatus = [liveInfo intValueForKey:@"code" defaultValue:-1];
//
//        if (codeStatus == 0 && liveInfo.allKeys.count > 0) {
//            NSDictionary *data = [liveInfo dictionaryValueForKey:@"data" defalutValue:nil];
//            NSDictionary *info = [data dictionaryValueForKey:@"live_info" defalutValue:nil];
//            failMessage = [self handleVideoPlayTypeLiveWithLiveInfo:info];
//        } else {
//            failMessage = @"live_info is not a dic";
//        }
//    }

    if (!isEmptyString(failMessage)) {
        if (![self.retryErrorDict valueForKey:@"url"]) {
            [self.retryErrorDict setValue:self.videoRequestUrl forKey:@"url"];
        }
        [self.retryErrorDict setValue:failMessage forKey:@"data_error"];
        [self notifyError:self.retryErrorDict];
    }
}

- (void)parseVideoADList:(NSArray <NSDictionary *>*)videoADList forVideoModel:(ExploreVideoModel *)model
{
    if (videoADList.count == 0) {
        return;
    }
    NSMutableArray <TTVideoPasterADModel *> *afterVideoADList = [[NSMutableArray alloc] initWithCapacity:2];
    if (afterVideoADList.count > 0) {
        model.afterVideoADList = [afterVideoADList copy];
    }
}

+ (NSString *)userForSP:(ExploreVideoSP)sp
{
    if (sp == ExploreVideoSPLeTV) {
        return [ExploreMovieManager leTVUser];
    }
    else if (sp == ExploreVideoSPToutiao) {
        return [ExploreMovieManager toutiaoVideoUser];
    }
    return nil;
}

+ (NSString *)secertForSP:(ExploreVideoSP)sp
{
    if (sp == ExploreVideoSPLeTV) {
        return [ExploreMovieManager LeTVSecretKey];
    }
    else if (sp == ExploreVideoSPToutiao) {
        return [ExploreMovieManager toutiaoVideoSecretKey];
    }
    return nil;
}

- (NSString *)apiForSP:(ExploreVideoSP)sp
{
    if (sp == ExploreVideoSPLeTV) {
        return [ArticleURLSetting leTVAPIURL];
    }
    else if (sp == ExploreVideoSPToutiao) {
        return [ArticleURLSetting toutiaoVideoAPIURL];
    }
    return nil;
}


+ (NSString *)videoTypeForSP:(ExploreVideoSP)sp
{
    if (sp == ExploreVideoSPLeTV) {
        return [ExploreMovieManager leTVVideoType];
    }
    else if (sp == ExploreVideoSPToutiao) {
        return [ExploreMovieManager toutiaoVideoType];
    }
    return nil;
}


#pragma mark -- letv user key

+ (NSString *)leTVUser
{
    NSString * leTVUserKey = [[NSUserDefaults standardUserDefaults] objectForKey:kLeTVUserKey];
    if (isEmptyString(leTVUserKey)) {
        return @"ff03bba36a";
    }
    return leTVUserKey;
}

+ (void)saveleTVUserKey:(NSString *)userKey
{
    if (isEmptyString(userKey)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:userKey forKey:kLeTVUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -- letv secret key

+ (NSString *)LeTVSecretKey
{
    NSString * leTVSecretKey = [[NSUserDefaults standardUserDefaults] objectForKey:kLeTVSecretKey];
    if (isEmptyString(leTVSecretKey)) {
        return @"944fdf087f83a1f6b7aad88ec2793bbc";
    }
    return leTVSecretKey;
}

+ (void)saveLeTVSecretKey:(NSString *)secretKey
{
    if (isEmptyString(secretKey)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:secretKey forKey:kLeTVSecretKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -- toutiao user key

+ (NSString *)toutiaoVideoUser
{
    NSString * leTVUserKey = [[NSUserDefaults standardUserDefaults] objectForKey:kToutiaoVideoUserKey];
    if (isEmptyString(leTVUserKey)) {
        return @"toutiao";
    }
    return leTVUserKey;
}

+ (void)saveToutiaoVideoUserKey:(NSString *)userKey
{
    if (isEmptyString(userKey)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:userKey forKey:kToutiaoVideoUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -- toutiao secret key

+ (NSString *)toutiaoVideoSecretKey
{
    NSString * toutiaoVideoSecretKey = [[NSUserDefaults standardUserDefaults] objectForKey:kToutiaoVideoSecretKey];
    if (isEmptyString(toutiaoVideoSecretKey)) {
        return @"17601e2231500d8c3389dd5d6afd08de";
    }
    return toutiaoVideoSecretKey;
}

+ (void)saveToutiaoVideoSecretKey:(NSString *)secretKey
{
    if (isEmptyString(secretKey)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:secretKey forKey:kToutiaoVideoSecretKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 表示视频uri请求失败后重试第二地址的间隔，单位是秒
+ (NSInteger)videoPlayRetryInterval {
    NSNumber *interval = [[NSUserDefaults standardUserDefaults] objectForKey:kVideoPlayRetryIntervalKey];
    if (!interval || ![interval isKindOfClass:[NSNumber class]]) {
        return kDefaultRetryInterval;
    }
    return [interval integerValue];
}

+ (void)saveVideoPlayRetryInterval:(NSInteger)interval {
    if (interval <= 0) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(interval) forKey:kVideoPlayRetryIntervalKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 表示视频url请求失败后重试策略，0代表不重试，1代表重试1次，2代表重试所有地址
+ (TTVideoPlayRetryPolicy)videoPlayRetryPolicy {
    NSNumber *policy = [[NSUserDefaults standardUserDefaults] objectForKey:kVideoPlayRetryPolicyKey];
    if (!policy || ![policy isKindOfClass:[NSNumber class]]) {
        return kDefaultRetryPolicy;
    }
    return [policy integerValue];
}

+ (void)saveVideoPlayRetryPolicy:(NSInteger)policy {
    if (policy < 0 || policy > TTVideoPlayRetryPolicyRetryAll) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(policy) forKey:kVideoPlayRetryPolicyKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 表示视频url请求超时时长，单位是秒
+ (NSInteger)videoPlayTimeoutInterval {
    NSNumber *interval = [[NSUserDefaults standardUserDefaults] objectForKey:kVideoPlayAPITimeoutKey];
    if (!interval || ![interval isKindOfClass:[NSNumber class]]) {
        return kDefalutTimeoutInterval;
    }
    return [interval integerValue];
}

+ (void)saveVideoPlayTimeoutInterval:(NSInteger)interval {
    if (interval <= 0) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(interval) forKey:kVideoPlayAPITimeoutKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 视频加载非超时失败重试
+ (void)setRetryLoadWhenFailed:(BOOL)bRetry {
    [[NSUserDefaults standardUserDefaults] setObject:@(bRetry) forKey:kVideoRetryLoadWhenFailedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isRetryLoadWhenFailed {
    NSNumber * retry = [[NSUserDefaults standardUserDefaults] objectForKey:kVideoRetryLoadWhenFailedKey];
    if ([retry isKindOfClass:[NSNumber class]]) {
        return [retry boolValue];
    } else {
        return YES; //缺省
    }
}

@end

@implementation TTVideoURLRequestInfo
@end
