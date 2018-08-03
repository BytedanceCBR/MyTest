//
//  TTFlowStatisticsManager+Helper.m
//  Pods
//
//  Created by 王双华 on 2017/7/17.
//
//

#import "TTFlowStatisticsManager+Helper.h"

@implementation TTFlowStatisticsManager(Helper)

- (BOOL)hts_isFreeFlow
{
    return  [[TTFlowStatisticsManager sharedInstance] flowStatisticsEnable] &&
            [TTFlowStatisticsManager sharedInstance].isSupportFreeFlow &&
            [TTFlowStatisticsManager sharedInstance].isOpenFreeFlow &&
            ![TTFlowStatisticsManager sharedInstance].isExcessFlow;
}
@end
