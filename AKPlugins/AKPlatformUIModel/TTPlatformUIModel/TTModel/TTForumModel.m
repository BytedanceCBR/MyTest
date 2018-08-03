//
//  TTForumModel.m
//  Article
//
//  Created by Zhang Leonardo on 15-1-15.
//
//

#import "TTForumModel.h"
#import "TTBaseMacro.h"

@implementation TTForumTableItem

@end

@implementation TTForumModel

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id": @"forumID",
                                                       @"avatar_url": @"avatarURLString" ,
                                                       @"banner_url": @"bannerURLString",
                                                       @"follower_count": @"followerCount",
                                                       @"talk_count": @"talkCount",
                                                       @"user_forum_unread_count": @"todayTalkCount",
                                                       @"is_followed":@"isFollowed",
                                                       @"desc": @"desc",
                                                       @"count_desc": @"countDesc"}];
}

- (instancetype)initWithDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.forumID = [NSString stringWithFormat:@"%@", [data objectForKey:@"id"]];
        self.name = [data objectForKey:@"name"];
        self.avatarURLString = [data objectForKey:@"avatar_url"];
        self.bannerURLString = [data objectForKey:@"banner_url"];
        self.desc = [data objectForKey:@"desc"];
        self.followerCount = [[data objectForKey:@"participant_count"] intValue];
        self.talkCount = [[data objectForKey:@"talk_count"] intValue];
        self.todayTalkCount = [[data objectForKey:@"user_forum_unread_count"] intValue];
        self.isFollowed = [[data objectForKey:@"is_followed"] intValue];
        self.shareURL = data[@"share_url"];
        self.recomText = data[@"share_content"];
        self.countDesc = data[@"count_desc"];
        NSMutableArray *tables = [data objectForKey:@"table"];
        if (!SSIsEmptyArray(tables)) {
            NSMutableArray *modelTables = [NSMutableArray arrayWithCapacity:tables.count];
            [tables enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                TTForumTableItem *item = [[TTForumTableItem alloc] init];
                item.name = obj[@"name"];
                item.URLString = obj[@"url"];
                if ([obj valueForKey:@"refresh_interval"]) {
                    item.refreshInterval = [obj[@"refresh_interval"] doubleValue];
                } else {
                    item.refreshInterval = 10;
                }
                item.joinCommonParameters = [obj[@"need_common_params"] boolValue];
                item.extra = obj[@"extra"];
                [modelTables addObject:item];
            }];
            
            self.forumTables = modelTables;
        }
    }
    return self;
}

@end
