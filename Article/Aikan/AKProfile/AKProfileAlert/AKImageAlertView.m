//
//  AKImageAlertView.m
//  Article
//
//  Created by chenjiesheng on 2018/3/8.
//

#import "AKImageAlertView.h"
#import "AKImageAlertModel.h"
#import <TTAlphaThemedButton.h>
@interface AKImageAlertView ()

@property (nonatomic, strong)UIImageView                    *imageView;
@property (nonatomic, strong)TTAlphaThemedButton            *closeButton;
@property (nonatomic, strong)AKImageAlertModel              *alertModel;
@end

@implementation AKImageAlertView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.closeButton];
        self.backgroundColors = nil;
        self.backgroundColor = [UIColor clearColor];
        self.borderColorThemeKey = nil;
        self.layer.borderWidth = 0;
        self.layer.shadowColor = [UIColor clearColor].CGColor;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 0.f;
        self.layer.shadowOpacity = 0.f;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize imageSize = CGSizeMake([TTDeviceUIUtils tt_newPadding:300], [TTDeviceUIUtils tt_newPadding:410]);
    self.imageView.size = imageSize;
    self.imageView.center = CGPointMake(self.width / 2, self.height / 2);
    self.closeButton.right = self.width - [TTDeviceUIUtils tt_newPadding:28.f];
    self.closeButton.bottom = self.imageView.top - [TTDeviceUIUtils tt_newPadding:36.f];
    if (self.closeButton.top < 20) {
        self.closeButton.top = 20.f;
    }
}

- (void)setupViewWithModel:(TTInterfaceTipBaseModel *)model
{
    [super setupViewWithModel:model];
    if ([model isKindOfClass:[AKImageAlertModel class]]) {
        self.alertModel = (AKImageAlertModel *)model;
        self.imageView.image = _alertModel.image;
    }
}

- (TTInterfaceTipViewType)viewType
{
    return TTInterfaceTipViewTypeAlert;
}

- (BOOL)needDimBackground
{
    return YES;
}

- (BOOL)needBlockTouchInBlankView
{
    return YES;
}

- (BOOL)needPanGesture
{
    return NO;
}

- (BOOL)needTimer
{
    return NO;
}

- (CGFloat)heightForView
{
    return [TTUIResponderHelper mainWindow].height;
}

- (CGFloat)widthForView
{
    return [TTUIResponderHelper mainWindow].width;
}

#pragma Getter

- (UIImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapGestureAction:)];
        [_imageView addGestureRecognizer:tapGesture];
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

- (TTAlphaThemedButton *)closeButton
{
    if (_closeButton == nil) {
        _closeButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setImage:[UIImage imageNamed:@"ak_alert_close"] forState:UIControlStateNormal];
        [_closeButton sizeToFit];
    }
    return _closeButton;
}

#pragma private

- (void)closeButtonClicked:(UIButton *)button
{
    [self dismissSelfWithAnimation:@NO];
    if (self.alertModel.closeButtonClickBlock) {
        self.alertModel.closeButtonClickBlock();
    }
}

- (void)imageViewTapGestureAction:(UITapGestureRecognizer *)tapGesture
{
    if (self.alertModel.imageViewClickBlock) {
        self.alertModel.imageViewClickBlock();
    }
    [self dismissSelfWithAnimation:@NO];
}
@end
