//
//  FHMyJoinNeighbourhoodView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/12.
//

#import "FHMyJoinNeighbourhoodView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "FHUGCCellHeaderView.h"
#import "FHUserTracker.h"
#import <FHHouseBase/FHBaseCollectionView.h>
#import "FHEnvContext.h"

@interface FHMyJoinNeighbourhoodView ()

@property(nonatomic, strong) FHUGCCellHeaderView *headerView;
@property(nonatomic, strong) UIView *bottomSepView;

@end

@implementation FHMyJoinNeighbourhoodView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
        [self trackElementShow];
    }
    return self;
}

- (void)initViews {
    self.headerView = [[FHUGCCellHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    _headerView.titleLabel.text = @"我的关注";
    _headerView.titleLabel.backgroundColor = [UIColor themeGray7];
    _headerView.moreBtn.hidden = YES;
    [self addSubview:_headerView];
    
    self.searchView = [[FHUGCSearchView alloc] initWithFrame:CGRectZero];
    _searchView.backgroundColor = [UIColor themeGray7];
    [self addSubview:_searchView];
    
    [self initCollectionView];
    
    self.messageView = [[FHUGCMessageView alloc] initWithFrame:CGRectZero];
    _messageView.hidden = YES;
    [self addSubview:_messageView];
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    _bottomSepView.hidden = YES;
    [self addSubview:_bottomSepView];
    
    self.backgroundColor = [UIColor whiteColor];
    _headerView.hidden = YES;
    _bottomSepView.hidden = NO;
}

- (void)initCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    flowLayout.minimumLineSpacing = 8;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    self.collectionView = [[FHBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.alwaysBounceHorizontal = YES;
    _collectionView.backgroundColor = [UIColor themeGray7];
    [self addSubview:_collectionView];
    
    _collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)initConstraints {
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(15);
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.height.mas_equalTo(34);
    }];
    
    [self.messageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.collectionView.mas_bottom).offset(15);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(42);
    }];
    
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(5);
    }];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.searchView.mas_bottom).offset(15);
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(60);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)showMessageView {
    self.messageView.hidden = NO;
}

- (void)hideMessageView {
    self.messageView.hidden = YES;
}

//跳转到更多小区页面
- (void)goToMore {
    if(self.delegate && [self.delegate respondsToSelector:@selector(gotoMore)]){
        [self.delegate gotoMore];
    }
}

- (void)trackElementShow {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"element_type"] = @"my_joined_neighborhood";
    tracerDict[@"page_type"] = @"my_join_feed";
    tracerDict[@"enter_from"] = @"neighborhood_tab";
    tracerDict[@"card_type"] = @"large";
    TRACK_EVENT(@"element_show", tracerDict);
}

@end
