//
//  ExploreArticleWebCellView.h
//  Article
//
//  Created by Chen Hong on 15/1/8.
//
//

#import "ExploreCellViewBase.h"

#define kExploreWebCellDidUpdateNotification @"kExploreWebCellDidUpdateNotification"
#define kExploreWebCellChooseCityNotification @"kExploreWebCellChooseCityNotification"
//#define kExploreWebCellActiveRefreshListViewNotification @"kExploreWebCellActiveRefreshListViewNotification"

@interface ExploreArticleWebCellView : ExploreCellViewBase

- (void)didEndDisplaying;

@end
