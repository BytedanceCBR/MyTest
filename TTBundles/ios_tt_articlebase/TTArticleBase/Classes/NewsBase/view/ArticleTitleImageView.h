//
//  ArticleTitleImageView.h
//  Article
//
//  Created by Dianwei on 13-1-22.
//
//

#import <UIKit/UIKit.h>
#import "SSTitleBarView.h"

typedef enum ArticleTitleImageViewUIType {
    ArticleTitleImageViewUITypeDefault,
    ArticleTitleImageViewUITypeDetailView,
    ArticleTitleImageViewUITypeExplore,
    ArticleTitleImageViewUITypeNone,
}ArticleTitleImageViewUIType;

@interface ArticleTitleImageView : SSTitleBarView

@property(nonatomic, assign)ArticleTitleImageViewUIType titleUItype;

- (void)setBottomLineColorName:(NSString *)name;
@end
