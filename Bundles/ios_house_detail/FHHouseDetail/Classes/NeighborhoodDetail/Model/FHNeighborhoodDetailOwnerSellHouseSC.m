//
//  FHNeighborhoodDetailOwnerSellHouseSC.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/14.
//

#import "FHNeighborhoodDetailOwnerSellHouseSC.h"
#import "FHNeighborhoodDetailOwnerSellHouseSM.h"
#import "FHNeighborhoodDetailOwnerSellHouseCollectionCell.h"

@implementation FHNeighborhoodDetailOwnerSellHouseSC

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    FHNeighborhoodDetailOwnerSellHouseSM *model = (FHNeighborhoodDetailOwnerSellHouseSM *)self.sectionModel;
    return [FHNeighborhoodDetailOwnerSellHouseCollectionCell cellSizeWithData:model.ownerSellHouseModel width:width];
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    FHNeighborhoodDetailOwnerSellHouseSM *model = (FHNeighborhoodDetailOwnerSellHouseSM *)self.sectionModel;
    FHNeighborhoodDetailOwnerSellHouseCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailOwnerSellHouseCollectionCell class] withReuseIdentifier:NSStringFromClass([model.ownerSellHouseModel class]) forSectionController:self atIndex:index];
    [cell refreshWithData:model.ownerSellHouseModel];
    [cell setSellHouseButtonClickBlock:^{
        [weakSelf addClickOptionsLog];
        [weakSelf jumpToOwnerSellHouse];
    }];
    return cell;
}


-(void)jumpToOwnerSellHouse {
    [self addClickOptionsLog];
    FHNeighborhoodDetailOwnerSellHouseSM *model = (FHNeighborhoodDetailOwnerSellHouseSM *)self.sectionModel;
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"origin_from"] = self.detailTracerDict[@"origin_from"];
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    if(model.ownerSellHouseModel.helpMeSellHouseOpenUrl.length) {
        NSURL *openUrl = [NSURL URLWithString:model.ownerSellHouseModel.helpMeSellHouseOpenUrl];
        [[TTRoute sharedRoute] openURLByViewController:openUrl userInfo:userInfo];
    }
}

//埋点
- (void)addClickOptionsLog {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"page_type"] = self.detailTracerDict[@"page_type"] ?: @"be_null";
    params[@"element_type"] = @"driving_sale_house";
    params[@"click_position"] = @"button";
    params[@"event_tracking_id"] = @"107633";
    TRACK_EVENT(@"click_options", params);
}
@end
