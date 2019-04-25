//
//  PopularHashtagData.m
//  Article
//
//  Created by lipeilun on 2018/1/17.
//

#import "PopularHashtagData.h"

@implementation PopularHashtagData
@synthesize forumModelArray = _forumModelArray;

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"hashtagPrimaryID";
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    PopularHashtagData *other = (PopularHashtagData *)object;
    
    if (![self.hashtagPrimaryID isEqualToString:other.hashtagPrimaryID]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    return [self.hashtagPrimaryID hash];
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    PopularHashtagData *model = nil;
    if (!properties) {
        properties = @[
                       @keypath(model, hashtagPrimaryID),
                        @keypath(model, uniqueID),
                        @keypath(model, title),
                        @keypath(model, showMore),
                        @keypath(model, icon),
                        @keypath(model, forumList)
                        ];
    }
    
    return properties;
}

+ (NSDictionary *)keyMapping {
    return @{};
}

+ (PopularHashtagData *)objectForCategory:(NSString *)categoryID uniqueID:(NSString *)uniqueID {
    NSString *primaryKey = [NSString stringWithFormat:@"%@_%@", categoryID, uniqueID];
    return [PopularHashtagData objectForPrimaryKey:primaryKey];
}

+ (PopularHashtagData *)updateWithDictionary:(NSDictionary *)dictionary uniqueID:(NSString *)uniqueID {
    NSString *primaryKey = [NSString stringWithFormat:@"%@_%@", [dictionary tt_stringValueForKey:@"categoryID"], uniqueID];
    NSMutableDictionary *mutableDict = dictionary.mutableCopy;
    [mutableDict setValue:primaryKey forKey:@"hashtagPrimaryID"];
    return [PopularHashtagData updateWithDictionary:mutableDict forPrimaryKey:primaryKey];
}

- (void)updateWithDictionary:(NSDictionary *)dataDict {
    if (!self.managedObjectContext) return;
    
    [super updateWithDictionary:dataDict];
    
    NSDictionary *rawData = [dataDict tt_dictionaryValueForKey:@"raw_data"];
    if (rawData != nil) {
        self.title = [rawData tt_stringValueForKey:@"title"];
        self.showMore = [rawData tt_dictionaryValueForKey:@"show_more"];
        self.icon = [rawData tt_dictionaryValueForKey:@"icon"];
        self.forumList = [rawData tt_arrayValueForKey:@"forum_list"];
    }
    
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:8];
    for (NSDictionary *dict in self.forumList) {
        NSError *error;
        FRForumStructModel *model = [[FRForumStructModel alloc] initWithDictionary:dict error:&error];
        if (!error && model) {
            [models addObject:model];
        }
    }
    
    self.forumModelArray = models;
}

- (NSArray<FRForumStructModel *> *)forumModelArray {
    if ([_forumModelArray isKindOfClass:[NSArray class]] && [_forumModelArray count] > 0) {
        return _forumModelArray;
    }
    
    if (![self.forumList isKindOfClass:[NSArray class]] || [self.forumList count] == 0) {
        return nil;
    }
    
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary *dict in self.forumList) {
        NSError *error;
        FRForumStructModel *model = [[FRForumStructModel alloc] initWithDictionary:dict error:&error];
        if (!error && model) {
            [models addObject:model];
        }
    }
    _forumModelArray = models;
    
    return _forumModelArray;
}

- (void)setForumModelArray:(NSArray<FRForumStructModel *> *)forumModelArray {
    if (_forumModelArray == forumModelArray) {
        return;
    }
    
    _forumModelArray = forumModelArray;
    
    NSMutableArray *models = [NSMutableArray array];
    for (FRForumStructModel *model in forumModelArray) {
        [models addObject:[model toDictionary]];
    }
    self.forumList = models;
    [self save];
}

#pragma mark - public / GET

- (NSString *)showMoreText {
    return [self.showMore tt_stringValueForKey:@"text"];
}

- (NSString *)showMoreSchema {
    return [self.showMore tt_stringValueForKey:@"url"];
}

- (NSString *)dayIconURL {
    return [self.icon tt_stringValueForKey:@"day"];
}

- (NSString *)nightIconURL {
    return [self.icon tt_stringValueForKey:@"night"];
}

@end
