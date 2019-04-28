//
//  ExploreCellViewBase.m
//  Article
//
//  Created by Chen Hong on 14-9-9.
//
//

#import "ExploreCellViewBase.h"

@implementation ExploreCellViewBase

/** 分割条的高度 */
inline CGFloat kCellSeprateViewHeight() {
    return 6.f;
}

- (void)dealloc {

}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)identifier {
    self = [self initWithFrame:frame];
    self.reuseIdentifier = identifier;
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)refreshUI
{
    // subView implements.........
}

- (void)refreshWithData:(id)data
{
    // subView implements.........
}

- (id)cellData
{
    return nil;
}

- (void)fontSizeChanged
{
    // subView implements.........
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    // subView implements.........
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    //subview implement
    return 0;
}

- (BOOL)shouldRefresh {
    return NO;
}

- (void)refreshDone {    
}

- (void)addKVO
{
    //subview implement
}

- (void)removeKVO
{
    //subview implement
}

+ (NSUInteger)cellTypeForCacheHeightFromOrderedData:(id)orderedData {
    return [[self class] hash];
}

- (NSUInteger)getRefer {
    return [[self cell] refer];
}


//- (UIView *)animationFromView
//{
//    return nil;
//}
//
//- (UIView *)animationFromImage
//{
//    return nil;
//}
//
//- (void)animationFromClose
//{
//
//}
//
//- (void)animationFromCancel
//{
//
//}

- (ExploreCellStyle)cellStyle {
    return ExploreCellStyleUnknown;
}

- (ExploreCellSubStyle)cellSubStyle {
    return ExploreCellSubStyleUnknown;
}

// 子类可重载
- (void)didSelectWithContext:(nullable TTFeedCellSelectContext *)context {
    [TTFeedCellDefaultSelectHandler didSelectCellView:self context:context];
}

// didSelect之后调用，所有cell通用的处理（比如统计），子类不需要重载
- (void)postSelectWithContext:(nullable TTFeedCellSelectContext *)context {
    [TTFeedCellDefaultSelectHandler postSelectCellView:self context:context];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = event.allTouches.anyObject;
    CGPoint point = [touch locationInView:self];
    TTTouchContext *touchContext = [TTTouchContext new];
    touchContext.targetView = self;
    touchContext.touchPoint = point;
    self.lastTouchContext = touchContext;
    [super touchesEnded:touches withEvent:event];
}

- (NSDictionary *)adCellLayoutInfo {
    return nil;
}

@end
