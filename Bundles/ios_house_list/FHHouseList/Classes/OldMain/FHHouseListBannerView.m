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
#import <BDWebImage/BDWebImage.h>
#import <TTBaseLib/TTDeviceHelper.h>

@implementation FHHouseListBannerItem



@end

@interface FHHouseListBannerItemView ()

@property(nonatomic , strong) UIImageView *bgView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UILabel *subtitleLabel;
@property(nonatomic , strong) UIControl *tapBtn;

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
    [self addSubview:self.tapBtn];
    [self.tapBtn addTarget:self action:@selector(tapBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];

    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.centerY.mas_equalTo(self);
        make.bottom.mas_equalTo(0);
    }];
    CGFloat topMargin = [TTDeviceHelper isScreenWidthLarge320] ? 13 : 9;
    CGFloat bottomMargin = [TTDeviceHelper isScreenWidthLarge320] ? 12 : 8;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(topMargin);
    }];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(-bottomMargin);
    }];
    [self.tapBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)tapBtnDidClick:(UIControl *)btn
{
    if (self.clickedItemBlock) {
        self.clickedItemBlock(self.tag);
    }
}

- (UIImageView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIImageView alloc]init];
    }
    return _bgView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [TTDeviceHelper isScreenWidthLarge320] ? [UIFont themeFontRegular:15] : [UIFont themeFontRegular:13];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel
{
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc]init];
        _subtitleLabel.font = [TTDeviceHelper isScreenWidthLarge320] ? [UIFont themeFontLight:12] : [UIFont themeFontLight:10];
        _subtitleLabel.textColor = [UIColor colorWithHexString:@"#ffeccb"];
    }
    return _subtitleLabel;
}

- (UIControl *)tapBtn
{
    if (!_tapBtn) {
        _tapBtn = [[UIControl alloc]init];
    }
    return _tapBtn;
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
        make.height.mas_equalTo(60 * [TTDeviceHelper scaleToScreen375]);
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
    for (NSInteger index = 0; index < items.count; index++) {
        
        FHHouseListBannerItem *item = items[index];
        FHHouseListBannerItemView *itemView = [[FHHouseListBannerItemView alloc]init];
        itemView.titleLabel.text = item.title;
        itemView.subtitleLabel.text = item.subtitle;
        NSURL *imgUrl = [NSURL URLWithString:item.iconName];
        __weak typeof(self) wself = self;
        [[BDWebImageManager sharedManager] requestImage:imgUrl options:BDImageRequestHighPriority complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
            if (!error && image) {
                UIImage *strechImage = [image stretchableImageWithLeftCapWidth:image.size.width / 2 topCapHeight:image.size.height / 2];
                itemView.bgView.image = strechImage;
            }else {
                itemView.bgView.image = [UIImage imageNamed:@"icon_placeholder"];
            }
        }];
        [self.containerView addSubview:itemView];
        itemView.tag = 100 + index;
        itemView.clickedItemBlock = ^(NSInteger index) {
            [wself tapAction:index - 100];
        };
    }
    [self updateLayout];
}

- (void)tapAction:(NSInteger)index
{
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

        [bannerViews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:10 leadSpacing:20 * [TTDeviceHelper scaleToScreen375] tailSpacing:20 * [TTDeviceHelper scaleToScreen375]];
        [bannerViews mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self.containerView);
            make.height.mas_equalTo(60 * [TTDeviceHelper scaleToScreen375]);
        }];
    } else {
        UIView * view = bannerViews.firstObject;
        if ([view isKindOfClass:[UIView class]]) {
            UIView* theView = (UIView*)view;
            [theView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(self.containerView);
                make.left.mas_equalTo(20);
                make.right.mas_equalTo(-[UIScreen mainScreen].bounds.size.width / 2 - 5);
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
