//
//  TTPlayerResolutionControlView.m
//  Article
//
//  Created by liuty on 2017/1/10.
//
//

#import "TTPlayerResolutionControlView.h"
#import "TTVideoResolutionService.h"
#import "TTVPlayerUtility.h"

@implementation TTPlayerResolutionView

- (void)setSupportedTypes:(NSArray <NSNumber *> *)supportedTypes
              currentType:(TTVideoEngineResolutionType)type {}

- (NSString *)titleForResolution:(TTVideoEngineResolutionType)resolution {
    return nil;
}

- (void)showInView:(UIView *)view atTargetPoint:(CGPoint)point {}
- (void)dismiss {}

@end

@interface TTPlayerResolutionControlView ()

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) UIButton *fullHDButton;
@property (nonatomic, strong) UIButton *hdButton;
@property (nonatomic, strong) UIButton *sdButton;

@property (nonatomic, strong) UIButton *currentButton;

@property (nonatomic, readwrite) TTVideoEngineResolutionType currentResolutionType;

@end

@implementation TTPlayerResolutionControlView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self ) {
        self.alpha = 0;
        self.isShowing = NO;
        self.currentResolutionType = TTVideoEngineResolutionTypeUnknown;
        [self _buildViewHierarchy];
    }
    return self;
}

#pragma mark -
#pragma mark actions

- (void)buttonClicked:(UIButton *)button {
    TTVideoEngineResolutionType type = TTVideoEngineResolutionTypeSD;
    if (button == self.fullHDButton) {
        type = TTVideoEngineResolutionTypeFullHD;
    } else if (button == self.hdButton) {
        type = TTVideoEngineResolutionTypeHD;
    } else {
        type = TTVideoEngineResolutionTypeSD;
    }
    self.currentResolutionType = type;
    if (type != TTVideoEngineResolutionTypeUnknown && self.didResolutionChanged) {
        self.didResolutionChanged(type);
    }
    if (self.currentResolutionType != TTVideoEngineResolutionTypeUnknown) {
        [TTVideoResolutionService setDefaultResolutionType:self.currentResolutionType];
        [TTVideoResolutionService setAutoModeEnable:NO];
    }
}

#pragma mark -
#pragma mark public methods

- (void)setSupportedTypes:(NSArray <NSNumber *> *)supportedTypes currentType:(TTVideoEngineResolutionType)type {
    [self _setSupportedTypes:supportedTypes];
    self.currentResolutionType = type;
}

- (NSString *)titleForResolution:(TTVideoEngineResolutionType)resolution {
    if (resolution < self.titles.count) {
        return self.titles[resolution];
    }
    return [self.titles lastObject];
}

- (void)showInView:(UIView *)view atTargetPoint:(CGPoint)point {
    if (self.isShowing) return;
    self.isShowing = YES;
    
    [view addSubview:self];
    // cal center
    self.center = CGPointMake(point.x, self.center.y);
    // cal bottom
    CGRect frame = self.frame;
    frame.origin.y = point.y - frame.size.height;
    self.frame = frame;

    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)dismiss {
    if (!self.isShowing) return;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.isShowing = NO;
        [self removeFromSuperview];
    }];
}

#pragma mark -
#pragma mark private methods

- (void)_setSupportedTypes:(NSArray <NSNumber *> *)supportedTypes {
    NSUInteger count = supportedTypes.count;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 15 + count * 30);
    
    [self _hideAllButtons];
    [supportedTypes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger type = [obj unsignedIntegerValue];
        UIButton *button = [self buttonForType:type];
        button.frame = CGRectMake(0, 6 + (count - idx - 1) * 30, self.frame.size.width, 30);
        button.hidden = NO;
    }];
}

- (void)_hideAllButtons {
    TTVideoEngineResolutionType type = TTVideoEngineResolutionTypeSD;
    while (type++ < TTVideoEngineResolutionTypeUnknown) {
        UIButton *button = [self buttonForType:type];
        button.hidden = YES;
    }
}

- (void)_updateButtonTitleWithType:(TTVideoEngineResolutionType)type {
    UIButton *button = [self buttonForType:type];
    button.hidden = NO;
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    if (self.currentButton != button) {
        [self.currentButton setTitleColor:[UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
        self.currentButton = button;
    }
}

- (void)setCurrentResolutionType:(TTVideoEngineResolutionType)currentResolutionType {
    if (_currentResolutionType != currentResolutionType) {
        _currentResolutionType = currentResolutionType;
        if (currentResolutionType != TTVideoEngineResolutionTypeUnknown) {
            [self _updateButtonTitleWithType:currentResolutionType];
        }
    } else {
        [self dismiss];
    }
}

#pragma mark -
#pragma mark UI

- (void)_buildViewHierarchy {
    [self addSubview:self.bgImageView];
    [self addSubview:self.fullHDButton];
    [self addSubview:self.hdButton];
    [self addSubview:self.sdButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bgImageView.frame = self.bounds;
}

#pragma mark -
#pragma mark getters

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"标清", @"高清", @"超清"];
    }
    return _titles;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        UIImage *image = [UIImage imageNamed:@"clarity_popup_bg"];
        UIEdgeInsets insets = UIEdgeInsetsMake(image.size.height / 2,
                                               image.size.width / 2,
                                               image.size.height / 2,
                                               image.size.width / 2);
        image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        _bgImageView = [[UIImageView alloc] initWithImage:image];
    }
    return _bgImageView;
}

- (UIButton *)fullHDButton {
    if (!_fullHDButton) {
        _fullHDButton = [self themedButtonWithType:TTVideoEngineResolutionTypeFullHD];
    }
    return _fullHDButton;
}

- (UIButton *)hdButton {
    if (!_hdButton) {
        _hdButton = [self themedButtonWithType:TTVideoEngineResolutionTypeHD];
    }
    return _hdButton;
}

- (UIButton *)sdButton {
    if (!_sdButton) {
        _sdButton = [self themedButtonWithType:TTVideoEngineResolutionTypeSD];
    }
    return _sdButton;
}

- (UIButton *)themedButtonWithType:(TTVideoEngineResolutionType)type {
    if (type > 0 && type >= self.titles.count) {
        return nil;
    }
    UIButton *button = [[UIButton alloc] init];
    [button setTitleColor:[UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:[TTVPlayerUtility tt_fontSize:13.0f]]];
    
    [button setTitle:self.titles[type] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // cal size
    CGRect frame = button.frame;
    frame.size = CGSizeMake(self.frame.size.width, 30);
    button.frame = frame;
    
    button.hidden = YES;
    
    return button;
}

- (UIButton *)buttonForType:(TTVideoEngineResolutionType)type {
    UIButton *button;
    switch (type) {
        case TTVideoEngineResolutionTypeSD:
            button = self.sdButton;
            break;
        case TTVideoEngineResolutionTypeHD:
            button = self.hdButton;
            break;
        case TTVideoEngineResolutionTypeFullHD:
            button = self.fullHDButton;
            break;
        default:
            button = self.sdButton;
            break;
    }
    return button;
}

@end
