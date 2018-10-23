//
//  WDAnswerEntity.m
//  Article
//
//  Created by ZhangLeonardo on 15/12/10.
//
//

#import "WDAnswerEntity.h"
#import "WDQuestionEntity.h"
#import "WDDetailUserPermission.h"
#import "WDDataBaseManager.h"
#import "WDDefines.h"
#import "WDPersonModel.h"
#import "TTImageInfosModel.h"

@interface WDAnswerEntity ()

@property (nonatomic, copy) NSArray<NSDictionary *> *thumbImageArray;
@property (nonatomic, copy) NSArray<NSDictionary *> *largeImageArray;

@end

@implementation WDAnswerEntity

#pragma mark  --GYModelObject

//此方法暂用于首页的model初始化，想要使用，需要增加key-map
+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary {
    
    WDAnswerEntity *object = [super objectWithDictionary:dictionary];
    
    object.ansid = [dictionary stringValueForKey:@"ansid" defaultValue:@""];
    object.banComment = !((NSNumber *)[dictionary objectForKey:@"canComment"]).boolValue;
    object.qid = [dictionary stringValueForKey:@"qid" defaultValue:@""];
    
    return object;
}

+ (NSString *)dbName
{
    return [WDDataBaseManager wenDaDBName];
}

+ (NSString *)primaryKey
{
    return @"ansid";
}

+ (NSArray *)persistentProperties {
    
    static NSArray *properties = nil;
    if (!properties) {
        
        NSMutableArray *multiArray = [[NSMutableArray alloc] init];
        if ([super persistentProperties] && [super persistentProperties].count > 0) {
            [multiArray addObjectsFromArray:[super persistentProperties]];
        }
        [multiArray addObjectsFromArray:@[
                                          @"ansid",
                                          @"buryCount",
                                          @"createTime",
                                          @"diggCount",
                                          @"displayStatus",
                                          @"qid",
                                          @"opStatus",
                                          @"modifyTime",
                                          @"status",
                                          @"uname",
                                          @"userId",
                                          @"abstract",
                                          @"isLightAnswer",
                                          @"content",
                                          @"ansCount",
                                          @"banComment",
                                          @"isDigg",
                                          @"isBuryed",
                                          @"isShowBury",
                                          @"isFollowed",
                                          @"answerDeleted",
                                          @"ansURL",
                                          @"readCount",
                                          @"answerSchema",
                                          @"editAnswerSchema",
                                          @"questionTitle",
                                          @"detailWendaExtra",
                                          @"detailAnswer",
                                          @"hasRead",
                                          @"userLike",
                                          @"userRepined",
                                          @"shareURL",
                                          @"mediaInfo",
                                          @"source",
                                          @"commentCount",
                                          @"forwardCount",
                                          @"answerCommentSchema",
                                          @"imageMode",
                                          @"h5Extra",
                                          @"logExtra",
                                          @"thumbImageArray",
                                          @"largeImageArray",
                                          @"articlePosition"]];
        
        properties = multiArray;
    }
    return properties;
}

+ (GYCacheLevel)cacheLevel {
    return GYCacheLevelResident;
}

+ (NSInteger)dbVersion
{
    return [WDDataBaseManager wenDaDBVersion];
}

#pragma mark -- TTEntityBase

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[super keyMapping]];
        [dict addEntriesFromDictionary:@{
                                         @"abstract":@"abstract",
                                         @"isLightAnswer":@"is_light_answer",
                                         @"buryCount":@"bury_count",
                                         @"createTime":@"create_time",
                                         @"diggCount":@"digg_count",
                                         @"displayStatus":@"display_status",
                                         @"modifyTime":@"modify_time",
                                         @"opStatus":@"op_status",
                                         @"status":@"status",
                                         @"uname":@"uname",
                                         @"userId":@"userId",
                                         @"articlePosition":@"articlePosition",}];
        properties = [dict copy];
    }
    return properties;
}

