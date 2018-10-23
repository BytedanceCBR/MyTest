//
//  TTLayOutGroupPicCell.m
//  Article
//
//  Created by 王双华 on 16/10/12.
//
//

#import "TTLayOutGroupPicCell.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTArticleCellHelper.h"
#import "TTArticleCellConst.h"
#import "TTDeviceHelper.h"
#import "ExploreCellHelper.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreArticleCellView.h"
#import "TTLayOutPlainGroupPicCellModel.h"
#import "TTLayOutUnifyADGroupPicCellModel.h"
#import "Article+TTADComputedProperties.h"
#import "ExploreOrderedData+TTAd.h"

@implementation TTLayOutGroupPicCell

+ (Class)cellViewClass
{
    return [TTLayOutGroupPicCellView class];
}

@end

@implementation TTLayOutGroupPicCellView

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    if ([orderedData article]) {
        if (!orderedData.cellLayOut || orderedData.cellLayOut.needUpdateAllFrame){
            TTAdFeedCellDisplayType displayType = [orderedData.adModel displayType];
            if (displayType == TTAdFeedCellDisplayTypeGroup && [orderedData.adModel showActionButton]) {
                orderedData.cellLayOut = [[TTLayOutUnifyADGroupPicCellModel alloc] init];
                orderedData.layoutUIType = TTLayOutCellUITypeUnifyADCellGroupPic;
            }
            else if ([orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle6) {
                orderedData.cellLayOut = [[TTLayOutPlainGroupPicCellModelS1 alloc] init];
                orderedData.layoutUIType = TTLayOutCellUITypePlainCellGroupPicS1;
            }
            else if ([orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle7) {
                orderedData.cellLayOut = [[TTLayOutPlainGroupPicCellModelS2 alloc] init];
                orderedData.layoutUIType = TTLayOutCellUITypePlainCellGroupPicS2;
            }
            else{
                orderedData.cellLayOut = [[TTLayOutPlainGroupPicCellModelS0 alloc] init];
                orderedData.layoutUIType = TTLayOutCellUITypePlainCellGroupPicS0;
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
    return 0;
}

- (ExploreCellStyle)cellStyle {
    if ([self.orderedData isUnifyADCell]){
        return ExploreCellStyleUnknown;
    }
    if (self.orderedData.article.isImageSubject) {
        return ExploreCellStylePhoto;
    } else {
        return ExploreCellStyleArticle;
    }
}

- (ExploreCellSubStyle)cellSubStyle {
    if ([self.orderedData isUnifyADCell]){
        return ExploreCellSubStyleUnknown;
    }
    if (self.orderedData.article.isImageSubject) {
        return ExploreCellSubStyleGalleryGroupPic;
    } else {
        return ExploreCellSubStyleGroupPic;
    }
}


@end
