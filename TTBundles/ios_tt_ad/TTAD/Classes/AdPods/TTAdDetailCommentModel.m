//
//  TTAdDetailCommentModel.m
//  Article
//
//  Created by carl on 2016/11/20.
//
//

#import "TTAdDetailCommentModel.h"


@implementation TTAdDetailCommentModel

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id"                    : @"ad_id",
                                                       @"track_url_list"        : @"show_track_urls",
                                                       @"click_track_url_list"  : @"click_track_urls"
                                                       }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"ad_id"]) {
        return NO;
    }
    return YES;
}

@end

