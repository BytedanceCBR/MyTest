//
//  TSVRecUserSinglePersonModel.m
//  Article
//
//  Created by 王双华 on 2017/9/27.
//

#import "TSVRecUserSinglePersonModel.h"

@implementation TSVRecUserSinglePersonModel

+ (JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

