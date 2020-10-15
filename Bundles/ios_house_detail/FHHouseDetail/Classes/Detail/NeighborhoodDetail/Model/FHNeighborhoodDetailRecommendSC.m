//
//  FHNeighborhoodDetailRecommendSC.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/10/14.
//

#import "FHNeighborhoodDetailRecommendSC.h"
#import "FHNeighborhoodDetailRecommendSM.h"
#import "FHNeighborhoodDetailRecommendCell.h"
#import "FHDetailSectionTitleCollectionView.h"

@interface FHNeighborhoodDetailRecommendSC()<IGListSupplementaryViewSource>

@end

@implementation FHNeighborhoodDetailRecommendSC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.supplementaryViewSource = self;
    }
    return self;
}

- (NSInteger)numberOfItems {
    FHNeighborhoodDetailRecommendSM *SM = (FHNeighborhoodDetailRecommendSM *)self.sectionModel;
    return SM.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 30;
    FHNeighborhoodDetailRecommendSM *SM = (FHNeighborhoodDetailRecommendSM *)self.sectionModel;
    if (index >= 0 && index < SM.items.count) {
        return [FHNeighborhoodDetailRecommendCell cellSizeWithData:SM.items[index] width:width];
    }
    return CGSizeZero;
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailRecommendSM *SM = (FHNeighborhoodDetailRecommendSM *)self.sectionModel;
    FHNeighborhoodDetailRecommendCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailRecommendCell class] withReuseIdentifier:NSStringFromClass([SM.recommendCellModel class]) forSectionController:self atIndex:index];
    if (index >= 0 && index < SM.items.count) {
        [cell refreshWithData:SM.items[index]];
    }
    return cell;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailRecommendSM *SM = (FHNeighborhoodDetailRecommendSM *)self.sectionModel;
    if (index >= 0 && index < SM.items.count) {
        FHSearchHouseDataItemsModel *model = SM.items[index];
        NSMutableDictionary *traceParam = [NSMutableDictionary new];
        traceParam[@"card_type"] = @"left_pic";
        traceParam[@"log_pb"] = [model logPb] ? : UT_BE_NULL;;
        //traceParam[@"enter_from"] = @"mapfind";
        traceParam[@"origin_from"] = self.detailTracerDict[@"origin_from"] ? : UT_BE_NULL;
        traceParam[@"origin_search_id"] = model.searchId ? : UT_BE_NULL;//cellModel.searchId ? : UT_BE_NULL;
        traceParam[@"search_id"] = model.searchId ? : UT_BE_NULL;//cellModel.searchId? : UT_BE_NULL;
        traceParam[@"rank"] = @(index);
        traceParam[@"enter_from"] = @"neighborhood_detail";
        NSMutableDictionary *dict = @{@"house_type":@(2),
                              @"tracer": traceParam
                              }.mutableCopy;
        
        if (model.hid) {
            NSURL *jumpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@", model.hid]];
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByPushViewController:jumpUrl userInfo:userInfo];
        }
    }
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
    titleView.titleLabel.text = @"推荐房源";
    titleView.arrowsImg.hidden = YES;
    titleView.userInteractionEnabled = NO;
    titleView.backgroundColor = [UIColor themeGray7];
    if (titleView.titleLabel.frame.origin.x != 0) {
        [titleView.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
        }];
    }
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width, 42);
    }
    return CGSizeZero;
}

@end
