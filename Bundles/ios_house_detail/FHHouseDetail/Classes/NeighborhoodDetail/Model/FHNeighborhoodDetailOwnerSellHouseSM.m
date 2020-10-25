//
//  FHNeighborhoodDetailOwnerSellHouseSM.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/14.
//

#import "FHNeighborhoodDetailOwnerSellHouseSM.h"

@implementation FHNeighborhoodDetailOwnerSellHouseSM

- (void)updateDetailModel:(FHDetailNeighborhoodModel *)model {
    
    FHNeighborhoodDetailOwnerSellHouseModel *ownerSellHouse = [[FHNeighborhoodDetailOwnerSellHouseModel alloc] init];
    FHDetailNeighborhoodSaleHouseEntranceModel *saleHouseEntrance = model.data.saleHouseEntrance;
    ownerSellHouse.questionText = saleHouseEntrance.title;
    ownerSellHouse.hintText = saleHouseEntrance.subtitle;
    ownerSellHouse.helpMeSellHouseText = saleHouseEntrance.buttonText;
    ownerSellHouse.helpMeSellHouseOpenUrl = saleHouseEntrance.openUrl;
    
    self.ownerSellHouseModel = ownerSellHouse;
}

@end
