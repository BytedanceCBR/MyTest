//
//  TTVCommodityItemView.m
//  Article
//
//  Created by panxiang on 2017/8/8.
//
//

#import "TTVCommodityItemView.h"
#import "TTURLUtils.h"
#import "TTRoute.h"
#import "TTVCommodityEntity.h"
#import "TTArticleCellHelper.h"
#import "TTMovieStore.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import <BDWebImage/SDWebImageAdapter.h>
#import "TTNavigationController.h"
#import "UIView+CustomTimingFunction.h"


typedef NS_ENUM(NSUInteger, TTVCommodityItemViewType) {
    TTVCommodityItemViewTypeNone = 1,
    TTVCommodityItemViewTypeBuyButton,
    TTVCommodityItemViewTypeCloseButton,
};

@interface TTVCommodityItemView()<UIGestureRecognizerDelegate>
@property (nonatomic ,strong)UIButton *background;
@property (nonatomic ,strong)UIImageView *imageView;
@property (nonatomic ,strong)UIImageView *recommandIcon;
@property (nonatomic ,strong)UILabel *titleLabel;
@property (nonatomic ,strong)UILabel *priceLabel;
@property (nonatomic ,strong)UILabel *couponLabel;
@property (nonatomic ,strong)UIButton *closeButton;
@property (nonatomic ,strong)UIButton *buyButton;
@property (nonatomic ,strong)UIButton *imageBuyButton;
@property (nonatomic ,assign)TTVCommodityItemViewType itemViewType;
//拖动手势
@property (nonatomic, strong)UIPanGestureRecognizer *pan;
@property (nonatomic, assign) CGFloat lastX;
@property (nonatomic, assign) CGFloat originX;
@property (nonatomic, assign) BOOL isDraggingView;

@end

@implementation TTVCommodityItemView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
        self.userInteractionEnabled = YES;
        self.hidden = YES;
        _imageView = [[UIImageView alloc] init];
        _imageView.userInteractionEnabled = NO;
        _imageView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground5];
        [self addSubview:_imageView];
        
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
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:[TTDeviceUIUtils tt_newFontSize:10]]];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_titleLabel];
        
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:[TTDeviceUIUtils tt_newFontSize:12]]];
        _priceLabel.textColor = [UIColor colorWithHexString:@"f85959"];
        _priceLabel.textAlignment = NSTextAlignmentLeft;
        _priceLabel.numberOfLines = 1;
        [self addSubview:_priceLabel];
        
        _background = [UIButton buttonWithType:UIButtonTypeCustom];
        _background.frame = self.bounds;
        _background.backgroundColor = [UIColor clearColor];
        [self addSubview:_background];
        [_background addTarget:self action:@selector(openCommodity) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pangesHandler:)];
        pan.delegate = self;
        self.userInteractionEnabled = YES;
        pan.minimumNumberOfTouches = 1;
        pan.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:pan];
        self.pan = pan;

        NSInteger style = [[dic valueForKey:@"commodity_show_style"] integerValue];
        switch (style) {
            case 0:
                self.itemViewType = TTVCommodityItemViewTypeNone;
                break;
            case 1:
                _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _closeButton.backgroundColor = [UIColor clearColor];
                _closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-15, -15, -15, -15);
                [_closeButton setImage:[UIImage imageNamed:@"commodity_float_close.png"] forState:UIControlStateNormal];
                [_closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
                [_closeButton sizeToFit];
                [self addSubview:_closeButton];
                self.itemViewType = TTVCommodityItemViewTypeCloseButton;
                break;
            case 2:
                _buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _buyButton.layer.cornerRadius = 2;
                _buyButton.hitTestEdgeInsets = UIEdgeInsetsMake(-15, -15, -15, -15);
                _buyButton.backgroundColor = [UIColor colorWithRed:248/255.0 green:89/255.0 blue:89/255.0 alpha:1];
                [_buyButton setTitle:@"查看" forState:UIControlStateNormal];
                [_buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                _buyButton.titleLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:10]];
                [_buyButton addTarget:self action:@selector(openCommodityClickButton) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:_buyButton];
                self.itemViewType = TTVCommodityItemViewTypeBuyButton;

                break;
            default:
                break;
        }
        
    }
    return self;
}

- (void)show
{
    self.alpha = 1;
    self.hidden = NO;
    self.superview.alpha = 1;
    self.superview.hidden = NO;
}

- (void)closeButtonAction
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        self.superview.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)openCommodityClickButton
{
    [self openCommodity];
}

