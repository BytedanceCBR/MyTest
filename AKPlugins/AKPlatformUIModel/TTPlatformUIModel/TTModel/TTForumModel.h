//
//  TTForumModel.h
//  Article
//
//  Created by Zhang Leonardo on 15-1-15.
//
//  讨论区model

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "TTApiModel.h"


@interface TTForumTableItem : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *URLString;
@property(nonatomic) BOOL   joinCommonParameters;
@property(nonatomic, copy) NSDictionary *extra;
@property(nonatomic) NSTimeInterval refreshInterval;

//table_type: 1,
//name: u"新闻",
//url: "http://m.toutiao.com/xxxx",
//extra: {
//category: "social"
//}

@end

@interface TTForumModel : TTApi

@property(nonatomic, strong)NSString * forumID;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *avatarURLString;
@property(nonatomic, strong)NSString *desc;
@property(nonatomic, strong)NSString *countDesc;
@property(nonatomic, strong)NSString *bannerURLString;
@property(nonatomic, assign)NSInteger followerCount;
@property(nonatomic, assign)NSInteger talkCount; // 话题贴数
@property(nonatomic, assign)NSInteger todayTalkCount; // 今日话题贴数
@property(nonatomic, assign)BOOL isFollowed;

@property(nonatomic, copy) NSArray *forumTables;
@property(nonatomic, copy)NSString * shareURL;  //分享URL
@property(nonatomic, copy)NSString * recomText; //话题分享推荐语

- (instancetype)initWithDictionary:(NSDictionary *)data;
@end
