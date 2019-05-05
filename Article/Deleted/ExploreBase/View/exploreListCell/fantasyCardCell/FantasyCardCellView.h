//
//  FantasyCardCellView.h
//  Article
//
//  Created by chenren on 1/02/18.
//
//

#import "ExploreCellViewBase.h"
#import "FantasyCardData.h"

@interface FantasyCardCellView : ExploreCellViewBase

@property (nonatomic, strong) FantasyCardData *fantasyData;
@property (nonatomic, strong) ExploreOrderedData *orderedData;

@end
