//
//  TTRealnameAuthContainerView.m
//  Article
//
//  Created by lizhuoli on 16/12/18.
//
//

#import "TTRealnameAuthContainerView.h"
#import "TTRealnameAuthProgressView.h"
#import "TTRealnameAuthButton.h"
#import "TTRealnameAuthMacro.h"

@interface TTRealnameAuthContainerView ()

@property (nonatomic, assign) CGFloat navHeight;
@property (nonatomic, strong) TTRealnameAuthProgressView *progressView;
@property (nonatomic, strong) SSThemedLabel *startLabel;
@property (nonatomic, strong) SSThemedImageView *startImageView;
@property (nonatomic, strong) TTRealnameAuthStartButton *startButton;
@property (nonatomic, strong) SSThemedButton *retakeButton;

@property (nonatomic, strong) SSThemedImageView *leftImageView;
@property (nonatomic, strong) SSThemedImageView *rightImageView;
@property (nonatomic, strong) SSThemedLabel *leftLabel;
@property (nonatomic, strong) SSThemedLabel *rightLabel;

@property (nonatomic, strong) SSThemedTextField *personName;
@property (nonatomic, strong) SSThemedTextField *personIDNum;
@property (nonatomic, strong) TTRealnameAuthSubmitTipView *submitTipView;

@property (nonatomic, strong) SSThemedImageView *cardImageView;

@property (nonatomic, strong) SSThemedImageView *authStatusImageView;
@property (nonatomic, strong) SSThemedLabel *authStatusDetailLabel;
@property (nonatomic, strong) SSThemedLabel *authStatusLabel;

@end

@implementation TTRealnameAuthContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground4;
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGFloat navBarHeight = self.navigationController.navigationBar.height;
        _navHeight = statusBarHeight + navBarHeight;
    }
    return self;
}

- (void)setupContainerViewWithModel:(TTRealnameAuthModel *)model
{
    switch (model.state) {
        case TTRealnameAuthStateNotAuth:
            [self setupAuthInfoSubviewsIsFace:NO];
            break;
        case TTRealnameAuthStateCardForegroundInfo:
            [self setupInfoSubviewsWithModel:model];
            break;
        case TTRealnameAuthStateCardBackgroundInfo:
            [self setupInfoSubviewsWithModel:model];
            break;
        case TTRealnameAuthStateCardSubmit:
            [self setupCardSubmitSubviewsWithModel:model];
            break;
        case TTRealnameAuthStatePersonAuth:
            [self setupAuthInfoSubviewsIsFace:YES];
            break;
        case TTRealnameAuthStatePersonSubmit:
            [self setupInfoSubviewsWithModel:model];
            break;
        case TTRealnameAuthStateAuthSucess:
            [self setupAuthStatusViewWithModel:model];
            break;
        case TTRealnameAuthStateAuthError:
            [self setupAuthStatusViewWithModel:model];
            break;
        case TTRealnameAuthStateAuthed:
            [self setupAuthStatusViewWithModel:model];
            break;
        default:
            break;
    }
}

- (void)updateContainerViewWithModel:(TTRealnameAuthModel *)model
{
    switch (model.state) {
        case TTRealnameAuthStateCardForegroundInfo:
            [self updateCardInfoViewWithImage:model.foregroundImage];
            break;
        case TTRealnameAuthStateCardBackgroundInfo:
            [self updateCardInfoViewWithImage:model.backgroundImage];
            break;
        case TTRealnameAuthStatePersonSubmit:
            [self updateCardInfoViewWithImage:model.personImage];
            break;
        default:
            break;
    }
}

