//
//  TSVDownloadPromotionModel.m
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/9/12.
//

#import "TSVDownloadPromotionModel.h"
#import <ReactiveObjC/ReactiveObjC.h>

@implementation TSVDownloadPromotionModel

+ (JSONKeyMapper *)keyMapper
{
    TSVDownloadPromotionModel *model;
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @keypath(model, appDownloadText): @"raw_data.app_download_text",
                                                                   @keypath(model, coverImage): @"raw_data.cover_image",
                                                                   @keypath(model, cellStyle): @"raw_data.cell_ctrls",
                                                                   @keypath(model, groupSource): @"raw_data.group_source",                                                       }];
}

- (void)setCoverImageWithNSDictionary:(NSDictionary *)dict
{
    self.coverImage = [[TTImageInfosModel alloc] initWithDictionary:dict];
}

@end
