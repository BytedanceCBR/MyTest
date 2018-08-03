//
//  AKAwardCoinTipView.m
//  Article
//
//  Created by chenjiesheng on 2018/3/12.
//

#import "AKAwardCoinTipView.h"
#import "AKAwardCoinTipModel.h"

@interface AKAwardCoinTipView ()

@property (nonatomic, strong)UIView                 *contentView;
@property (nonatomic, strong)UILabel                *titleLabel;
@property (nonatomic, strong)UIImageView            *iconImageView;
@property (nonatomic, strong)UILabel                *coinNumlabel;
@property (nonatomic, strong)UIView                 *backView;
@property (nonatomic, assign)CGFloat                 viewHeight;
@property (nonatomic, assign)CGFloat                 viewWidth;
@property (nonatomic, weak)AKAwardCoinTipModel      *viewModel;
@end
@implementation AKAwardCoinTipView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundColors = nil;
        self.userInteractionEnabled = NO;
        self.layer.shadowOpacity = 0;
        self.layer.borderWidth = 0;
        [self addSubview:self.backView];
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)show
{
    [super show];
    if (self.model.useCustomBackView && self.model.customBackView) {
        switch (self.viewModel.tipType) {
            case AKAwardCoinTipTypeVideo:
            {
                UIView *customBackView = self.model.customBackView;
                self.right = customBackView.width - [TTDeviceUIUtils tt_newPadding:10];
                self.bottom = customBackView.height - [TTDeviceUIUtils tt_newPadding:10];
                self.transform = CGAffineTransformMakeScale(.01, .01);
                [UIView animateWithDuration:.22 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    
                }];
            }
                break;
                
            default:
                break;
        }
    }
}

- (BOOL)needPanGesture
{
    return NO;
}

- (BOOL)needDimBackground
{
    return NO;
}

- (BOOL)needBlockTouchInBlankView
{
    return NO;
}

- (CGFloat)timerDuration
{
    return 1;
}

- (CGFloat)heightForView
{
    return self.viewHeight;
}

- (CGFloat)widthForView
{
    return self.viewWidth;
}

- (TTInterfaceTipViewType)viewType
{
    if (self.model.useCustomBackView && self.model.customBackView) {
        return TTInterfaceTipViewTypeNone;
    }
    return TTInterfaceTipViewTypeAlert;
}

- (void)removeFromSuperViewByTimer
{
    [super dismissSelfWithAnimation:@NO];
}

