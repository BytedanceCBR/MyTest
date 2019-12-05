//
//  FHMinisdkManager.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/2.
//

#import "FHMinisdkManager.h"
#import <TTInstallIDManager.h>
#import <TTRoute.h>

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

- (NSString *)taskID {
    return @"311";
}

- (void)initTask {
    [BDMTaskCenterManager sharedInstance].delegate = self;
    [[BDMTaskCenterManager sharedInstance] uploadAppFirstOpenAfterDownload];
}

- (void)appBecomeActive:(NSString *)ackToken {
    [[BDMTaskCenterManager sharedInstance] setAckToken:ackToken];
}

- (void)taskComplete:(BDDTaskFinishBlock)finishBlock {
    [[BDMTaskCenterManager sharedInstance] updateTaskID:[self taskID] finishBlock:finishBlock];
}
    
- (void)seeVideo {
    //执行一些操作
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //doSomething
        [[FHMinisdkManager sharedInstance] taskComplete:^(BOOL isCompleted, NSError *error) {
            NSLog(@"我完成了任务");
        }];
    });
    
    //以上为联调测试使用
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSString *routeUrl = @"sslocal://awemevideo?category_name=my_comments&enter_from=personal_comment_list&gd_ext_json=%7B%22group_id_str%22%3A%226751326314264792332%22%2C%22impr_id%22%3A%22201912041624180100140510970E6F682E%22%2C%22is_reposted%22%3A%221%22%2C%22repost_gid%22%3A%226756837337651216392%22%7D&group_id=6751326314264792332&group_source=19&item_id=6751326314264792332&load_more=0&log_pb=%7B%22group_id%22%3A%226751326314264792332%22%2C%22group_source%22%3A%2219%22%2C%22impr_id%22%3A%22201912041624180100140510970E6F682E%22%2C%22social_group_id%22%3A%220%22%7D&request_id=201912041624180100140510970E6F682E";
//        NSURL *openUrl = [NSURL URLWithString:routeUrl];
//        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
//    });
}

#pragma mark - BDDTaskCenterManagerProtocol

- (NSString *)deviceId {
    return [[TTInstallIDManager sharedInstance] deviceID];
}

- (NSString *)appId {
    return @"1370";
}
    
@end
