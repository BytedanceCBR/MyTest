//
//  TTVCommodityItemViewFull.m
//  Article
//
//  Created by panxiang on 2017/8/8.
//
//

#import "TTVCommodityItemViewFull.h"
#import "TTImageView.h"
#import "TTURLUtils.h"
#import "TTRoute.h"
#import "TTVCommodityEntity.h"
#import "TTArticleCellHelper.h"
#import "TTMovieStore.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import <BDWebImage/SDWebImageAdapter.h>
//#import "NSString+TTADD.h"

@interface TTVCommodityItemViewFull()
@property (nonatomic ,strong)UIButton *background;
@property (nonatomic ,strong)UIImageView *imageView;
@property (nonatomic ,strong)UILabel *titleLabel;
@property (nonatomic ,strong)UILabel *priceLabel;
@property (nonatomic ,strong)UILabel *couponLabel;
@property (nonatomic ,strong)UIButton *buyButton;
@property (nonatomic ,strong)UIButton *imageBuyButton;
@property (nonatomic ,strong)UIImageView *recommandIcon;
@end

@implementation TTVCommodityItemViewFull


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        _background = [UIButton buttonWithType:UIButtonTypeCustom];
        _background.frame = self.bounds;
        _background.backgroundColor = [UIColor clearColor];
        [_background addTarget:self action:@selector(openCommodityByGesture) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_background];
        self.backgroundColor = _background.backgroundColor;
        
        _imageView = [[UIImageView alloc] init];
        _imageView.userInteractionEnabled = NO;
        _imageView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground5];
        [_background addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 2;
        [_background addSubview:_titleLabel];
        
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:18]];
        _priceLabel.textColor = [UIColor colorWithHexString:@"f85959"];
        _priceLabel.textAlignment = NSTextAlignmentLeft;
        _priceLabel.numberOfLines = 1;
        [_background addSubview:_priceLabel];
        
        _buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _buyButton.layer.cornerRadius = 4;
        _buyButton.backgroundColor = [UIColor colorWithRed:248/255.0 green:89/255.0 blue:89/255.0 alpha:1];
        [_buyButton setTitle:@"购买" forState:UIControlStateNormal];
        [_buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _buyButton.titleLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        [_buyButton addTarget:self action:@selector(openCommodityClickButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_buyButton];
        
        NSDictionary *dic = [[TTSettingsManager sharedManager] settingForKey:@"tt_video_commodity" defaultValue:@{} freeze:NO];
        BOOL isVideoCommodityRecommandClose = [[dic valueForKey:@"video_commodity_author_recommand_icon_hidden"] boolValue];
        if (!isVideoCommodityRecommandClose) {
            _recommandIcon = [[UIImageView alloc] init];
            _recommandIcon.backgroundColor = [UIColor clearColor];
            
            NSString *imageUrl = [dic valueForKey:@"author_recommend_icon"];
            if (!isEmptyString(imageUrl)) {
                [_recommandIcon sda_setImageWithURL:[NSURL URLWithString:imageUrl]];
            }else{
                _recommandIcon.image = [UIImage imageNamed:@"video_commodity_recommand.png"];
            }
            [_imageView addSubview:_recommandIcon];
        }
    }
    return self;
}

- (void)setEntity:(TTVCommodityEntity *)entity
{
    _entity = entity;
    _priceLabel.text = [NSString stringWithFormat:@"¥ %.2f",entity.price / 100.f];
    _titleLabel.text = [NSString stringWithFormat:@"%@",entity.title];
    [self resetPriceLabelIfNeed];
    if (!isEmptyString(entity.image_url)) {
        [_imageView sda_setImageWithURL:[NSURL URLWithString:entity.image_url]];
    }else{
        _imageView.image = nil;
    }
    [self setNeedsLayout];
}

