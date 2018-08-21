//
//  HuoShanTalentBanner.m
//  Article
//
//  Created by Chen Hong on 2016/11/20.
//
//

#import "HuoShanTalentBanner.h"
#import "TTImageInfosModel.h"

@implementation HuoShanTalentBanner

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"uniqueID",
                       @"bannerId",
                       @"coverImageInfo",
                       @"schemaUrl",
                       ];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{
                       @"bannerId":@"banner_id",
                       @"schemaUrl":@"schema_url",
                       };
    }
    return properties;
}

- (void)updateWithDictionary:(NSDictionary *)dataDict{
    [super updateWithDictionary:dataDict];
    
    if ([dataDict objectForKey:@"cover_image_info"]) {
        self.coverImageInfo = [dataDict tt_dictionaryValueForKey:@"cover_image_info"];
    }
}

- (nullable TTImageInfosModel *)coverImageModel {
    if (![self.coverImageInfo isKindOfClass:[NSDictionary class]] || [self.coverImageInfo count] == 0) {
        return nil;
    }
    TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:self.coverImageInfo];
    return model;
}

@end
