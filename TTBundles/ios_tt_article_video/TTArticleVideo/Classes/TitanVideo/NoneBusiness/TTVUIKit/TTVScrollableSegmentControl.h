//
//  TTVScrollableSegmentControl.h
//  Article
//
//  Created by pei yun on 2017/3/22.
//
//

#import <UIKit/UIKit.h>
#import "TTVSegmentedControl.h"

@class TTVScrollableSegmentControl;
@protocol TTVScrollableSegmentControlDelegate <TTVSegmentedControlDelegate>

@optional
- (void)scrollableSegmentControl:(TTVScrollableSegmentControl *)scrollableSegmentControl didSelectItemAtIndex:(NSInteger)index;

- (void)scrollableSegmentControl:(TTVScrollableSegmentControl *)scrollableSegmentControl controlsWillBeAdded:(NSArray *)controls;   // do customization is this
- (void)scrollableSegmentControl:(TTVScrollableSegmentControl *)scrollableSegmentControl controlsWillLayout:(NSArray *)controls;   // note: can be called many times
- (void)scrollableSegmentControl:(TTVScrollableSegmentControl *)scrollableSegmentControl controlsDidLayout:(NSArray *)controls;

@optional

@end

@interface TTVScrollableSegmentControl : UIView <TTVSegmentedControl>

@property (strong, nonatomic) NSArray<UIControl *> *controls;
@property (strong, nonatomic) UIView *movableBackgroundView;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (assign, nonatomic) UIEdgeInsets contentInsets;
@property (assign, nonatomic) CGFloat itemSpacing;
@property (assign, nonatomic) CGFloat visibleItemCount;
@property (assign, nonatomic) BOOL adoptGradient;   //defaults to YES
@property (assign, nonatomic) CGFloat animateDuration;  //defaults to 0.3

@property (weak, nonatomic) id<TTVScrollableSegmentControlDelegate> segmentedControlDelegate;

@end

@interface TTVScrollableLabelSegmentControl : TTVScrollableSegmentControl

@property (strong, nonatomic) NSArray<NSString *> *titles;

@end
