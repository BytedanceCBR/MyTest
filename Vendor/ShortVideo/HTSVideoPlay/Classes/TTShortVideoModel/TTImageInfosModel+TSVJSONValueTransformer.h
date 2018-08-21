//
//  TTImageInfosModel+TSVJSONValueTransformer.h
//  HTSVideoPlay
//
//  Created by 王双华 on 2017/12/1.
//

#import <TTImage/TTImageInfosModel.h>

@interface TTImageInfosModel (TSVJSONValueTransformer)

+ (TTImageInfosModel *)genImageInfosModelWithNSArray:(NSArray *)array;
+ (NSArray *)genNSArrayWithTTImageInfosModel:(TTImageInfosModel *)model;

@end
