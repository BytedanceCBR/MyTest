//
//  TTLayOutWenDaCell.m
//  Article
//
//  Created by 王双华 on 2017/5/12.
//
//

#import "TTLayOutWenDaCell.h"
#import "TTLayOutWenDaCellModel.h"

@implementation TTLayOutWenDaCell

+ (Class)cellViewClass {
    return [TTLayOutWenDaCellView class];
}

@end

@implementation TTLayOutWenDaCellView


+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    if (!orderedData.cellLayOut || orderedData.cellLayOut.needUpdateAllFrame){
        if ([orderedData article]) {
            if([orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle10){
                orderedData.cellLayOut = [[TTLayOutWenDaCellModel alloc] init];
                orderedData.layoutUIType = TTLayOutCellUITypeWenDaCell;
            }
        }
    }
    TTLayOutCellBaseModel *cellLayOut = orderedData.cellLayOut;
    [cellLayOut updateFrameForData:orderedData cellWidth:width listType:listType];
    
    CGFloat height = cellLayOut.cellCacheHeight;
    if (height > 0) {
        return height;
    }
    return 0;
}

- (void)themeChanged:(NSNotification*)notification {
    [super themeChanged:notification];
    TTLayOutWenDaCellModel *cellLayOut = (TTLayOutWenDaCellModel*)self.orderedData.cellLayOut;
    if ([cellLayOut isKindOfClass:[TTLayOutWenDaCellModel class]]) {
        [cellLayOut updateCommentAttr];
        [self layoutCommentLabel];
    }
}

- (void)layoutCommentLabel
{
    TTLayOutWenDaCellModel *cellLayOut = (TTLayOutWenDaCellModel*)self.orderedData.cellLayOut;
    if ([cellLayOut isKindOfClass:[TTLayOutWenDaCellModel class]]) {
        self.commentAttrLabel.hidden = cellLayOut.commentLabelHidden;
        if (!self.commentAttrLabel.hidden) {
            self.commentAttrLabel.frame = cellLayOut.commentLabelFrame;
            self.commentAttrLabel.numberOfLines = cellLayOut.commentLabelNumberOfLines;
            self.commentAttrLabel.attributedTruncationToken = cellLayOut.commentAttrTruncationToken;
            self.commentAttrLabel.userInteractionEnabled = cellLayOut.commentLabelUserInteractionEnabled;
            self.commentAttrLabel.text = nil;
            self.commentAttrLabel.attributedText = [cellLayOut commentAttrLabelAttributedStr];
        }
    } else {
        [super layoutCommentLabel];
    }
}


@end
