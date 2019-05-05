//
//  ArticleWebViewToAppStoreManager.m
//  Article
//
//  Created by Huaqing Luo on 26/8/15.
//
//

#import "ArticleWebViewToAppStoreManager.h"
#import "NSStringAdditions.h"
#import <TTBaseLib/JSONAdditions.h>
#import "TTNetworkManager.h"


#import "TTStringHelper.h"

#define kWebViewToAppStoreWhiteListFileName @"kWebViewToAppStoreWhiteList.json"
#define kWebViewToAppStoreWhiteListFileMD5 @"kWebViewToAppStoreWhiteListFileMD5"
#define kWebViewToAppStoreWhiteListFileLastDownloadTime @"kWebViewToAppStoreWhiteListFileLastDownloadTime"

#define kWebViewToAppStoreWhiteListFileDownloadInterval 24.f * 60 * 60

@interface ArticleWebViewToAppStoreManager ()
{
    BOOL _isWhiteListReady;
}

@property(nonatomic, strong)NSArray * whiteListURLStrs;

@end

@implementation ArticleWebViewToAppStoreManager

static ArticleWebViewToAppStoreManager * s_manager = nil;

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[ArticleWebViewToAppStoreManager alloc] init];
    });
    
    return s_manager;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _isWhiteListReady = NO;
    }
    
    return self;
}

- (void)refreshWithSettingsDict:(NSDictionary *)dict
{
    NSString * whiteListFileURLStr = [dict objectForKey:@"download_white_list_file_url"];
    NSString * whiteListFileMD5 = [dict objectForKey:@"download_white_list_file_md5"];
    
    NSString * lastWhiteListFileMD5 = [[NSUserDefaults standardUserDefaults] objectForKey:kWebViewToAppStoreWhiteListFileMD5];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExist = [fileManager fileExistsAtPath:[kWebViewToAppStoreWhiteListFileName stringCachePath]];
    
    if ([whiteListFileMD5 isKindOfClass:[NSString class]] && ![whiteListFileMD5 isEqualToString:lastWhiteListFileMD5]) {
        NSTimeInterval lastDownloadTime = [[[NSUserDefaults standardUserDefaults] objectForKey:kWebViewToAppStoreWhiteListFileLastDownloadTime] doubleValue];
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval interval = currentTime - lastDownloadTime;
        
        if (interval > kWebViewToAppStoreWhiteListFileDownloadInterval || !fileExist) {
            if ([whiteListFileURLStr isKindOfClass:[NSString class]] && !isEmptyString(whiteListFileURLStr)) {
                NSURL * url = [TTStringHelper URLWithURLString:whiteListFileURLStr];

                [[TTNetworkManager shareInstance] requestForBinaryWithURL:url.absoluteString params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error,id responseObject){
                    if (!error) {
                        if (responseObject) {
                            [self saveWhiteListFile:responseObject];
                            [[NSUserDefaults standardUserDefaults] setValue:whiteListFileMD5 forKey:kWebViewToAppStoreWhiteListFileMD5];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                    } else {
                        [self fillWhiteListURLStrsFromFile];
                    }
                }];
                
//                AFHTTPSessionManager * downloadManager = [AFHTTPSessionManager manager];
//                downloadManager.responseSerializer = [AFHTTPResponseSerializer serializer];
//                [downloadManager GET:url.absoluteString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//                    if (responseObject) {
//                        [self saveWhiteListFile:responseObject];
//                        [[NSUserDefaults standardUserDefaults] setValue:whiteListFileMD5 forKey:kWebViewToAppStoreWhiteListFileMD5];
//                        [[NSUserDefaults standardUserDefaults] synchronize];
//                    }
//                    
//                } failure:^(NSURLSessionDataTask *task, NSError *error) {
//                    [self fillWhiteListURLStrsFromFile];
//                }];
            }
        }
    } else if (fileExist) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self fillWhiteListURLStrsFromFile];
        });
    }
}

- (BOOL)isAllowedURLStr:(NSString *)urlStr
{
    if (_isWhiteListReady && self.whiteListURLStrs.count > 0) {
        for (id whiteUrlStr in _whiteListURLStrs) {
            if ([urlStr rangeOfString:whiteUrlStr].location != NSNotFound) {
                return YES;
            }
        }
        
        return NO;
    }
    // 如果white list还没有ready则统一放行
    // 理论上这种case不太可能出现，需要和PM确认策略
    return NO;
}

#pragma mark -- Private

- (void)saveWhiteListFile:(NSData *)fileData
{
    NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithDouble:currentInterval] forKey:kWebViewToAppStoreWhiteListFileLastDownloadTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // set whiteListURLStrs
    __autoreleasing NSError * error = nil;
    id urls = [NSString tt_objectWithJSONData:fileData error:&error];
    if (!error && [urls isKindOfClass:[NSArray class]]) {
        self.whiteListURLStrs = urls;
        _isWhiteListReady = YES;
    }
    
    NSString * jsonFile = [kWebViewToAppStoreWhiteListFileName stringCachePath];
    [fileData writeToFile:jsonFile atomically:YES];
}

- (void)fillWhiteListURLStrsFromFile
{
    NSString* jsonFile = [kWebViewToAppStoreWhiteListFileName stringCachePath];
    NSString* jsonString = [NSString stringWithContentsOfFile:jsonFile usedEncoding:NULL error:NULL];
    id urls = [jsonString tt_JSONValue];
    if ([urls isKindOfClass:[NSArray class]]) {
        self.whiteListURLStrs = urls;
        _isWhiteListReady = YES;
    }
}

+ (BOOL)isToAppStoreRequestURLStr:(NSString *)urlStr
{
    if ([urlStr hasPrefix:@"http://itunes.apple.com"] || [urlStr hasPrefix:@"https://itunes.apple.com"] || [urlStr hasPrefix:@"http://appstore.com"] || [urlStr hasPrefix:@"https://appstore.com"]) {
        return true;
    }
    
    return false;
}

@end