#pragma mark -- self
+ (NSMapTable *)answerMap
{
    static dispatch_once_t token;
    static NSMapTable * answerEntityMaptable;
    dispatch_once(&token, ^{
        answerEntityMaptable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    });
    return answerEntityMaptable;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithAnswerStructModel:(WDAnswerStructModel *)model
{
    self = [super init];
    if (self) {
        [self updateWithAnswerModel:model];
    }
    return self;
}

- (instancetype)initWithAnsid:(NSString *)ansid
{
    if (self = [super init]) {
        [self updateWithAnsid:ansid];
    }
    return self;
}

- (void)updateWithAnswerModel:(WDAnswerStructModel *)model
{
    self.ansid = model.ansid;
    self.content = model.content;
    self.createTime = model.create_time;
    self.user = [WDPersonModel genWDPersonModelFromWDUserModel:model.user];
    self.contentAbstract = model.content_abstract;
    self.diggCount = model.digg_count;
    self.buryCount = model.bury_count;
    self.readCount = model.brow_count;
    self.commentCount = model.comment_count;
    self.forwardCount = model.forward_count;
    self.answerCommentSchema = model.comment_schema;
    self.isDigg = [model.is_digg boolValue];
    self.isBuryed = [model.is_buryed boolValue];
    self.isShowBury = [model.is_show_bury boolValue];
    self.ansURL = model.ans_url;
    @try {
        self.shareData = [model.share_data toDictionary];
    }
    @catch (NSException *exception) {
        // nothing to do...
    }
    self.answerSchema = model.schema;
    self.profitLabel = model.profit_label;
    self.isLightAnswer = model.is_light_answer;
}

- (void)updateWithAnsid:(NSString *)ansid
                Content:(NSString *)content
{
    self.ansid = ansid;
    self.content = content;
}

- (void)updateWithAnsid:(NSString *)ansid
{
    self.ansid = ansid;
}

+ (instancetype)generateAnswerEntityFromAnswerModel:(WDAnswerStructModel *)model
{
    if (!model.ansid) {
        return nil;
    }
    NSString * key = [NSString stringWithFormat:@"%@", model.ansid];
    WDAnswerEntity * entity = [[self answerMap] objectForKey:key];
    if (entity) {
        [entity updateWithAnswerModel:model];
        [entity save];
        return entity;
    }
    entity = [WDAnswerEntity objectForPrimaryKey:model.ansid];
    if (entity) {
        [entity updateWithAnswerModel:model];
        [[self answerMap] setObject:entity forKey:key];
        [entity save];
        return entity;
    }
    entity = [[WDAnswerEntity alloc] initWithAnswerStructModel:model];
    [[self answerMap] setObject:entity forKey:key];
    [entity save];
    return entity;
}

+ (instancetype)generateAnswerEntityFromAnsid:(NSString *)ansid
{
    NSString * key = [NSString stringWithFormat:@"%@", ansid];
    WDAnswerEntity * entity = [[self answerMap] objectForKey:key];
    if (entity) {
        [entity updateWithAnsid:ansid];
        return entity;
    }
    entity = [WDAnswerEntity objectForPrimaryKey:ansid];
    if (entity) {
        [[self answerMap] setObject:entity forKey:key];
        return entity;
    }
    entity = [[WDAnswerEntity alloc] initWithAnsid:ansid];
    [[self answerMap] setObject:entity forKey:key];
    [entity save];
    return entity;
}

- (BOOL)isValid
{
    return !isEmptyString(self.ansid) && !isEmptyString(self.content);
}

- (NSArray *)thumbImageList {
    if (!_thumbImageList) {
        NSMutableArray *thumb = [[NSMutableArray alloc] init];
        for (NSDictionary *image in self.thumbImageArray) {
            TTImageInfosModel *infosModel = [[TTImageInfosModel alloc] initWithDictionary:image];
            [thumb addObject:infosModel];
        }
        _thumbImageList = [NSArray arrayWithArray:thumb];
    }
    return _thumbImageList;
}

- (NSArray *)largeImageList {
    if (!_largeImageList) {
        NSMutableArray *large = [[NSMutableArray alloc] init];
        for (NSDictionary *image in self.largeImageArray) {
            TTImageInfosModel *infosModel = [[TTImageInfosModel alloc] initWithDictionary:image];
            [large addObject:infosModel];
        }
        _largeImageList = [NSArray arrayWithArray:large];
    }
    if ([_largeImageList count] == 0 && self.thumbImageList.count != 0) {
        _largeImageList = [NSArray arrayWithArray:_thumbImageList];
    }
    return _largeImageList;
}

- (NSArray *)contentThumbImageList {
    if (!_contentThumbImageList) {
        NSMutableArray *thumb = [[NSMutableArray alloc] init];
        for (WDImageUrlStructModel *imageModel in self.contentAbstract.thumb_image_list) {
            @try {
                TTImageInfosModel *infosModel = [[TTImageInfosModel alloc] initWithDictionary:[imageModel toDictionary]];
                [thumb addObject:infosModel];
            }
            @catch (NSException *exception) {
                // nothing to do...
            }
        }
        _contentThumbImageList = [NSArray arrayWithArray:thumb];
    }
    return _contentThumbImageList;
}

@end

@implementation WDAnswerEntity (WDCategory)

- (instancetype)objectWithCategory:(NSDictionary *)dic
{

    return [WDAnswerEntity objectWithDictionary:dic];
}

@end

@implementation WDAnswerEntity (WDDetailPage)

- (void)updateWithDetailWendaAnswer:(NSDictionary *)wendaAnswer
{
    self.detailAnswer = wendaAnswer;
    self.abstract = [wendaAnswer tt_stringValueForKey:@"answer_abstract"];
    self.questionTitle = [wendaAnswer tt_objectForKey:@"title"];
    self.qid = [wendaAnswer tt_objectForKey:@"qid"];
    self.ansid = [wendaAnswer tt_objectForKey:@"groupid"];
    self.content = [wendaAnswer tt_stringValueForKey:@"content"];
    self.commentCount = [wendaAnswer tt_objectForKey:@"comment_count"];
    self.source = [wendaAnswer tt_stringValueForKey:@"source"];
    self.shareURL = [wendaAnswer tt_stringValueForKey:@"share_url"];
    
    [self updateWithDetailWendaExtra:[wendaAnswer tt_dictionaryValueForKey:@"wenda_extra"]];
}

- (void)updateWithDetailWendaExtra:(NSDictionary *)wendaExtra
{
    self.detailWendaExtra = wendaExtra;
    self.questionTitle = [wendaExtra tt_objectForKey:@"title"];
    self.qid = [wendaExtra tt_objectForKey:@"qid"];
    
    NSDictionary *userDict = [wendaExtra tt_dictionaryValueForKey:@"user"];
    if (userDict) {
        self.user = [WDPersonModel genWDPersonModelFromDictionary:userDict];
    }
}

- (void)updateWithInfoWendaData:(WDDetailWendaStructModel *)wendaModel
{
    self.ansCount = wendaModel.ans_count;
    self.diggCount = wendaModel.digg_count;
    self.readCount = wendaModel.brow_count;
    self.buryCount = wendaModel.bury_count;
    self.banComment = [wendaModel.is_ban_comment boolValue];
    self.isFollowed = [wendaModel.is_concern_user boolValue];
    self.isDigg = [wendaModel.is_digg boolValue];
    self.isBuryed = [wendaModel.is_buryed boolValue];
    self.answerDeleted = [wendaModel.is_answer_delete boolValue];
    self.questionDeleted = [wendaModel.is_question_delete boolValue];
    self.editAnswerSchema = [wendaModel edit_answer_url];
    self.isShowBury = [wendaModel.is_show_bury boolValue];
    self.user.followerCount = [wendaModel.fans_count intValue];
    self.userLike = [wendaModel.is_concern_user boolValue];
    self.user.isFollowing = self.userLike;
    
    self.userPermission = [[WDDetailUserPermission alloc] initWithStructModel:wendaModel.perm];
}

- (NSArray *)detailLargeImageModels
{
    if (![self.detailAnswer.allKeys containsObject:@"image_detail"]) {
        return nil;
    }
    NSMutableArray * result = [NSMutableArray arrayWithCapacity:10];
    NSArray *images = [self.detailAnswer tt_arrayValueForKey:@"image_detail"];
    int index = 0;
    for(NSDictionary *dict in images)
    {
        TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:dict];
        model.imageType = TTImageTypeLarge;
        model.userInfo = @{@"kArticleImgsIndexKey":@(index)};
        index ++;
        if (model) {
            [result addObject:model];
        }
    }
    return result;
}

