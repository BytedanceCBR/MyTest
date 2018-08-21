//
//  TTPushService.m
//  Article
//
//  Created by matrixzk on 28/03/2017.
//
//

#import "TTPushService.h"

#import "TTPushManager.h"
#import "TTLCSServerConfig.h"
#import "TTLCSManager.h"
#import "TTLCSMessageReceiver.h"
#import "TTInstallIDManager.h"
#import "TTDeviceHelper.h"
#import "TTIMManager.h"
#import "TTPLManager.h"
#import "SSCookieManager.h"



static NSString * const kAppKey = @"e92afe409d29ce57cd31b483c25981de";
NSString * const kFpId = @"1";


@interface TTPushService ()
<
TTLCSManagerDelegate,
TTAccountMulticastProtocol
>

@property (nonatomic, strong) NSString *currentSessionId;
@end


@implementation TTPushService

+ (instancetype)sharedService
{
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self config];
        
        [TTAccount addMulticastDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [TTAccount removeMulticastDelegate:self];
}

- (void)config
{
    // [[TTPushManager sharedManager] enableDebugLog:YES];
    
    NSString *sessionId = [SSCookieManager sessionIDFromCookie];
    
    self.currentSessionId = sessionId;
    
    // 初始化长连接服务
    [[TTLCSManager sharedManager] configLCSWithMessageReceiver:[TTLCSMessageReceiver new]
                                                        appKey:kAppKey
                                                          fpId:kFpId
                                                      deviceId:[[TTInstallIDManager sharedInstance] deviceID]
                                                         appId:[TTSandBoxHelper ssAppID]
                                                     installId:[[TTInstallIDManager sharedInstance] installID]
                                                     sessionId:sessionId
                                                        wsURLs:nil];
    [TTLCSManager sharedManager].delegate = self;
    [[TTLCSManager sharedManager] startConnection];
    
    // 初始化 IM 相关服务
    /*
    if ([SSCommonLogic isIMServerEnable]) {
        [TTIMManager sharedManager];
        [TTPLManager sharedManager];
    }
     */
    [TTPLManager sharedManager];
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    [self onSessionIdChanged];
}

- (void)onSessionIdChanged
{
    NSString *sessionId = [SSCookieManager sessionIDFromCookie];
    
    if ((!self.currentSessionId && !sessionId) || [self.currentSessionId isEqualToString:sessionId]) {
        LOGD(@"login session is not changed, skip.");
        return;
    }

    LOGI(@"login session changed, reconnect lcs connection.");
    [[TTLCSManager sharedManager] stopConnection];
    [self config];
}

#pragma mark - TTLCSManagerDelegate

- (void)ttlcs_onPushManagerConnectionStateChanged:(TTPushManagerConnectionState)newState url:(NSString *)url
{
    if (newState == TTPushManagerConnectionState_Connected) {
        [self sendFeedbackLog:newState url:url error:@""];
    }
}

- (void)ttlcs_onPushManagerConnectionError:(NSString *)error
                           connectionState:(TTPushManagerConnectionState)connectionState
                                       url:(NSString *)url
{
    [self sendFeedbackLog:connectionState url:url error:error];
}

- (void)ttlcs_onReceivedUnknownPushMessageWithPayload:(NSString *)payload
{
}


#pragma mark - Helper

/* 火山直播用长连接log格式
 did : xxx;//device ID
 status : xxx;
 // 链接状态
 0, 初始化
 1,链接失败
 2,链接关闭
 3,链接中
 4,链接上
 url : xxx;// ws url地址
 extra : {error:xxx}
 */

- (void)sendFeedbackLog:(TTPushManagerConnectionState)state url:(NSString *)url error:(NSString *)error
{
    if (state != TTPushManagerConnectionState_Connected) {
        if (! [[TTLCSServerConfig sharedInstance] canSendFeedbackLog]) {
            return;
        }
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:url forKey:@"url"];
    [dict setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"timestamp"];
    
    [dict setValue:[@((long)state) stringValue] forKey:@"state"];
    [dict setValue:error forKey:@"error"];
    
    [[TTMonitor shareManager] trackData:dict logTypeStr:@"ss_lcs_v2"];
}

@end