- (void)resetPriceLabelIfNeed
{
    if (self.entity.coupon_type && self.entity.coupon_num) {
        self.couponLabel.text = @"券后价¥ ";
        [self.couponLabel sizeToFit];
        if (self.entity.coupon_type == 1) {
            _priceLabel.text = [NSString stringWithFormat:@"%.2f",(self.entity.price - self.entity.coupon_num) / 100.f];
        }else if (self.entity.coupon_type == 2){
            _priceLabel.text = [NSString stringWithFormat:@"%.2f",self.entity.price * self.entity.coupon_num / 1000.f];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = CGRectMake(0, 0, self.height, self.height);
    _recommandIcon.frame = _imageView.bounds;
    NSInteger buyButtonWidth = [TTDeviceUIUtils tt_newPadding:58];
    if (self.isFullScreen) {
        _background.frame = self.bounds;
        NSInteger height = 28;
        if (self.entity.coupon_type && self.entity.coupon_num) {
            buyButtonWidth = [TTDeviceUIUtils tt_newPadding:72];
            self.imageBuyButton.frame =  CGRectMake(self.width - buyButtonWidth, (self.height - height) / 2.0, buyButtonWidth, height);
            [self.buyButton removeFromSuperview];
            self.buyButton = nil;
        }else{
            _buyButton.frame = CGRectMake(self.width - buyButtonWidth, (self.height - height) / 2.0, buyButtonWidth, height);
        }
        CGFloat buttonLeft = _buyButton ? _buyButton.left : _imageBuyButton.left;
        [_titleLabel sizeToFit];
        _titleLabel.frame = CGRectMake(_imageView.right + [TTDeviceUIUtils tt_newPadding:8], 0, buttonLeft - _imageView.right - [TTDeviceUIUtils tt_newPadding:28], _titleLabel.height);
        
        if (self.entity.coupon_type && self.entity.coupon_num) {
            NSInteger height = 12;
            self.couponLabel.frame = CGRectMake(_titleLabel.origin.x, self.height - _titleLabel.top - height, _couponLabel.width, height);
            [_priceLabel sizeToFit];
            height = 14;
            _priceLabel.frame = CGRectMake(self.couponLabel.right + [TTDeviceUIUtils tt_newPadding:2], self.height - _titleLabel.top - height, _background.width - _imageView.right - [TTDeviceUIUtils tt_newPadding:5 * 2] - self.couponLabel.width, height);
        }else{
            [_priceLabel sizeToFit];
            _priceLabel.frame = CGRectMake(_titleLabel.origin.x, _titleLabel.bottom, _priceLabel.width, _priceLabel.height);
        }
    }else{
        _background.frame = self.bounds;
        NSInteger height = 28;
        if (self.entity.coupon_type && self.entity.coupon_num) {
            buyButtonWidth = [TTDeviceUIUtils tt_newPadding:72];
            self.imageBuyButton.frame =  CGRectMake(self.width - buyButtonWidth, (self.height - height) / 2.0, buyButtonWidth, height);
            [self.buyButton removeFromSuperview];
            self.buyButton = nil;
        }else{
            _buyButton.frame = CGRectMake(self.width - buyButtonWidth, (self.height - height) / 2.0, buyButtonWidth, height);
        }
        CGFloat buttonLeft = _buyButton ? _buyButton.left : _imageBuyButton.left;
        [_titleLabel sizeToFit];
        _titleLabel.frame = CGRectMake(_imageView.right + [TTDeviceUIUtils tt_newPadding:8], 0, buttonLeft - _imageView.right - [TTDeviceUIUtils tt_newPadding:28], _titleLabel.height);
        
        
        if (self.entity.coupon_type && self.entity.coupon_num) {
            NSInteger height = 12;
            self.couponLabel.frame = CGRectMake(_titleLabel.origin.x, self.height - _titleLabel.top - height, _couponLabel.width, height);
            [self.couponLabel sizeToFit];
            [_priceLabel sizeToFit];
            height = 14;
            _priceLabel.frame = CGRectMake(_couponLabel.right + [TTDeviceUIUtils tt_newPadding:6], self.height - _titleLabel.top - height, _priceLabel.width, height);
        }else{
            [_priceLabel sizeToFit];
            _priceLabel.frame = CGRectMake(_titleLabel.origin.x, _titleLabel.bottom, _priceLabel.width, _priceLabel.height);
        }
        
    }
}

- (void)openCommodityIsClickButton:(BOOL)isClickButton
{
    BOOL isHandled = NO;
    if (!isHandled && !isEmptyString(self.entity.charge_url)) { // SDK 不能处理的，使用内置浏览器打开
        NSURL *url = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:@{@"url" : self.entity.charge_url}];
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            [[TTRoute sharedRoute] openURLByPushViewController:url];
            isHandled = YES;
        }
    }
    if (isHandled) {
        if ([self.delegate respondsToSelector:@selector(ttv_didOpenCommodity:isClickButton:)]) {
            [self.delegate ttv_didOpenCommodity:self.entity isClickButton:isClickButton];
        }
    }
}

- (void)openCommodityByGesture
{
    [self openCommodityIsClickButton:NO];
}

- (void)openCommodityClickButton
{
    [self openCommodityIsClickButton:YES];
}

#pragma mark - getter

- (UILabel *)couponLabel{
    if (!_couponLabel) {
        _couponLabel = [[UILabel alloc] init];
        _couponLabel.backgroundColor = [UIColor clearColor];
        _couponLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
        _couponLabel.textColor = [UIColor colorWithHexString:@"f85959"];
        _couponLabel.textAlignment = NSTextAlignmentLeft;
        _couponLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _couponLabel.numberOfLines = 2;
        [_background addSubview:_couponLabel];
    }
    return _couponLabel;
}

- (UIButton *)imageBuyButton{
    if (!_imageBuyButton) {
        _imageBuyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _imageBuyButton.layer.cornerRadius = 4;
        _imageBuyButton.backgroundColor = [UIColor colorWithRed:248/255.0 green:89/255.0 blue:89/255.0 alpha:1];
        [_imageBuyButton setTitle:@"购买" forState:UIControlStateNormal];
        [_imageBuyButton setTitleColor:[UIColor colorWithHexString:@"#FFF3BC"] forState:UIControlStateNormal];
        _imageBuyButton.titleLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        [_imageBuyButton setImage:[UIImage imageNamed:@"red_packet_redbtn"] forState:UIControlStateNormal];
        [_imageBuyButton addTarget:self action:@selector(openCommodityClickButton) forControlEvents:UIControlEventTouchUpInside];
        [_imageBuyButton layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageLeft imageTitlespace:[TTDeviceUIUtils tt_newPadding:4]];
        [self addSubview:_imageBuyButton];
    }
    return _imageBuyButton;
}

@end

