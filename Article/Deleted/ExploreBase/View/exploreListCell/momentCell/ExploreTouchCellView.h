//
//  ExploreTouchCellView.h
//  Article
//
//  Created by Chen Hong on 15/1/20.
//
//

#import "ExploreCellViewBase.h"

@interface ExploreTouchCellView : ExploreCellViewBase <UIGestureRecognizerDelegate>

- (NSDictionary *)buildClickEvent:(NSDictionary *)data;

@end
