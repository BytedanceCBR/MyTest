//
//  TSVFeedStoryCell.h
//  Article
//
//  Created by dingjinlu on 2018/1/9.
//

#import "ExploreCellBase.h"
#import "ExploreCellViewBase.h"

@interface TSVFeedStoryCell : ExploreCellBase

@end

@interface TSVFeedStoryCellView : ExploreCellViewBase

- (void)willDisplay;

- (void)didEndDisplaying;

@end

