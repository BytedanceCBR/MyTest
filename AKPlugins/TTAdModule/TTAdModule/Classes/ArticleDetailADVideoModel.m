//
//  ArticleDetailADVideoModel.m
//  Article
//
//  Created by huic on 16/5/5.
//
//

#import "ArticleDetailADVideoModel.h"

@implementation ArticleDetailADVideoModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *mapper = @{
                             @"cover_url" : @"coverURL",
                             @"video_id" : @"videoID",
                             @"video_duration" : @"videoDuration",
                             @"width" : @"videoWidth",
                             @"height" : @"videoHeight"
                             };
    return [[JSONKeyMapper alloc] initWithDictionary:mapper];
}

@end
