//
//  FRGameEntity.m
//  Article
//
//  Created by 王霖 on 16/7/8.
//
//

#import "FRGameEntity.h"

@implementation FRGameEntity

+ (JSONKeyMapper *)keyMapper {
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

@end
