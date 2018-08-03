//
//  EssayData.m
//  Essay
//
//  Created by 于天航 on 12-9-4.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "EssayData.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreArticleEssayCommentObject.h" //神评论
#import "TTVerifyIconHelper.h"
#import "NSDictionary+TTAdditions.h"

@implementation EssayData

- (void)updateWithDictionary:(NSDictionary *)dataDict
{
    [super updateWithDictionary:dataDict];
    
    if([dataDict objectForKey:@"large_image"])
    {
        self.largeImageDict = [dataDict dictionaryValueForKey:@"large_image"
                                                defalutValue:nil];

    }
    
    if([dataDict objectForKey:@"middle_image"])
    {
        self.middleImageDict = [dataDict dictionaryValueForKey:@"middle_image"
                                                defalutValue:nil];
    }
    
    if([dataDict objectForKey:@"comment"])
    {
        self.comment = [dataDict dictionaryValueForKey:@"comment"
                                                defalutValue:nil];
    }

    if ([dataDict objectForKey:@"god_comments"]) {
        self.godComments = [dataDict arrayValueForKey:@"god_comments"
                                       defaultValue:nil];
    }
}

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = [[super persistentProperties] arrayByAddingObjectsFromArray:@[
                       @"comment",
                       @"godComments",
                       @"content",
                       @"createTime",
                       @"dataURL",
                       @"largeImageDict",
                       @"middleImageDict",
                       @"profileImageURL",
                       @"screenName",
                       @"status",
                       @"statusDesc",
                       ]];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[super keyMapping]];
        [dict addEntriesFromDictionary:@{
                                         @"createTime":@"create_time",
                                         @"dataURL":@"data_url",
                                         @"godComments":@"god_comments",
                                         @"profileImageURL":@"profile_image_url",
                                         @"screenName":@"screen_name",
                                         @"statusDesc":@"status_desc",
                                         }];
        properties = [dict copy];
    }
    return properties;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
}

- (TTImageInfosModel *)largeImageModel
{
    if (![self.largeImageDict isKindOfClass:[NSDictionary class]] || [self.largeImageDict count] == 0) {
        return nil;
    }
    TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:self.largeImageDict];
    return model;
}

- (TTImageInfosModel *)middleImageModel
{
    if (![self.middleImageDict isKindOfClass:[NSDictionary class]] || [self.middleImageDict count] == 0) {
        return nil;
    }
    TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:self.middleImageDict];
    return model;
}


- (NSString*)commentContent
{
    NSMutableString *result = [NSMutableString stringWithCapacity:50];
    if([self.comment objectForKey:@"user_name"])
    {
        NSString *userAuthInfo = [self.comment tt_stringValueForKey:@"user_auth_info"];
        if ([TTVerifyIconHelper isVerifiedOfVerifyInfo:userAuthInfo])
        {
            [result appendFormat:@"%@V：", [self.comment objectForKey:@"user_name"]];
        }
        else
        {
            [result appendFormat:@"%@：", [self.comment objectForKey:@"user_name"]];
        }
        
    }
    
    if([self.comment objectForKey:@"text"])
    {
        [result appendFormat:@"%@", [self.comment objectForKey:@"text"]];
    }
    
    return result;
}

- (NSArray *)godCommentObjArray {
    NSMutableArray *array = nil;
    if (self.godComments.count > 0) {
        array = [NSMutableArray arrayWithCapacity:self.godComments.count];
        for (NSDictionary *dict in self.godComments) {
            ExploreArticleEssayCommentObject *commentObj = [[ExploreArticleEssayCommentObject alloc] init];
            [commentObj updateWithDictionary:dict];
            [array addObject:commentObj];
        }
    }
    return array;
}


#pragma mark - 评论测试数据

//- (NSArray *)godComments
//{
//    NSDictionary *dict = @{@"user":@{@"name":@"隔壁老王"}, @"content":@"老师打了精神分裂阿萨德路附近阿斯蒂芬拉；桑德菲杰阿里是否就打算； 爱上了对方就阿里山的房间阿里斯顿就发了发拉丝机法拉盛附加 阿拉山口的减肥了；a地方阿里山发动机啊地方案例；伺服电机阿里；的房间啊；老师放假骄傲了放假阿斯顿飞机；啊老师放假阿里； 老师的开发将阿里放假哦亲文件佛前我就佛啊方式"};
//    NSArray *comments = @[dict,dict];
//    return comments;
//}
//
//- (NSDictionary *)comment
//{
//    NSDictionary *dict = @{@"user_name":@"隔壁老王", @"text":@"老师打了精神分裂阿萨德路附近阿斯蒂芬拉；桑德菲杰阿里是否就打算； 爱上了对方就阿里山的房间阿里斯顿就发了发拉丝机法拉盛附加 阿拉山口的减肥了；a地方阿里山发动机啊地方案例；伺服电机阿里；的房间啊；老师放假骄傲了放假阿斯顿飞机；啊老师放假阿里； 老师的开发将阿里放假哦亲文件佛前我就佛啊方式"};
//    return dict;
//}

@end
