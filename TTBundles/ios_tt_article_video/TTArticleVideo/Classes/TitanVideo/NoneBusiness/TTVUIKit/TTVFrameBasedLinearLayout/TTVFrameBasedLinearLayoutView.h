//
//  TTVFrameBasedLinearLayoutView.h
//  Article
//
//  Created by pei yun on 2017/5/8.
//
//

#import <UIKit/UIKit.h>

@protocol TTVFrameBasedLinearLayoutItem <NSObject>

- (UIView *)view;
@optional
- (UIEdgeInsets)edgeInsets;

@end

@protocol TTVFrameBasedLinearLayoutContainer <NSObject>

- (NSArray<id<TTVFrameBasedLinearLayoutItem>> *)allItems;

- (void)addSubview:(UIView *)view withEdgeInsets:(UIEdgeInsets)edgeInsets;
- (void)addSubview:(UIView *)view withTopMargin:(CGFloat)topMargin;

- (void)addItem:(id<TTVFrameBasedLinearLayoutItem>)item;

@end


@interface TTVFrameBasedLinearLayoutView : UIView <TTVFrameBasedLinearLayoutContainer>

@end

@interface TTVFrameBasedLinearLayoutScrollView : UIScrollView <TTVFrameBasedLinearLayoutContainer>
@property (nonatomic, readonly) TTVFrameBasedLinearLayoutView *contentView;

- (void)setAutoScrollTextFieldToVisible:(BOOL)autoScroll;

@end


@interface TTVFrameBasedLinearLayoutItemSimpleContainer : NSObject <TTVFrameBasedLinearLayoutItem>

@property (nonatomic, strong) id item;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

+ (id<TTVFrameBasedLinearLayoutItem>)containerWithView:(UIView *)view withEdgeInsets:(UIEdgeInsets)edgeInsets;
+ (id<TTVFrameBasedLinearLayoutItem>)containerWithView:(UIView *)view withTopMargin:(CGFloat)topMargin;

@end

@interface TTVFrameBasedLinearLayoutItemView : UIView <TTVFrameBasedLinearLayoutItem>

@end
