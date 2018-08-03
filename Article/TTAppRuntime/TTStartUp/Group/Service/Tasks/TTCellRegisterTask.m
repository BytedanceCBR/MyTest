//
//  TTCellRegisterTask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTCellRegisterTask.h"
#import "ExploreCellHelper.h"
//#import "TTForumCellHelper.h"
//#import "TTWendaCellHelper.h"
#import "TTADCellHelper.h"

@implementation TTCellRegisterTask

- (NSString *)taskIdentifier {
    return @"CellRegister";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    //注册混排列表cell
    [ExploreCellHelper registerCellBridge];
//    [TTForumCellHelper registerCellViewAndCellDataHelper];
//    [TTWendaCellHelper registerCellViewAndCellDataHelper];
    [TTADCellHelper registerCellViewAndCellDataHelper];
}

@end
