//
//  FHHouseFindHelpMainViewModel.m
//  FHHouseFind
//
//  Created by 张静 on 2019/4/1.
//

#import "FHHouseFindHelpMainViewModel.h"
#import "FHMainApi+HouseFind.h"
#import "FHHouseFindMainViewController.h"
#import <FHHouseType.h>

@interface FHHouseFindHelpMainViewModel ()

@property (nonatomic , weak) FHHouseFindMainViewController *viewController;
@property (nonatomic , weak) TTRouteParamObj *paramObj;
@property (nonatomic , assign) FHHouseType houseType;

@end

@implementation FHHouseFindHelpMainViewModel

- (instancetype)initWithViewController:(FHHouseFindMainViewController *)viewController paramObj:(TTRouteParamObj *)paramObj
{
    self = [super init];
    if (self) {
        _viewController = viewController;
        _paramObj = paramObj;
        _houseType = FHHouseTypeSecondHandHouse;
    }
    return self;
}

- (void)processData:(FHHouseFindRecommendDataModel *)model
{
    self.recommendModel = model;
    if (self.recommendModel.used) {
        [self.viewController addHouseFindResultVC];
    }else {
        [self.viewController addHouseFindHelpVC];
    }
}
- (void)startLoadData
{
    __weak typeof(self)wSelf = self;
    [FHMainApi requestHFHelpUsedByHouseType:[NSString stringWithFormat:@"%ld",_houseType] completion:^(FHHouseFindRecommendModel * _Nonnull model, NSError * _Nonnull error) {
        
        if (model && error == NULL) {
            if (model.data) {
                [wSelf processData:model.data];

                wSelf.viewController.hasValidateData = YES;
                [wSelf.viewController.emptyView hideEmptyView];
            } else {
                wSelf.viewController.hasValidateData = NO;
                [wSelf.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
            }
        } else {
            wSelf.viewController.hasValidateData = NO;
            [wSelf.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
        }
    }];
    
}


@end
