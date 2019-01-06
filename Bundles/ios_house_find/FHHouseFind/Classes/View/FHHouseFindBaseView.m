//
//  FHHouseFindBaseView.m
//  Pods
//
//  Created by 张静 on 2019/1/2.
//

#import "FHHouseFindBaseView.h"
#import "FHHouseFindListView.h"
#import "Masonry.h"

@interface FHHouseFindBaseView ()

@property(nonatomic , strong) FHHouseFindListView *containerView;
@property(nonatomic , strong) FHHouseFindSectionItem *item;
@property(nonatomic , assign) BOOL needRefresh;

@end

@implementation FHHouseFindBaseView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.needRefresh = YES;
        [self setupUI];
    }
    return self;
}

- (void)setChangeHouseTypeBlock:(void (^)(FHHouseType))changeHouseTypeBlock
{
    self.containerView.changeHouseTypeBlock = changeHouseTypeBlock;
}

- (void)updateDataWithItem: (FHHouseFindSectionItem *)item needRefresh: (BOOL)needRefresh
{
    if (!self.needRefresh) {
        return;
    }
    _item = item;
    [self.containerView updateDataWithItem:item needRefresh:needRefresh];
    self.needRefresh = NO;
}
- (void)setupUI
{
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.top.mas_equalTo(self);
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
