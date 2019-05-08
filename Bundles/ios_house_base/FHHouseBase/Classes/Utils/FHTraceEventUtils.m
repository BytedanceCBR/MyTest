//
//  FHTraceEventUtils.m
//  FHHouseBase
//
//  Created by fupeidong on 2019/1/8.
//

#import "FHTraceEventUtils.h"

@implementation FHTraceEventUtils

+ (NSString *)generateEnterfrom:(NSString *)categoryName {
    if ([@"f_house_news" isEqualToString:categoryName]) {
        return @"click_headline";
    }
    if ([@"related" isEqualToString:categoryName]) {
        return @"click_related";
    }
    if ([@"favorite" isEqualToString:categoryName]) {
        return @"click_favorite";
    }
    return @"click_category";
}

+ (NSString *)generateEnterfrom:(NSString *)categoryName enterFrom:(NSString *)enterFrom {
    if (categoryName != nil && ![categoryName isEqualToString:@""]  && ![enterFrom hasSuffix:categoryName]) {
        return enterFrom;
    }
    if ([@"f_house_news" isEqualToString:categoryName]) {
        return @"click_headline";
    }
    if ([@"related" isEqualToString:categoryName]) {
        return @"click_related";
    }
    if ([@"favorite" isEqualToString:categoryName]) {
        return @"click_favorite";
    }
    return @"click_category";
}

@end
