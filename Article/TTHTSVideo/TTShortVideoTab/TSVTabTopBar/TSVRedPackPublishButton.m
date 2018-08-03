//
//  TSVRedPackPublishButton.m
//  Article
//
//  Created by xushuangqing on 05/12/2017.
//

#import "TSVRedPackPublishButton.h"
#import "TTTopBarManager.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import <SSThemed.h>

@interface TSVRedPackPublishButton()

@property (nonatomic, assign) BOOL viewIsAppear;

@property (nonatomic, strong) SSThemedImageView *normalPublishImageView;

@property (nonatomic, strong) CALayer *rotationLayer;
@property (nonatomic, strong) CALayer *imageLayer;
@property (nonatomic, strong) CAKeyframeAnimation *imageAnimation;
@property (nonatomic, strong) CAKeyframeAnimation *rotationAnimation;

@end

@implementation TSVRedPackPublishButton

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self addSubview:self.normalPublishImageView];
    [self.normalPublishImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(24.f, 24.f));
        make.center.equalTo(self);
    }];
    
    [self.layer addSublayer:self.rotationLayer];
    [self.rotationLayer addSublayer:self.imageLayer];
    
    /*给转动效果加个透视*/
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0/200.0;
    self.layer.sublayerTransform = perspective;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleThemeChanged)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.rotationLayer.frame = CGRectMake(CGRectGetMidX(self.bounds) - 12.0f, CGRectGetMidY(self.bounds) - 12.0f, 24.0f, 24.0f);;
    self.imageLayer.frame = self.rotationLayer.bounds;
}

- (void)startAnimation {
    if (self.style == TSVRedPackPublishButtonStyleRed) {
        [self.rotationLayer addAnimation:self.rotationAnimation forKey:@"rotation"];
        [self.imageLayer addAnimation:self.imageAnimation forKey:@"image"];
    }
}

- (void)setStyle:(TSVRedPackPublishButtonStyle)style {
    _style = style;
    if (style == TSVRedPackPublishButtonStyleNormal) {
        self.rotationLayer.hidden = YES;
        self.normalPublishImageView.hidden = NO;
    }
    else if (style == TSVRedPackPublishButtonStyleRed) {
        self.rotationLayer.hidden = NO;
        self.normalPublishImageView.hidden = YES;
        if (self.viewIsAppear) {
            [self startAnimation];
        }
    }
}

- (void)handleThemeChanged {
    self.imageAnimation.values = [self animationImagesArray];
}

#pragma mark - accessors

- (SSThemedImageView *)normalPublishImageView {
    if (!_normalPublishImageView) {
        _normalPublishImageView = [[SSThemedImageView alloc] init];
        _normalPublishImageView.imageName = [[self class] publishImageName];
//        _normalPublishImageView.contentMode = UIViewContentModeCenter;
        _normalPublishImageView.userInteractionEnabled = NO;
    }
    return _normalPublishImageView;
}

- (CALayer *)rotationLayer {
    if (!_rotationLayer) {
        _rotationLayer = [CALayer layer];
        _rotationLayer.frame = CGRectMake(CGRectGetMidX(self.bounds) - 12.0f, CGRectGetMidY(self.bounds) - 12.0f, 24.0f, 24.0f);
    }
    return _rotationLayer;
}

- (CALayer *)imageLayer {
    if (!_imageLayer) {
        _imageLayer = [CALayer layer];
        _imageLayer.frame = CGRectMake(0, 0, 24.0f, 24.0f);
        _imageLayer.contents = (id)[[UIImage themedImageNamed:@"titlebar_video_redpack_camera"] CGImage];
    }
    return _imageLayer;
}

- (CAKeyframeAnimation *)imageAnimation {
    if (!_imageAnimation) {
        _imageAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
        _imageAnimation.values = [self animationImagesArray];
        _imageAnimation.duration = 4.0f;
        _imageAnimation.keyTimes = @[@(0.0f/4.0f), @(1.5f/4.0f), @(3.5f/4.0f), @(4.0f/4.0f)];
        _imageAnimation.removedOnCompletion = YES;
        _imageAnimation.calculationMode = kCAAnimationDiscrete;
    }
    return _imageAnimation;
}

- (CAKeyframeAnimation *)rotationAnimation {
    if (!_rotationAnimation) {
        _rotationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.y"];
        _rotationAnimation.duration = 4.0f;
        _rotationAnimation.values = @[@0, @0, @(M_PI_2), @(M_PI), @(M_PI), @(3*M_PI_2), @(2*M_PI)];
        _rotationAnimation.keyTimes = @[@0, @(1.0f/4.0f), @(1.5f/4.0f), @(2.0f/4.0f), @(3.0f/4.0f), @(3.5/4.0f), @(4.0/4.0f)];
        _rotationAnimation.removedOnCompletion = YES;
    }
    return _rotationAnimation;
}

- (NSArray *)animationImagesArray {
    NSMutableArray *muArray = [[NSMutableArray alloc] initWithCapacity:2];
    UIImage *cameraImage = [UIImage themedImageNamed:[[self class] publishRedpackImageName]];
    [muArray addObject:(id)[cameraImage CGImage]];
    UIImage *moneyImage = [UIImage themedImageNamed:@"titlebar_video_redpack"];
    [muArray addObject:(id)[moneyImage CGImage]];
    [muArray addObject:(id)[cameraImage CGImage]];
    [muArray addObject:(id)[cameraImage CGImage]];
    return [muArray copy];
}

//小视频tab发布器普通样式图标
+ (NSString *)publishImageName {
    NSString *publishImageName;
    NSNumber *iconStyle = [[TTSettingsManager sharedManager] settingForKey:@"tt_short_video_publish_icon" defaultValue:@(0) freeze:YES];
    switch (iconStyle.integerValue) {
        case 0:
            publishImageName = @"titlebar_video";
            break;
        case 1:
            publishImageName = @"short_video_publish_icon_camera";
            break;
        default:
            publishImageName = @"titlebar_video";
            break;
    }
    
    return publishImageName;
}

//小视频tab发布器红包样式图标
+ (NSString *)publishRedpackImageName {
    NSString *publishRedpackImageName;
    NSNumber *iconStyle = [[TTSettingsManager sharedManager] settingForKey:@"tt_short_video_publish_icon" defaultValue:@(0) freeze:YES];
    switch (iconStyle.integerValue) {
        case 0:
            publishRedpackImageName = @"titlebar_video_redpack_camera";
            break;
        case 1:
            publishRedpackImageName = @"short_video_publish_icon_camera";
            break;
        default:
            publishRedpackImageName = @"titlebar_video_redpack_camera";
            break;
    }
    
    return publishRedpackImageName;
}

@end
