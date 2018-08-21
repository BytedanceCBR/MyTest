//
//  TTLiveOverallInfoModel.h
//  TTLive
//
//  Created by xuzichao on 16/3/17.
//  Copyright © 2016年 Nick Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTLiveOverallInfoModel : NSObject

//直播类型
@property (nonatomic, strong)   NSNumber *liveType;

// 事件统计
@property (nonatomic, copy) NSString *referFrom;  //TODO:从哪个入口进来的,从schema取出来
@property (nonatomic, copy) NSString *enterFrom;
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, copy) NSDictionary *logPb;
@property (nonatomic, strong) NSNumber *groupSource;
@property (nonatomic, copy)   NSString *categoryID;
@property (nonatomic, strong) NSArray *channelItems;

@property (nonatomic, assign) BOOL cameraBeautyEnable;
@property (nonatomic, assign) BOOL initializeWithSelfieMode;

//活动信息
@property (nonatomic, copy)     NSString *liveId;
@property (nonatomic, strong)   NSNumber *liveStateNum;
@property (nonatomic, strong)   UIImage  *liveShareImage;
@property (nonatomic, copy)     NSString *liveShareImageURL;
@property (nonatomic, copy)     NSString *liveShareURL;
@property (nonatomic, strong)   NSNumber *liveShareGroupId;
@property (nonatomic, copy)     NSString *liveTitle;
@property (nonatomic, copy)     NSString *liveDescription;
@property (nonatomic, copy)     NSString *liveAbstract;
@property (nonatomic, copy)     NSString *liveContent;
@property (nonatomic, strong)   NSArray  *liveLeaders;
@property (nonatomic, strong)   NSArray  *liveRoles;

//登陆用户信息
@property (nonatomic, copy)     NSString *userId;
@property (nonatomic, strong)   NSString *userAvatarUrl;
@property (nonatomic, copy)     NSString *userName;
@property (nonatomic, copy)     NSString *userRoleName;

//广告相关信息
@property (nonatomic, copy)     NSString *adId;
@property (nonatomic, copy)     NSString *logExtra;

//置顶消息ID
@property (nonatomic, copy)     NSString *topMessageID;

@end
