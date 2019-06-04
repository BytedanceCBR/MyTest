//
//  TTMapperRegisterTask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTMapperRegisterTask.h"
#import "TTRelationshipMapper.h"
#import "TTEditUserProfileMapper.h"
#import "TTLaunchDefine.h"

DEC_TASK("TTMapperRegisterTask",FHTaskTypeService,TASK_PRIORITY_HIGH+2);

@implementation TTMapperRegisterTask

- (NSString *)taskIdentifier {
    return @"MapperRegister";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    [[TTProjectLogicManager sharedInstance_tt] registerMapper:[[TTRelationshipMapper alloc] init]];
    [[TTProjectLogicManager sharedInstance_tt] registerMapper:[[TTEditUserProfileMapper alloc] init]];
}

@end
