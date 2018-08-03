//
//  TTLayoutLoopPicCell.m
//  Article
//
//  Created by 曹清然 on 2017/6/20.
//
//

#import "TTLayoutLoopPicCell.h"
#import "TTLayoutLoopCellModel.h"

@interface TTLayoutLoopPicCell ()

@property (nonatomic, strong) TTLayoutLoopPicCellView *loopPicCellView;

@end

@implementation TTLayoutLoopPicCell

+ (Class)cellViewClass
{
    return [TTLayoutLoopPicCellView class];
}

-(void)willDisplay{
    [(TTLayoutLoopPicCellView *)self.cellView willDisplay];
}


- (void)didEndDisplaying {
    [(TTLayoutLoopPicCellView *)self.cellView didEndDisplaying];
}


@end


@implementation TTLayoutLoopPicCellView

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType{
    
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    if ([orderedData article]) {
        if (!orderedData.cellLayOut || orderedData.cellLayOut.needUpdateAllFrame){
            orderedData.cellLayOut = [[TTLayoutLoopCellModel alloc] init];
            orderedData.layoutUIType = TTLayOutCellUITypePlainCellLoopPic;
        }
    }
    TTLayOutCellBaseModel *cellLayOut = orderedData.cellLayOut;
    if ([cellLayOut needUpdateHeightCacheForWidth:width]) {
        [cellLayOut updateFrameForData:orderedData cellWidth:width listType:listType];
    }
    
    CGFloat height = cellLayOut.cellCacheHeight;
    if (height > 0) {
        if ([orderedData hasTopPadding]) {
            if ([orderedData nextCellHasTopPadding]){
                height -= kUFSeprateViewHeight();
            }
            if ([orderedData preCellHasBottomPadding]) {
                height -= kUFSeprateViewHeight();
            }
            if (height > 0) {
                return height;
            }
        }
        else{
            return height;
        }
    }
    return 0;
    
}

- (void)refreshUI
{
    [super refreshUI];
    
    if (![self.orderedData preCellHasBottomPadding] && [self.orderedData hasTopPadding]) {
        CGRect bounds = self.bounds;
        bounds.origin.y = - kUFSeprateViewHeight();
        self.bounds = bounds;
        self.topRect.bottom = 0;
        self.topRect.width = self.width;
        self.topRect.hidden = NO;
    } else {
        CGRect bounds = self.bounds;
        bounds.origin.y = 0;
        self.bounds = bounds;
        self.topRect.hidden = YES;
    }
    
    if (![self.orderedData nextCellHasTopPadding] && [self.orderedData hasTopPadding]) {
        self.bottomRect.bottom = self.height + self.bounds.origin.y;
        self.bottomRect.width = self.width;
        self.bottomRect.hidden = NO;
    }
    else{
        self.bottomRect.hidden = YES;
    }
}


- (ExploreCellStyle)cellStyle {
    return ExploreCellStyleUnknown;
}

- (ExploreCellSubStyle)cellSubStyle {
    return ExploreCellSubStyleUnknown;
}

-(void)willDisplay{

}

- (void)didEndDisplaying {
}

@end


