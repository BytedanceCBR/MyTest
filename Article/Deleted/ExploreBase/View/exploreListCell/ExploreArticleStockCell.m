//
//  ExploreArticleStockCell.m
//  Article
//
//  Created by 王双华 on 16/4/22.
//
//

#import "ExploreArticleStockCell.h"
#import "ExploreArticleStockCellView.h"
#import "StockData.h"
#import "TTRoute.h"

@implementation ExploreArticleStockCell

+ (Class)cellViewClass
{
    return [ExploreArticleStockCellView class];
}

- (void)didEndDisplaying {
    [(ExploreArticleStockCellView *)self.cellView didEndDisplaying];
}

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath viewModel:(TTFeedContainerViewModel *)viewModel {
    [super didSelectAtIndexPath:indexPath viewModel:viewModel];
    StockData *stock = nil;
    if ([self.cellData isKindOfClass:[StockData class]]) {
        stock = (StockData *)self.cellData;
    }
    else if ([((ExploreOrderedData *)self.cellData).originalData isKindOfClass:[StockData class]]) {
        stock = (StockData *)((ExploreOrderedData *)self.cellData).originalData;
    }
    
    if(stock != nil){
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:stock.schemaUrl]];
    }
}

@end