- (void)setEntity:(TTVCommodityEntity *)entity
{
    [self show];
    _entity = entity;
    _priceLabel.text = [NSString stringWithFormat:@"¥ %.2f",entity.price / 100.f];
    _titleLabel.text = [NSString stringWithFormat:@"%@",entity.title];
    [self reSetPriceLabelIfNeed];
    self.hidden = NO;
    if (!isEmptyString(entity.image_url)) {
        [_imageView sda_setImageWithURL:[NSURL URLWithString:entity.image_url]];
    }else{
        _imageView.image = nil;
    }
    [self setNeedsLayout];
}
- (void)reSetPriceLabelIfNeed
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
    _background.frame = self.bounds;
    NSInteger buyButtonWidth = 38;
    NSInteger buyButtonHeight = 20;
    
    CGFloat buyButtonLeft = _buyButton.left;
    if (self.itemViewType == TTVCommodityItemViewTypeBuyButton){
        if (self.entity.coupon_type && self.entity.coupon_num) {
            buyButtonWidth = [TTDeviceUIUtils tt_newPadding:48];
            self.imageBuyButton.frame =  CGRectMake(_background.width - [TTDeviceUIUtils tt_newPadding:8] - buyButtonWidth, (_background.height - buyButtonHeight) / 2.0, buyButtonWidth, buyButtonHeight);
            buyButtonLeft = self.imageBuyButton.left;
            [self.buyButton setHidden:YES];
        }else{
            self.buyButton.hidden = NO;
            _buyButton.frame = CGRectMake(_background.width - [TTDeviceUIUtils tt_newPadding:12] - buyButtonWidth, (_background.height - buyButtonHeight) / 2.0, buyButtonWidth, buyButtonHeight);
            [_imageBuyButton removeFromSuperview];
            _imageBuyButton = nil;
        }
    }
    
    _closeButton.frame = CGRectMake(_background.width - [TTDeviceUIUtils tt_newPadding:12] - _closeButton.width, (_background.height - _closeButton.height) / 2.0, _closeButton.width, _closeButton.height);
    NSInteger height = (self.height - 8);
    _imageView.frame = CGRectMake(4, 4, height, height);
    _recommandIcon.frame = _imageView.bounds;
    if (self.itemViewType == TTVCommodityItemViewTypeCloseButton) {
        _titleLabel.frame = CGRectMake(_imageView.right + [TTDeviceUIUtils tt_newPadding:4], [TTDeviceUIUtils tt_newPadding:4], _closeButton.left - _imageView.right - [TTDeviceUIUtils tt_newPadding:4] - [TTDeviceUIUtils tt_newPadding:8], 28);
    }else if (self.itemViewType == TTVCommodityItemViewTypeBuyButton){
        _titleLabel.frame = CGRectMake(_imageView.right + [TTDeviceUIUtils tt_newPadding:4], [TTDeviceUIUtils tt_newPadding:4], buyButtonLeft - _imageView.right - [TTDeviceUIUtils tt_newPadding:4] - [TTDeviceUIUtils tt_newPadding:8], 28);
    }else{
        _titleLabel.frame = CGRectMake(_imageView.right + [TTDeviceUIUtils tt_newPadding:4], [TTDeviceUIUtils tt_newPadding:1], _background.width - _imageView.right - [TTDeviceUIUtils tt_newPadding:4 * 2], 28);
    }
    
    if (self.entity.coupon_type && self.entity.coupon_num) {
        NSInteger height = 12;
        self.couponLabel.hidden = NO;
        self.couponLabel.frame = CGRectMake(_titleLabel.origin.x, self.height - _titleLabel.top - height, _couponLabel.width, height);
        [_priceLabel sizeToFit];
        height = 14;
        _priceLabel.frame = CGRectMake(self.couponLabel.right + [TTDeviceUIUtils tt_newPadding:2], self.height - _titleLabel.top - height, _background.width - _imageView.right - [TTDeviceUIUtils tt_newPadding:5 * 2] - self.couponLabel.width, height);
    }else{
        [_couponLabel removeFromSuperview];
        _couponLabel = nil;
        [_priceLabel sizeToFit];
        _priceLabel.frame = CGRectMake(_titleLabel.origin.x, _titleLabel.bottom, _background.width - _imageView.right - [TTDeviceUIUtils tt_newPadding:4 * 2], 14);
    }
    
    [super layoutSubviews];
}


