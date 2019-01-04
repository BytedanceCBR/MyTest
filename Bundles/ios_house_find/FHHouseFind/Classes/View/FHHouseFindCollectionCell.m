//
//  FHHouseFindCollectionCell.m
//  Pods
//
//  Created by 张静 on 2019/1/2.
//

#import "FHHouseFindCollectionCell.h"
#import "FHHouseFindListView.h"
#import "Masonry.h"

@interface FHHouseFindCollectionCell ()

@property(nonatomic , strong) FHHouseFindListView *containerView;

@end

@implementation FHHouseFindCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
    }
    return self;
}
- (void)updateDataWithHouseType:(FHHouseType)houseType openUrl:(NSString *)openUrl
{
    [self.containerView updateDataWithHouseType:houseType openUrl:openUrl];
}
- (void)setupUI
{
    [self.contentView addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
         
        make.left.right.bottom.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView);
     }];
}

- (FHHouseFindListView *)containerView
{
    if (!_containerView) {
        _containerView = [[FHHouseFindListView alloc]initWithFrame:CGRectZero];
    }
    return _containerView;
}
@end
