//
//  FHMapSearchConfigModel.m
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHMapSearchConfigModel.h"
#import "FHHouseType.h"
#import "NSMutableDictionary+FHQueryItems.h"

@implementation FHMapSearchConfigModel

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    NSMutableDictionary *validDict = [dict mutableCopy];
    [validDict fh_clearInvalidKeysIfNeed];
    return [super initWithDictionary:validDict error:err];
}

+(JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperForSnakeCase];
}

+(BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

-(NSString *)houseTypeName
{
    if (self.houseType == FHHouseTypeRentHouse) {
        return @"rent";
    }
    return @"old";
}

@end
