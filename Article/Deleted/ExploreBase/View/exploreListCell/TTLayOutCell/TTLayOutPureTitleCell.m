//
//  TTLayOutPureTitleCell.m
//  Article
//
//  Created by 王双华 on 16/10/12.
//
//

#import "TTLayOutPureTitleCell.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTArticleCellHelper.h"
#import "TTArticleCellConst.h"
#import "TTDeviceHelper.h"
#import "ExploreCellHelper.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTLayOutPlainPureTitleCellModel.h"
#import "TTLayOutUGCPureTitleCellModel.h"

@implementation TTLayOutPureTitleCell

+ (Class)cellViewClass {
    return [TTLayOutPureTitleCellView class];
}
@end

@implementation TTLayOutPureTitleCellView

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    if ([orderedData article]) {
        if (!orderedData.cellLayOut || orderedData.cellLayOut.needUpdateAllFrame){
            if ([orderedData isFeedUGC]){
                orderedData.cellLayOut = [[TTLayOutUGCPureTitleCellModel alloc] init];
                orderedData.layoutUIType = TTLayOutCellUITypeUGCCellPureTitle;
            }
            else if ([orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle6){
                orderedData.cellLayOut = [[TTLayOutPlainPureTitleCellModelS1 alloc] init];
                orderedData.layoutUIType = TTLayOutCellUITypePlainCellPureTitleS1;
            }
            else if ([orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle7){
                orderedData.cellLayOut = [[TTLayOutPlainPureTitleCellModelS2 alloc] init];
                orderedData.layoutUIType = TTLayOutCellUITypePlainCellPureTitleS2;
            }
            else{
                orderedData.cellLayOut = [[TTLayOutPlainPureTitleCellModelS0 alloc] init];
                orderedData.layoutUIType = TTLayOutCellUITypePlainCellPureTitleS0;
            }
        }
    }
    TTLayOutCellBaseModel *cellLayOut = orderedData.cellLayOut;
    if ([cellLayOut needUpdateHeightCacheForWidth:width]) {
        [cellLayOut updateFrameForData:orderedData cellWidth:width listType:listType];
    }
    
    if (cellLayOut.cellCacheHeight > 0) {
        return cellLayOut.cellCacheHeight;
    }
    return 0.f;
}

- (ExploreCellStyle)cellStyle {
    if ([self.orderedData isUnifyADCell]){
        return ExploreCellStyleUnknown;
    }
    return ExploreCellStyleArticle;
}

- (ExploreCellSubStyle)cellSubStyle {
    if ([self.orderedData isUnifyADCell]){
        return ExploreCellSubStyleUnknown;
    }
    return ExploreCellSubStylePureTitle;
}
@end
