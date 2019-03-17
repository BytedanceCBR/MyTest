//
//  TTMovieBrightnessView.m
//  Article
//
//  Created by songxiangwu on 2016/9/22.
//
//

#import "TTMovieBrightnessView.h"

static const CGFloat kBrightViewH = 7;
static const CGFloat kBrightViewPadding = 13;
static const CGFloat kBrightViewGridW = 7;
static const CGFloat kBrightViewGridH = 5;
static const int kBrightViewGridNum = 16;

@interface TTMovieBrightnessView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UIView *brightView;
@property (nonatomic, strong) NSMutableArray *gridArray;
@property (nonatomic, strong) UIToolbar *backView;

@end

@implementation TTMovieBrightnessView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
        _backView = [[UIToolbar alloc] initWithFrame:self.bounds];
        UIColor *color = [UIColor colorWithHexString:@"898989"];
        _backView.backgroundColor = [color colorWithAlphaComponent:7];
        [self addSubview:_backView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = NSLocalizedString(@"亮度", nil);
        _titleLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_titleLabel sizeToFit];
        [self addSubview:_titleLabel];
        
        UIImage *img = [UIImage themedImageNamed:@"ios_light"];
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        _logoImageView.image = img;
        [self addSubview:_logoImageView];
        
        _brightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 2 * kBrightViewPadding, kBrightViewH)];
        _brightView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [self addSubview:_brightView];
        
        [self p_configureBrightViewGrid];
        
        [[UIScreen mainScreen] addObserver:self forKeyPath:@"brightness" options:NSKeyValueObservingOptionNew context:NULL];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)p_configureBrightViewGrid {
    _gridArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < kBrightViewGridNum; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kBrightViewGridW, kBrightViewGridH)];
        view.backgroundColor = [UIColor whiteColor];
        [_brightView addSubview:view];
        [_gridArray addObject:view];
    }
    [self p_updateBrightness:[UIScreen mainScreen].brightness];
}

- (void)p_updateBrightness:(CGFloat)value {
    CGFloat average = 1.0 / kBrightViewGridNum;
    NSInteger cur = value / average - 1;
    [_gridArray enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        if (cur == -1) {
            view.hidden = YES;
        } else if (idx <= cur) {
            view.hidden = NO;
        } else {
            view.hidden = YES;
        }
    }];
}

- (CGAffineTransform)currentTransformInIOS7IPad {
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGFloat angle = 0;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            angle = 0;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = -M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI_2;
            break;
        default:
            break;
    }
    transform = CGAffineTransformMakeRotation(angle);
    return transform;
}

- (CGPoint)currentCenterInIOS7IPad {
    CGPoint center = CGPointMake(self.superview.width / 2, self.superview.height / 2 - 5);
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            center = CGPointMake(self.superview.width / 2, self.superview.height / 2 - 5);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            center = CGPointMake(self.superview.width / 2, self.superview.height / 2);
            break;
        case UIInterfaceOrientationLandscapeRight:
            center = CGPointMake(self.superview.width / 2, self.superview.height / 2);
            break;
        default:
            break;
    }
    return center;
}

- (BOOL)isIOS7IPad {
    if ([TTDeviceHelper OSVersionNumber] < 8.f && [TTDeviceHelper isPadDevice]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    CGFloat value = [change[@"new"] floatValue];
    [self p_updateBrightness:value];
}

- (void)orientationDidChange:(NSNotification *)notification {
    if ([self isIOS7IPad]) {
        self.transform = [self currentTransformInIOS7IPad];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.centerX = [UIScreen mainScreen].bounds.size.width / 2;
    self.centerY = [UIScreen mainScreen].bounds.size.height / 2;
    _logoImageView.centerX = self.width / 2;
    _logoImageView.centerY = self.height / 2;
    _titleLabel.centerX = self.width / 2;
    _titleLabel.bottom = _logoImageView.top - 14;
    _brightView.top = _logoImageView.bottom + 19;
    _brightView.centerX = self.width / 2;
    CGFloat space = (_brightView.width - kBrightViewGridW * kBrightViewGridNum) / (kBrightViewGridNum + 1);
    [_gridArray enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        view.left = (idx + 1) * space + idx * kBrightViewGridW;
        view.centerY = _brightView.height / 2;
    }];
}

@end
