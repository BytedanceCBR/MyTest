//
//  TSVActivityBannerModel.m
//  Article
//
//  Created by 王双华 on 2017/12/1.
//

#import "TSVActivityBannerModel.h"
#import "TTImageInfosModel+TSVJSONValueTransformer.h"

@implementation TSVActivityBannerModel

+ (JSONKeyMapper *)keyMapper
{
    TSVActivityBannerModel *model;
    NSDictionary *dict = @{
                           @"id": @keypath(model, groupID),
                           @"log_pb": @keypath(model, logPb),
                           @"raw_data.forum_id": @keypath(model, forumID),
                           @"raw_data.cover_image_list": @keypath(model, coverImageModel),
                           @"raw_data.open_url": @keypath(model, openURL),
                           };
    return [[JSONKeyMapper alloc] initWithDictionary:dict];
}

- (void)setCoverImageModelWithNSArray:(NSArray *)array
{
    self.coverImageModel = [[TTImageInfosModel class] genImageInfosModelWithNSArray:array];
}

- (NSArray *)JSONObjectForCoverImageModel
{
    return [[TTImageInfosModel class] genNSArrayWithTTImageInfosModel:self.coverImageModel];
}

@end
