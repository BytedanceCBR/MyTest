//
//  TSVActivityEntranceModel.m
//  Article
//
//  Created by 王双华 on 2017/12/1.
//

#import "TSVActivityEntranceModel.h"
#import "TTImageInfosModel+TSVJSONValueTransformer.h"

@implementation TSVActivityEntranceModel

+ (JSONKeyMapper *)keyMapper
{
    TSVActivityEntranceModel *model;
    NSDictionary *dict = @{
                           @"id": @keypath(model, groupID),
                           @"raw_data.forum_id": @keypath(model, forumID),
                           @"log_pb": @keypath(model, logPb),
                           @"raw_data.label": @keypath(model, label),
                           @"raw_data.name": @keypath(model, name),
                           @"raw_data.open_url": @keypath(model, openURL),
                           @"raw_data.activity_info": @keypath(model, activityInfo),
                           @"raw_data.style": @keypath(model, style),
                           @"raw_data.cover_image_list": @keypath(model, coverImageModel),
                           @"raw_data.animated_image_list": @keypath(model, animatedImageModel),
                           };
    return [[JSONKeyMapper alloc] initWithDictionary:dict];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    TSVActivityEntranceModel *model = nil;
    NSArray *optionalArray = @[@keypath(model, style),
                                ];
    
    return [optionalArray containsObject:propertyName];
}

- (void)setCoverImageModelWithNSArray:(NSArray *)array
{
    self.coverImageModel = [[TTImageInfosModel class] genImageInfosModelWithNSArray:array];
}

- (NSArray *)JSONObjectForCoverImageModel
{
    return [[TTImageInfosModel class] genNSArrayWithTTImageInfosModel:self.coverImageModel];
}

- (void)setAnimatedImageModelWithNSArray:(NSArray *)array
{
    self.animatedImageModel = [[TTImageInfosModel class] genImageInfosModelWithNSArray:array];
}

- (NSArray *)JSONObjectForAnimatedImageModel
{
    return [[TTImageInfosModel class] genNSArrayWithTTImageInfosModel:self.animatedImageModel];
}

@end
