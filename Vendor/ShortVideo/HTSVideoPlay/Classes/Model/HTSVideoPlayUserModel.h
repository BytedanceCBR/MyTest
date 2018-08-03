//
//  HTSVideoPlayUserModel.h
//  LiveStreaming
//
//  Created by Quan Quan on 16/2/19.
//  Copyright © 2016年 Bytedance. All rights reserved.
//


#import <Mantle/Mantle.h>

typedef NS_ENUM(NSUInteger, HTSVideoPlayFollowStatus) {
    HTSVideoPlayFollowStatusFailed            = -1,
    HTSVideoPlayFollowStatusUnFollow          = 0, //未关注
    HTSVideoPlayFollowStatusFollowed          = 1, //已关注
    HTSVideoPlayFollowStatusFollowingFollowed = 2, //双向关注
    HTSVideoPlayFollowStatusUnDefined,
};


@interface HTSVideoPlayURLModel: MTLModel <MTLJSONSerializing>
@property (nonatomic, strong, readonly) NSArray  *urlList;
@property (nonatomic, strong, readonly) NSString *uri;
@end


@interface HTSVideoPlayUserStatsModel : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong, readonly) NSNumber *userID;
@property (nonatomic, strong, readonly) NSNumber *itemCount;
@property (nonatomic, strong, readonly) NSNumber *recordCount;
@property (nonatomic, strong, readonly) NSNumber *followingCount;
@property (nonatomic, strong, readonly) NSNumber *followerCount;
@property (nonatomic, strong, readonly) NSNumber *diamondCount;
@property (nonatomic, strong, readonly) NSNumber *dailyFanTicketCount;
@property (nonatomic, strong, readonly) NSNumber *dailyIncome;
@end


@interface HTSVideoPlayUserModel : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong, readonly) NSNumber *userID;
@property (nonatomic, strong, readonly) NSNumber *shortID;
@property (nonatomic, strong, readonly) NSString *nickName;
@property (nonatomic, strong, readonly) NSString *signature;
@property (nonatomic, strong, readonly) NSNumber *level;
@property (nonatomic, strong, readonly) NSNumber *birthday;
@property (nonatomic, assign, readonly) BOOL birthdayVaild;
@property (nonatomic, strong, readonly) NSString *birthdayDescription;
@property (nonatomic, strong, readonly) NSString *constellation;
@property (nonatomic, strong, readonly) NSString *city;
@property (nonatomic, assign) HTSVideoPlayFollowStatus followStatus;
@property (nonatomic, assign, readonly) BOOL blockStatus;
@property (nonatomic, strong, readonly) HTSVideoPlayUserStatsModel *stats;
@property (nonatomic, strong, readonly) NSArray<HTSVideoPlayUserModel *>  *topFans;
@property (nonatomic, strong, readonly) HTSVideoPlayURLModel *avatarLarge;
@property (nonatomic, strong, readonly) HTSVideoPlayURLModel *avatarThumb;
@property (nonatomic, strong, readonly) HTSVideoPlayURLModel *avatarMedium;
@property (nonatomic, strong, readonly) NSNumber *ticketCount;
@property (nonatomic, strong, readonly) NSString *sinaVerifiedReason;
@property (nonatomic, assign, readonly) BOOL sinaVerified;
@property (nonatomic, strong, readonly) NSNumber *topVipNo;/// 他人可以下载我发布的视频
@property (nonatomic, assign, readonly) BOOL canOthersDownloadVideo;
@end
