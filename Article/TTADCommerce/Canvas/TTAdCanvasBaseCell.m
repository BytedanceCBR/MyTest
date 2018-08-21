//
//  TTAdCanvasBaseView.m
//  Article
//
//  Created by yin on 2017/3/28.
//
//

#import "TTAdCanvasBaseCell.h"

@interface TTAdCanvasBaseCell ()

//ScrollView上加UIView  view无法响应 侧滑背景色变透明  贴个label解决
@property (nonatomic, strong) SSThemedLabel* backLabel;

@end

@implementation TTAdCanvasBaseCell

- (void)dealloc
{
    self.delegate = nil;
}


- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super init];
    if (self) {
        self.constrainWidth = width;
        [self createSubview];
    }
    return self;
}

- (void)createSubview
{
    self.backLabel = [[SSThemedLabel alloc] init];
    self.backLabel.backgroundColor = [UIColor blackColor];
    [self addSubview:self.backLabel];
}

- (void)setBackLabelColor:(UIColor*)color
{
    if (color && [color isKindOfClass:[UIColor class]]) {
        self.backLabel.backgroundColor = color;
    }
}

- (void)refreshWithModel:(TTAdCanvasLayoutModel *)model
{
    
}


- (void)canvasCell:(TTAdCanvasBaseCell *)cell showStatus:(TTAdCanvasItemShowStatus)showStatus itemIndex:(NSInteger)itemIndex
{
    
}

//此处status有点不准,可能item是didDisplay,因为item只需要willdisplay, so...
- (void)scrollView:(UIScrollView*)scrollView item:(TTAdCanvasBaseCell*)canvasCell itemIndex:(NSInteger)itemIndex
{
    if (CGRectIntersectsRect(scrollView.frame, canvasCell.frame)) {
        [self canvasCell:canvasCell showStatus:TTAdCanvasItemShowStatus_WillDisplay itemIndex:itemIndex];
    }
}

- (void)scrollView:(UIScrollView *)scrollView lastOffset:(CGFloat)lastOffset itemInCritical:(TTAdCanvasBaseCell *)canvasCell
orientation:(TTAdCanvasScrollOrientation)orientation itemIndex:(NSInteger)itemIndex{
    
    CGFloat contentOffset = scrollView.contentOffset.y;
    CGFloat scrollViewHeight = scrollView.height;
 
    TTAdCanvasItemShowStatus showStatus = TTAdCanvasItemShowStatus_None;

    //cell在屏幕外、上方
    if (lastOffset >= canvasCell.bottom) {
        
        if (orientation == TTAdCanvasScrollOrientation_Down)
        {
            if (contentOffset < canvasCell.bottom ) {
                showStatus = TTAdCanvasItemShowStatus_WillDisplay;
                [self canvasCell:canvasCell showStatus:showStatus itemIndex:itemIndex];
            }
        }
        
    }
    //cell在屏幕外、下方
    else if (lastOffset + scrollViewHeight <= canvasCell.top)
    {
        if (orientation == TTAdCanvasScrollOrientation_Up) {
            if (contentOffset+ scrollViewHeight > canvasCell.top) {
                showStatus = TTAdCanvasItemShowStatus_WillDisplay;
                [self canvasCell:canvasCell showStatus:showStatus itemIndex:itemIndex];
            }
        }
    }
    //cell全部在屏幕里
    else if (lastOffset + scrollView.height >= canvasCell.bottom && lastOffset <= canvasCell.top)
    {
        if (orientation == TTAdCanvasScrollOrientation_Up) {
            if (contentOffset >= canvasCell.top) {
                showStatus = TTAdCanvasItemShowStatus_WillEndDisplay;
                [self canvasCell:canvasCell showStatus:showStatus itemIndex:itemIndex];
            }
        }
        else if (orientation == TTAdCanvasScrollOrientation_Down)
        {
            if (contentOffset + scrollView.height >= canvasCell.bottom) {
                showStatus = TTAdCanvasItemShowStatus_WillEndDisplay;
                [self canvasCell:canvasCell showStatus:showStatus itemIndex:itemIndex];
            }
        }
    }
    //cell部分在屏幕里  部分在屏幕外 卡在屏幕顶部
    else if(lastOffset >= canvasCell.top && lastOffset <= canvasCell.bottom){
        if (orientation == TTAdCanvasScrollOrientation_Up) {
            
            if (contentOffset >= canvasCell.bottom) {
                showStatus = TTAdCanvasItemShowStatus_DidEndDisplay;
                [self canvasCell:canvasCell showStatus:showStatus itemIndex:itemIndex];
            }
        }
        else if (orientation == TTAdCanvasScrollOrientation_Down)
        {
            if (contentOffset <= canvasCell.top) {
                showStatus = TTAdCanvasItemShowStatus_DidDisplay;
                [self canvasCell:canvasCell showStatus:showStatus itemIndex:itemIndex];
            }
        }
    }
    //cell部分在屏幕里  部分在屏幕外 卡在屏幕底部
    else if (lastOffset + scrollViewHeight >= canvasCell.top && lastOffset + scrollViewHeight <= canvasCell.bottom)
    {
        if (orientation == TTAdCanvasScrollOrientation_Up) {
            
            if (contentOffset + scrollViewHeight >= canvasCell.bottom) {
                showStatus = TTAdCanvasItemShowStatus_DidDisplay;
                [self canvasCell:canvasCell showStatus:showStatus itemIndex:itemIndex];
            }
        }
        else if (orientation == TTAdCanvasScrollOrientation_Down)
        {
            if (contentOffset + scrollViewHeight <= canvasCell.top ) {
                showStatus = TTAdCanvasItemShowStatus_DidEndDisplay;
                [self canvasCell:canvasCell showStatus:showStatus itemIndex:itemIndex];
            }
        }
    }
}

- (void)cellMediaPlay:(TTAdCanvasBaseCell*)canvasCell
{
    
}

- (void)cellAnimateToTop
{
    
}

- (void)cellPauseByEvent
{
    
}

- (void)cellResumeByEvent
{
    
}

- (void)cellBreakByEvent
{
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backLabel.frame = self.bounds;
}

+ (CGFloat)heightForModel:(TTAdCanvasLayoutModel *)model inWidth:(CGFloat)constraintWidth
{
    CGFloat height = model.styles.height.floatValue;
    CGFloat width = model.styles.width.floatValue;
    if (width > 0) {
        height = model.styles.height.floatValue * (constraintWidth /width);
        return height>0? height:211;
    }
    return 211;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
