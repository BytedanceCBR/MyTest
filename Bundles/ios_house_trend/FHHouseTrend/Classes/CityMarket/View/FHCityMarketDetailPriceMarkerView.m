//
//  FHCityMarketDetailPriceMarkerView.m
//  AKCommentPlugin
//
//  Created by leo on 2019/4/2.
//

#import "FHCityMarketDetailPriceMarkerView.h"

@implementation FHCityMarketDetailPriceMarkerView

- (void)refreshContent:(FHDetailPriceMarkerData *)markData
{
    self.firstLabel.text = nil;
    self.secondLabel.text = nil;
    self.thirdLabel.text = nil;

    NSArray *items = markData.trendItems;
    if (items.count < 1) {
        return;
    }
    if (items.count > 0) {

        FHDetailPriceMarkerItem *item = items.firstObject;
        NSString *name = item.name;
        self.titleLabel.text = item.priceModel.timeStr;
        if (name.length > 7) {
            name = [NSString stringWithFormat:@"%@...",[name substringToIndex:7]];
        }
        double price = item.priceModel.price.doubleValue;
        self.firstLabel.text = [NSString stringWithFormat:@"%@：%ld%@",name,(long)price, _unitText];
    }
    if (items.count > 1) {

        FHDetailPriceMarkerItem *item = items[1];
        NSString *name = item.name;
        self.titleLabel.text = item.priceModel.timeStr;
        if (name.length > 7) {
            name = [NSString stringWithFormat:@"%@...",[name substringToIndex:7]];
        }
        double price = item.priceModel.price.doubleValue;
        self.secondLabel.text = [NSString stringWithFormat:@"%@：%ld%@",name,(long)price, _unitText];
    }
    if (items.count > 2) {

        FHDetailPriceMarkerItem *item = items[2];
        NSString *name = item.name;
        self.titleLabel.text = item.priceModel.timeStr;
        if (name.length > 7) {
            name = [NSString stringWithFormat:@"%@...",[name substringToIndex:7]];
        }
        double price = item.priceModel.price.doubleValue;
        self.thirdLabel.text = [NSString stringWithFormat:@"%@：%ld%@",name,(long)price, _unitText];
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
