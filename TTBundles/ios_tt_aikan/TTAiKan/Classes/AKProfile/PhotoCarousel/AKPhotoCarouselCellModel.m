//
//  AKPhotoCarouselCellModel.m
//  Article
//
//  Created by chenjiesheng on 2018/3/6.
//

#import "AKPhotoCarouselCellModel.h"

@implementation AKPhotoCarouselCellModel

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dict = @{@"imageURL" : @"image_url",
                           @"openURL": @"activity_url",
                           };
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:dict];
}

@end
