//
//  FHDetailTagBackgroundView.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/5/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailTagBackgroundView : UIView
@property (nonatomic, copy)     UIFont    *textFont;
@property (nonatomic, assign)   CGFloat   fontHeight,labelHeight,cornerRadius,tagMargin,insideMargin;

- (void)removeAllTag;
- (void)refreshWithTags:(NSArray *)tags withNum:(NSUInteger)num withmaxLen:(CGFloat)maxLen;
- (instancetype)initWithLabelHeight:(CGFloat)labelHeight withCornerRadius:(CGFloat)cornerRadius;
- (void)setMarginWithTagMargin:(CGFloat)tagMargin withInsideMargin:(CGFloat)insideMargin;
@end

NS_ASSUME_NONNULL_END
