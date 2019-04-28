//
//  TSVHorizontalCardCellInfoView.h
//  Article
//
//  Created by dingjinlu on 2018/2/27.
//

#import <UIKit/UIKit.h>

@class ExploreOrderedData;

@interface TSVHorizontalCardCellInfoView : UIView

- (void)refreshWithData:(ExploreOrderedData *)data;

- (void)configureFollowRecommendEnableStatus:(BOOL)followRecommendEnableStatus;

@end
