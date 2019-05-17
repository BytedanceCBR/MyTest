//
//  ExploreMoviePlayerLogManager.m
//  Article
//
//  Created by Zhang Leonardo on 15-3-22.
//
//

#import "SSMoviePlayerLogManager.h"
#import "SSMoviePlayerLogConfig.h"

#define kReachabilityChangedNotification @"kNetworkReachabilityChangedNotification"

@interface SSMoviePlayerLogManager()
{
    BOOL _hasDownloadedDNSInfo;
}

@property(nonatomic, strong)NSString * userIP;
@property(nonatomic, strong)NSString * DNSAddress;
@property(nonatomic, strong)NSMutableArray * needAddDNSInfoDatas;
@end

@implementation SSMoviePlayerLogManager

static SSMoviePlayerLogManager * dataManager;

+ (SSMoviePlayerLogManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[SSMoviePlayerLogManager alloc] init];
    });
    return dataManager;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kReachabilityChangedNotification object:nil];
    }
    return self;
}

- (void)addMovieTrackerToLog:(NSDictionary *)dict needDNSInfo:(BOOL)need
{
    if ([dict count] == 0) {
        return;
    }
    
    BOOL needFetch = need;
    if (![SSMoviePlayerLogConfig fetchDNSInfo]) {
        needFetch = NO;
    }

    NSMutableDictionary * mDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [mDict setValue:@"video_playq" forKey:@"log_type"];
    if (needFetch && !_hasDownloadedDNSInfo) {
        if (!_needAddDNSInfoDatas) {
            self.needAddDNSInfoDatas = [NSMutableArray arrayWithCapacity:20];
        }
        [_needAddDNSInfoDatas addObject:mDict];
        [self fetchDNS];
    }
    else {
        [mDict setValue:_userIP forKey:@"ip"];
        [mDict setValue:_DNSAddress forKey:@"dns"];
        [self.logReceiver appendLogData:mDict];
    }
}

- (void)addUploadMovieTrackerToLog:(NSDictionary *)dict
{
    if ([dict count] == 0) {
        return;
    }
    
    NSMutableDictionary * mDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [mDict setValue:@"video_uploadq" forKey:@"log_type"];
    
    if (!_hasDownloadedDNSInfo) {
        if (!_needAddDNSInfoDatas) {
            self.needAddDNSInfoDatas = [NSMutableArray arrayWithCapacity:20];
        }
        [_needAddDNSInfoDatas addObject:mDict];
        [self fetchDNS];
    }
    else {
        [mDict setValue:_userIP forKey:@"ip"];
        [mDict setValue:_DNSAddress forKey:@"dns"];
        [self.logReceiver appendLogData:mDict];
    }
}

- (void)fetchDNS
{
    // 用户ip、用户DNS和serverIP的获取
    // 参考https://wiki.bytedance.com/pages/viewpage.action?pageId=24511424
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://trace-ldns.ksyun.com/getlocaldns"]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            if (data) {
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ([result isKindOfClass:[NSDictionary class]]) {
                    self.userIP = [result valueForKey:@"ClientIP"];
                    self.DNSAddress = [result valueForKey:@"LocalDnsIP"];
                }
            }
        }

        _hasDownloadedDNSInfo = YES;
        [self dealNeedAddDNSInfoDatas];
    }];
}

- (void)dealNeedAddDNSInfoDatas
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray * array = [_needAddDNSInfoDatas copy];
        for (NSMutableDictionary * dict in array) {
            if ([dict isKindOfClass:[NSMutableDictionary class]]) {
                [dict setValue:_userIP forKey:@"ip"];
                [dict setValue:_DNSAddress forKey:@"dns"];
                [self.logReceiver appendLogData:dict];
            }
        }
        [_needAddDNSInfoDatas removeAllObjects];
    });
}

#pragma mark - kReachabilityChangedNotification

- (void)connectionChanged:(NSNotification *)notification
{
    // 网络变化时，dns需要重新请求
    _hasDownloadedDNSInfo = NO;
    self.userIP = nil;
    self.DNSAddress = nil;
}

@end
