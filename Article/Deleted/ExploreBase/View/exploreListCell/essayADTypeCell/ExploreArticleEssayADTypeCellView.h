//
//  ExploreArticleEssayADTypeCellView.h
//  Article
//
//  Created by chenren on 9/05/17.
//
//

#import "ExploreCellViewBase.h"
#import "EssayADData.h"

@interface ExploreArticleEssayADTypeCellView : ExploreCellViewBase

@property (nonatomic, strong) EssayADData *adData;
@property (nonatomic, strong) ExploreOrderedData *orderedData;

@end
