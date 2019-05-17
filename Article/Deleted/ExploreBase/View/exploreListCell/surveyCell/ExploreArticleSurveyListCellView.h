//
//  ExploreArticleSurveyListCellView.h
//  Article
//
//  Created by chenren on 9/05/17.
//
//

#import "ExploreCellViewBase.h"
#import "SurveyListData.h"

@interface ExploreArticleSurveyListCellView : ExploreCellViewBase

@property (nonatomic, strong) SurveyListData *surveyListData;
@property (nonatomic, strong) ExploreOrderedData *orderedData;

@end
