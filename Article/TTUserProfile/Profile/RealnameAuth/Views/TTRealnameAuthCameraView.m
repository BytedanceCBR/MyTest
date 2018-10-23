//
//  TTRealnameAuthCameraView.m
//  Article
//
//  Created by lizhuoli on 16/12/19.
//
//

#import "TTRealnameAuthCameraView.h"
#import "SSThemed.h"
#import <AVFoundation/AVFoundation.h>

@interface TTRealnameAuthCameraBottomView ()

@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) SSThemedButton *cancelButton;

@end

@interface TTRealnameAuthCameraTopView ()

@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) SSThemedButton *autoButton;
@property (nonatomic, strong) SSThemedButton *openButton;
@property (nonatomic, strong) SSThemedButton *closeButton;

@end

@interface TTRealnameAuthCameraOverlayView ()

@end


@implementation TTRealnameAuthCameraBottomView

- (instancetype)initWithFlipOn:(BOOL)flipOn
{
    self = [super init];
    if (self) {
        self.captureButton = [TTRealnameAuthCaptureButton new];
        self.cancelButton = [SSThemedButton new];
        self.leftView = [UIView new];
        
        [self addSubview:self.leftView];
        [self.leftView addSubview:self.cancelButton];
        [self addSubview:self.captureButton];
        
        if (flipOn) {
            self.rightView = [UIView new];
            self.flipButton = [SSThemedButton new];
            
            [self addSubview:self.rightView];
            [self.rightView addSubview:self.flipButton];
        }
        
        [self setupSubviewsWithFlipOn:flipOn];
    }
    return self;
}

- (void)setupSubviewsWithFlipOn:(BOOL)flipOn
{
    CGFloat bottomInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.equalTo(self);
        make.bottom.equalTo(self).offset(-bottomInset);
        make.right.equalTo(self.captureButton.mas_left);
    }];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.leftView);
    }];
    [self.captureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(67);
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(-bottomInset / 2);
    }];
    if (flipOn) {
        [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.and.top.and.equalTo(self);
            make.bottom.equalTo(self).offset(-bottomInset);
            make.left.equalTo(self.captureButton.mas_right);
        }];
        [self.flipButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.rightView);
        }];
        
        [self.flipButton setImage:[UIImage imageNamed:@"lens_flip_verification"] forState:UIControlStateNormal];
    }
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    self.cancelButton.titleColorThemeKey = kColorText8;
    self.cancelButton.highlightedTitleColorThemeKey = kColorText8Highlighted;
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:19];
    [self.cancelButton sizeToFit];
}

@end

@implementation TTRealnameAuthCameraTopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.autoButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        self.openButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        self.closeButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        
        [self addSubview:self.flashButton];
        [self addSubview:self.autoButton];
        [self addSubview:self.openButton];
        [self addSubview:self.closeButton];
        
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    CGFloat topInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.top;
    [self.flashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(14);
        make.centerY.equalTo(self).offset(topInset / 2);
    }];
    [self.openButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(topInset / 2);
    }];
    [self.autoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.openButton.mas_left).with.offset(-45);
        make.centerY.equalTo(self.openButton);
    }];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.openButton.mas_right).with.offset(45);
        make.centerY.equalTo(self.openButton);
    }];
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    
    [self.flashButton setImage:[UIImage imageNamed:@"flashlight_default_certification"] forState:UIControlStateNormal];
    [self.flashButton setImage:[UIImage imageNamed:@"flashlight_open_certification"] forState:UIControlStateHighlighted];
    [self.flashButton setImage:[UIImage imageNamed:@"flashlight_close_certification"] forState:UIControlStateDisabled];
    
    [self.autoButton setTitle:@"自动" forState:UIControlStateNormal];
    self.autoButton.titleColorThemeKey = kColorText8;
    self.autoButton.selectedTitleColorThemeKey = kColorText4;
    self.autoButton.adjustsImageWhenHighlighted = NO;
    self.autoButton.tag = AVCaptureFlashModeAuto;
    [self.openButton setTitle:@"打开" forState:UIControlStateNormal];
    self.openButton.titleColorThemeKey = kColorText8;
    self.openButton.selectedTitleColorThemeKey = kColorText4;
    self.openButton.adjustsImageWhenHighlighted = NO;
    self.openButton.tag = AVCaptureFlashModeOn;
    [self.closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    self.closeButton.titleColorThemeKey = kColorText8;
    self.closeButton.selectedTitleColorThemeKey = kColorText4;
    self.closeButton.adjustsImageWhenHighlighted = NO;
    self.closeButton.tag = AVCaptureFlashModeOff;
}

