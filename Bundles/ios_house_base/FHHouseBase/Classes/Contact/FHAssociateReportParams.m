//
//  FHAssociateReportParams.m
//  FHHouseBase
//
//  Created by 张静 on 2020/4/2.
//

#import "FHAssociateReportParams.h"

@implementation FHAssociateReportParams

+ (JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperForSnakeCase];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
