//
//  FHMinisdkManager.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/2.
//

#import "FHMinisdkManager.h"
#import <TTInstallIDManager.h>
#import <TTRoute.h>
#import <ToastManager.h>
#import <TTAccountLoginManager.h>
#import <TTAccountManager.h>

//固定值
#define taskID @"503"
#define kFHSpringAlreadyReport @"kFHSpringAlreadyReport"

@interface FHMinisdkManager ()<BDMTaskCenterManagerProtocol>

@property(nonatomic, assign) BOOL alreadyReport;
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

- (void)excuteTask {
    self.isSpring = NO;
    [self gotoLogin];
}
    
//- (void)seeVideo:(NSString *)vid {
//    //执行一些操作
//    if(vid.length > 0){
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSString *routeUrl = [NSString stringWithFormat:@"sslocal://awemevideo?category_name=spring&enter_from=spring&group_id=%@&group_source=19&item_id=%@&load_more=0&spring=1",vid,vid];
//            NSURL *openUrl = [NSURL URLWithString:routeUrl];
//            [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
//        });
//    }
//    
//    if(self.alreadyReport){
//        //已经上报成功了
//        [[ToastManager manager] showToast:@"之前已经上报过了"];
//        return;
//    }
//    //以下为联调测试使用
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        //doSomething
//        [[FHMinisdkManager sharedInstance] taskComplete:^(BOOL isCompleted, NSError *error) {
//            if(error){
//                //重试逻辑
//                return;
//            }
//            
//            if(isCompleted){
//                self.alreadyReport = YES;
//                [[ToastManager manager] showToast:@"恭喜你，完成任务"];
//            }else{
//                [[ToastManager manager] showToast:@"一台设备不能重复完成"];
//            }
//        }];
//    });
//}

- (void)gotoLogin {
    __weak typeof(self) wSelf = self;
    __block NSInteger retryCount = 0;
    
    self.finishBlock = ^(BOOL isCompleted, NSError *error) {
        if(error){
            //重试逻辑
            if(retryCount < 1){
                //3秒后重试，只重试一次
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    retryCount++;
                    [[FHMinisdkManager sharedInstance] taskComplete:self.finishBlock];
                });
            }
            return;
        }
        
        if(isCompleted){
            wSelf.alreadyReport = YES;
            [[ToastManager manager] showToast:@"恭喜你，完成任务"];
        }else{
            [[ToastManager manager] showToast:@"一台设备不能重复完成"];
        }
    };
    
    //当前用户已经登录
    if ([TTAccountManager isLogin]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(wSelf.alreadyReport){
                //已经上报成功了
                [[ToastManager manager] showToast:@"之前已经上报过了"];
                return;
            }
            
            [[FHMinisdkManager sharedInstance] taskComplete:self.finishBlock];
        });
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    [params setObject:@"spring" forKey:@"enter_from"];
    [params setObject:@"click" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];

    [TTAccountLoginManager presentAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(wSelf.alreadyReport){
                        //已经上报成功了
                        [[ToastManager manager] showToast:@"之前已经上报过了"];
                        return;
                    }
                    
                    [[FHMinisdkManager sharedInstance] taskComplete:self.finishBlock];
                });
            }
        }
    }];
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
    
@end
