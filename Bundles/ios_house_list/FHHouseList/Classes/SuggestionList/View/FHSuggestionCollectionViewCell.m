//
//  FHSuggestionCollectionViewCell.m
//  FHHouseList
//
//  Created by xubinbin on 2020/4/17.
//

#import "FHSuggestionCollectionViewCell.h"
#import "FHHouseType.h"
#import "FHChildSuggestionListViewController.h"

@interface FHSuggestionCollectionViewCell()

@end

@implementation FHSuggestionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setHouseType:(FHHouseType)houseType
{
    _houseType = houseType;
    if (!_vc) {
        _vc = [[FHChildSuggestionListViewController alloc] init];
        [self.contentView addSubview:_vc.view];
    }
}

- (void)refreshData:(id)data andHouseType:(FHHouseType)houseType
{//cell加标记是否已经请求数据成功
    _houseType = houseType;
    if (!_vc) {
        _vc = [[FHChildSuggestionListViewController alloc] initWithRouteParamObj:data];
        [self.contentView addSubview:_vc.view];
    }
    _vc.houseType = houseType;
}

- (void)cellDisappear
{
    if (_vc) {
        ;
    }
}

@end
