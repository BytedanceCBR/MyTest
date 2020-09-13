//
//  FHNewHouseDetailSurroundingSC.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailSurroundingSC.h"
#import "FHNewHouseDetailSurroundingSM.h"
#import "FHNewHouseDetailSurroundingCollectionCell.h"
#import "FHNewHouseDetailMapCollectionCell.h"
#import "FHNewHouseDetailMapResultCollectionCell.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHNewHouseDetailViewController.h"
#import "FHNewHouseDetailViewModel.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHDetailStaticMap.h"
#import "MAMapKit.h"

@interface FHNewHouseDetailSurroundingSC ()<IGListSupplementaryViewSource>

@end

@implementation FHNewHouseDetailSurroundingSC

- (instancetype)init {
    if (self = [super init]) {
        self.supplementaryViewSource = self;
//        self.displayDelegate = self;
    }
    return self;
}

#pragma mark - Action
- (void)imAction
{
    FHNewHouseDetailSurroundingCellModel *model = [(FHNewHouseDetailSurroundingSM *)self.sectionModel surroundingCellModel];
    FHNewHouseDetailSurroundingSM *sectionModel = (FHNewHouseDetailSurroundingSM *)self.sectionModel;
    if (model.surroundingInfo.surrounding.chatOpenurl.length > 0) {

        NSMutableDictionary *imExtra = @{}.mutableCopy;
        imExtra[@"source_from"] = @"education_type";
        imExtra[@"im_open_url"] = model.surroundingInfo.surrounding.chatOpenurl;
        if(sectionModel.detailModel.data.surroundingInfo.associateInfo) {
            imExtra[kFHAssociateInfo] = sectionModel.detailModel.data.surroundingInfo.associateInfo;
        }

        [self.detailViewController.viewModel.contactViewModel onlineActionWithExtraDict:imExtra];
        
        [self.detailViewController.viewModel addClickOptionLog:@"education_type"];
    }
}

- (NSInteger)numberOfItems {
    FHNewHouseDetailSurroundingSM *model = (FHNewHouseDetailSurroundingSM *)self.sectionModel;
    return model.dataItems.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    FHNewHouseDetailSurroundingSM *model = (FHNewHouseDetailSurroundingSM *)self.sectionModel;
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    if (model.dataItems[index] == model.surroundingCellModel) {
        return [FHNewHouseDetailSurroundingCollectionCell cellSizeWithData:model.surroundingCellModel width:width];
    } else if (model.dataItems[index] == model.mapCellModel) {
        return [FHNewHouseDetailMapCollectionCell cellSizeWithData:model.mapCellModel width:width];
    } else if ([model.dataItems[index] isKindOfClass:[FHStaticMapAnnotation class]]) {
        return [FHNewHouseDetailMapResultCollectionCell cellSizeWithData:model.dataItems[index] width:width];
    } else if ([model.dataItems[index] isKindOfClass:[NSString class]]) {
        NSString *emptyString = model.dataItems[index];
        if (emptyString && emptyString.length) {
            return [FHNewHouseDetailMapResultCollectionCell cellSizeWithData:model.dataItems[index] width:width];
        } else {
            return CGSizeMake(width, 20);
        }
    }
    
    return CGSizeZero;
}


- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    FHNewHouseDetailSurroundingSM *model = (FHNewHouseDetailSurroundingSM *)self.sectionModel;
    if (model.dataItems[index] == model.surroundingCellModel) {
        FHNewHouseDetailSurroundingCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailSurroundingCollectionCell class] withReuseIdentifier:NSStringFromClass([model.surroundingCellModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.surroundingCellModel];
        return cell;
    } else if (model.dataItems[index] == model.mapCellModel) {
        FHNewHouseDetailMapCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailMapCollectionCell class] withReuseIdentifier:NSStringFromClass([model.mapCellModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.mapCellModel];
        [cell setRefreshActionBlock:^{
            [weakSelf.detailViewController refreshSectionModel:weakSelf.sectionModel animated:YES];
        }];
        return cell;
    } else if ([model.dataItems[index] isKindOfClass:[FHStaticMapAnnotation class]]) {
        FHStaticMapAnnotation *annotation = (FHStaticMapAnnotation *)model.dataItems[index];
        FHNewHouseDetailMapResultCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailMapResultCollectionCell class] withReuseIdentifier:NSStringFromClass([annotation class]) forSectionController:self atIndex:index];
        
        
        NSString *stringName = @"暂无信息";
        if (annotation.title.length) {
            stringName = annotation.title;
        }
        
        NSString *stringDistance = @"未知";
        if (annotation) {
            MAMapPoint from = MAMapPointForCoordinate(CLLocationCoordinate2DMake([model.mapCellModel.gaodeLat floatValue], [model.mapCellModel.gaodeLng floatValue]));
            
            MAMapPoint to = MAMapPointForCoordinate(CLLocationCoordinate2DMake(annotation.coordinate.latitude, annotation.coordinate.longitude));
            
            CLLocationDistance distance = MAMetersBetweenMapPoints(from, to);
            if (distance < 1000) {
                stringDistance = [NSString stringWithFormat:@"%d米", (int) distance];
            } else {
                stringDistance = [NSString stringWithFormat:@"%.1f公里", ((CGFloat) distance) / 1000.0];
            }
        }
        cell.titleLabel.text = stringName;
        cell.subTitleLabel.text = stringDistance;
        cell.titleLabel.hidden = NO;
        cell.subTitleLabel.hidden = NO;
        return cell;
    } else if ([model.dataItems[index] isKindOfClass:[NSString class]]) {
        NSString *emptyString = model.dataItems[index];
        FHNewHouseDetailMapResultCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailMapResultCollectionCell class] withReuseIdentifier:NSStringFromClass([emptyString class]) forSectionController:self atIndex:index];
        cell.subTitleLabel.hidden = YES;
        if (emptyString.length) {
            cell.titleLabel.font = [UIFont themeFontRegular:17];
            cell.titleLabel.textColor = [UIColor themeGray3];
            cell.titleLabel.textAlignment = NSTextAlignmentCenter;
            cell.titleLabel.hidden = NO;
            cell.titleLabel.text = emptyString;
        } else {
            cell.titleLabel.hidden = YES;
        }
        return cell;
    }
    return nil;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    //新房暂时不需要跳转
//    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;
}

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}


- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index {
//    FHNewHouseDetailSurroundingSM *model = (FHNewHouseDetailSurroundingSM *)self.sectionModel;
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    titleView.titleLabel.font = [UIFont themeFontMedium:20];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    titleView.titleLabel.text = @"位置及周边配套";
    // 设置下发标题
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
