//
//  FHMinisdkManager.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/2.
//

#import "FHMinisdkManager.h"
//#import <BDDiamond20/BDDTaskCenterManager.h>
//#import <TTInstallIDManager.h>
//
//@interface FHMinisdkManager ()<BDDTaskCenterManagerProtocol>
//
//@end

@implementation FHMinisdkManager
    
+ (instancetype)sharedInstance {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });

    return manager;
}

//- (NSString *)taskID {
//    return @"104";
//}
//
//- (void)initTask {
//    [BDDTaskCenterManager sharedInstance].delegate = self;
//    [[BDDTaskCenterManager sharedInstance] uploadAppFirstOpenAfterDownload];
//}
//
//- (void)appBecomeActive:(NSString *)ackToken {
//    [[BDDTaskCenterManager sharedInstance] setAckToken:ackToken];
//}
//
//- (void)taskComplete:(BDDTaskFinishBlock)finishBlock {
//    [[BDDTaskCenterManager sharedInstance] updateTaskID:[self taskID] finishBlock:finishBlock];
//}
//
//#pragma mark - BDDTaskCenterManagerProtocol
//
//- (NSString *)deviceId {
//    return [[TTInstallIDManager sharedInstance] deviceID];
//}
//
//- (NSString *)aid {
//    return @"1370";
//}
    
@end
