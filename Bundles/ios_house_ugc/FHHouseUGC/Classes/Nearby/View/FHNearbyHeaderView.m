//
//  FHNearbyHeaderView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/1/7.
//

#import "FHNearbyHeaderView.h"

@implementation FHNearbyHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor whiteColor];
    self.progressView = [FHPostUGCProgressView sharedInstance];
    [self addSubview:self.progressView];
    
    self.searchView = [[FHUGCSearchView alloc] initWithFrame:CGRectZero];
    _searchView.backgroundColor = [UIColor themeGray7];
    _searchView.hidden = YES;
    [self addSubview:_searchView];
}

- (void)initConstraints {
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.progressView.mas_bottom).offset(15);
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.height.mas_equalTo(34);
    }];
}

@end
