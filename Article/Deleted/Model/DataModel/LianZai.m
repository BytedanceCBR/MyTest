//
//  LianZai.m
//  
//
//  Created by 邱鑫玥 on 16/7/18.
//
//

#import "LianZai.h"
#import "TTImageInfosModel.h"

@implementation LianZai

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"uniqueID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = [[super persistentProperties] arrayByAddingObjectsFromArray:@[
                       @"abstract",
                       @"actionList",
                       @"chapterList",
                       @"coverImageInfo",
                       @"filterWords",
                       @"mediaInfo",
                       @"openURL",
                       @"serialID",
                       @"serialType",
                       @"source",
                       @"sourceOpenURL",
                       @"title",
                       @"serialStyle",
                       @"showMoreText",
                       ]];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{
                       @"commentCount":@"comment_count",//评论数
                       @"serialID":@"id",// 连载ID
                       @"openURL":@"open_url",//跳转url
                       @"serialStyle":@"serial_style",//封面在左还是在右
                       @"serialType":@"serial_type",//连载类别
                       @"showMoreText":@"show_more_text",//展示更多文案
                       @"sourceOpenURL":@"source_open_url",//来源跳转链接
                       };
    }
    return properties;
}

- (void)updateWithDictionary:(NSDictionary *)dataDict{
//    if(!self.managedObjectContext){
//        return;
//    }
    
    [super updateWithDictionary:dataDict];
    
    // 封面图
    if ([dataDict objectForKey:@"cover_image_info"]){
        self.coverImageInfo = [dataDict tt_dictionaryValueForKey:@"cover_image_info"];
    }
    
    // PGC信息
    if ([dataDict objectForKey:@"media_info"]){
        self.mediaInfo = [dataDict tt_dictionaryValueForKey:@"media_info"];
    }
    
    // 不喜欢的理由
    if ([dataDict objectForKey:@"filter_words"]){
        self.filterWords = [dataDict tt_arrayValueForKey:@"filter_words"];
    }
    
    // 下拉更多列表
    if ([dataDict objectForKey:@"action_list"]){
        self.actionList = [dataDict tt_arrayValueForKey:@"action_list"];
    }
    
    // 章节列表
    if ([dataDict objectForKey:@"chapter_list"]){
        self.chapterList = [dataDict tt_arrayValueForKey:@"chapter_list"];
    }
}

- (nullable TTImageInfosModel *)coverImageModel {
    if (![self.coverImageInfo isKindOfClass:[NSDictionary class]] || [self.coverImageInfo count] == 0) {
        return nil;
    }
    TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:self.coverImageInfo];
    return model;
}

- (nullable NSString *)newestTitle{
    if (![self.chapterList isKindOfClass:[NSArray class]]||
        [self.chapterList count] < 2){
        return nil;
    }
    if(![self.chapterList[0] isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    return [self.chapterList[0] objectForKey:@"title"];
}

- (nullable NSString *)newestInfo{
    if (![self.chapterList isKindOfClass:[NSArray class]]||
        [self.chapterList count] < 2){
        return nil;
    }
    if(![self.chapterList[0] isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    return [self.chapterList[0] objectForKey:@"text"];
}

- (nullable NSString *)readedTitle{
    if (![self.chapterList isKindOfClass:[NSArray class]]||
        [self.chapterList count] < 2){
        return nil;
    }
    if(![self.chapterList[1] isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    return [self.chapterList[1] objectForKey:@"title"];
}

- (nullable NSString *)readedInfo{
    if (![self.chapterList isKindOfClass:[NSArray class]]||
        [self.chapterList count] < 2){
        return nil;
    }
    if(![self.chapterList[1] isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    return [self.chapterList[1] objectForKey:@"text"];
}



@end
