//
//  TTFoldableLayoutDefinitaions.h
//  Article
//
//  Created by Dai Dongpeng on 4/17/16.
//
//

#ifndef TTFoldableLayoutDefinitaions_h
#define TTFoldableLayoutDefinitaions_h
#import "UIViewController+TTCustomLayout.h"

@class TTFoldableLayout;
@protocol TTFoldableLayoutProtocol <TTLayoutProtocol>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *tabView;
@property (nonatomic, strong) UIViewController *pageViewController;
@property (nonatomic) CGFloat minHeaderHeight;
@property (nonatomic) CGFloat maxHeaderHeight;

@optional
@property (nonatomic, strong) UIViewController *headerViewController;
@property (nonatomic) UIEdgeInsets tabViewOffset; //用来表示tabView的top bottom left right四个约束值
@property (nonatomic) CGFloat tabViewHeight;
@property (nonatomic, strong) UIColor *bottomViewColor;

@end

@protocol TTFoldableLayoutDelegate <NSObject>
- (void)distanceDidChanged:(CGFloat)distance;
@optional

@end

@protocol TTFoldableLayoutItemDelegate <NSObject>
- (UIScrollView *)tt_foldableDirvenScrollView;
//- (UIView *)tt_bottomView;
@end



#endif /* TTFoldableLayoutDefinitaions_h */
