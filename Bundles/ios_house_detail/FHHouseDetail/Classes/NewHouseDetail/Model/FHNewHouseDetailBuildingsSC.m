//
//  FHNewHouseDetailBuildingsSC.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailBuildingsSC.h"
#import "FHNewHouseDetailBuildingsSM.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHNewHouseDetailViewController.h"

@interface FHNewHouseDetailBuildingsSC ()<IGListSupplementaryViewSource>

@end
@implementation FHNewHouseDetailBuildingsSC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.supplementaryViewSource = self;
    }
    return self;
}

- (NSInteger)numberOfItems {
    FHNewHouseDetailBuildingsSM *model = (FHNewHouseDetailBuildingsSM *)self.sectionModel;
    return model.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    FHNewHouseDetailBuildingsSM *model = (FHNewHouseDetailBuildingsSM *)self.sectionModel;
    if (model.items[index] == model.buildingCellModel) {
        return [FHNewHouseDetailBuildingCollectionCell cellSizeWithData:model.buildingCellModel width:width];
    }
    return CGSizeZero;
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    FHNewHouseDetailBuildingsSM *model = (FHNewHouseDetailBuildingsSM *)self.sectionModel;
    if (model.items[index] == model.buildingCellModel) {
        FHNewHouseDetailBuildingCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailBuildingCollectionCell class] withReuseIdentifier:NSStringFromClass([model.buildingCellModel class]) forSectionController:self atIndex:index];
        cell.addClickOptions = ^(NSString * from) {
            [weakSelf addClickOptions:from];
        };
        cell.goBuildingDetail = ^(NSString * buildingID) {
            [weakSelf goBuildingDetail:buildingID];
        };
        [cell refreshWithData:model.buildingCellModel];
        return cell;
    }
    return [super defaultCellAtIndex:index];
}
#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}


- (CGSize)sizeForSupplementaryViewOfKind:(nonnull NSString *)elementKind atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 15 * 2, 61);
    }
    return CGSizeZero;
}


- (nonnull __kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(nonnull NSString *)elementKind atIndex:(NSInteger)index {
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    titleView.titleLabel.font = [UIFont themeFontMedium:20];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    titleView.titleLabel.text = @"楼栋信息";
    titleView.arrowsImg.hidden = YES;
    titleView.userInteractionEnabled = NO;
    return titleView;
}

#pragma mark - operator

//进入楼栋详情页
- (void)goBuildingDetail:(NSString *)originId{
    if (!self.detailViewController.viewModel.houseId) {
        return;
    }
    NSMutableDictionary *traceParam = [NSMutableDictionary dictionary];
    
    traceParam[@"enter_from"] = @"new_detail";
    traceParam[@"log_pb"] = self.detailTracerDict[@"log_pb"];
    traceParam[@"origin_from"] = self.detailTracerDict[@"origin_from"];
    traceParam[@"card_type"] = @"left_pic";
    traceParam[@"origin_search_id"] = self.detailTracerDict[@"origin_search_id"];
    traceParam[@"element_from"] = @"building";
    traceParam[@"page_type"] = @"building_detail";
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *subPageParams = [self subPageParams].mutableCopy;
    subPageParams[@"contact_phone"] = nil;
    [infoDict addEntriesFromDictionary:subPageParams];
    infoDict[@"tracer"] = traceParam;
    infoDict[@"house_id"] = self.detailViewController.viewModel.houseId?:@"";
    infoDict[@"origin_id"] = originId;
    
    if (self.detailViewController.viewModel.contactViewModel) {
        infoDict[@"contactViewModel"] = self.detailViewController.viewModel.contactViewModel;
    }
    
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];

    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://new_building_detail"] userInfo:info];
}

- (void)addClickOptions:(NSString *)clickPosition {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:self.detailTracerDict];
    params[@"group_id"] = self.detailViewController.viewModel.houseId?:@"";
    params[@"click_position"] = clickPosition;
    params[@"element_type"] = @"building";
    [FHUserTracker writeEvent:@"click_options" params:params];
}


@end
