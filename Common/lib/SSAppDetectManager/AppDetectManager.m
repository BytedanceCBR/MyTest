//
//  AppDetectManager.m
//  Article
//
//  Created by Dianwei on 13-4-2.
//
//

#import "AppDetectManager.h"
#import "SSOperation.h"
#import "NSObject+SBJSON.h"
#import "CommonURLSetting.h"
#import "InstallIDManager.h"
#import "UIDevice+ProcessesAdditions.h"

#import "NSStringAdditions.h"
#import "SSSZipArchive.h"
#import "NSString+SBJSON.h"

#define kLastGetTimeIntervalStarogeKey  @"kLastGetTimeIntervalStarogeKey"
#define kLastSendRecentAppsInterval @"kLastSendRecentAppsInterval"
#define kLastSendInstallAppsInterval @"kLastSendInstallAppsInterval"


#define kInstalledAppStorageKey         @"kInstalledAppStorageKey"

#define kGetAppListInterval 60 * 60 * 12.f
#define kSendRecentAppsInterval 60 * 60 * 2.f
#define kSendInstallAppsInterval 60 * 60 * 6.f

#define kApplistFileLastModified @"kApplistFileLastModified"

#define kAppListFileName @"app_list.json"
#define kAppListZipFileName @"app_list.zip"

@interface AppDetectManager()
@property(nonatomic, retain)SSHttpOperation *operation;
@end

@implementation AppDetectManager
@synthesize operation;

- (void)dealloc
{
    [operation cancelAndClearDelegate];
    self.operation = nil;
    [super dealloc];
}

static AppDetectManager *s_manager;

+ (AppDetectManager*)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[AppDetectManager alloc] init];
    });
    
    return s_manager;
}

- (void)startAppDetect
{
    NSTimeInterval lastInterval = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastGetTimeIntervalStarogeKey] doubleValue];
    NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];


    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExist = [fileManager fileExistsAtPath:[kAppListFileName stringCachePath]];
    
    double interval = currentInterval - lastInterval;
    
    if((int)interval > kGetAppListInterval || !fileExist)
    {
        
        NSString* urlString = [CommonURLSetting appListFileURLString];
        NSURL * url = [NSURL URLWithString:urlString];
        
        ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:url];
        
        //avoid download no change file
        NSString* storedApplistFileLastModified = [[NSUserDefaults standardUserDefaults] objectForKey:kApplistFileLastModified];
        NSMutableDictionary* headerDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:storedApplistFileLastModified,@"If-Modified-Since", nil];
        request.requestHeaders = headerDic;
        
        request.delegate = self;
        [SSOperationManager addOperation:request];
    
    }
    else
    {
        [self trySendResult];
    }
}

- (void)trySendResult
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //判断时间间隔
        NSTimeInterval lastSendRecentAppsInterval = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastSendRecentAppsInterval] floatValue];
        NSTimeInterval lastSendInstallAppsInterval = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastSendInstallAppsInterval] floatValue];
        
        NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];

        double recentInterval = currentInterval - lastSendRecentAppsInterval;
        double installInterval = currentInterval - lastSendInstallAppsInterval;
        
        
        double sendRecentAppsInterval = kSendRecentAppsInterval;
        double sendInstallAppsInterval = kSendInstallAppsInterval;
        
        NSString* recentAppsInterval = [SSCommonLogic getRecentAppsInterval];
        if (recentAppsInterval != nil) {
            sendRecentAppsInterval = [recentAppsInterval doubleValue];
        }
        
        NSString* installAppsInterval = [SSCommonLogic getInstallAppsInterval];
        if (installAppsInterval != nil) {
            sendInstallAppsInterval = [installAppsInterval doubleValue];
        }
        
        if ((int)recentInterval > sendRecentAppsInterval || installInterval > sendInstallAppsInterval ) {
            
            NSArray *installedApp = [self installedApp];
            NSString *installedJSON = [installedApp JSONRepresentation];
            
            NSArray* recentApp = [self recentApp];
            NSString* recentAppJSON = [recentApp JSONRepresentation];
            
            //存储的所有安装的app
            NSArray *storedInstalledApp = [self storedInstalledApp];
            if(!storedInstalledApp)
            {
                // to make the empty array comparison the same
                storedInstalledApp = [NSMutableArray arrayWithCapacity:1];
            }
            NSString *storedJSON = [storedInstalledApp JSONRepresentation];
            
            //存储的最近使用的app
            NSArray *storedRecentApp = [self storedRecentApp];
            if (!storedRecentApp) {
                storedRecentApp = [NSMutableArray arrayWithCapacity:1];
            }
            NSString *storedRecentJSON = [storedRecentApp JSONRepresentation];
            
            
            BOOL shouldSendRecentApps = NO;
            BOOL shouldSendApps = NO;
          
            NSMutableDictionary *postParam = [NSMutableDictionary dictionaryWithCapacity:2];
            [postParam setValue:[[InstallIDManager sharedManager] deviceID] forKey:@"device_id"];
            
            //大于请求的时间间隔 且 数据有变动 才去发送请求
            
            if ((int)recentInterval > sendRecentAppsInterval && ![recentAppJSON isEqualToString:storedRecentJSON]) {
                
                NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithDouble:nowInterval] forKey:kLastSendRecentAppsInterval];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUserDefaults standardUserDefaults] setValue:recentApp forKey:kRecentAppStorageKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [postParam setValue:recentAppJSON forKey:@"recent_apps"];
                
                shouldSendRecentApps = YES;
                
            }
            
            if ((int)installInterval > sendInstallAppsInterval && ![installedJSON isEqualToString:storedJSON]) {
                
                NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithDouble:nowInterval] forKey:kLastSendInstallAppsInterval];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUserDefaults standardUserDefaults] setValue:installedApp forKey:kInstalledAppStorageKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [postParam setValue:installedJSON forKey:@"apps"];
                
                shouldSendApps = YES;
            }
            
            if(shouldSendRecentApps || shouldSendApps)
            {
                [operation cancelAndClearDelegate];
                self.operation = [SSHttpOperation httpOperationWithURLString:[CommonURLSetting appUpdateURLString] getParameter:nil postParameter:postParam userInfo:[NSDictionary dictionaryWithObjectsAndKeys:installedApp, @"apps", recentApp, @"recent_apps", nil]];
                
                [operation setFinishTarget:self selector:@selector(updateOperation:finishedResult:error:context:)];
                [SSOperationManager addOperation:operation];
            }

        }
    
    });
    
}

