//
//  ArticleCategoryManagerView.h
//  Article
//
//  Created by Zhang Leonardo on 13-11-21.
//
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"

extern NSString *const kDisplayCategoryManagerViewNotification;

typedef NS_ENUM(NSInteger, ArticleCategoryManagerViewStyle){
    ArticleCategoryManagerViewNormalStyle,
    ArticleCategoryManagerViewTabStyle
};

@interface ArticleCategoryManagerView : SSViewBase

@property (nonatomic, assign) BOOL isShowing;

extern NSString *const kCategoryManagerViewWillDisplayNotification;
//extern NSString *const kCategoryManagerViewWillHideNotification;
extern NSString *const kCloseCategoryManagerViewNotification;

- (void)closeIfNeeded;
- (void)close;
- (void)save;
- (void)reloadData;
- (void)showInView:(UIView *)view;
- (void)didShow:(void(^)(void))showBlock didDisAppear:(void(^)(void))disappearBlock;
//- (instancetype)initWithFrame:(CGRect)frame Style:(ArticleCategoryManagerViewStyle)tStyle;
//- (void)showInView:(UIView*)view frame:(CGRect)frame animateDuration:(NSTimeInterval)duration;
@end
