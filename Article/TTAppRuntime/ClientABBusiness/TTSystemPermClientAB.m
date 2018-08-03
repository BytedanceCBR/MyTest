//
//  TTSystemPermClientAB.m
//  Article
//
//  Created by zuopengliu on 2/11/2017.
//

#import "TTSystemPermClientAB.h"
#import <TTABManager/TTABManager.h>
#import <TTABManager/TTABHelper.h>
#import <TTDialogDirector/TTDialogDirector+ClientAB.h>
#import <UIAlertView+Blocks.h>



@implementation TTSystemPermClientAB

+ (void)distributeSPAB
{
    [self.class dialogDirectorLoadSPOptimizationType];
}

+ (void)dialogDirectorLoadSPOptimizationType
{
    NSString *optFeatureValueString = [[TTABHelper sharedInstance_tt] valueForFeatureKey:@"launch_system_permissions_type"];
    
    TTLaunchSystemPermOptimizationType distributionType = TTLaunchSystemPermOptimizationTypeNone;
    if (isEmptyString(optFeatureValueString) || [optFeatureValueString isEqualToString:@"move_none"]) {
        distributionType = TTLaunchSystemPermOptimizationTypeNone;
    } else if ([optFeatureValueString isEqualToString:@"move_location"]) {
        distributionType = TTLaunchSystemPermOptimizationTypeMoveLoc;
    } else if ([optFeatureValueString isEqualToString:@"move_location_notification"]) {
        distributionType = TTLaunchSystemPermOptimizationTypeMoveNote | TTLaunchSystemPermOptimizationTypeMoveLoc;
    }
    
    [TTDialogDirector setSystemPermOptimizationType:distributionType];
}

@end