- (void)refreshUIWithModel:(AKAwardCoinTipModel *)model
{
    switch (model.tipType) {
        case AKAwardCoinTipTypeArticle:
        {
            self.viewWidth = [TTDeviceUIUtils tt_newPadding:178.f];
            self.viewHeight = [TTDeviceUIUtils tt_newPadding:141.f];
            self.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f]];
            self.coinNumlabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
            self.contentView.width = self.viewWidth;
            if (!isEmptyString(model.iconImageName)) {
                self.iconImageView.image = [UIImage imageNamed:model.iconImageName];
            } else {
                self.iconImageView.image = [UIImage imageNamed:@"award_coin_icon_image_big"];
            }
            self.iconImageView.size = CGSizeMake([TTDeviceUIUtils tt_newPadding:60], [TTDeviceUIUtils tt_newPadding:60]);
            if (!isEmptyString(model.title)) {
                self.titleLabel.text = model.title;
            } else {
                self.titleLabel.text = @"奖励认真阅读的你";
            }
            
            self.titleLabel.width = self.viewWidth;
            self.coinNumlabel.text = [NSString stringWithFormat:@"金币+%ld",model.coinNum];
            if (model.coinNum <= 0) {
                self.coinNumlabel.text = nil;
                self.coinNumlabel.height = 0;
            } else {
                [self.coinNumlabel sizeToFit];
            }
            self.coinNumlabel.width = self.viewWidth;
            self.backView.size = CGSizeMake(self.viewWidth, self.viewHeight);
            self.backView.origin = CGPointZero;
            self.backView.layer.cornerRadius = 12;
            self.backView.clipsToBounds = YES;
            
            self.iconImageView.centerX = self.viewWidth / 2;
            self.iconImageView.top = 0;
            self.titleLabel.left = 0;
            self.titleLabel.top = self.iconImageView.bottom + 5;
            self.coinNumlabel.left = 0;
            self.coinNumlabel.top = self.titleLabel.bottom + 5;
            self.contentView.height = self.coinNumlabel.bottom;
            self.contentView.center = CGPointMake(self.viewWidth / 2, self.viewHeight / 2);
        }
            break;
        case AKAwardCoinTipTypeVideo:
        {
            self.viewHeight = 27;
            self.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12.f]];
            self.coinNumlabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12.f]];
            self.contentView.width = self.viewWidth;
            if (!isEmptyString(model.iconImageName)) {
                self.iconImageView.image = [UIImage imageNamed:model.iconImageName];
            } else {
                self.iconImageView.image = [UIImage imageNamed:@"award_coin_icon_image_small"];
            }
            self.iconImageView.size = CGSizeMake([TTDeviceUIUtils tt_newPadding:18], [TTDeviceUIUtils tt_newPadding:18]);
            if (!isEmptyString(model.title)) {
                self.titleLabel.text = model.title;
            } else {
                self.titleLabel.text = @"认真看视频,";
            }
            [self.titleLabel sizeToFit];
            self.coinNumlabel.text = [NSString stringWithFormat:@"金币+%ld",model.coinNum];
            [self.coinNumlabel sizeToFit];
    
            self.contentView.height = self.viewHeight;
            self.iconImageView.origin = CGPointZero;
            self.iconImageView.centerY = self.contentView.height / 2;
            self.titleLabel.left = self.iconImageView.right + 5;
            self.titleLabel.centerY = self.iconImageView.centerY;
            self.coinNumlabel.left = self.titleLabel.right;
            self.coinNumlabel.centerY = self.titleLabel.centerY;
            self.contentView.width = self.coinNumlabel.right;
            
            self.viewWidth = self.contentView.width + [TTDeviceUIUtils tt_newPadding:20.f];
            self.contentView.center = CGPointMake(self.viewWidth / 2, self.viewHeight / 2);
            self.backView.size = CGSizeMake(self.viewWidth, self.viewHeight);
            self.backView.origin = CGPointZero;
            self.backView.layer.cornerRadius = self.viewHeight / 2;
            self.backView.clipsToBounds = YES;
        }
            break;
    }
}

- (void)setupViewWithModel:(TTInterfaceTipBaseModel *)model
{
    [super setupViewWithModel:model];
    if ([model isKindOfClass:[AKAwardCoinTipModel class]]) {
        self.viewModel = (AKAwardCoinTipModel *)model;
        [self refreshUIWithModel:self.viewModel];
    }
}

#pragma Getter

- (UIView *)backView
{
    if (_backView == nil) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    }
    return _backView;
}

- (UIImageView *)iconImageView
{
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImageView;
}

- (UILabel *)coinNumlabel
{
    if (_coinNumlabel == nil) {
        _coinNumlabel = [[UILabel alloc] init];
        _coinNumlabel.textColor = [UIColor whiteColor];
        _coinNumlabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
        _coinNumlabel.text = @"金币+10";
        _coinNumlabel.textAlignment = NSTextAlignmentCenter;
        [_coinNumlabel sizeToFit];
    }
    return _coinNumlabel;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f]];
        _titleLabel.text = @"奖励认真阅读的你";
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (UIView *)contentView
{
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:self.iconImageView];
        [_contentView addSubview:self.coinNumlabel];
        [_contentView addSubview:self.titleLabel];
    }
    return _contentView;
}

@end
