//
//  FRGameIconCellEntity.m
//  Article
//
//  Created by 王霖 on 16/7/12.
//
//

#import "FRGameIconCellEntity.h"

@implementation FRGameIconCellEntity

+ (JSONKeyMapper *)keyMapper {
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

@end
