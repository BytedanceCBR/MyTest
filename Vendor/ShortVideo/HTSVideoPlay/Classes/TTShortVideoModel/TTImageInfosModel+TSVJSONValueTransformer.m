//
//  TTImageInfosModel+TSVJSONValueTransformer.m
//  HTSVideoPlay
//
//  Created by 王双华 on 2017/12/1.
//

#import "TTImageInfosModel+TSVJSONValueTransformer.h"
#import "TTImageInfosModel+Private.h"

@implementation TTImageInfosModel (TSVJSONValueTransformer)

+ (TTImageInfosModel *)genImageInfosModelWithNSArray:(NSArray *)array
{
    TTImageInfosModel *res = nil;
    if ([array isKindOfClass:[NSArray class]] && [array count] > 0) {
        NSDictionary *dict = [array firstObject];
        if ([dict isKindOfClass:[NSDictionary class]] && [dict count] > 0) {
            res = [[TTImageInfosModel alloc] initWithDictionary:dict];
        }
    }
    return res;
}

+ (NSArray *)genNSArrayWithTTImageInfosModel:(TTImageInfosModel *)model
{
    NSMutableArray *res = [NSMutableArray array];
    NSDictionary *dict = [model originalDict];
    if ([dict count] > 0) {
        [res addObject:dict];
    }
    return [res copy];
}

@end
