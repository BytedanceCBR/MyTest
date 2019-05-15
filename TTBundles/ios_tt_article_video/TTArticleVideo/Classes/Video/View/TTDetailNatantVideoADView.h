//
//  TTDetailNatantVideoADView.h
//  Article
//
//  Created by 刘廷勇 on 16/6/7.
//
//

#import "TTDetailNatantViewBase.h"
#import "ExploreActionButton.h"
#import "TTImageView.h"
#import "UIScrollView+Impression.h"

@interface TTDetailNatantVideoADView : TTDetailNatantViewBase <TTImpressionViewProtocol>

@property (nonatomic, strong) ExploreOrderedData *data;

@end