@end

@interface TTRealnameAuthCameraToastView ()

@property (nonatomic, strong) SSThemedLabel *toastLabel;

@end

@implementation TTRealnameAuthCameraToastView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.toastLabel = [SSThemedLabel new];
        
        [self addSubview: self.toastLabel];
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(28);
    }];
    [self.toastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.left.equalTo(self.mas_left).with.offset(16);
        make.right.equalTo(self.mas_right).with.offset(-16);
    }];
    
    self.backgroundColor = [UIColor blackColor];
    self.alpha = .7f;
    self.layer.cornerRadius = 6;
    self.clipsToBounds = YES;
    self.toastLabel.text = @"正在识别...";
    self.toastLabel.textColorThemeKey = kColorText8;
    self.toastLabel.font = [UIFont systemFontOfSize:12];
    self.toastLabel.textAlignment = NSTextAlignmentCenter;
}

@end

@interface TTRealnameAuthCameraView ()

@property (nonatomic, strong) SSThemedLabel *tipLabel;

@end

@implementation TTRealnameAuthCameraView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setupCameraViewWithModel:(TTRealnameAuthModel *)model
{
    switch (model.state) {
        case TTRealnameAuthStateCardForegroundCamera: {
            [self setupCameraCardViewIsForeground:YES];
        }
            break;
        case TTRealnameAuthStateCardBackgroundCamera: {
            [self setupCameraCardViewIsForeground:NO];
        }
            break;
        case TTRealnameAuthStatePersonCamera: {
            [self setupCameraPersonView];
        }
            break;
        default:
            break;
    }
}

- (void)setupCameraCardViewIsForeground:(BOOL)isForeground
{
    self.topView = [TTRealnameAuthCameraTopView new];
    self.bottomView = [[TTRealnameAuthCameraBottomView alloc] initWithFlipOn:NO];
    //self.toastView = [TTRealnameAuthCameraToastView new];
    self.tipLabel = [SSThemedLabel new];
    UIImage *overlayImage;
    if (isForeground) {
        overlayImage = [UIImage imageNamed:@"IDcard_front_certification"];
    } else {
        overlayImage = [UIImage imageNamed:@"IDcard_contrary_certification"];
    }
    self.overlayView = [[UIImageView alloc] initWithImage:overlayImage];
    
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    //[self addSubview:self.toastView];
    [self addSubview:self.overlayView];
    CGFloat bottomInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    CGFloat topInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.top;
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44 + topInset);
        make.top.and.left.and.right.equalTo(self);
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(97 + bottomInset);
        make.bottom.and.left.and.right.equalTo(self);
    }];
