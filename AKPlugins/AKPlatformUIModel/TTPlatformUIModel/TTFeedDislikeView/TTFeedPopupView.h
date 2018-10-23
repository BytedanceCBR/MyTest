//
//  ExplorePopupView.h
//  Article
//
//  Created by Chen Hong on 14/11/19.
//
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"

typedef NS_ENUM(NSUInteger, TTFeedPopupViewArrowDirection) {
    TTFeedPopupViewArrowNone,
    TTFeedPopupViewArrowUp,
    TTFeedPopupViewArrowDown,
};

@interface TTFeedPopupView : SSViewBase

@property(nonatomic, strong)UIColor *borderColor;
@property(nonatomic, strong)UIColor *fillColor;
@property(nonatomic, assign)TTFeedPopupViewArrowDirection arrowDirection;

@property(nonatomic, assign)CGPoint arrowPoint;
@property(nonatomic,strong)UIButton *maskView;


- (void)dismiss;
- (void)dismiss:(BOOL)animated;
- (void)refreshUI;
- (void)showAtPoint:(CGPoint)arrowPoint direction:(TTFeedPopupViewArrowDirection)dir;
- (void)viewWillDisappear;
@end
