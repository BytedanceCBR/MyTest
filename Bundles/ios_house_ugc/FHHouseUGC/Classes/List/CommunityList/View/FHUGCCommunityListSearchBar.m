//
// Created by zhulijun on 2019-07-17.
//

#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/View+MASAdditions.h>
#import "FHUGCCommunityListSearchBar.h"


@interface FHUGCCommunityListSearchBar ()
@property(nonatomic, strong) UIButton *searchAreaPanel;
@property(nonatomic, strong) UILabel *searchLabel;
@property(nonatomic, strong) UIImageView *searchIcon;
@property(nonatomic, strong) UIView *separatorLine;
@end

@implementation FHUGCCommunityListSearchBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self initConstraints];
    }
    return self;
}

- (void)setSearchTint:(NSString *)searchTint {
    _searchTint = [searchTint mutableCopy];
    self.searchLabel.text = _searchTint;
}

- (void)initView {
    // searchAreaPanel
    _searchAreaPanel = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchAreaPanel.backgroundColor = [UIColor themeGray7];
    _searchAreaPanel.layer.masksToBounds = YES;
    _searchAreaPanel.layer.cornerRadius = 17.0f;
    [_searchAreaPanel addTarget:self action:@selector(onSearchClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_searchAreaPanel];

    // searchIcon
    _searchIcon = [[UIImageView alloc] init];
    _searchIcon.image = [UIImage imageNamed:@"icon-search-titlebar"];
    [_searchAreaPanel addSubview:_searchIcon];

    // searchTint
    _searchLabel = [[UILabel alloc] init];
    _searchLabel.font = [UIFont themeFontRegular:12];
    _searchLabel.textColor = [UIColor themeGray3];
    [_searchAreaPanel addSubview:_searchLabel];
    
    _separatorLine = [[UIView alloc] init];
    _separatorLine.backgroundColor = [UIColor themeGray6];
    [self addSubview:_separatorLine];
}

-(void)initConstraints{

    [self.searchAreaPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsMake(3, 20, 9, 20));
    }];

    [self.searchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchAreaPanel).mas_offset(10);
        make.height.width.mas_equalTo(12);
        make.centerY.mas_equalTo(self.searchAreaPanel);
    }];

    [self.searchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchIcon.mas_right).offset(8);
        make.height.mas_equalTo(17);
        make.centerY.mas_equalTo(self.searchAreaPanel);
        make.right.mas_equalTo(self.searchAreaPanel).offset(-8);
    }];
    
    [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}

-(void)onSearchClicked{
    if(self.searchClickBlk){
        self.searchClickBlk();
    }
}

@end
