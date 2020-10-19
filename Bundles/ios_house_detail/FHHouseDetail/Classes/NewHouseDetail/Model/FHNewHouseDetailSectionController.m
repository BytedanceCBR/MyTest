//
//  FHNewHouseDetailSectionController.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailSectionController.h"
#import "FHNewHouseDetailSectionModel.h"
#import "FHNewHouseDetailViewController.h"

@implementation FHNewHouseDetailSectionController

- (instancetype)init {
    if (self = [super init]) {
        self.inset = UIEdgeInsetsMake(0, 15, 12, 15);
    }
    return self;
}

- (void)didUpdateToObject:(id)object{
    if (object && [object isKindOfClass:[FHNewHouseDetailSectionModel class]]) {
        _sectionModel = (FHNewHouseDetailSectionModel *)object;
    }
}

- (FHNewHouseDetailViewController *)detailViewController {
    if (self.viewController && [self.viewController isKindOfClass:[FHNewHouseDetailViewController class]]) {
        return (FHNewHouseDetailViewController *)self.viewController;
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