//    [self.toastView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.bottomView.mas_top).with.offset(-10);
//        make.centerX.equalTo(self);
//    }];
    UIView *tipView = [UIView new];
    [tipView addSubview:self.tipLabel];
    [self addSubview:tipView];
    [tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.left.and.right.equalTo(self);
        make.bottom.equalTo(self.overlayView.mas_top);
    }];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tipView);
        make.centerX.equalTo(self);
    }];
    [self.overlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        if ([TTDeviceHelper is480Screen] || [TTDeviceHelper is568Screen]) {
            make.top.equalTo(self.topView.mas_bottom).with.offset(45);
            make.bottom.equalTo(self.bottomView.mas_top).with.offset(-25);
        } else {
            make.top.equalTo(self.topView.mas_bottom).with.offset(56);
            make.bottom.equalTo(self.bottomView.mas_top).with.offset(-56);
        }
        make.width.equalTo(self.overlayView.mas_height).with.offset(overlayImage.size.width / overlayImage.size.height);
    }];
    
    if (isForeground) {
        self.tipLabel.text = @"请确保文本清晰，证件和提示边缘对齐，头像在框内";
    } else {
        self.tipLabel.text = @"请确保文本清晰，证件和提示边缘对齐，国徽在框内";
    }

    self.tipLabel.textColorThemeKey = kColorText8;
    self.tipLabel.font = [UIFont systemFontOfSize:12];
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.tipLabel sizeToFit];
    
    self.overlayView.contentMode = UIViewContentModeScaleAspectFit; // 身份证轮廓等高缩放
    
    [self.bottomView.captureButton addTarget:self action:@selector(captureButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView.cancelButton addTarget:self action:@selector(dismissButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView.autoButton addTarget:self action:@selector(flashButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView.openButton addTarget:self action:@selector(flashButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView.closeButton addTarget:self action:@selector(flashButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupCameraPersonView
{
    self.bottomView = [[TTRealnameAuthCameraBottomView alloc] initWithFlipOn:YES];
    self.toastView = [TTRealnameAuthCameraToastView new];
    self.tipLabel = [SSThemedLabel new];
    UIImage *overlayImage = [UIImage imageNamed:@"facescan_front_certification"];
    self.overlayView = [[UIImageView alloc] initWithImage:overlayImage];
    
    [self addSubview:self.bottomView];
    [self addSubview:self.toastView];
    [self addSubview:self.overlayView];
    
    CGFloat bottomInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(97 + bottomInset);
        make.bottom.and.left.and.right.equalTo(self);
    }];
    [self.toastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottomView.mas_top).with.offset(-10);
        make.centerX.equalTo(self);
    }];
    [self.overlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([TTDeviceHelper is480Screen]) {
            make.top.equalTo(self.mas_top).with.offset(50);
        } else {
            make.top.equalTo(self.mas_top).with.offset(72);
        }
        make.left.and.right.equalTo(self);
        make.centerX.equalTo(self);
        make.height.equalTo(self.overlayView.mas_width).with.multipliedBy(overlayImage.size.height / overlayImage.size.width);
    }];
    UIView *tipView = [UIView new];
    [tipView addSubview:self.tipLabel];
    [self addSubview:tipView];
    [tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(self);
        make.bottom.equalTo(self.overlayView.mas_top);
    }];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tipView);
        make.centerX.equalTo(self);
    }];
    
    self.tipLabel.text = @"请将身体放在指定区域内";
    self.tipLabel.textColorThemeKey = kColorText8;
    self.tipLabel.font = [UIFont systemFontOfSize:19];
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.tipLabel sizeToFit];
    
    self.overlayView.contentMode = UIViewContentModeScaleAspectFit; // 头像轮廓等宽缩放
    
    [self.bottomView.captureButton addTarget:self action:@selector(captureButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView.cancelButton addTarget:self action:@selector(dismissButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView.flipButton addTarget:self action:@selector(flipButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)captureButtonTouched:(UIButton *)sender
{
    [self.delegate captureButtonTouched:sender];
}

- (void)dismissButtonTouched:(UIButton *)sender
{
    [self.delegate dismissButtonTouched:sender];
}

- (void)flashButtonTouched:(UIButton *)sender
{
    switch (sender.tag) {
        case AVCaptureFlashModeOff: {
            self.topView.flashButton.enabled = NO;
            self.topView.flashButton.highlighted = NO;
            self.topView.closeButton.selected = YES;
            self.topView.openButton.selected = NO;
            self.topView.autoButton.selected = NO;
        }
            break;
        case AVCaptureFlashModeOn: {
            self.topView.flashButton.enabled = YES;
            self.topView.flashButton.highlighted = YES;
            self.topView.closeButton.selected = NO;
            self.topView.openButton.selected = YES;
            self.topView.autoButton.selected = NO;
        }
            break;
        case AVCaptureFlashModeAuto: {
            self.topView.flashButton.enabled = YES;
            self.topView.flashButton.highlighted = NO;
            self.topView.closeButton.selected = NO;
            self.topView.openButton.selected = NO;
            self.topView.autoButton.selected = YES;
        }
            break;
        default:
            break;
    }
    [self.delegate flashButtonTouched:sender];
}

- (void)flipButtonTouched:(UIButton *)sender
{
    [self.delegate flipButtonTouched:sender];
}

@end
