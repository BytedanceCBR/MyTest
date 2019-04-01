//
//  FHHouseFindHelpMainViewModel.m
//  FHHouseFind
//
//  Created by 张静 on 2019/4/1.
//

#import "FHHouseFindHelpMainViewModel.h"
#import "FHMainApi+HouseFind.h"
#import "FHHouseFindMainViewController.h"
#import "FHHouseFindRecommendModel.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <FHHouseType.h>

@interface FHHouseFindHelpMainViewModel ()

@property (nonatomic , weak) FHHouseFindMainViewController *viewController;
@property (nonatomic , weak) TTRouteParamObj *paramObj;
@property (nonatomic , strong) FHHouseFindRecommendDataModel *recommendModel;
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
        NSDictionary *recommendDict = [paramObj.allParams tt_dictionaryValueForKey:@"recommend_house"];
        if (recommendDict.count > 0) {
            self.recommendModel = [[FHHouseFindRecommendDataModel alloc]initWithDictionary:recommendDict error:nil];
        }
    }
    return self;
}

- (void)processData:(FHHouseFindRecommendModel *)model
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // add by zjing for test
        if (self.recommendModel.used) {

            [self.viewController addHouseFindResultVC];
        }else {
            [self.viewController addHouseFindHelpVC];

        }
        self.viewController.isLoadingData = NO;
        self.viewController.hasValidateData = YES;
        
    });
}
- (void)startLoadData
{
    __weak typeof(self)wSelf = self;
    [FHMainApi requestHFHelpUsedByHouseType:[@(_houseType) description] completion:^(FHHouseFindRecommendModel * _Nonnull model, NSError * _Nonnull error) {
        
        if (model && error == NULL) {
            if (model.data) {
                [wSelf processData:model];

                wSelf.viewController.hasValidateData = YES;
                [wSelf.viewController.emptyView hideEmptyView];
            } else {
                wSelf.viewController.isLoadingData = NO;
                wSelf.viewController.hasValidateData = NO;
                [wSelf.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
            }
        } else {
            wSelf.viewController.isLoadingData = NO;
            wSelf.viewController.hasValidateData = NO;
            [wSelf.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
        }
    }];
    
}


@end
