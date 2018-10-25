//
//  FHMapSearchConfigModel.m
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHMapSearchConfigModel.h"

@implementation FHMapSearchConfigModel

+(JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperForSnakeCase];
}

+(BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
