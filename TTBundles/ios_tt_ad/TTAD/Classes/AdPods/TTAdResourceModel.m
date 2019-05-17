//
//  TTResourceModel.m
//  Article
//
//  Created by carl on 2017/5/24.
//
//

#import "TTAdResourceModel.h"
#import "NSDictionary+TTAdditions.h"

@implementation TTAdResourceModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *mapper = @{
                             @"content_type" : @"contentType",
                             @"content_size" : @"contentSize",
                             @"resource_url" : @"uri",
                             @"charset" : @"charset",
                             @"resource" : @"resource"
                             };
    return [[JSONKeyMapper alloc] initWithDictionary:mapper];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"resource"]) {
        return NO;
    }
    return YES;
}


- (NSArray<NSString *> *)video_urls {
    NSDictionary *video_info = self.resource;
    NSArray *url_list = [video_info tt_arrayValueForKey:@"url_list"];
    NSMutableArray *video_urls = [NSMutableArray arrayWithCapacity:url_list.count];
    [url_list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            [video_urls addObject:obj];
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSString *url = [obj tt_stringValueForKey:@"url"];
            if (url) {
                [video_urls addObject:url];
            }
        }
    }];
    return video_urls;
}

@end
