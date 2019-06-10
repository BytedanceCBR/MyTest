//
//  Article+TTVConvertToOrderedData.m
//  Article
//
//  Created by pei yun on 2017/4/24.
//
//

#import "Article+TTVConvertToOrderedData.h"

@implementation Article (TTVConvertToOrderedData)

- (ExploreOrderedData *)ttv_convertedOrderedData
{
    ExploreOrderedData *data = [[ExploreOrderedData alloc] initWithArticle:self];
    data.uniqueID = [NSString stringWithFormat:@"%lld", self.uniqueID];
    data.itemID = self.itemID;
    //data.originalData = self.detailModel.article;
    data.cellType = ExploreOrderedDataCellTypeArticle;
    data.logExtra = [self relatedLogExtra];
    data.adID = self.relatedVideoExtraInfo[kArticleInfoRelatedVideoAdIDKey];
//    if (data.adID) {
//        data.adIDStr = [NSString stringWithFormat:@"%@",data.adID];
//    }
    return data;
}

@end
