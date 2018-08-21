//
//  WDQuestionEntity.h
//  Article
//
//  Created by ZhangLeonardo on 15/12/10.
//
//

#import "WDPostQuestionDefine.h"
#import "TTEntityBase.h"
#import "WDDataBaseManager.h"
#import "WDApiModel.h"

@class WDQuestionTagEntity;
@class WDQuestionDescEntity;
@class WDQuestionFoldReasonEntity;

@interface WDQuestionEntity : TTEntityBase

//持久化属性
@property (nonatomic, strong) NSDictionary *categoryContent;
@property (nonatomic, strong) NSNumber *createTime;
@property (nonatomic, strong) NSNumber *niceAnsCount;
@property (nonatomic, strong) NSNumber *normalAnsCount;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *qid;

@property (nonatomic, strong) NSNumber *groupId;
@property (nonatomic, strong) NSNumber *itemId;
@property (nonatomic, strong) NSNumber *opStatus;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, strong) NSNumber *tagId;
@property (nonatomic, copy)   NSString *tagName;
@property (nonatomic, copy)   NSString *uname;
@property (nonatomic, strong) NSNumber *userId;

@property (nonatomic, strong) WDQuestionDescEntity *content;
@property (nonatomic, strong) NSDictionary *shareData;
@property (nonatomic, copy)   NSString *foldReasonId;
@property (nonatomic, copy)   NSArray<NSDictionary *> *tagEntityDics;
@property (nonatomic, strong) WDQuestionFoldReasonEntity *foldReasonEntity;
@property (nonatomic, assign) WDQuestionReviewStatus reviewStatus;
@property (nonatomic, assign) WDInvitedQuestionType questionType;
@property (nonatomic, assign) WDDataBasePageType dataBaseType;
@property (nonatomic, copy)   NSNumber *followCount;
@property (nonatomic, copy)   NSString *inviteHint;
@property (nonatomic, copy)   NSString *listSchema;
@property (nonatomic, copy)   NSString *postAnswerSchema;
@property (nonatomic, strong) NSNumber *behotTime;
@property (nonatomic, strong) NSDictionary *adPromotion;

@property (nonatomic, assign) BOOL shouldShowDelete;
@property (nonatomic, assign) BOOL canDelete;
@property (nonatomic, assign) BOOL shouldShowEdit;
@property (nonatomic, assign) BOOL canEdit;
@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, assign) BOOL isAnswered;
@property (nonatomic, assign) BOOL background;

//未能持久化的属性
@property (nonatomic, strong) WDUserStructModel *user;
@property (nonatomic, copy)   NSArray<WDQuestionTagEntity *> *tagEntities;
@property (nonatomic, strong) WDProfitLabelStructModel *profitLabel;
@property (nonatomic, strong) NSArray *answerIDS;

@property (nonatomic, assign) BOOL isTagModified;

+ (instancetype)genQuestionEntityFromQID:(NSString *)qID;
+ (instancetype)genQuestionEntityFromModel:(WDQuestionStructModel *)model;

//方法
- (NSNumber *)allAnsCount;

@end

@interface WDQuestionEntity (WDInvite)

+ (instancetype)genQuestionEntityFromInviteModel:(WDWendaInvitedQuestionStructModel *)model;

@end

@interface WDQuestionEntity (TTFeed)

+ (instancetype)genQuestionEntityFromFeedQuestionModel:(WDStreamQuestionStructModel *)model;

@end
