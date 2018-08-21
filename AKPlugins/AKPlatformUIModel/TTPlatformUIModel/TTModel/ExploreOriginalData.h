//
//  ExploreOriginalData.h
//  Article
//
//  Created by Yu Tianhang on 13-2-25.
//
//

#import "TTEntityBase.h"

#define kExploreOriginalDataUpdateNotification @"kExploreOriginalDataUpdateNotification"

@interface ExploreOriginalData : TTEntityBase

@property (nonatomic, assign) int buryCount;
@property (nonatomic, assign) int commentCount;
@property (nonatomic, assign) int diggCount;
@property (nonatomic, retain, nullable) NSNumber * groupFlags;
@property (nonatomic, retain, nullable) NSNumber * hasRead;
@property (nonatomic, retain, nullable) NSNumber * notInterested;
@property (nonatomic, retain, nullable) NSNumber * repinCount;
@property (nonatomic, retain, nullable) NSString * shareURL;
@property (nonatomic, retain, nullable) NSNumber * hasShown; //废弃，回流逻辑已去掉
@property (nonatomic, retain, nullable) NSNumber * showAddForum;  //added 4.9：发评论时是否显示添加话题
/**
 *  [4.5] 如果服务端返回infoDesc字段，则显示infoDesc，不显示‘评论 + 评论数‘
 */
@property(nonatomic, copy, nullable) NSString * infoDesc;

/**
 *  唯一表示一个originData的ID
 *      对于ExploreArticle、ExploreEssay其相当于groupd ID
 *      对于ExploreThread其相当于thread ID
 *      对于ExploreADModel相当于ad ID
 *  *客户端添加的属性
 */
@property (nonatomic) int64_t uniqueID;
@property (nonatomic, assign) BOOL userBury;
@property (nonatomic, assign) BOOL userDigg;
@property (nonatomic, assign) BOOL userRepined;
@property (nonatomic, retain, nullable) NSNumber * userRepinTime;

/**
 *  4.8:增加喜欢功能
 */
@property (nonatomic, retain, nullable) NSNumber * likeCount;
@property (nonatomic, retain, nullable) NSNumber * userLike;
@property (nonatomic, retain, nullable) NSString * likeDesc;

// 接口下发该条数据的时间
@property (nonatomic) double requestTime;

/**
 *  与UI展示相关的字段修改后需要设置needRefreshUI = YES
 */
@property (nonatomic, assign) BOOL needRefreshUI;

@end
