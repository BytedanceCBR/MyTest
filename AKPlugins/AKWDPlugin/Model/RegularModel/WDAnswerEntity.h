//
//  WDAnswerEntity.h
//  Article
//
//  Created by ZhangLeonardo on 15/12/10.
//
//

#import "TTEntityBase.h"
#import "WDPersonModel.h"

@class WDQuestionEntity;
@class WDDetailUserPermission;
@class TTImageInfosModel;

@interface WDAnswerEntity : TTEntityBase

#pragma mark -- 持久化属性
@property (nonatomic, copy) NSString * ansid;
@property (nonatomic, copy) NSNumber * buryCount;
@property (nonatomic, copy) NSNumber * createTime;
@property (nonatomic, copy) NSNumber * diggCount;
@property (nonatomic, copy) NSNumber * displayStatus;
@property (nonatomic, copy) NSString * qid;
@property (nonatomic, copy) NSNumber * opStatus;
@property (nonatomic, copy) NSNumber * modifyTime;
@property (nonatomic, copy) NSString * status;
@property (nonatomic, copy) NSString * uname;
@property (nonatomic, copy) NSNumber * userId;
@property (nonatomic, copy) NSString * abstract;
@property (nonatomic, copy) NSNumber * isLightAnswer;

@property (nonatomic, copy)   NSString * content;
@property (nonatomic, copy)   NSNumber * ansCount;
@property (nonatomic, assign) BOOL banComment;
@property (nonatomic, assign) BOOL isDigg;
@property (nonatomic, assign) BOOL isBuryed;
@property (nonatomic, assign) BOOL isShowBury;
@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, assign) BOOL answerDeleted;
@property (nonatomic, assign) BOOL questionDeleted;

@property (nonatomic, copy)   NSString *ansURL;
@property (nonatomic, strong) NSDictionary *shareData;
@property (nonatomic, copy)   NSNumber * readCount;
@property (nonatomic, copy)   NSString *answerSchema;
@property (nonatomic, copy)   NSString *editAnswerSchema;
@property (nonatomic, copy)   NSString *postAnswerSchema;
@property (nonatomic, copy)   NSString *questionTitle;

//详情页
@property (nonatomic, copy)   NSDictionary *detailWendaExtra;
@property (nonatomic, copy)   NSDictionary *detailAnswer;
@property (nonatomic, assign) BOOL  hasRead;
@property (nonatomic, assign) BOOL userLike;
@property (nonatomic, assign) BOOL userRepined;
@property (nonatomic, copy)   NSString *shareURL;
@property (nonatomic, copy)   NSDictionary *mediaInfo;
@property (nonatomic, copy)   NSString *source;
@property (nonatomic, strong) NSNumber *commentCount;
@property (nonatomic, strong) NSNumber *forwardCount;

@property (nonatomic, strong) NSNumber *imageMode;
@property (nonatomic, copy)   NSDictionary * h5Extra;
@property (nonatomic, copy)   NSString *logExtra;

@property (nonatomic, copy)   NSString *answerCommentSchema;
@property (nonatomic, strong) NSNumber *articlePosition;

@property (nonatomic, copy)   NSArray<TTImageInfosModel *> *thumbImageList;
@property (nonatomic, copy)   NSArray<TTImageInfosModel *> *largeImageList;
@property (nonatomic, copy)   NSArray<TTImageInfosModel *> *contentThumbImageList;

#pragma mark -- 非持久化属性
@property (nonatomic, strong) WDPersonModel *user;
@property (nonatomic, strong) WDAbstractStructModel *contentAbstract;
@property (nonatomic, strong) WDDetailUserPermission *userPermission;
@property (nonatomic, strong) WDProfitLabelStructModel *profitLabel;


#pragma mark -- 生成方法

+ (instancetype)generateAnswerEntityFromAnswerModel:(WDAnswerStructModel *)model;
+ (instancetype)generateAnswerEntityFromAnsid:(NSString *)ansid;

#pragma mark -- 辅助方法
- (BOOL)isValid;
- (void)updateWithAnsid:(NSString *)ansid
                Content:(NSString *)content;

@end

#pragma mark -- 分类方法

@interface WDAnswerEntity (WDCategory)

- (instancetype)objectWithCategory:(NSDictionary *)dic;

@end

@interface WDAnswerEntity (WDDetailPage)

- (void)updateWithDetailWendaExtra:(NSDictionary *)wendaAnswer;
- (void)updateWithDetailWendaAnswer:(NSDictionary *)wendaExtra;
- (void)updateWithInfoWendaData:(WDDetailWendaStructModel *)wendaModel;
- (NSArray *)detailLargeImageModels;
- (NSArray *)detailThumbImageModels;

@end

@interface WDAnswerEntity (WDPostAnswer)

- (void)updateWithContentAbstract:(WDAbstractStructModel *)abstractModel;

@end

@interface WDAnswerEntity (TTFeed)

+ (instancetype)generateAnswerEntityFromFeedAnswerModel:(WDStreamAnswerStructModel *)answerModel;

@end
