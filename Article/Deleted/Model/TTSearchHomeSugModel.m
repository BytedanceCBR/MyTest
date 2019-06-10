//
//  TTSearchHomeSugModel.m
//  Article
//
//  Created by 王双华 on 16/12/21.
//
//

#import "TTSearchHomeSugModel.h"

@implementation TTSearchHomeSugModel

@end

@implementation TTSearchWeatherModel

@end

@implementation TTSearchHomeSugItem

+ (JSONKeyMapper *)keyMapper {
    
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"call_per_refresh":@"callPerRefresh",
                                                @"homepage_search_suggest":@"homePageSearchSuggest"}];
}

@end
