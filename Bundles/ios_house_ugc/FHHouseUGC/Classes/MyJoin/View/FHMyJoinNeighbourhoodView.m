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

@interface FHMyJoinNeighbourhoodView ()

@property(nonatomic, strong) FHUGCCellHeaderView *headerView;

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
    
//    self.backgroundColor = [UIColor themeGray7];
//    self.progressView = [FHPostUGCProgressView sharedInstance];
//    [self addSubview:self.progressView];
    
    self.headerView = [[FHUGCCellHeaderView alloc] initWithFrame:CGRectZero];
    _headerView.titleLabel.text = @"我的关注";
    _headerView.titleLabel.backgroundColor = [UIColor themeGray7];
    _headerView.moreBtn.hidden = YES;
    [self addSubview:_headerView];
    
    [self initCollectionView];
    
    self.messageView = [[FHUGCMessageView alloc] initWithFrame:CGRectZero];
    _messageView.hidden = YES;
    [self addSubview:_messageView];
}

- (void)initCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 0);
    flowLayout.minimumLineSpacing = 8;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    self.collectionView = [[FHBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.alwaysBounceHorizontal = YES;
    _collectionView.backgroundColor = [UIColor themeGray7];
    
    [self addSubview:_collectionView];
}

- (void)initConstraints {
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(128);
    }];
    
    [self.messageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.collectionView.mas_bottom).offset(15);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(42);
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
    tracerDict[@"page_type"] = @"my_join_list";
    tracerDict[@"enter_from"] = @"neighborhood_tab";
    tracerDict[@"card_type"] = @"large";
    TRACK_EVENT(@"element_show", tracerDict);
}

@end