- (void)openCommodity
{
    BOOL isHandled = NO;
    BOOL isWeb = NO;
    if (!isHandled && !isEmptyString(self.entity.charge_url)) { // SDK 不能处理的，使用内置浏览器打开
        NSURL *url = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:@{@"url" : self.entity.charge_url}];
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            [[TTRoute sharedRoute] openURLByPushViewController:url];
            isHandled = YES;
            isWeb = YES;
        }
    }
    if (isHandled) {
        if ([self.delegate respondsToSelector:@selector(ttv_didOpenCommodityByWeb:)]) {
            [self.delegate ttv_didOpenCommodityByWeb:isWeb];
        }
    }
}

- (UILabel *)couponLabel{
    if (!_couponLabel) {
        _couponLabel = [[UILabel alloc] init];
        _couponLabel.backgroundColor = [UIColor clearColor];
        _couponLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:10]];
        _couponLabel.textColor = [UIColor colorWithHexString:@"f85959"];
        _couponLabel.textAlignment = NSTextAlignmentLeft;
        _couponLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _couponLabel.numberOfLines = 2;
        [self addSubview:_couponLabel];
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
        _imageBuyButton.titleLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:10]];
        UIImage *image = [UIImage imageNamed:@"red_packet_redbtn"];
        image = [self scaleImage:image toSize:CGSizeMake(14.f, 15.2f)];
        [_imageBuyButton setImage:image forState:UIControlStateNormal];
        [_imageBuyButton addTarget:self action:@selector(openCommodityClickButton) forControlEvents:UIControlEventTouchUpInside];
        [_imageBuyButton layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageLeft imageTitlespace:[TTDeviceUIUtils tt_newPadding:4]];
        [self addSubview:_imageBuyButton];
    }
    return _imageBuyButton;
}

- (void)pangesHandler:(UIPanGestureRecognizer *) ges{
    if (self.isAnimationing) {
        return ;
    }
    CGPoint locationPoint = [ges locationInView:self.superview];
    CGPoint velocityPoint = [ges velocityInView:self.superview];
    if (ges != self.pan) {
        return;
    }
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.originX = self.frame.origin.x;
            self.lastX = locationPoint.x;
            if (velocityPoint.x > 0 && !self.isDraggingView) {
                self.isDraggingView = YES;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (velocityPoint.x > 0 && !self.isDraggingView) {
                self.isDraggingView = YES;
            }
            if (self.isDraggingView) {
                CGFloat step = locationPoint.x - self.lastX;
                CGRect frame = self.frame;
                frame.origin.x += step;
                if (frame.origin.x < self.originX) {
                    frame.origin.x = self.originX;
                }
                self.frame = frame;
            }
            self.lastX = locationPoint.x;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            if (self.isDraggingView) {
                CGRect frame = self.frame;
                float stepPercent = (frame.origin.x - self.originX) / self.width ;
                frame.origin.x = (velocityPoint.x > 0 || stepPercent > 0.2)  ? self.originX + self.width : self.originX;
                if (frame.origin.x > self.originX){
                    if (self.delegate && [self.delegate respondsToSelector:@selector(ttv_dimissItemViewWithTargetAnimation:)]){
                        [self.delegate ttv_dimissItemViewWithTargetAnimation:YES];
                    }
                }else{
                    [UIView animateWithDuration: 0.25f customTimingFunction: CustomTimingFunctionSineOut animation:^{
                        self.frame = frame;
                    } completion:^(BOOL finished) {
                    }];
                }
            }
            self.isDraggingView = NO;
        }
            break;
        default:
            break;
    }
 
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (self.pan == gestureRecognizer){
        TTNavigationController *navi = (TTNavigationController *)[TTUIResponderHelper topNavigationControllerFor:self];
        if (navi.panRecognizer == otherGestureRecognizer || navi.swipeRecognizer == otherGestureRecognizer) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == self.pan) {
        CGPoint velocity = [self.pan velocityInView:self];
        if (fabs(velocity.y) > fabs(velocity.x)){
            return NO;
        }
        if (CGRectGetWidth(self.frame) == 0 || CGRectGetHeight(self.frame) == 0) {
            return NO;
        }
//        if (self.frame.origin.x >= self.originX + self.width){
//            return NO;
//        }
        
        CGPoint translation = [((UIPanGestureRecognizer *)gestureRecognizer) translationInView:gestureRecognizer.view];
        if (fabs(translation.y) > fabs(translation.x)) {
            return NO;
        }
        return YES;
    }
    return YES;
}

/// 压缩到制定尺寸 - 保真
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width > size.width) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        return image;
    }
}

@end
