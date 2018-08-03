//
//  TTContactsDeniedRedPacketGuideView.m
//  Article
//
//  Created by Jiyee Sheng on 7/31/17.
//
//

#import "TTContactsDeniedRedPacketGuideView.h"
#import "TTContactsUserDefaults.h"


#define kTTTitleLabelWidth           [TTDeviceUIUtils tt_newPadding:260.f]
#define kTTTitleLabelHeight          [TTDeviceUIUtils tt_newPadding:24.f]

@interface TTContactsDeniedRedPacketGuideView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *subtitleLabel;

@end

@implementation TTContactsDeniedRedPacketGuideView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.containerView addSubview:self.backgroundImageView];
        [self.containerView addSubview:self.imageView];
        [self.containerView addSubview:self.titleLabel];
        [self.containerView addSubview:self.subtitleLabel];

        self.titleLabel.text = @"同步通讯录";
        self.subtitleLabel.text = [[TTContactsUserDefaults dictionaryOfContactsRedPacketContents] stringValueForKey:@"open_redpack" defaultValue:@"领取好友红包"];
        [self.submitButton setTitle:@"去设置" forState:UIControlStateNormal];

        self.backgroundImageView.centerX = self.containerView.width / 2;
        self.backgroundImageView.top = [TTDeviceUIUtils tt_newPadding:0];

        self.imageView.centerX = self.containerView.width / 2;
        self.imageView.top = [TTDeviceUIUtils tt_newPadding:46];

        self.titleLabel.centerX = self.containerView.width / 2;
        self.titleLabel.top = [TTDeviceUIUtils tt_newPadding:239];

        self.subtitleLabel.centerX = self.containerView.width / 2;
        self.subtitleLabel.top = [TTDeviceUIUtils tt_newPadding:274];

        [self drawBackgroundLayer];
    }

    return self;
}

- (void)drawBackgroundLayer {
    CGFloat gradientLayerWidth = self.containerView.size.width;
    CGFloat gradientLayerHeight = self.containerView.size.height;

    _gradientLayer = [CAGradientLayer layer];
    [_gradientLayer setColors:@[
        (id) [UIColor colorWithHexString:@"F88981"].CGColor,
        (id) [UIColor colorWithHexString:@"F36962"].CGColor,
        (id) [UIColor colorWithHexString:@"EF514A"].CGColor,
        (id) [UIColor colorWithHexString:@"E13D35"].CGColor
    ]];
    [_gradientLayer setLocations:@[@(0), @(0.1), @(0.4)]];
    [_gradientLayer setStartPoint:CGPointMake(0, 0)];
    [_gradientLayer setEndPoint:CGPointMake(0.5, 0.5)];
    _gradientLayer.zPosition = -1;
    _gradientLayer.frame = CGRectMake(0, 0, gradientLayerWidth, gradientLayerHeight);

    [self.containerView.layer addSublayer:_gradientLayer];
}

#pragma mark - getter and setter

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contacts_red_packet_settings_background"]];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    }

    return _backgroundImageView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contacts_red_packet_settings"]];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }

    return _imageView;
}

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, kTTTitleLabelWidth, kTTTitleLabelHeight)];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexString:@"FFF3BC"];
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:15]];
    }

    return _titleLabel;
}

- (SSThemedLabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, kTTTitleLabelWidth, kTTTitleLabelHeight)];
        _subtitleLabel.numberOfLines = 1;
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.textColor = [UIColor colorWithHexString:@"FFF3BC"];
        _subtitleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17]];
    }

    return _subtitleLabel;
}

@end
