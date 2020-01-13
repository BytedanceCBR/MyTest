//
//  FHMinisdkManager.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/2.
//

#import "FHMinisdkManager.h"
#import <TTInstallIDManager.h>
#import "TTRoute.h"
#import <ToastManager.h>
#import "TTAccountLoginManager.h"
#import <TTAccountManager.h>
#import <FHEnvContext.h>
#import <FHUserTracker.h>
#import <TTTabBarProvider.h>

//固定值
#define taskID @"503"
#define kFHSpringAlreadyReport @"kFHSpringAlreadyReport"

@interface FHMinisdkManager ()<BDMTaskCenterManagerProtocol,TTRouteVCHandlerDelegate>

@property(nonatomic, assign) BOOL alreadyReport;
@property(nonatomic, assign) NSInteger retryCount;
@property(nonatomic, copy) BDDTaskFinishBlock finishBlock;

@end

@implementation FHMinisdkManager
    
+ (instancetype)sharedInstance {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });

    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initVars];
    }
    return self;
}

- (void)initVars {
    self.finishBlock = ^(BOOL isCompleted, NSError *error) {
        if(error){
            NSString *code = [NSString stringWithFormat:@"%i",error.code];
            [self addIsApiSuccessLog:NO errorCode:code];
            //重试逻辑
            if(self.retryCount < 1){
                //3秒后重试，只重试一次
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.retryCount++;
                    [[FHMinisdkManager sharedInstance] taskComplete:self.finishBlock];
                });
            }
            return;
        }
        
        //接口返回成功
        [self addIsApiSuccessLog:YES errorCode:nil];
        [self addFinishTaskLog:isCompleted];

        //不管成功还是失败，都会设置空，登录就不会在上报，除非重新从主端拉活
        self.url = nil;
    };
}

- (void)initTask {
    [BDMTaskCenterManager sharedInstance].delegate = self;
    [[BDMTaskCenterManager sharedInstance] uploadAppFirstOpenAfterDownload];
}

- (void)appBecomeActive:(NSString *)ackToken {
    [[BDMTaskCenterManager sharedInstance] setAckToken:ackToken];
}

- (void)taskComplete:(BDDTaskFinishBlock)finishBlock {
    [[BDMTaskCenterManager sharedInstance] updateTaskID:taskID finishBlock:finishBlock];
}

//春节活动
- (void)goSpring {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([FHEnvContext isSpringOpen]){
            if(self.isSpring && self.url){
                [[TTRoute sharedRoute] openURL:self.url userInfo:nil objHandler:nil];
            }
        }
    });
}

- (void)excuteTask {
    self.isSpring = NO;
    [self gotoLogin];
}

- (void)taskFinished {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if(self.alreadyReport){
//            self.url = nil;
//            return;
//        }
        
        [[FHMinisdkManager sharedInstance] taskComplete:self.finishBlock];
    });
}

- (BOOL)isCurrentTabFirst {
    if ([[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabHomeTabKey]) {
        return YES;
    }
    return NO;
}

- (void)gotoLogin {
    __weak typeof(self) wSelf = self;
    self.retryCount = 0;
    
    //当前用户已经登录
    if ([TTAccountManager isLogin]) {
        [self taskFinished];
        return;
    }
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    NSString *enterFrom = [FHEnvContext enterTabLogName];
    if(enterFrom){
        [params setObject:enterFrom forKey:@"enter_from"];
    }
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentAlertSpringLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                // 登录成功
                if ([TTAccountManager isLogin]) {
                    [wSelf taskFinished];
                }
            }
        }];
        self.url = nil;
    });
}

- (void)presentAlertSpringLoginVCWithParams:(NSDictionary *)params completeBlock:(TTAccountLoginAlertPhoneInputCompletionBlock)complete {
    TTAcountFLoginDelegate *delegate = [[TTAcountFLoginDelegate alloc] init];
    delegate.completeAlert = complete;
    NSHashTable *delegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [delegateTable addObject:delegate];
    NSMutableDictionary *dict = @{}.mutableCopy;
    [dict setObject:delegateTable forKey:@"delegate"];
    [dict setObject:@(YES) forKey:@"present"];
    
    if (params.count > 0) {
        if ([params tta_stringForKey:@"enter_from"] != nil) {
            [dict setObject:[params tta_stringForKey:@"enter_from"] forKey:@"enter_from"];
        }
        if ([params tta_stringForKey:@"enter_type"] != nil) {
            [dict setObject:[params tta_stringForKey:@"enter_type"] forKey:@"enter_type"];
        }
        if ([params tta_stringForKey:@"need_pop_vc"] != nil) {
            [dict setObject:[params tta_stringForKey:@"need_pop_vc"] forKey:@"need_pop_vc"];
        }
        if (params[@"from_ugc"]) {
            [dict setObject:params[@"from_ugc"] forKey:@"from_ugc"];
        }
    }
    
    TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPresentViewController:[NSURL URLWithString:@"sslocal://spring_login"] userInfo:userInfo app:nil vcHandlerDelegate:self];
}

- (void)navigationControllerHandlePresentVC:(UINavigationController *)navigationController vc:(UIViewController *)vc animated:(BOOL)animated {
    vc.providesPresentationContextTransitionStyle = YES;
    vc.definesPresentationContext = YES;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [navigationController presentViewController:vc animated:NO completion:nil];
}

#pragma mark - BDDTaskCenterManagerProtocol

- (NSString *)deviceId {
    return [[TTInstallIDManager sharedInstance] deviceID];
}

- (NSString *)appId {
    return @"1370";
}

#pragma mark - 记录状态，完成任务后不在上报

- (void)setAlreadyReport:(BOOL)alreadyReport {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:alreadyReport] forKey:kFHSpringAlreadyReport];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)alreadyReport {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kFHSpringAlreadyReport] boolValue];
}

#pragma mark -  埋点

- (void)addFinishTaskLog:(BOOL)isCompleted {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"task_name"] = @"festival_login";
    tracerDict[@"complete"] = @(isCompleted);
    TRACK_EVENT(@"finish_task", tracerDict);
}

- (void)addActivationLog {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"is_reactive"] = @"1";
    TRACK_EVENT(@"activation", tracerDict);
}

- (void)addIsApiSuccessLog:(BOOL)success errorCode:(NSString *)errorCode {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"api_name"] = @"spring_festival_login_task";
    tracerDict[@"recall_success"] = @(success);
    if(errorCode){
        tracerDict[@"code"] = errorCode;
    }
    TRACK_EVENT(@"is_api_success", tracerDict);
}
    
@end