- (void)setupAuthInfoSubviewsIsFace:(BOOL)isFace
{
    self.progressView = [TTRealnameAuthProgressView new];
    self.startLabel = [SSThemedLabel new];
    UIImage *infoImage = nil;
    if (isFace) {
        infoImage = [UIImage themedImageNamed:@"facescan_certification"];
    } else {
        infoImage = [UIImage themedImageNamed:@"IDcard_certification"];
    }
    self.startImageView = [[SSThemedImageView alloc] initWithImage:infoImage];
    self.startButton = [TTRealnameAuthStartButton new];
    
    [self addSubview:self.progressView];
    [self addSubview:self.startLabel];
    [self addSubview:self.startImageView];
    [self addSubview:self.startButton];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(self.navHeight + 20);
        make.left.equalTo(self.mas_left).with.offset(10);
        make.right.equalTo(self.mas_right).with.offset(-10);
        make.height.mas_equalTo(60);
    }];
    [self.startLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.startImageView.mas_top).with.offset([TTDeviceUIUtils tt_newPadding:-20]);
        make.left.equalTo(self.mas_left).with.offset(20);
        make.right.equalTo(self.mas_right).with.offset(-20);
    }];
    [self.startImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([TTDeviceHelper is480Screen]) { // iPhone 4S高度不够，需要偏移
            make.centerY.equalTo(self.mas_centerY).with.offset(20);
        } else {
            make.centerY.equalTo(self);
        }
        make.left.equalTo(self.mas_left).with.offset(40);
        make.right.equalTo(self.mas_right).with.offset(-40);
        make.height.equalTo(self.startImageView.mas_width).with.multipliedBy(infoImage.size.height / infoImage.size.width);
    }];
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.left.equalTo(self.mas_left).with.offset(40);
        make.right.equalTo(self.mas_right).with.offset(-40);
        if ([TTDeviceHelper is480Screen]) {
            make.bottom.equalTo(self.mas_bottom).with.offset(-40);
        } else {
            make.bottom.equalTo(self.mas_bottom).with.offset([TTDeviceUIUtils tt_newPadding:-78]);
        }
    }];
    
    if (isFace) {
        [self.progressView setupViewWithStep:TTRealnameAuthProgressFace];
    } else {
        [self.progressView setupViewWithStep:TTRealnameAuthProgressID];
    }
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    
    self.startImageView.alpha = isDayModel ? 1 : 0.5;
    self.startLabel.textColorThemeKey = kColorText1;
    self.startLabel.textAlignment = NSTextAlignmentCenter;
    self.startLabel.font = [UIFont systemFontOfSize:17];
    
    if (isFace) {
        self.startLabel.text = @"请确保被拍摄对象是持证人";
        self.startButton.title = @"开始识别";
        self.startButton.tag = TTRealnameAuthStatePersonCamera;
    } else {
        self.startLabel.text = @"请拍摄身份证正面和反面";
        self.startButton.title = @"拍摄正面";
        self.startButton.tag = TTRealnameAuthStateCardForegroundCamera;
    }
    [self.startLabel sizeToFit];
    [self.startButton addTarget:self action:@selector(startButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupInfoSubviewsWithModel:(TTRealnameAuthModel *)model
{
    UIImage *infoImage = nil;
    switch (model.state) {
        case TTRealnameAuthStateCardForegroundInfo:
            infoImage = model.foregroundImage;
            break;
        case TTRealnameAuthStateCardBackgroundInfo:
            infoImage = model.backgroundImage;
            break;
        case TTRealnameAuthStatePersonSubmit:
            infoImage = model.personImage;
            break;
        default:
            break;
    }
    
    self.cardImageView = [[SSThemedImageView alloc] initWithImage:infoImage];
    self.startButton = [TTRealnameAuthStartButton new];
    self.retakeButton = [SSThemedButton new];
    
    [self addSubview:self.cardImageView];
    [self addSubview:self.startButton];
    [self addSubview:self.retakeButton];
    
    if (model.state == TTRealnameAuthStatePersonSubmit) {
        [self.cardImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).with.offset(self.navHeight + 47.5);
            make.bottom.equalTo(self.startButton.mas_top).with.offset([TTDeviceUIUtils tt_newPadding:-70]);
            make.width.equalTo(self.cardImageView.mas_height).with.multipliedBy(kPersonPhotoRatio);
            make.centerX.equalTo(self);
        }];
    } else {
        self.startLabel = [SSThemedLabel new];
        [self addSubview:self.startLabel];
        [self.startLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.left.equalTo(self.mas_left).with.offset(20);
            make.right.equalTo(self.mas_right).with.offset(-20);
            if ([TTDeviceHelper is480Screen]) {
                make.bottom.equalTo(self.cardImageView.mas_top).with.offset([TTDeviceUIUtils tt_newPadding:-20]);
            } else {
                make.bottom.equalTo(self.cardImageView.mas_top).with.offset([TTDeviceUIUtils tt_newPadding:-30]);
            }
        }];
        [self.cardImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).with.offset(40);
            make.right.equalTo(self.mas_right).with.offset(-40);
            if ([TTDeviceHelper is480Screen]) {
                make.bottom.equalTo(self.startButton.mas_top).with.offset(-71);
            } else {
                make.bottom.equalTo(self.startButton.mas_top).with.offset([TTDeviceUIUtils tt_newPadding:-120]);
            }
            make.height.equalTo(self.cardImageView.mas_width).with.multipliedBy(kIDCardPhotoRatio);
        }];
    }
    [self.retakeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cardImageView.mas_bottom).with.offset([TTDeviceUIUtils tt_newPadding:20]);
        make.centerX.equalTo(self);
    }];
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.left.equalTo(self.mas_left).with.offset(40);
        make.right.equalTo(self.mas_right).with.offset(-40);
        if ([TTDeviceHelper is480Screen]) {
            make.bottom.equalTo(self.mas_bottom).with.offset(-40);
        } else {
            make.bottom.equalTo(self.mas_bottom).with.offset([TTDeviceUIUtils tt_newPadding:-78]);
        }
    }];
    
    switch (model.state) {
        case TTRealnameAuthStateCardForegroundInfo: {
            self.startLabel.text = @"身份证正面";
            self.startButton.title = @"拍摄反面";
            self.startButton.tag = TTRealnameAuthStateCardBackgroundCamera;
            self.retakeButton.tag = TTRealnameAuthStateCardForegroundCamera;
        }
            break;
        case TTRealnameAuthStateCardBackgroundInfo: {
            self.startLabel.text = @"身份证反面";
            self.startButton.title = @"下一步";
            self.startButton.tag = TTRealnameAuthStateCardSubmit;
            self.retakeButton.tag = TTRealnameAuthStateCardBackgroundCamera;
        }
            break;
        case TTRealnameAuthStatePersonSubmit: {
            self.startButton.title = @"确认并提交";
            self.startButton.tag = TTRealnameAuthStatePersonSubmitting;
            self.retakeButton.tag = TTRealnameAuthStatePersonAuth;
        }
            break;
        default:
            break;
    }
    
    if (self.startLabel) {
        self.startLabel.textColorThemeKey = kColorText1;
        self.startLabel.font = [UIFont systemFontOfSize:19];
        self.startLabel.textAlignment = NSTextAlignmentCenter;
        [self.startLabel sizeToFit];
    }
    
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    
    self.cardImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.cardImageView.clipsToBounds = YES;
    self.cardImageView.alpha = isDayModel ? 1 : 0.5;
    [self.startButton addTarget:self action:@selector(startButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.retakeButton setTitle:@"重 拍" forState:UIControlStateNormal];
    self.retakeButton.titleColorThemeKey = kColorText5;
    self.retakeButton.highlightedTitleColorThemeKey = kColorText5Highlighted;
    self.retakeButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.retakeButton addTarget:self action:@selector(retakeButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupCardSubmitSubviewsWithModel:(TTRealnameAuthModel *)model
{
    self.leftLabel = [SSThemedLabel new];
    self.rightLabel = [SSThemedLabel new];
    self.leftImageView = [[SSThemedImageView alloc] initWithImage:model.foregroundImage];
    self.rightImageView = [[SSThemedImageView alloc] initWithImage:model.backgroundImage];
    self.startButton = [TTRealnameAuthStartButton new];
    self.submitView = [TTRealnameAuthSubmitView new];
    
    [self addSubview:self.leftLabel];
    [self addSubview:self.rightLabel];
    [self addSubview:self.leftImageView];
    [self addSubview:self.rightImageView];
    [self addSubview:self.startButton];
    [self addSubview:self.submitView];
    
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([TTDeviceHelper is480Screen]) {
            make.top.equalTo(self.mas_top).with.offset(self.navHeight + 30);
        } else {
            make.top.equalTo(self.mas_top).with.offset(self.navHeight + 57.5);
        }
        make.left.equalTo(self.mas_left).with.offset(40);
        make.right.equalTo(self.mas_centerX).with.offset(-15);
        make.height.equalTo(self.leftImageView.mas_width).with.multipliedBy(kIDCardPhotoRatio);
    }];
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([TTDeviceHelper is480Screen]) {
            make.top.equalTo(self.mas_top).with.offset(self.navHeight + 30);
        } else {
            make.top.equalTo(self.mas_top).with.offset(self.navHeight + 57.5);
        }
        make.right.equalTo(self.mas_right).with.offset(-40);
        make.left.equalTo(self.mas_centerX).with.offset(15);
        make.height.equalTo(self.rightImageView.mas_width).with.multipliedBy(kIDCardPhotoRatio);
    }];
    UIImageView *leftWaterMarkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"authentication_watermark"]];
    [self.leftImageView addSubview:leftWaterMarkView];
    [leftWaterMarkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.leftImageView.mas_height).with.multipliedBy(0.5);
        make.width.equalTo(self.leftImageView.mas_width).with.multipliedBy(0.5);
        make.center.equalTo(self.leftImageView);
    }];
    leftWaterMarkView.contentMode = UIViewContentModeScaleAspectFill;
    leftWaterMarkView.clipsToBounds = YES;
    UIImageView *rightWaterMarkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"authentication_watermark"]];
    [self.rightImageView addSubview:rightWaterMarkView];
    [rightWaterMarkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.rightImageView.mas_height).with.multipliedBy(0.5);
        make.width.equalTo(self.rightImageView.mas_width).with.multipliedBy(0.5);
        make.center.equalTo(self.rightImageView);
    }];
    rightWaterMarkView.contentMode = UIViewContentModeScaleAspectFill;
    rightWaterMarkView.clipsToBounds = YES;
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.leftImageView.mas_bottom).with.offset(7);
        make.width.equalTo(self.leftImageView);
        make.centerX.equalTo(self.leftImageView);
    }];
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rightImageView.mas_bottom).with.offset(7);
        make.width.equalTo(self.rightImageView);
        make.centerX.equalTo(self.rightImageView);
    }];
    if ([TTDeviceHelper is480Screen]) { // iPhone 4S特殊适配
        [self.submitView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY).with.offset(self.navHeight / 2 + 20);
            make.left.equalTo(self.mas_left).with.offset(15);
            make.right.equalTo(self.mas_right).with.offset(-15);
            make.height.mas_equalTo(133);
        }];
    } else {
        [self.submitView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).with.offset(self.navHeight / 2);
            make.left.equalTo(self.mas_left).with.offset(15);
            make.right.equalTo(self.mas_right).with.offset(-15);
            make.height.mas_equalTo(133);
        }];
    }
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.left.equalTo(self.mas_left).with.offset(40);
        make.right.equalTo(self.mas_right).with.offset(-40);
        if ([TTDeviceHelper is480Screen]) {
            make.bottom.equalTo(self.mas_bottom).with.offset(-40);
        } else {
            make.bottom.equalTo(self.mas_bottom).with.offset([TTDeviceUIUtils tt_newPadding:-78]);
        }
    }];
    
    self.submitView.name = model.name;
    self.submitView.IDNum = model.IDNum;
    self.submitView.delegate = self.delegate;
    
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    
    self.leftImageView.alpha = isDayModel ? 1 : 0.5;
    self.rightImageView.alpha = isDayModel ? 1: 0.5;
    
    self.startLabel.text = @"确认信息";
    self.startLabel.textColorThemeKey = kColorText1;
    self.startLabel.font = [UIFont systemFontOfSize:19];
    self.startLabel.textAlignment = NSTextAlignmentCenter;
    [self.startLabel sizeToFit];
    
    self.leftLabel.text = @"正面";
    self.leftLabel.textColorThemeKey = kColorText1;
    self.leftLabel.font = [UIFont systemFontOfSize:12];
    self.leftLabel.textAlignment = NSTextAlignmentCenter;
    [self.leftLabel sizeToFit];
    
    self.rightLabel.text = @"反面";
    self.rightLabel.textColorThemeKey = kColorText1;
    self.rightLabel.font = [UIFont systemFontOfSize:12];
    self.rightLabel.textAlignment = NSTextAlignmentCenter;
    [self.rightLabel sizeToFit];
    
    self.startButton.title = @"下一步";
    self.startButton.tag = TTRealnameAuthStateCardSubmitting;
    [self.startButton addTarget:self action:@selector(startButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupAuthStatusViewWithModel:(TTRealnameAuthModel *)model
{
    self.authStatusLabel = [SSThemedLabel new];
    
    switch (model.state) {
        case TTRealnameAuthStateAuthed:
        case TTRealnameAuthStateAuthSucess: {
            self.authStatusDetailLabel = [SSThemedLabel new];
            self.progressView = [TTRealnameAuthProgressView new];
            [self addSubview:self.authStatusDetailLabel];
            [self addSubview:self.progressView];
            [self.progressView setupViewWithStep:TTRealnameAuthProgressEnd];
            
            self.authStatusImageView = [[SSThemedImageView alloc] initWithImage:[UIImage themedImageNamed:@"end_certification"]];
            self.authStatusLabel.text = @"恭喜，您的认证已提交成功";
        }
            break;
        case TTRealnameAuthStateAuthError: {
            self.authStatusImageView = [[SSThemedImageView alloc] initWithImage:[UIImage themedImageNamed:@"unfinished_certification"]];
            self.authStatusLabel.text = @"抱歉，您还未开通头条号，请登录mp.toutiao.com进行申请/反馈";
        }
            break;
        default:
            break;
    }
    
    [self addSubview:self.authStatusLabel];
    [self addSubview:self.authStatusImageView];
    
    [self.authStatusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.mas_centerY).with.multipliedBy(0.8);
        make.size.mas_equalTo(50);
    }];
    [self.authStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.authStatusImageView.mas_bottom).with.offset(15);
        make.left.equalTo(self.mas_left).with.offset(40);
        make.right.equalTo(self.mas_right).with.offset(-40);
    }];
    
    if (model.state == TTRealnameAuthStateAuthSucess || model.state == TTRealnameAuthStateAuthed) {
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).with.offset(self.navHeight + 20);
            make.left.equalTo(self.mas_left).with.offset(10);
            make.right.equalTo(self.mas_right).with.offset(-10);
            make.height.mas_equalTo(80);
        }];
        [self.authStatusDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.authStatusLabel.mas_bottom).with.offset(15);
            make.left.equalTo(self.mas_left).with.offset(40);
            make.right.equalTo(self.mas_right).with.offset(-40);
        }];
        
        self.authStatusDetailLabel.text = @"完成所有头条号申请环节后，审核结果会在24小时内通过系统通知";
        self.authStatusDetailLabel.textColorThemeKey = kColorText3;
        self.authStatusDetailLabel.font = [UIFont systemFontOfSize:12];
        self.authStatusDetailLabel.textAlignment = NSTextAlignmentCenter;
        self.authStatusDetailLabel.numberOfLines = 0;
        self.authStatusDetailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.authStatusDetailLabel sizeToFit];
    }
    
    self.authStatusLabel.textColorThemeKey = kColorText1;
    self.authStatusLabel.font = [UIFont systemFontOfSize:14];
    self.authStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.authStatusLabel.numberOfLines = 0;
    self.authStatusLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.authStatusLabel sizeToFit];
}

