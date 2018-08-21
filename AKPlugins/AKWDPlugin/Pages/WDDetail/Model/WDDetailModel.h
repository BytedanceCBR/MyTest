//
//  WDDetailModel.h
//  Article
//
//  Created by 延晋 张 on 16/8/30.
//
//

#import <Foundation/Foundation.h>
#import "WDDefines.h"

#import "TTAdDetailViewDefine.h"

@class WDAnswerEntity;
@class WDDetailUserPermission;
@class WDRedPackStructModel;

@protocol WDDetailModelDataSource;

extern NSString * _Nonnull const kWDDetailNatantTagsKey;
extern NSString * _Nonnull const kWDDetailNatantRelatedKey;
extern NSString * _Nonnull const kWDDetailNatantAdsKey;
extern NSString * _Nonnull const kWDDetailNatantLikeAndRewardsKey;
extern NSString * _Nonnull const kWDDetailShowReport;

@interface WDDetailModel : NSObject <TTAdNatantDataModel>

@property (nonatomic, weak, nullable) id<WDDetailModelDataSource> dataSource;

@property (nonatomic, strong, nonnull, readonly) NSDictionary *gdExtJsonDict;
@property (nonatomic, strong, nonnull, readonly) NSDictionary *apiParam;

@property (nonatomic, copy, nullable, readonly) NSDictionary *ordered_info;
@property (nonatomic, copy, nullable, readonly) NSArray *classNameList;
@property (nonatomic, copy, nullable, readonly) NSString *insertedContextJS;
@property (nonatomic, copy, nullable, readonly) NSString *etag;

@property (nonatomic, strong, nullable) UIImage *shareImg;
@property (nonatomic, copy, nullable) NSString *shareImgUrl;
@property (nonatomic, copy, nullable) NSString *shareTitle;

// 转发相关
@property (nonatomic, strong, nullable, readonly) WDForwardStructModel *repostParams;

@property (nonatomic, copy, nullable) NSString *nextAnsid;
@property (nonatomic, copy, nullable) NSString *nextAnswerSchema;
@property (nonatomic, copy, nullable) NSString *allAnswerText;
@property (nonatomic, copy, nullable) NSString *nextAnswerText;
@property (nonatomic, assign) BOOL hasNextData;
@property (nonatomic, assign) BOOL showToast;
@property (nonatomic, assign) BOOL hasNext;

@property (nonatomic, strong, nonnull) WDAnswerEntity *answerEntity;
@property (nonatomic, assign) BOOL isArticleReliable;
@property (nonatomic, assign) BOOL useCDN;

@property (nonatomic, assign) BOOL hasPrevData;
@property (nonatomic, copy, nullable) NSString *prevAnsid;
@property (nonatomic, copy, nullable) NSString *prevAnswerSchema;
@property (nonatomic, copy, nullable) NSString *prevAnswerText;
@property (nonatomic, assign) BOOL hasPrev;

@property (nonatomic, assign) BOOL showComment;
@property (nonatomic, strong, nonnull) NSDictionary *adPromotion;

@property (nonatomic, copy, nullable) NSString *err_tips;

@property (nonatomic, copy, nullable) NSString *postAnswerText;
@property (nonatomic, assign) BOOL showPostAnswer;

@property (nonatomic, assign) BOOL isJumpComment;
@property (nonatomic, copy, nullable) NSString *msgId;

@property (nonatomic, assign) BOOL needSendRedPackFlag;
@property (nonatomic, strong, nullable) WDRedPackStructModel *redPack;

@property (nonatomic, readonly, assign) WDDetailReportStyle relatedReportStyle;

@property (nonatomic, readonly, copy, nullable)  NSString *rid;

/** 问答惩戒用户公示名单的提示数据，透传给前端 */
@property (nonatomic, copy, nullable) NSDictionary *answerTips;

/** 是否显示创作引导Tips，此时头部有特殊的显示处理 */
@property (nonatomic, assign) BOOL showTips;

/** 是否需要隐藏回答按钮 */
@property (nonatomic, assign) BOOL shouldHideAnswerButton;

/** 是否需要详情页进入时隐藏头部 */
@property (nonatomic, assign) BOOL shouldHideHeader;

- (nonnull instancetype)initWithAnswerId:(nonnull NSString *)answerID params:(nullable NSDictionary *)params;

- (void)updateDetailModelWithExtraData:(nonnull NSDictionary *)wendaExtra;
- (void)updateDetailModelWith:(nonnull WDWendaAnswerInformationResponseModel *)responseModel;

- (void)openListPage;

- (BOOL)isContentHasFetched;
- (nullable NSDictionary *)newsDetailRightButtons;

- (nonnull WDDetailUserPermission *)userPermission;
- (nonnull NSString *)listSchema;
- (nullable NSString *)enterFrom;
- (nullable NSString *)parentEnterFrom;
- (BOOL)needReturn;

@end

@interface WDDetailModel (Track)

- (void)sendDetailTrackEventWithTag:(nullable NSString *)tag label:(nullable NSString *)label;
- (void)sendDetailTrackEventWithTag:(nullable NSString *)tag label:(nullable NSString *)label extra:(nullable NSDictionary *)extra;

@end

@protocol WDDetailModelDataSource <NSObject>

- (BOOL)needReturn;

@end