- (NSArray*)installedApp
{
    
    NSString* jsonFile = [kAppListFileName stringCachePath];
    NSString* jsonString = [NSString stringWithContentsOfFile:jsonFile usedEncoding:NULL error:NULL];
    NSDictionary* jsonDic = [jsonString JSONValue];
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:20];
    for (NSString* key in jsonDic) {
        
        NSArray* jsonArray = [jsonDic objectForKey:key];
        
        NSAutoreleasePool* autoreleasePool = [[NSAutoreleasePool alloc] init];
        int i = 0;
        
        for (NSDictionary* dic in jsonArray) {
            
            NSString *scheme = [dic objectForKey:@"url"];
            if([scheme rangeOfString:@"://"].location == NSNotFound)
            {
                scheme = [NSString stringWithFormat:@"%@://", scheme];
            }
            
            if(!isEmptyString(scheme))
            {
                NSURL *url = [NSURL URLWithString:scheme];
                if([[UIApplication sharedApplication] canOpenURL:url])
                {
                    NSString *appID = [dic objectForKey:@"id"];
                    if(appID)
                    {
                        [result addObject:appID];
                    }
                }
            }
            
            if (i % 100 == 0) {
                [autoreleasePool release];
                autoreleasePool = [[NSAutoreleasePool alloc] init];
            }
            
            i++;
        }
        
        [autoreleasePool release];
        
    }
    
    [result sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *id1 = (NSString*)obj1;
        NSString *id2 = (NSString*)obj2;
        return [id1 compare:id2];
    }];
    
    return result;
    
}

- (NSArray*)recentApp
{
    
    NSString* jsonFile = [kAppListFileName stringCachePath];
    NSString* jsonString = [NSString stringWithContentsOfFile:jsonFile usedEncoding:NULL error:NULL];
    jsonString = [jsonString lowercaseString];
    NSDictionary* jsonDic = [jsonString JSONValue];
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:20];
    
    NSArray * runningInfos = [[UIDevice currentDevice] runningProcesses];
    
    for (NSDictionary* dic in runningInfos) {
        
        NSString* processName = [dic objectForKey:@"ProcessName"];
        processName = [processName lowercaseString];
        
        NSArray* appListWithProcessName = [jsonDic objectForKey:processName];
        
        
        for (NSDictionary* appDic in appListWithProcessName) {
            
            NSString *scheme = [appDic objectForKey:@"url"];
            if([scheme rangeOfString:@"://"].location == NSNotFound)
            {
                scheme = [NSString stringWithFormat:@"%@://", scheme];
            }
            
            if(!isEmptyString(scheme))
            {
                NSURL *url = [NSURL URLWithString:scheme];
                if([[UIApplication sharedApplication] canOpenURL:url])
                {
                    NSString *appID = [appDic objectForKey:@"id"];
                    if(appID)
                    {
                        [result addObject:appID];
                    }
                }
            }
            
        }
        
    }
    
    [result sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *id1 = (NSString*)obj1;
        NSString *id2 = (NSString*)obj2;
        return [id1 compare:id2];
    }];
    
    return result;
    
}

- (NSArray*)storedInstalledApp
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kInstalledAppStorageKey];
}

- (NSArray*)storedRecentApp
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kRecentAppStorageKey];
}

#pragma mark -- ASIHTTPRequestDelegate

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSString* applistFileLastModified = [responseHeaders objectForKey:@"Last-Modified"];
    
    [[NSUserDefaults standardUserDefaults] setObject:applistFileLastModified forKey:kApplistFileLastModified];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    NSData * responseData = [request responseData];
    
    if (responseData != nil) {
        
        NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithDouble:currentInterval] forKey:kLastGetTimeIntervalStarogeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //写入zip文件
        NSString * zipfile = [kAppListZipFileName stringCachePath];
        [responseData writeToFile:zipfile atomically:YES];
        
        //解压文件
        NSString * unzipfile = [@"" stringCachePath];
        [SSSZipArchive unzipFileAtPath:zipfile toDestination:unzipfile];
        
        //删除zip文件
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        [defaultManager removeItemAtPath:zipfile error:nil];
    
        [self trySendResult];
        
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    //暂时不实现重试
}

#pragma mark SSHttpOperation delegate
- (void)updateOperation:(SSHttpOperation*)operation finishedResult:(NSDictionary*)result error:(NSError*)error context:(id)context
{

}

@end
