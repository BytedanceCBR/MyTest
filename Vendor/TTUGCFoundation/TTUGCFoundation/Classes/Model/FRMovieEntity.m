//
//  FRMovieEntity.m
//  Article
//
//  Created by 王霖 on 16/8/4.
//
//

#import "FRMovieEntity.h"

@implementation FRMovieEntity

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"name": @"name",
                                                       @"english_name": @"englishName",
                                                       @"type": @"type",
                                                       @"area_info": @"areaInfo",
                                                       @"actors": @"actors",
                                                       @"rate": @"rate",
                                                       @"days": @"days",
                                                       @"image_url": @"imageUrl",
                                                       @"movie_id": @"movieID",
                                                       @"uniqueID": @"uniqueID",
                                                       @"group_flags": @"groupFlags",
                                                       @"purchase_url": @"purchaseUrl",
                                                       @"rate_user_count": @"rateUserCount",
                                                       @"produce_area": @"produceArea",
                                                       @"release_area": @"releaseArea",
                                                       @"release_date": @"releaseDate",
                                                       @"duration": @"duration",
                                                       @"directors_str": @"directorsStr",
                                                       @"actors_str": @"actorsStr"
                                                       }];
}

@end
