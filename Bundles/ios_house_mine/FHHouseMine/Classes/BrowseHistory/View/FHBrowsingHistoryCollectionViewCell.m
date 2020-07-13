//
//  FHBrowsingHistoryCollectionViewCell.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/7/12.
//

#import "FHBrowsingHistoryCollectionViewCell.h"
#import "FHChildBrowsingHistoryViewController.h"

@interface FHBrowsingHistoryCollectionViewCell()

@property (nonatomic, strong) FHChildBrowsingHistoryViewController *vc;

@end

@implementation FHBrowsingHistoryCollectionViewCell

- (void)refreshData:(id)data andHouseType:(FHHouseType)houseType {
    if (!_vc) {
        _vc = [[FHChildBrowsingHistoryViewController alloc] initWithRouteParamObj:data];
        [self.contentView addSubview:_vc.view];
        [_vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
    }
}

@end
