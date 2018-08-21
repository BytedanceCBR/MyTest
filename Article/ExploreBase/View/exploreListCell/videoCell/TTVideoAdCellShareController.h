//
//  TTVideoAdCellShareController.h
//  Article
//
//  Created by xiangwu on 2017/2/21.
//
//

#import <Foundation/Foundation.h>
#import "SSThemed.h"
#import "ArticleVideoActionButton.h"
#import "ExploreOrderedData+TTBusiness.h"
@class ExploreCellViewBase;

@interface TTVideoAdCellShareController : NSObject

@property (nonatomic, strong) ArticleVideoActionButton *shareBtn;
@property (nonatomic, weak) ExploreCellViewBase *cellView;
@property (nonatomic, strong) ExploreOrderedData *orderedData;

- (void)refreshUI;

@end
