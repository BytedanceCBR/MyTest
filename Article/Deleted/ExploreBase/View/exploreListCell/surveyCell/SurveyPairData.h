//
//  SurveyPairData.h
//  Article
//
//  Created by chenren on 9/05/17.
//
//

#import "ExploreOriginalData.h"
#import "Article.h"

@interface Article (GroupID)
@property (nonatomic, strong, nullable) NSString       *groupID;
@end

@interface SurveyPairData : ExploreOriginalData

@property (nullable, nonatomic, copy) NSString *title;  //主标题
@property (nullable, nonatomic, strong) Article *article1;
@property (nullable, nonatomic, strong) Article *article2;
@property (nullable, nonatomic, strong) Article *selectedArticle;
@property (nonatomic, assign)  BOOL fixed;
@property (nonatomic, assign) BOOL hideNextTime;
@property (nullable, nonatomic, strong) id evaluateID;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) BOOL hasReadUpActicle;
@property (nonatomic, assign) BOOL hasReadDownActicle;

@end
