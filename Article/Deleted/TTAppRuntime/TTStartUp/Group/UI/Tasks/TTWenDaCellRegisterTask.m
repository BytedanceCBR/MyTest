//
//  TTStatusBarHiddenTask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTWenDaCellRegisterTask.h"

#import "WDCellRouteCenter.h"
#import "WDCellGroupService.h"

#import "TTCategoryAddToFirstPageCell.h"
#import "TTCategoryAddToFirstPageData.h"

#import "WDLastReadCellData.h"
#import "ExploreLastReadCell.h"

@implementation TTWenDaCellRegisterTask

- (NSString *)taskIdentifier {
    return @"WenDaCellRegister";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    
    //注册其他频道的cell到问答频道
    [[WDCellGroupService sharedInstance] registerCell:[TTCategoryAddToFirstPageCell class]
                                          forCellData:[TTCategoryAddToFirstPageData class]];
    [[WDCellGroupService sharedInstance] registerCell:[ExploreLastReadCell class]
                                          forCellData:[WDLastReadCellData class]];
    
    //注册服务
    [[WDCellRouteCenter sharedInstance] registerCellGroup:[WDCellGroupService sharedInstance]];
}

@end
