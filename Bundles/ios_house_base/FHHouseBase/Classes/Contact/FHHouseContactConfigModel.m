//
//  FHHouseContactConfigModel.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/4/22.
//

#import "FHHouseContactConfigModel.h"

@implementation FHHouseContactConfigModel

+(JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperForSnakeCase];
}

+(BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}


@end
