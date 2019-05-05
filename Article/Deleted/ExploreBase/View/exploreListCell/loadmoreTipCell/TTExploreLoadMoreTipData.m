//
//  TTExploreLoadMoreTipData.m
//  Article
//
//  Created by carl on 2018/1/29.
//

#import "TTExploreLoadMoreTipData.h"

@implementation TTExploreLoadMoreTipData

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    NSParameterAssert([dictionary isKindOfClass:[NSDictionary class]]);
    
    [super updateWithDictionary:dictionary];
    NSDictionary *raw_data = dictionary[@"raw_data"];
    if (raw_data && [raw_data isKindOfClass:[NSDictionary class]]) {
        self.openURL = [raw_data tt_stringValueForKey:@"open_url"];
        self.display_info = [raw_data tt_stringValueForKey:@"display_info"];
        self.enableLoadmore = [raw_data tt_boolValueForKey:@"enable_loadmore"];
    }
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        NSMutableArray *props = [NSMutableArray arrayWithArray:[super persistentProperties]];
        properties = [props arrayByAddingObjectsFromArray:@[
                                                            @"openURL",
                                                            @"display_info",
                                                            @"enableLoadmore"]];
    };
    return properties;
}

//注.此处的映射，客户端以topic表示专题， 服务器端后面修改为subject。
+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[super keyMapping]];
        [dict addEntriesFromDictionary:@{
                                         @"openURL":@"open_url",
                                         @"display_info":@"display_info",
                                         @"enableLoadmore":@"enable_loadmore"
                                        }];
        properties = [dict copy];
    }
    return properties;
}

@end
