//
//  FHNeighborhoodDetailSectionController.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHNeighborhoodDetailSectionController.h"
#import "FHNeighborhoodDetailSectionModel.h"
#import "FHNeighborhoodDetailViewController.h"
#import "FHDetailBaseCell.h"

@implementation FHNeighborhoodDetailSectionController

- (instancetype)init {
    if (self = [super init]) {
        self.inset = UIEdgeInsetsMake(0, 9, 12, 9);
    }
    return self;
}

- (void)didUpdateToObject:(id)object{
    if (object && [object isKindOfClass:[FHNeighborhoodDetailSectionModel class]]) {
        _sectionModel = (FHNeighborhoodDetailSectionModel *)object;
    }
}

- (FHNeighborhoodDetailViewController *)detailViewController {
    if (self.viewController && [self.viewController isKindOfClass:[FHNeighborhoodDetailViewController class]]) {
        return (FHNeighborhoodDetailViewController *)self.viewController;
    }
    return nil;
}

- (NSDictionary *)detailTracerDict {
    return self.detailViewController.viewModel.detailTracerDic;
}

- (NSDictionary *)subPageParams {
    return self.detailViewController.viewModel.subPageParams;
}

- (NSMutableDictionary *)elementShowCaches {
    return self.detailViewController.elementShowCaches;
}

- (__kindof UICollectionViewCell *)defaultCellAtIndex:(NSInteger)index {
    FHDetailBaseCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHDetailBaseCollectionCell class] withReuseIdentifier:NSStringFromClass([self class]) forSectionController:self atIndex:index];
    return cell;
}

@end

@implementation FHNeighborhoodDetailBindingSectionController

- (instancetype)init {
    if (self = [super init]) {
        self.inset = UIEdgeInsetsMake(0, 9, 12, 9);
    }
    return self;
}

- (void)didUpdateToObject:(id)object{
    if (object && [object isKindOfClass:[FHNeighborhoodDetailSectionModel class]]) {
        _sectionModel = (FHNeighborhoodDetailSectionModel *)object;
    }
    [super didUpdateToObject:object];
}

- (FHNeighborhoodDetailViewController *)detailViewController {
    if (self.viewController && [self.viewController isKindOfClass:[FHNeighborhoodDetailViewController class]]) {
        return (FHNeighborhoodDetailViewController *)self.viewController;
    }
    return nil;
}

- (NSDictionary *)detailTracerDict {
    return self.detailViewController.viewModel.detailTracerDic;
}

- (NSDictionary *)subPageParams {
    return self.detailViewController.viewModel.subPageParams;
}

- (NSMutableDictionary *)elementShowCaches {
    return self.detailViewController.elementShowCaches;
}

- (__kindof UICollectionViewCell *)defaultCellAtIndex:(NSInteger)index {
    FHDetailBaseCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHDetailBaseCollectionCell class] withReuseIdentifier:NSStringFromClass([self class]) forSectionController:self atIndex:index];
    return cell;
}

@end
