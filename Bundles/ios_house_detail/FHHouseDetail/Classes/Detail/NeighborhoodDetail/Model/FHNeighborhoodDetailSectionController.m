//
//  FHNeighborhoodDetailSectionController.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHNeighborhoodDetailSectionController.h"
#import "FHNeighborhoodDetailSectionModel.h"
#import "FHNeighborhoodDetailViewController.h"

@implementation FHNeighborhoodDetailSectionController

- (instancetype)init {
    if (self = [super init]) {
        self.inset = UIEdgeInsetsMake(0, 15, 12, 15);
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

@end
