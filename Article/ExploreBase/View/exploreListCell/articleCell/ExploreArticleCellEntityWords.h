//
//  ExploreArticleCellEntityWords.h
//  Article
//
//  Created by Yang Xinyu on 4/1/16.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "ExploreOrderedData+TTBusiness.h"

@interface TTArticleCellEntityWordView : SSThemedView

- (void)updateEntityWordViewWithOrderedData:(ExploreOrderedData *)orderedData;

@end