- (NSArray *)detailThumbImageModels
{
    if (![self.detailAnswer.allKeys containsObject:@"thumb_image"]) {
        return nil;
    }
    NSMutableArray * result = [NSMutableArray arrayWithCapacity:10];
    NSArray *images = [self.detailAnswer tt_arrayValueForKey:@"thumb_image"];
    int index = 0;
    for(NSDictionary *dict in images)
    {
        TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:dict];
        model.imageType = TTImageTypeThumb;
        model.userInfo = @{@"kArticleImgsIndexKey":@(index)};
        index ++;
        if (model) {
            [result addObject:model];
        }
    }
    return result;
}

/*
 * detail接口，去article之前未发现问答使用
 * "show_post_answer_strategy"
 * "show_time"
 * "middle_image": 文章natant使用
 * "image_detail":5.5信息流组图创意通投广告，需要将article中的image_list传入ad_data中
 */

#pragma mark - Override

- (BOOL)isEqual:(id)object
{
    if(object == self)
    {
        return YES;
    }
    
    if([object isKindOfClass:[WDAnswerEntity class]])
    {
        return ([self hash] == [object hash]);
    }
    
    return NO;
}

- (NSUInteger)hash
{
    return [self.ansid hash];
}

@end

@implementation WDAnswerEntity (TTFeed)

