//
//  FRColumnEntity.m
//  Article
//
//  Created by 王霖 on 16/8/1.
//
//

#import "FRColumnEntity.h"

@implementation FRColumnEntity

+ (JSONKeyMapper *)keyMapper {
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

@end
