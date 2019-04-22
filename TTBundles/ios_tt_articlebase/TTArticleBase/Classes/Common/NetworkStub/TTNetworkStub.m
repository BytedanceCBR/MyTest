//
//  TTNetworkStub.m
//  Article
//
//  Created by 延晋 张 on 16/5/30.
//
//

#import "TTNetworkStub.h"
#import "OHHTTPStubs.h"

@interface TTNetworkStub ()

@property NSMutableArray *stubArray;

@end

@implementation TTNetworkStub

+ (instancetype)sharedInstance
{
    static TTNetworkStub *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TTNetworkStub alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.stubArray = [NSMutableArray array];
        [OHHTTPStubs onStubActivation:^(NSURLRequest *request, id<OHHTTPStubsDescriptor> stub) {
            NSLog(@"[OHHTTPStubs] Request to %@ has been stubbed with %@", request.URL, stub.name);
        }];
    }
    return self;
}


#pragma mark - Public Methods
+ (void)setEnabled:(BOOL)enabled
{
    [OHHTTPStubs setEnabled:enabled];
}

- (void)setupStub:(NSString *)stubName withConfigArray:(NSArray *)configArray
{
    __block NSString *matchedFile = nil;
    id<OHHTTPStubsDescriptor> stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        if ([request.HTTPMethod isEqualToString:@"GET"]) {
            NSString *absoluteString = request.URL.absoluteString;
            
            for (NSDictionary *dict in configArray) {
                NSString *path = dict[@"path"];
                NSArray *params = dict[@"params"];
                NSString *file = dict[@"file"];
                
                // path匹配 且 指定的参数匹配
                if ([request.URL.path isEqualToString:path]) {
                    NSLog(@"[NetworkStub] Matched:%@", request.URL.path);
                    BOOL bMatch = YES;
                    for (NSString *aParam in params) {
                        NSRange rangeOfTheParam = [absoluteString rangeOfString:aParam];
                        if (rangeOfTheParam.location == NSNotFound) {
                            bMatch = NO;
                            break;
                        }
                    }
                    if (bMatch) {
                        matchedFile = file;
                        return YES;
                    }
                }
            }
        } else if ([request.HTTPMethod isEqualToString:@"POST"]) {
            NSString *httpBodyStr = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
            
            for (NSDictionary *dict in configArray) {
                NSString *path = dict[@"path"];
                NSArray *params = dict[@"params"];
                NSString *file = dict[@"file"];
                
                // path匹配 且 指定的参数匹配
                if ([request.URL.path isEqualToString:path]) {
                    NSLog(@"[NetworkStub] Matched:%@", request.URL.path);
                    BOOL bMatch = YES;
                    for (NSString *aParam in params) {
                        NSRange rangeOfTheParam = [httpBodyStr rangeOfString:aParam];
                        if (rangeOfTheParam.location == NSNotFound) {
                            bMatch = NO;
                            break;
                        }
                    }
                    if (bMatch) {
                        matchedFile = file;
                        return YES;
                    }
                }
            }
        }
        return NO;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        if (matchedFile) {
            return [[OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(matchedFile, [NSBundle mainBundle])
                                                     statusCode:200
                                                        headers:@{@"Content-Type":@"text/plain"}]
                    requestTime:0.2f
                    responseTime:OHHTTPStubsDownloadSpeedWifi];
        }
        return nil;
    }];
    
    stub.name = stubName;
    [self.stubArray addObject:stub];
}

- (void)removeStub:(NSString *)stubName
{
    for (id<OHHTTPStubsDescriptor> stub in self.stubArray) {
        if ([stub.name isEqualToString:stubName]) {
            [OHHTTPStubs removeStub:stub];
            [self.stubArray removeObject:stub];
            return;
        }
    }
}

- (void)restoreAllStubs
{
    NSDictionary *stubStatusDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"NetworkStubStatus"];
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"NetworkStubItems" ofType:@"plist"];
    NSDictionary *stubItemsDict = [NSDictionary dictionaryWithContentsOfFile:file];
    
    for (NSString *stubName in stubStatusDict) {
        BOOL isOpen = [stubStatusDict[stubName] boolValue];
        if (isOpen) {
            NSDictionary *item = stubItemsDict[stubName];
            if (item) {
                NSArray *configArray = nil;
                NSDictionary *subRequestsDict = item[@"subRequests"];
                if (subRequestsDict) {
                    configArray = subRequestsDict.allValues;
                } else {
                    configArray = @[item];
                }
                [self setupStub:stubName withConfigArray:configArray];
            }
        }
    }
}

@end

