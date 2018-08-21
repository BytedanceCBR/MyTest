//
//  TTAdCanvasBaseView.h
//  Article
//
//  Created by yin on 2017/3/28.
//
//

#import "SSThemed.h"
#import "TTAdCanvasLayoutModel.h"
#import "TTAdConstant.h"

@class TTAdCanvasBaseCell;

@protocol TTAdCanvasBaseCellDelegate <NSObject>

- (void)canvasCellVideoPlay:(TTAdCanvasBaseCell*)cell;

- (void)canvasCellLivePlay:(TTAdCanvasBaseCell*)cell;

@end

@interface TTAdCanvasBaseCell : SSThemedView

@property (nonatomic, weak) __weak id<TTAdCanvasBaseCellDelegate>delegate;

@property (nonatomic, assign) CGFloat constrainWidth;

@property (nonatomic, assign) CGFloat cellHeight;

- (instancetype)initWithWidth:(CGFloat)width;

- (void)refreshWithModel:(TTAdCanvasLayoutModel*)model;

- (void)setBackLabelColor:(UIColor*)color;

- (void)canvasCell:(TTAdCanvasBaseCell *)cell showStatus:(TTAdCanvasItemShowStatus)showStatus itemIndex:(NSInteger)itemIndex;

- (void)scrollView:(UIScrollView*)scrollView item:(TTAdCanvasBaseCell*)canvasCell itemIndex:(NSInteger)itemIndex;

- (void)scrollView:(UIScrollView*)scrollView lastOffset:(CGFloat)lastOffset itemInCritical:(TTAdCanvasBaseCell*)canvasCell orientation:(TTAdCanvasScrollOrientation)orientation itemIndex:(NSInteger)itemIndex;

- (void)cellMediaPlay:(TTAdCanvasBaseCell*)canvasCell;

//全屏图片cell吸顶
- (void)cellAnimateToTop;

//页面消失、退到后台、电话、appstore推出
- (void)cellPauseByEvent;

- (void)cellResumeByEvent;

- (void)cellBreakByEvent;

+ (CGFloat)heightForModel:(TTAdCanvasLayoutModel *)model inWidth:(CGFloat)constraintWidth;



@end
