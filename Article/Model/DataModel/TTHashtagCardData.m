//
//  TTHashtagCardData.m
//  Article
//
//  Created by lipeilun on 2017/11/2.
//

#import "TTHashtagCardData.h"

@implementation TTHashtagForumInfoModel

+ (TTHashtagForumInfoModel *)generationForumInfoModelWithDict:(NSDictionary *)dict {
    TTHashtagForumInfoModel *model = [[TTHashtagForumInfoModel alloc] init];
    model.forum_id = [dict tt_stringValueForKey:@"forum_id"];
    model.forum_name = [dict tt_stringValueForKey:@"forum_name"];
    model.concern_id = [dict tt_stringValueForKey:@"concern_id"];
    model.avatar_url = [dict tt_stringValueForKey:@"avatar_url"];
    model.banner_url = [dict tt_stringValueForKey:@"banner_url"];
    model.desc = [dict tt_stringValueForKey:@"desc"];
    model.schema = [dict tt_stringValueForKey:@"schema"];
    model.label = [dict tt_stringValueForKey:@"label"];
    model.share_url = [dict tt_stringValueForKey:@"share_url"];
    model.talk_count = [dict tt_integerValueForKey:@"talk_count"];
    model.follower_count = [dict tt_integerValueForKey:@"follower_count"];
    model.read_count = [dict tt_integerValueForKey:@"read_count"];
    return model;
}

@end

@implementation TTHashtagCardData

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"uniqueID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"uniqueID",
                       @"title",
                       @"forum",
                       ];
    }
    
    return properties;
}

+ (NSDictionary *)keyMapping {
    return @{};
}

- (void)updateWithDictionary:(NSDictionary *)dataDict {
    if (!self.managedObjectContext) return;
    
    [super updateWithDictionary:dataDict];
    
    NSDictionary *rawData = [dataDict tt_dictionaryValueForKey:@"raw_data"];
    if (rawData != nil) {
        self.title = [rawData tt_stringValueForKey:@"title"];
        self.forum = [rawData tt_dictionaryValueForKey:@"forum"];
    }
}

- (TTHashtagForumInfoModel *)forumModel {
    TTHashtagForumInfoModel *info = nil;
    if (self.forum) {
        info = [TTHashtagForumInfoModel generationForumInfoModelWithDict:self.forum];
    }
    return info;
}

@end