- (void)updateCardInfoViewWithImage:(UIImage *)image
{
    self.cardImageView.image = image;
    [self.cardImageView setNeedsDisplay];
}

//- (UIImage *)waterMarkedImageWithImage:(UIImage *)image
//{
//    if (!image) {
//        return nil;
//    }
//    UIImage *watermarkImage = [UIImage imageNamed:@"authentication_watermark"];
//    // 水印为原图的50%
//    
//    UIGraphicsBeginImageContext(image.size);
//    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
//    [watermarkImage drawInRect:CGRectMake(image.size.width / 4, image.size.height / 4, image.size.width / 2, watermarkImage.size.height / 2)];
//    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return result;
//}

- (void)themeChanged:(NSNotification *)notification
{
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    if (self.startImageView) {
        self.startImageView.alpha = isDayModel ? 1 : 0.5;
    }
    if (self.cardImageView) {
        self.cardImageView.alpha = isDayModel ? 1 : 0.5;
    }
    if (self.leftImageView) {
        self.leftImageView.alpha = isDayModel ? 1 : 0.5;
    }
    if (self.rightImageView) {
        self.rightImageView.alpha = isDayModel ? 1 : 0.5;
    }
}

- (void)startButtonTouched:(UIButton *)sender
{
    [self.delegate startButtonTouched:sender];
}

- (void)retakeButtonTouched:(UIButton *)sender
{
    [self.delegate retakeButtonTouched:sender];
}

@end
