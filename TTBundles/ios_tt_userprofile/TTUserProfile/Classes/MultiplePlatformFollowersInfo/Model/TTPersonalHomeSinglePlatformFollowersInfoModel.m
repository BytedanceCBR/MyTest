//
//  TTPersonalHomeSinglePlatformFollowersInfoModel.m
//  Article
//
//  Created by 邱鑫玥 on 2018/1/9.
//

#import "TTPersonalHomeSinglePlatformFollowersInfoModel.h"

@implementation TTPersonalHomeSinglePlatformFollowersInfoModel

+ (JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
