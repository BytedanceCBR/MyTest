//
//  WDQuestionEntity.m
//  Article
//
//  Created by ZhangLeonardo on 15/12/10.
//
//

#import "WDQuestionEntity.h"
#import "WDQuestionDescEntity.h"
#import "WDQuestionTagEntity.h"
#import "WDQuestionFoldReasonEntity.h"
#import "WDApiModel.h"
#import "WDDataBaseManager.h"
#import "WenDaBaseData.h"

@interface WDQuestionEntity ()

@property (nonatomic, strong) NSDictionary *questionDescDict;

@end

@implementation WDQuestionEntity

#pragma mark -- GYModelObject

//此方法暂用于首页的model初始化，想要使用，需要增加key-map
+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary {
    
    WDQuestionEntity *object = [super objectWithDictionary:dictionary];
    object.qid = [dictionary stringValueForKey:@"qid" defaultValue:@""];
    
    return object;
}

+ (NSString *)dbName
{
    return [WDDataBaseManager wenDaDBName];
}

+ (NSString *)primaryKey
{
    return @"qid";
}

+ (NSArray *)persistentProperties {
    
    static NSArray *properties = nil;
    if (!properties) {
        
        NSMutableArray *multiArray = [[NSMutableArray alloc] init];
        if ([super persistentProperties] && [super persistentProperties].count > 0) {
            [multiArray addObjectsFromArray:[super persistentProperties]];
        }
        [multiArray addObjectsFromArray:@[
                                          @"categoryContent",
                                          @"createTime",
                                          @"niceAnsCount",
                                          @"normalAnsCount",
                                          @"title",
                                          @"qid",
                                          @"groupId",
                                          @"itemId",
                                          @"opStatus",
                                          @"status",
                                          @"tagId",
                                          @"tagName",
                                          @"uname",
                                          @"userId",
                                          @"dataBaseType",
                                          @"tagEntityDics",
                                          @"questionDescDict",
                                          @"shareData",
                                          @"foldReasonId",
                                          @"reviewStatus",
                                          @"followCount",
                                          @"inviteHint",
                                          @"questionType",
                                          @"listSchema",
                                          @"postAnswerSchema",
                                          @"behotTime",
                                          @"shouldShowDelete",
                                          @"canDelete",
                                          @"shouldShowEdit",
                                          @"canEdit",
                                          @"isFollowed",
                                          @"isAnswered",
                                          @"background"]];
        
        properties = multiArray;
    }
    return properties;
}

+ (GYCacheLevel)cacheLevel {
    return GYCacheLevelResident;
}

+ (void)deleteDBFileIfNeeded
{
    [super deleteDBFileIfNeeded];
    [WDQuestionTagEntity deleteDBFileIfNeeded];
}

#pragma mark -- TTEntityBase
+ (NSDictionary *)keyMapping
{
    static NSDictionary *properties = nil;
    if (!properties) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[super keyMapping]];
        [dict addEntriesFromDictionary:@{
                                         @"categoryContent":@"content",
                                         @"createTime":@"create_time",
                                         @"groupId":@"group_id",
                                         @"itemId":@"item_id",
                                         @"niceAnsCount":@"nice_ans_count",
                                         @"normalAnsCount":@"normal_ans_count",
                                         @"opStatus":@"op_status",
                                         @"status":@"status",
                                         @"title":@"title",
                                         @"uname":@"uname",
                                         @"userId":@"user_id",
                                         }
         ];
        properties = [dict copy];
    }
    return properties;
}

+ (NSInteger)dbVersion
{
    return [WDDataBaseManager wenDaDBVersion];
}

#pragma mark -- self

- (WDQuestionDescEntity *)content
{
    if (!_content && self.questionDescDict) {
        _content = [WDQuestionDescEntity objectWithDictionary:self.questionDescDict];
    }
    return _content;
}

- (NSNumber *)allAnsCount
{
    long long allCountValue = self.niceAnsCount.longLongValue + self.normalAnsCount.longLongValue;
    if (allCountValue < 0) {
        allCountValue = 0;
    }
    return @(allCountValue);
}

#pragma mark -- 各个入口更新并保存

+ (instancetype)genQuestionEntityFromModel:(WDQuestionStructModel *)model
{
    if (isEmptyString(model.qid)) {
        return nil;
    }
    NSString * key = [NSString stringWithFormat:@"%@", model.qid];
    WDQuestionEntity * entity = [WDQuestionEntity objectForPrimaryKey:key];
    if (entity) {
        [entity updateWithWDQuestionModel:model];
        [entity save];
        return entity;
    }
    entity = [[WDQuestionEntity alloc] initWithWDQuestionModel:model];
    [entity save];
    return entity;
}

+ (instancetype)genQuestionEntityFromQID:(NSString *)qID
{
    if (isEmptyString(qID)) {
        return nil;
    }
    NSString * key = [NSString stringWithFormat:@"%@", qID];
    WDQuestionEntity * entity = [WDQuestionEntity objectForPrimaryKey:key];
    if (entity) {
        return entity;
    }
    entity = [WDQuestionEntity new];
    entity.qid = qID;
    [entity save];
    return entity;
}

