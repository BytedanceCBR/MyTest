//
//  FHNewHouseDetailTimelineSC.m
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailTimelineSC.h"
#import "FHNewHouseDetailTimelineSM.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHNewHouseDetailViewController.h"

@interface FHNewHouseDetailTimelineSC()<IGListSupplementaryViewSource>

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation FHNewHouseDetailTimelineSC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.supplementaryViewSource = self;
        _selectedIndex = 0;
    }
    return self;
}

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 30;
    FHNewHouseDetailTimelineSM *model = (FHNewHouseDetailTimelineSM *)self.sectionModel;
    return [FHNewHouseDetailTimeLineCollectionCell cellSizeWithData:model.newsCellModel width:width];
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNewHouseDetailTimelineSM *model = (FHNewHouseDetailTimelineSM *)self.sectionModel;
    FHNewHouseDetailTimeLineCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailTimeLineCollectionCell class] withReuseIdentifier:NSStringFromClass([model.newsCellModel class]) forSectionController:self atIndex:index];
    [cell refreshWithData:model.newsCellModel];
    __weak typeof(self) wself = self;
    cell.selectedIndexChange = ^(NSInteger index) {
        wself.selectedIndex = index;
    };
    cell.clickContentBlock = ^{
        [wself gotoTimeLineDetail];
    };
    return cell;
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
    titleView.titleLabel.text = @"楼盘动态";
    titleView.arrowsImg.hidden = NO;
    titleView.userInteractionEnabled = YES;
    __weak typeof(self) wself = self;
    titleView.moreActionBlock = ^{
        [wself gotoTimeLineDetail];
    };
    return titleView;
}

- (void)gotoTimeLineDetail {
    FHNewHouseDetailTimelineSM *model = (FHNewHouseDetailTimelineSM *)self.sectionModel;
    if (model.newsCellModel) {
        FHNewHouseDetailViewController *vc = self.detailViewController;
        NSString *courtId = vc.viewModel.houseId;
        NSMutableDictionary *mutableDict = [self subPageParams].mutableCopy;
        mutableDict[@"top_index"] = @(self.selectedIndex);
        FHNewHouseDetailTimelineSM *model = (FHNewHouseDetailTimelineSM *)self.sectionModel;
        mutableDict[@"time_line_model"] = model.newsCellModel.timeLineModel;
        NSDictionary *dict = mutableDict.copy;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://floor_timeline_detail?court_id=%@",courtId]] userInfo:userInfo];
    }
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 15 * 2, 61);
    }
    return CGSizeZero;
}

@end
