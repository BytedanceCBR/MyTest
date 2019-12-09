//
//  FHMinisdkManager.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/2.
//

#import "FHMinisdkManager.h"
#import <TTInstallIDManager.h>
#import <TTRoute.h>

//固定值
#define taskID @"311"

@interface FHMinisdkManager ()<BDMTaskCenterManagerProtocol>

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
    
- (void)seeVideo:(NSString *)vid {
    //执行一些操作
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //doSomething
        [[FHMinisdkManager sharedInstance] taskComplete:^(BOOL isCompleted, NSError *error) {
            if(isCompleted){
                NSLog(@"我完成了任务");
            }else{
                //会加一个重试逻辑
            }
        }];
    });
    
    //以上为联调测试使用
    
    if(vid.length > 0){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *routeUrl = [NSString stringWithFormat:@"sslocal://awemevideo?category_name=spring&enter_from=spring&group_id=%@&group_source=19&item_id=%@&load_more=0&spring=1",vid,vid];
            NSURL *openUrl = [NSURL URLWithString:routeUrl];
            [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
        });
    }
}

#pragma mark - BDDTaskCenterManagerProtocol

- (NSString *)deviceId {
    return [[TTInstallIDManager sharedInstance] deviceID];
}

- (NSString *)appId {
    return @"1370";
}
    
@end