- (instancetype)initWithWDQuestionModel:(WDQuestionStructModel *)model
{
    if (self) {
        [self updateWithWDQuestionModel:model];
    }
    return self;
}

- (void)updateWithWDQuestionModel:(WDQuestionStructModel *)model
{
    self.qid = model.qid;
    self.title = model.title;
    self.followCount = model.follow_count;
    
    self.createTime = model.create_time;
    self.user = model.user;
    
    self.content = [[WDQuestionDescEntity alloc] initWithWDQuestionDescStructModel:model.content];
    
    self.foldReasonEntity = [[WDQuestionFoldReasonEntity alloc] initWithModel:model.fold_reason];
    self.foldReasonId = self.foldReasonEntity.openURL;
    
    self.niceAnsCount = model.nice_ans_count;
    self.normalAnsCount = model.normal_ans_count;
    self.reviewStatus = [model.status integerValue];
    self.tagEntityDics = [WDQuestionTagEntity genTagEntityDicsWithTagStructModels:model.concern_tag_list];
    self.tagEntities = [WDQuestionTagEntity genTagEntitiesWithTagStructModels:model.concern_tag_list];
    
    self.shouldShowEdit = [model.show_edit boolValue];
    self.shouldShowDelete = [model.show_delete boolValue];
    self.canEdit = [model.can_edit boolValue];
    self.canDelete = [model.can_delete boolValue];
    self.isFollowed = [model.is_follow boolValue];
    self.postAnswerSchema = model.post_answer_url;
    
    @try {
        self.questionDescDict = [model.content toDictionary];
        self.shareData = [model.share_data toDictionary];
        self.adPromotion = [model.recommend_sponsor toDictionary];
    }
    @catch (NSException *exception) {
        // nothing to do...
    }
    
}

@end

@implementation WDQuestionEntity (WDInvite)

+ (instancetype)genQuestionEntityFromInviteModel:(WDWendaInvitedQuestionStructModel *)model
{
    if (isEmptyString(model.qid)) {
        return nil;
    }
    NSString * key = [NSString stringWithFormat:@"%@", model.qid];
    WDQuestionEntity * entity = [WDQuestionEntity objectForPrimaryKey:key];
    if (entity) {
        [entity updateWithWDInviteModel:model];
        entity.dataBaseType = WDDataBasePageType_NeedToAnswer;
        [entity save];
        return entity;
    }
    entity = [[WDQuestionEntity alloc] initWithWDInviteModel:model];
    entity.dataBaseType = WDDataBasePageType_NeedToAnswer;
    [entity save];
    return entity;
}

- (instancetype)initWithWDInviteModel:(WDWendaInvitedQuestionStructModel *)model
{
    if (self) {
        [self updateWithWDInviteModel:model];
    }
    return self;
}

- (void)updateWithWDInviteModel:(WDWendaInvitedQuestionStructModel *)model
{
    self.qid = model.qid;
    self.niceAnsCount = model.nice_ans_count;
    self.normalAnsCount = model.normal_ans_count;
    self.followCount = model.follow_count;
    self.title = model.title;
    self.listSchema = model.list_schema;
    self.postAnswerSchema = model.post_answer_schema;
    self.behotTime = model.behot_time;
    self.inviteHint = model.invited_user_desc;
    self.questionType = model.invited_question_type;
    self.isAnswered = [model.is_answered boolValue];
    self.background = [model.background boolValue];
    self.profitLabel = model.profit_label;
}

@end

@implementation WDQuestionEntity (TTFeed)

+ (instancetype)genQuestionEntityFromFeedQuestionModel:(WDStreamQuestionStructModel *)model {
    if (isEmptyString(model.qid)) {
        return nil;
    }
    NSString * key = [NSString stringWithFormat:@"%@", model.qid];
    WDQuestionEntity * entity = [WDQuestionEntity objectForPrimaryKey:key];
    if (entity) {
        [entity updateWithFeedQuestionStructModel:model];
    }
    else {
        entity = [[WDQuestionEntity alloc] initWithFeedQuestionStructModel:model];
    }
    entity.dataBaseType = WDDataBasePageType_Feed;
    [entity save];
    return entity;
}

- (instancetype)initWithFeedQuestionStructModel:(WDStreamQuestionStructModel *)questionModel {
    if (self = [super init]) {
        [self updateWithFeedQuestionStructModel:questionModel];
    }
    return self;
}

- (void)updateWithFeedQuestionStructModel:(WDStreamQuestionStructModel *)questionModel {
    self.qid = questionModel.qid;
    self.title = questionModel.title;
    self.listSchema = questionModel.question_list_schema;
    self.niceAnsCount = questionModel.nice_ans_count;
    self.normalAnsCount = questionModel.normal_ans_count;
    self.followCount = questionModel.follow_count;
    self.postAnswerSchema = questionModel.write_answer_schema;
    self.createTime = questionModel.create_time;
    self.content = [[WDQuestionDescEntity alloc] initWithWDQuestionDescStructModel:questionModel.content];
    @try {
        self.questionDescDict = [questionModel.content toDictionary];
    }
    @catch (NSException *exception) {
        // nothing to do...
    }
}

@end
