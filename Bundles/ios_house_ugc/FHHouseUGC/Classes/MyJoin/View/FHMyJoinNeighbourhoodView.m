//
//  FHMyJoinNeighbourhoodView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/12.
//

#import "FHMyJoinNeighbourhoodView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "FHUGCCellHeaderView.h"

@interface FHMyJoinNeighbourhoodView ()

@property(nonatomic, strong) FHUGCCellHeaderView *headerView;

@end

@implementation FHMyJoinNeighbourhoodView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    
    self.backgroundColor = [UIColor themeGray7];
    
    self.headerView = [[FHUGCCellHeaderView alloc] initWithFrame:CGRectZero];
    [self.headerView.moreBtn addTarget:self action:@selector(goToMore) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_headerView];
    
    [self initCollectionView];
}

- (void)initCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    flowLayout.itemSize = CGSizeMake(130, 135);
    flowLayout.minimumLineSpacing = 8;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor themeGray7];
    
    [self addSubview:_collectionView];
}

- (void)initConstraints {
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self);
        make.height.mas_equalTo(44);
    }];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).offset(7);
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(135);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

//跳转到更多小区页面
- (void)goToMore {
    
}

@end
