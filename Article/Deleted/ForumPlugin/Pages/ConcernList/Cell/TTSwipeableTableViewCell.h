//
//  TTSwipeableTableViewCell.h
//  Article
//
//  Created by 王双华 on 16/4/8.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTBadgeNumberView.h"

typedef NS_ENUM(NSUInteger, SwipeableTableViewCellSide) {
    SwipeableTableViewCellSideLeft,
    SwipeableTableViewCellSideRight,
};

extern NSString *const kSwipeableTableViewCellCloseEvent;
/**
 * The maximum number of milliseconds that closing the buttons may take after release.
 *
 * If the time for the buttons to be hidden exceeds this number, they will be animated
 * to close quickly.
 */
extern CGFloat const kSwipeableTableViewCellMaxCloseMilliseconds;
/**
 * The minimum velocity required to open buttons if released before completely open.
 */
extern CGFloat const kSwipeableTableViewCellOpenVelocityThreshold;

@interface TTSwipeableTableViewCell : UITableViewCell <UIScrollViewDelegate>

@property (nonatomic, readonly) BOOL closed;
@property (nonatomic, readonly) CGFloat leftInset;
@property (nonatomic, readonly) CGFloat rightInset;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *scrollViewContentView;
@property (nonatomic, strong) SSThemedImageView *iconImageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *contentLabel;
@property (nonatomic, strong) SSThemedLabel *timeLabel;
@property (nonatomic, strong) TTBadgeNumberView *badgeNumberView;
@property (nonatomic, strong)SSThemedView * dividingLineView;

+ (void)closeAllCells;
+ (void)closeAllCellsExcept:(TTSwipeableTableViewCell *)cell;
- (void)close;
- (UIButton *)createButtonWithWidth:(CGFloat)width onSide:(SwipeableTableViewCellSide)side;
- (void)openSide:(SwipeableTableViewCellSide)side;
- (void)openSide:(SwipeableTableViewCellSide)side animated:(BOOL)animate;

@end
