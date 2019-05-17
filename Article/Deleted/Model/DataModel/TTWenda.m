//
//  TTWenda.m
//  Article
//
//  Created by wangqi.kaisa on 2017/7/13.
//
//

#import "TTWenda.h"
#import "WDApiModel.h"
#import "ExploreListIItemDefine.h"
#import "WDPersonModel.h"
#import "WDAnswerEntity.h"
#import "WDQuestionEntity.h"
#import "WDQuestionDescEntity.h"

@interface TTWenda ()

@property (nonatomic, strong) WDWendaAnswerCellStructModel *answerCellEntity;
@property (nonatomic, strong) WDWendaQuestionCellStructModel *questionCellEntity;

@property (nonatomic, copy) NSString *ansid;
@property (nonatomic, copy) NSString *qid;
@property (nonatomic, copy) NSDictionary *originDict;

@property (nonatomic, copy)   NSString *groupID;
@property (nonatomic, copy)   NSString *userSchema;
@property (nonatomic, copy)   NSString *commentSchema; // 直接显示评论的schema
@property (nonatomic, copy)   NSString *recommendReason; // action，之前一直没用
@property (nonatomic, assign) TTWendaFeedCellType wendaFeedType;
@property (nonatomic, strong) WDPersonModel *userEntity;
@property (nonatomic, strong) WDAnswerEntity *answerEntity;
@property (nonatomic, strong) WDQuestionEntity *questionEntity;
@property (nonatomic, strong) NSArray <NSDictionary *>*filterWords;
@property (nonatomic, strong) WDForwardStructModel* repostParams;

@property (nonatomic, assign) NSInteger questionImageType;
@property (nonatomic, assign) NSInteger questionLayoutType;
@property (nonatomic, assign) NSInteger answerLayoutType;

@property (nonatomic, assign) NSInteger answerTextMaxLines;
@property (nonatomic, assign) NSInteger answerTextDefaultLines;
@property (nonatomic, strong) NSNumber *answerImageJumpType;

@end

@implementation TTWenda

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = [[super persistentProperties] arrayByAddingObjectsFromArray:@[
                       @"groupID",
                       @"ansid",
                       @"qid",
                       @"userEntity",
                       @"filterWords",
                       @"userSchema",
                       @"commentSchema",
                       @"recommendReason",
                       @"wendaFeedType",
                       @"questionImageType",
                       @"questionLayoutType",
                       @"answerLayoutType",
                       @"originDict",
                       @"answerTextMaxLines",
                       @"answerTextDefaultLines",
                       @"answerImageJumpType",
                       @"repostParams",
                       ]];
    }
    return properties;
}

- (void)save {
    [super save];
    if (self.answerEntity) {
        [self.answerEntity save];
    }
    if (self.questionEntity) {
        [self.questionEntity save];
    }
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    [super updateWithDictionary:dictionary];
    NSDictionary *rawData = [dictionary tt_dictionaryValueForKey:@"raw_data"];
    ExploreOrderedDataCellType cellType = [dictionary tt_intValueForKey:@"cell_type"];
    self.originDict = rawData;
    if (cellType == ExploreOrderedDataCellTypeWendaAnswer) {
        self.wendaFeedType = TTWendaFeedCellTypeAnswer;
        self.answerCellEntity = [[WDWendaAnswerCellStructModel alloc] initWithDictionary:rawData error:nil];
        self.groupID = self.answerCellEntity.group_id;
        self.userEntity = [WDPersonModel genWDPersonModelFromWDFeedUserModel:self.answerCellEntity.content.user];
        self.userSchema = self.answerCellEntity.content.user.user_schema;
        self.commentSchema = self.answerCellEntity.content.comment_schema;
        NSMutableArray *dislikeWords = [NSMutableArray array];
        for (WDFilterWorldStructModel *filterWord in self.answerCellEntity.content.filter_words) {
            [dislikeWords addObject:[filterWord toDictionary]];
        }
        self.filterWords = dislikeWords;
        self.questionEntity = [WDQuestionEntity genQuestionEntityFromFeedQuestionModel:self.answerCellEntity.content.question];
        self.answerEntity = [WDAnswerEntity generateAnswerEntityFromFeedAnswerModel:self.answerCellEntity.content.answer];
        self.answerEntity.questionTitle = self.questionEntity.title;
        self.answerEntity.user = self.userEntity;
        self.answerLayoutType = self.answerCellEntity.content.layout_type.integerValue;
        self.qid = self.questionEntity.qid;
        self.ansid = self.answerEntity.ansid;
        self.recommendReason = self.answerCellEntity.content.recommend_reason;
        self.answerTextMaxLines = self.answerCellEntity.content.max_lines.integerValue;
        self.answerTextDefaultLines = self.answerCellEntity.content.default_lines.integerValue;
        self.answerImageJumpType = self.answerCellEntity.content.jump_type;
        self.repostParams = self.answerCellEntity.content.repost_params;
    }
    else if (cellType == ExploreOrderedDataCellTypeWendaQuestion) {
        self.wendaFeedType = TTWendaFeedCellTypeQuestion;
        self.questionCellEntity = [[WDWendaQuestionCellStructModel alloc] initWithDictionary:rawData error:nil];
        self.groupID = self.questionCellEntity.group_id;
        self.userEntity = [WDPersonModel genWDPersonModelFromWDFeedUserModel:self.questionCellEntity.content.user];
        self.userSchema = self.questionCellEntity.content.user.user_schema;
        NSMutableArray *dislikeWords = [NSMutableArray array];
        for (WDFilterWorldStructModel *filterWord in self.questionCellEntity.content.filter_words) {
            [dislikeWords addObject:[filterWord toDictionary]];
        }
        self.filterWords = dislikeWords;
        self.questionImageType = self.questionCellEntity.content.image_type.integerValue;
        self.questionLayoutType = self.questionCellEntity.content.layout_type.integerValue;
        self.questionEntity = [WDQuestionEntity genQuestionEntityFromFeedQuestionModel:self.questionCellEntity.content.question];
        self.qid = self.questionEntity.qid;
        self.recommendReason = self.questionCellEntity.content.recommend_reason;
    }
}

- (WDAnswerEntity *)answerEntity {
    if (!_answerEntity && !isEmptyString(self.ansid)) {
        _answerEntity = [WDAnswerEntity generateAnswerEntityFromAnsid:self.ansid];
        _answerEntity.questionTitle = self.questionEntity.title;
        _answerEntity.user = self.userEntity;
    }
    return _answerEntity;
}

- (WDQuestionEntity *)questionEntity {
    if (!_questionEntity && !isEmptyString(self.qid)) {
        _questionEntity = [WDQuestionEntity genQuestionEntityFromQID:self.qid];
    }
    return _questionEntity;
}

@end
