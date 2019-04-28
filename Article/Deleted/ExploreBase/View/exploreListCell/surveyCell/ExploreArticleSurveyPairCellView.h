//
//  ExploreArticleSurveyPairCellView.h
//  Article
//
//  Created by chenren on 9/05/17.
//
//

#import "ExploreCellViewBase.h"
#import "SurveyPairData.h"

typedef NS_ENUM(NSUInteger, SurveyPairCellSelectionStatus) {
    SurveyPairCellSelectionStatusNormal = 0,
    SurveyPairCellSelectionStatusSelected,
    SurveyPairCellSelectionStatusUnselected,
};

@interface ExploreArticleSurveyPairCellView : ExploreCellViewBase

@property (nullable, nonatomic, strong) SurveyPairData *surveyPairData;
@property (nullable, nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, assign) BOOL selected;

- (void)didReadArticle:(Article *_Nullable)article;
- (void)didSelectArticle:(Article *_Nullable)article;

@end

@interface ExploreArticleSurveyPairCellChildView : ExploreCellViewBase

@property (nullable, nonatomic, strong) Article *article;
@property (nullable, nonatomic, weak) ExploreArticleSurveyPairCellView *mainCell;
@property (nonatomic, assign) SurveyPairCellSelectionStatus selectionStatus;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL hasRead;

@end
