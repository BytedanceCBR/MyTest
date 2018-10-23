//
//  TTABHelperTask.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTABHelperTask.h"
#import "TTABHelper.h"
#import "TTSystemPermClientAB.h"



@implementation TTABHelperTask

- (NSString *)taskIdentifier {
    return @"ABHelper";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    //AB测试，迁移逻辑
    [[TTABHelper sharedInstance_tt] migrationIfNeed];
    
    //AB测试：分组逻辑 >>客户端实验分组应该放到
    [[TTABHelper sharedInstance_tt] distributionIfNeed];
    
    [self.class startClientABs];
}

+ (void)startClientABs
{
    // 系统弹窗客户端实验
    [TTSystemPermClientAB distributeSPAB];
}

@end
