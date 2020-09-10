//
//  FHNewHouseDetailRecommendSC.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailRecommendSC.h"
#import "FHNewHouseDetailRecommendSM.h"
#import "FHNewHouseDetailRelatedCollectionCell.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHNewHouseDetailViewController.h"

@interface FHNewHouseDetailRecommendSC()<IGListSupplementaryViewSource>

@property (nonatomic, strong)   NSMutableDictionary       *houseShowCache; // 埋点缓存

@end

@implementation FHNewHouseDetailRecommendSC

- (instancetype)init
{
    self = [super init];
    if (self) {
        _houseShowCache = [NSMutableDictionary new];
        self.supplementaryViewSource = self;
    }
    return self;
}

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 30;
    FHNewHouseDetailRecommendSM *model = (FHNewHouseDetailRecommendSM *)self.sectionModel;
    return [FHNewHouseDetailRelatedCollectionCell cellSizeWithData:model.relatedCellModel width:width];
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
       FHNewHouseDetailRecommendSM *model = (FHNewHouseDetailRecommendSM *)self.sectionModel;
    FHNewHouseDetailRelatedCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailRelatedCollectionCell class] withReuseIdentifier:NSStringFromClass([model.relatedCellModel class]) forSectionController:self atIndex:index];
    [cell refreshWithData:model.relatedCellModel];
    __weak typeof(self) wself = self;
    cell.clickCell = ^(id data, NSInteger index) {
        [wself cellDidSelected:data index:index];
    };
    cell.houseShow = ^(id data, NSInteger index) {
        [wself addHouseShowByIndex:index dataItem:data];
    };
    return cell;
}

- (void)cellDidSelected:(FHHouseListBaseItemModel *)dataItem index:(NSInteger)index {
    NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
    tracerDic[@"rank"] = @(index);
    tracerDic[@"card_type"] = @"left_pic";
    tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
    FHNewHouseDetailViewController *vc = self.detailViewController;
    tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:vc.viewModel.houseType];
    tracerDic[@"element_from"] = @"related";
    tracerDic[@"enter_from"] = @"new_detail";
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":tracerDic,@"house_type":@(FHHouseTypeNewHouse)}];
    NSString * urlStr = [NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",dataItem.houseid];
    if (urlStr.length > 0) {
        NSURL *url = [NSURL URLWithString:urlStr];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

- (void)addHouseShowByIndex:(NSInteger)index dataItem:(FHHouseListBaseItemModel *) dataItem {
    NSString *tempKey = [NSString stringWithFormat:@"%ld", index];
    if ([self.houseShowCache valueForKey:tempKey]) {
        return;
    }
    [self.houseShowCache setValue:@(YES) forKey:tempKey];
    // house_show
    NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
    tracerDic[@"rank"] = @(index);
    tracerDic[@"card_type"] = @"left_pic";
    tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
    FHNewHouseDetailViewController *vc = self.detailViewController;
    tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:vc.viewModel.houseType];
    tracerDic[@"element_type"] = @"related";
    tracerDic[@"search_id"] = dataItem.searchId.length > 0 ? dataItem.searchId : @"be_null";
    tracerDic[@"group_id"] = dataItem.houseid ? : @"be_null";
    tracerDic[@"impr_id"] = dataItem.imprId.length > 0 ? dataItem.imprId : @"be_null";
    [tracerDic removeObjectsForKeys:@[@"element_from"]];
    [FHUserTracker writeEvent:@"house_show" params:tracerDic];
    
}

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}

- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index {
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    titleView.titleLabel.font = [UIFont themeFontMedium:18];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    titleView.titleLabel.text = @"猜你喜欢";
    titleView.arrowsImg.hidden = YES;
    [titleView.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo(0);
    }];
    titleView.userInteractionEnabled = NO;
    return titleView;
}


- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 15 * 2, 46);
    }
    return CGSizeZero;
}

@end
