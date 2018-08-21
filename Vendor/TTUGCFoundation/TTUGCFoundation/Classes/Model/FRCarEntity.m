//
//  FRCarEntity.m
//  Article
//
//  Created by 王霖 on 16/7/8.
//
//

#import "FRCarEntity.h"

@implementation FRCarEntity

+ (JSONKeyMapper *)keyMapper {
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

@end
