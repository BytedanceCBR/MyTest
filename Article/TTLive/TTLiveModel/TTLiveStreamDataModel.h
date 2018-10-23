//
//  TTLiveStreamDataModel.h
//  TTLive
//
//  Created by xuzichao on 16/3/11.
//  Copyright © 2016年 Nick Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

//返回最终结果
@interface TTLiveStreamDataModel : NSObject

@property (nonatomic, copy)    NSString *status_display;
@property (nonatomic, strong)  NSNumber *status;
@property (nonatomic, strong)  NSNumber *score1;
@property (nonatomic, strong)  NSNumber *score2;
@property (nonatomic, copy)    NSNumber *participated;
@property (nonatomic, strong)  NSArray  *msgRegionArray;

@property (nonatomic, assign) NSUInteger refresh_interval;
@property (nonatomic, strong) NSNumber *infinite_like;
@property (nonatomic, strong) NSNumber *infinite_like_new_display;
@property (nonatomic, strong) NSString *subtitle;

@end

//消息大区间
@interface TTLiveMessageRegionModel : NSObject

@property (nonatomic, strong) NSNumber *cursor_max;
@property (nonatomic, strong) NSNumber *cursor_min;
@property (nonatomic, strong) NSNumber *channel;
@property (nonatomic, strong)  NSArray  *messageArray;
@property (nonatomic, strong)  NSArray  *deleted;
@property (nonatomic, strong)  NSArray  *replyArray;
@property (nonatomic, strong) NSNumber *unread_count;
@property (nonatomic, strong) NSNumber * clean_history;

@end

@class TTLiveMessageProfileModel;
@class TTLiveMessageMediaModel;
@class TTLiveMessageArticleModel;

//单独的消息数据
@interface TTLiveMessageModel : NSObject

@property (nonatomic, strong) NSNumber *liked;
@property (nonatomic, strong) NSNumber *uid;
@property (nonatomic, strong) NSNumber *content_type;
@property (nonatomic, strong) NSNumber *msgId;
@property (nonatomic, strong) NSNumber *cursor;
@property (nonatomic, copy)   NSString *role;
@property (nonatomic, strong) NSNumber *like_count;
@property (nonatomic, copy)   NSString *user_pic;
@property (nonatomic, strong) NSNumber *user_vip;
@property (nonatomic, copy)   NSString *tag;
@property (nonatomic, strong) NSNumber *time;
@property (nonatomic, strong) TTLiveMessageModel *reply;
@property (nonatomic, copy)   NSString *user_name;
@property (nonatomic, copy)   NSString *contentLink;
@property (nonatomic, copy)   NSString *contentOpenUrl;
@property (nonatomic, copy)   NSString *contentText;
@property (nonatomic ,strong) NSArray  *contentAudioArray;
@property (nonatomic ,strong) NSArray  *contentPictureArray;
@property (nonatomic ,strong) NSArray  *contentVideoArray;
@property (nonatomic, strong) TTLiveMessageProfileModel *contentProfile;
@property (nonatomic, strong) TTLiveMessageMediaModel *contentMedia;
@property (nonatomic, strong) TTLiveMessageArticleModel *contentArticle;

@end

//音频
@interface TTLiveMessageAudioModel : NSObject

@property (nonatomic, copy)   NSString *url;
@property (nonatomic, strong) NSNumber *length;
@property (nonatomic, copy)   NSString *audioId;
@property (nonatomic ,strong) NSNumber *size;

@end


//视频
@interface TTLiveMessageVideoModel : NSObject

@property (nonatomic, copy)   NSString *url;
@property (nonatomic, strong) NSNumber *length;
@property (nonatomic, copy)  NSString *videoId;
@property (nonatomic ,strong)   NSNumber *size;
@property (nonatomic, strong) NSDictionary *cover;

@end

//个人名片
@interface TTLiveMessageProfileModel : NSObject

@property (nonatomic, copy) NSString *profileId;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *vip;
@property (nonatomic, copy) NSString *summary;

@end

//头条号名片
@interface TTLiveMessageMediaModel : NSObject

@property (nonatomic, copy) NSString *mediaId;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *summary;

@end

//文章
@interface TTLiveMessageArticleModel : NSObject

@property (nonatomic, copy) NSString *articleId;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *sourceIcon;
@property (nonatomic, copy) NSString *sourceName;

@end
