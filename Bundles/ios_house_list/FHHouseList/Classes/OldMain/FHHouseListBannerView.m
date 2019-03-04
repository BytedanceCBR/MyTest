//
//  FHHouseListBannerView.m
//  Pods
//
//  Created by 张静 on 2019/3/3.
//

#import "FHHouseListBannerView.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry.h>
#import <UIImageView+BDWebImage.h>

@implementation FHHouseListBannerItem



@end

@interface FHHouseListBannerItemView ()

@property(nonatomic , strong) UIImageView *bgView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UILabel *subtitleLabel;

@end

@implementation FHHouseListBannerItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.subtitleLabel];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.centerY.mas_equalTo(self);
        make.bottom.mas_equalTo(0);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(13);
    }];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(-12);
    }];
}

- (UIImageView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIImageView alloc]init];
        _bgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _bgView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont themeFontRegular:15];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel
{
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc]init];
        _subtitleLabel.font = [UIFont themeFontLight:12];
        _subtitleLabel.textColor = [UIColor colorWithHexString:@"#ffeccb"];
    }
    return _subtitleLabel;
}

@end

@interface FHHouseListBannerView ()

@property(nonatomic , strong) UIView *containerView;
@property(nonatomic , strong) NSArray<FHHouseListBannerItem *> *itemsArray;

@end

@implementation FHHouseListBannerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(14);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(60);
    }];
}

- (void)addBannerItems:(NSArray<FHHouseListBannerItem *> *)items
{
    if (items.count < 1) {
        return;
    }
    self.itemsArray = items;
    for (UIView *subview in self.containerView.subviews) {
        [subview removeFromSuperview];
    }
    CGFloat margin = 10;
    CGFloat inset = 10;
    for (NSInteger index = 0; index < 3; index++) {
        
        FHHouseListBannerItem *item = items[index];
        FHHouseListBannerItemView *itemView = [[FHHouseListBannerItemView alloc]init];
        itemView.titleLabel.text = item.title;
        itemView.subtitleLabel.text = item.subtitle;
        NSURL *imgUrl = [NSURL URLWithString:item.iconName];
        [itemView.bgView bd_setImageWithURL:imgUrl placeholder:[UIImage imageNamed:@"icon_placeholder"]];
        [self.containerView addSubview:itemView];
        itemView.tag = 100 + index;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        itemView.userInteractionEnabled = YES;
        [itemView addGestureRecognizer:tap];
    }
    [self updateLayout];
}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
    NSInteger index = tap.view.tag - 100;
    if (index >= self.itemsArray.count) {
        return;
    }
    FHHouseListBannerItem *item = self.itemsArray[index];
    
    
    if (self.clickedItemCallBack) {
        self.clickedItemCallBack(index);
    }
}


- (void)updateLayout
{
    NSArray *bannerViews = self.containerView.subviews;
    if (bannerViews.count > 1) {

        [bannerViews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:10 leadSpacing:20 tailSpacing:20];
        [bannerViews mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self.containerView);
//            make.height.mas_equalTo(60);
        }];
    } else {
        UIView * view = bannerViews.firstObject;
        if ([view isKindOfClass:[UIView class]]) {
            UIView* theView = (UIView*)view;
            [theView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(self.containerView);
                make.left.mas_equalTo(20);
                make.right.mas_equalTo(-20);
            }];
        }
    }
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc]init];
    }
    return _containerView;
}

@end
