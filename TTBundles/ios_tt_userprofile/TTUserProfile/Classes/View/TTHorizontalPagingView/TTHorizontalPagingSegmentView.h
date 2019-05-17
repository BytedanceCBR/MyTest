//
//  TTHorizontalPagingSegmentView.h
//  Article
//
//  Created by 王迪 on 2017/3/15.
//
//

#import "SSThemed.h"

@class TTHorizontalPagingSegmentView;

@protocol TTHorizontalPagingSegmentViewDelegate <NSObject>
@optional
- (void)segmentView:(TTHorizontalPagingSegmentView *)segmentView didSelectedItemAtIndex:(NSInteger)index toIndex:(NSInteger)toIndex;

@end

typedef enum {
    TTPagingSegmentViewContentHorizontalAlignmentLeft,
    TTPagingSegmentViewContentHorizontalAlignmentEqually
}TTPagingSegmentViewHorizontalAlignment;

@interface TTHorizontalPagingSegmentView : SSThemedView

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) SSThemedView *bottomLine;
@property (nonatomic, assign) TTPagingSegmentViewHorizontalAlignment type;
@property (nonatomic, strong) NSArray<NSString *> *titles;
@property (nonatomic, weak) id <TTHorizontalPagingSegmentViewDelegate> delegate;
/**
 一次性设置素有字体属性

 @param titleEffectBlock 回调的block
 */
- (void)setUpTitleEffect:(void(^)(NSString *__autoreleasing *titleScrollViewColorKey,NSString *__autoreleasing *norColorKey,NSString *__autoreleasing *selColorKey,UIFont *__autoreleasing *titleFont))titleEffectBlock;

/**
 一次性设置所有下标的属性

 @param underLineBlock 回调的block
 */
- (void)setUpUnderLineEffect:(void(^)(BOOL *isUnderLineDelayScroll,CGFloat *underLineH,NSString *__autoreleasing *underLineColorKey, BOOL *isUnderLineEqualTitleWidth))underLineBlock;
// 内部调用方法，外部无需关心
- (void)scrollToOffsetX:(CGFloat)offsetX;
- (void)scrollToIndex:(NSInteger)toIndex;
- (void)titleClick:(UITapGestureRecognizer *)tap;

@end