+ (instancetype)generateAnswerEntityFromFeedAnswerModel:(WDStreamAnswerStructModel *)answerModel {
    if (!answerModel.ansid) {
        return nil;
    }
    NSString * key = [NSString stringWithFormat:@"%@", answerModel.ansid];
    WDAnswerEntity * entity = [[self answerMap] objectForKey:key];
    if (entity) {
        [entity updateWithFeedAnswerStructModel:answerModel];
        return entity;
    }
    entity = [[WDAnswerEntity alloc] initWithFeedAnswerStructModel:answerModel];
    [[self answerMap] setObject:entity forKey:key];
    return entity;
    
}

- (instancetype)initWithFeedAnswerStructModel:(WDStreamAnswerStructModel *)answerModel {
    if (self = [super init]) {
        [self updateWithFeedAnswerStructModel:answerModel];
    }
    return self;
}

- (void)updateWithFeedAnswerStructModel:(WDStreamAnswerStructModel *)answerModel {
    self.ansid = answerModel.ansid;
    self.abstract = answerModel.abstract_text;
    self.readCount = answerModel.brow_count;
    self.diggCount = answerModel.digg_count;
    self.commentCount = answerModel.comment_count;
    self.forwardCount = answerModel.forward_count;
    self.isDigg = answerModel.is_digg.boolValue;
    self.answerSchema = answerModel.answer_detail_schema;
    self.answerDeleted = (answerModel.status == WDAnswerStatusSELF_DELETE || answerModel.status == WDAnswerStatusOTHER_DELETE);
    self.createTime = answerModel.create_time;
    NSMutableArray *thumb = [[NSMutableArray alloc] init];
    NSMutableArray *thumbImageArray = [[NSMutableArray alloc] init];
    for (WDImageUrlStructModel *image in answerModel.thumb_image_list) {
        @try {
            TTImageInfosModel *infosModel = [[TTImageInfosModel alloc] initWithDictionary:[image toDictionary]];
            [thumbImageArray addObject:[image toDictionary]];
            [thumb addObject:infosModel];
        }
        @catch (NSException *exception) {
            // nothing to do...
        }
    }
    NSMutableArray *large = [NSMutableArray array];
    NSMutableArray *largeImageArray = [NSMutableArray array];
    for (WDImageUrlStructModel *image in answerModel.large_image_list) {
        @try {
            TTImageInfosModel *infosModel = [[TTImageInfosModel alloc] initWithDictionary:[image toDictionary]];
            [largeImageArray addObject:[image toDictionary]];
            [large addObject:infosModel];
        }
        @catch (NSException *exception) {
            // nothing to do...
        }
    }
    self.thumbImageList = [NSArray arrayWithArray:thumb];
    self.thumbImageArray = [NSArray arrayWithArray:thumbImageArray];
    self.largeImageList = [NSArray arrayWithArray:large];
    self.largeImageArray = [NSArray arrayWithArray:largeImageArray];
}

@end
