//
//  TTHotNewsCellView.h
//  Article
//
//  Created by Sunhaiyuan on 2018/1/22.
//

#import "ExploreCellViewBase.h"
#import "TTHotNewsData.h"

@interface TTHotNewsCellView : ExploreCellViewBase

@property (nonatomic, strong) Article *article;
@property (nonatomic, strong) ExploreOrderedData *orderedData;

@end
