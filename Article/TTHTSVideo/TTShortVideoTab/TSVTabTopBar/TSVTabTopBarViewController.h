//
//  TSVTabTopBarViewController.h
//  Article
//
//  Created by 王双华 on 2017/10/26.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TSVTabTopBarRightButtonType){
    TSVTabTopBarRightButtonTypeNone = 0,
    TSVTabTopBarRightButtonTypeSearch = 1,
    TSVTabTopBarRightButtonTypePublish = 2,
};

typedef void(^TSVTabTopBarViewControllerCategorySelectBlock)(NSInteger index);

@class TSVTabViewModel;

@interface TSVTabTopBarViewController : UIViewController

- (void)setCategorySelectBlock:(TSVTabTopBarViewControllerCategorySelectBlock)categorySelectBlock;
- (void)setViewModel:(TSVTabViewModel *)viewModel;

- (void)setCurrentIndex:(NSInteger)currentIndex scrollToPositionAnimated:(BOOL)animated;
- (void)scrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex completePercent:(CGFloat)percent;
- (void)scrollToIndex:(NSInteger)toIndex animated:(BOOL)animated;
- (void)didScrollToIndex:(NSInteger)toIndex;



@end
