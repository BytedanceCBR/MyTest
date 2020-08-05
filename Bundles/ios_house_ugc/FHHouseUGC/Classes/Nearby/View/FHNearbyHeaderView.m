//
//  FHNearbyHeaderView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/1/7.
//

#import "FHNearbyHeaderView.h"
#import "FHEnvContext.h"

@interface FHNearbyHeaderView ()

//新的发现页面
@property(nonatomic, assign) BOOL isNewDiscovery;

@end

@implementation FHNearbyHeaderView

- (instancetype)initWithFrame:(CGRect)frame isNewDiscovery:(BOOL)isNewDiscovery {
    self = [super initWithFrame:frame];
    if (self) {
        self.isNewDiscovery = isNewDiscovery;
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor whiteColor];
    
    self.searchView = [[FHUGCSearchView alloc] initWithFrame:CGRectZero];
    _searchView.backgroundColor = [UIColor themeGray7];
    _searchView.hidden = YES;
    [self addSubview:_searchView];
    
    if(!self.isNewDiscovery){
        self.progressView = [[FHPostUGCProgressView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.progressView];
    }
}

- (void)initConstraints {
    if(self.isNewDiscovery){
        [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).offset(15);
            make.left.mas_equalTo(self).offset(20);
            make.right.mas_equalTo(self).offset(-20);
            make.height.mas_equalTo(34);
        }];
    }else{
        [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.progressView.mas_bottom).offset(15);
            make.left.mas_equalTo(self).offset(20);
            make.right.mas_equalTo(self).offset(-20);
            make.height.mas_equalTo(34);
        }];
    }
}

@end
