//
//  WenDaBaseData.h
//  Article
//
//  Created by xuzichao on 2016/12/6.
//
//

#import "ExploreOriginalData.h"
#import "WDQuestionEntity.h"
#import "WDAnswerEntity.h"


@interface WenDaBaseData : ExploreOriginalData

@property (nonatomic, copy)     NSString * ansid;
@property (nonatomic, copy)     NSString * qid;
@property (nonatomic, copy)     NSDictionary *extra;
@property (nonatomic, copy)     NSDictionary *showLayer;
@property (nonatomic, copy)     NSNumber * behotTime;
@property (nonatomic, copy)     NSNumber * cellType;
@property (nonatomic, copy)     NSNumber * cursor;
@property (nonatomic, copy)     NSNumber * showTopSeparator;
@property (nonatomic, copy)     NSNumber * showBottomSeparator;
@property (nonatomic, copy)     NSNumber * showDislike;
@property (nonatomic, copy)     NSArray  * filterWords;
@property (nonatomic, strong)   WDQuestionEntity *question;
@property (nonatomic, strong)   WDAnswerEntity *answer;

@end
