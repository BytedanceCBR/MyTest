//
//  TTWenda.h
//  Article
//
//  Created by wangqi.kaisa on 2017/7/13.
//
//

#import "ExploreOriginalData.h"

/*
 * 7.13 首页feed中的问答模型类
 * 8.9  TTPersonModel改成WDPersonModel
 * 10.15 做完了发现需要AB，好尴尬
 * 12.12 再次UI调整，仍然需要AB
 */

@class WDAnswerEntity;
@class WDQuestionEntity;
@class WDPersonModel;
@class WDForwardStructModel;

typedef NS_ENUM(NSInteger, TTWendaFeedCellType)
{
    TTWendaFeedCellTypeAnswer = 0,             //推荐回答
    TTWendaFeedCellTypeQuestion = 1,               //推荐问题
};

@interface TTWenda : ExploreOriginalData

@property (nonatomic, copy, readonly)   NSString *groupID;
@property (nonatomic, copy, readonly)   NSString *userSchema;
@property (nonatomic, copy, readonly)   NSString *commentSchema; // 直接显示评论的schema
@property (nonatomic, copy, readonly)   NSString *recommendReason; // action，之前一直没用
@property (nonatomic, assign, readonly) TTWendaFeedCellType wendaFeedType;
@property (nonatomic, strong, readonly) WDPersonModel *userEntity;
@property (nonatomic, strong, readonly) WDAnswerEntity *answerEntity;
@property (nonatomic, strong, readonly) WDQuestionEntity *questionEntity;
@property (nonatomic, strong, readonly) NSArray <NSDictionary *>*filterWords;
@property (nonatomic, strong, readonly) WDForwardStructModel* repostParams;
/*
 * Plan A: 0 无图，1 右单图，2 三图
 * Plan B: 0 无图，1 左单图，2 三图，3 双图
 */
@property (nonatomic, assign, readonly) NSInteger questionImageType;
/*
 * 0: Plan A, 1: Plan B, 2: Plan C（UGC Style）
 */
@property (nonatomic, assign, readonly) NSInteger questionLayoutType;
/*
 * 0: Plan A, 1: Plan B（UGC Style）
 */
@property (nonatomic, assign, readonly) NSInteger answerLayoutType;

@property (nonatomic, assign, readonly) NSInteger answerTextMaxLines;
@property (nonatomic, assign, readonly) NSInteger answerTextDefaultLines;
@property (nonatomic, strong, readonly) NSNumber *answerImageJumpType;

@end
