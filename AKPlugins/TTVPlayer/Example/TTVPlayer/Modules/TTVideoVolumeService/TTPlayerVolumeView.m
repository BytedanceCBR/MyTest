//
//  TTPlayerVolumeView.m
//  Article
//
//  Created by 赵晶鑫 on 12/09/2017.
//
//

#import "TTPlayerVolumeView.h"
#import <TTThemed/SSThemed.h>
#import "TTVideoVolumeService.h"

static const CGFloat kVolumeViewH = 7;
static const CGFloat kVolumeViewPadding = 13;
static const CGFloat kVolumeViewGridW = 7;
static const CGFloat kVolumeViewGridH = 5;
static const int kVolumeViewGridNum = 16;

@interface TTPlayerVolumeView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UIView *volumeView;
@property (nonatomic, strong) NSMutableArray *gridArray;
@property (nonatomic, strong) UIToolbar *backView;

@property (nonatomic) BOOL isShowing;

@property (nonatomic, copy) NSString *currentLogoImageName;

@end

@implementation TTPlayerVolumeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        self.alpha = 0.0f;
        
        _backView = [[UIToolbar alloc] initWithFrame:self.bounds];
//        UIColor *color = [UIColor colorWithHexString:@"898989"];
//        _backView.backgroundColor = [color colorWithAlphaComponent:7];
        [self addSubview:_backView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = NSLocalizedString(@"音量", nil);
        _titleLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_titleLabel sizeToFit];
        [self addSubview:_titleLabel];
        
        _currentLogoImageName = @"ios_volume";
        UIImage *img = [UIImage imageNamed:_currentLogoImageName];
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        _logoImageView.image = img;
        [self addSubview:_logoImageView];
        
        _volumeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 2 * kVolumeViewPadding, kVolumeViewH)];
        _volumeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _volumeView.hidden = YES;
        [self addSubview:_volumeView];
        
        [self p_configureVolumeViewGrid];
        
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.text = @"静音";
        _hintLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _hintLabel.font = [UIFont systemFontOfSize:14];
        [_hintLabel sizeToFit];
        _hintLabel.hidden = YES;
        [self addSubview:_hintLabel];
        
        _isShowing = NO;
    }
    return self;
}

- (void)showAnimated:(BOOL)animated {
    if (self.isShowing) return;
    self.isShowing = YES;
    
    void(^animationBlock)(void) = ^ {
        self.alpha = 1;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3f
                         animations:animationBlock
                         completion:^(BOOL finished) {
                         }];
    } else {
        animationBlock();
    }
}

- (void)dismissAnimated:(BOOL)animated {
    void(^animationBlock)(void) = ^ {
        self.alpha = 0;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3f
                         animations:animationBlock
                         completion:^(BOOL finished) {
                             self.isShowing = NO;
                         }];
    } else {
        animationBlock();
        self.isShowing = NO;
    }
}

- (void)updateVolumeValue:(float)volume {
    [self p_updateVolume:volume];
}

- (void)p_configureVolumeViewGrid {
    _gridArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < kVolumeViewGridNum; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kVolumeViewGridW, kVolumeViewGridH)];
        view.backgroundColor = [UIColor whiteColor];
        [_volumeView addSubview:view];
        [_gridArray addObject:view];
    }
    [self p_updateVolume:self.service.currentVolume];
}

- (void)p_updateVolume:(CGFloat)value {
    BOOL isMute = fabs(value) < 0.0000001f;
    
    NSString *logoImageName = isMute ? @"ios_mute" : @"ios_volume";
    if (![_currentLogoImageName isEqualToString:logoImageName]) {
        _currentLogoImageName = logoImageName;
        _logoImageView.image = [UIImage imageNamed:_currentLogoImageName];
    }
    
    _hintLabel.hidden = !isMute;
    _volumeView.hidden = isMute;
    
    CGFloat average = 1.0 / kVolumeViewGridNum;
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

- (void)layoutSubviews {
    [super layoutSubviews];
    self.centerX = [UIScreen mainScreen].bounds.size.width / 2;
    self.centerY = [UIScreen mainScreen].bounds.size.height / 2;
    _logoImageView.centerX = self.width / 2;
    _logoImageView.centerY = self.height / 2;
    _titleLabel.centerX = self.width / 2;
    _titleLabel.bottom = _logoImageView.top - 14;
    _volumeView.top = _logoImageView.bottom + 19;
    _volumeView.centerX = self.width / 2;
    _hintLabel.centerX = self.width / 2;
    _hintLabel.centerY = _volumeView.centerY;
    CGFloat space = (_volumeView.width - kVolumeViewGridW * kVolumeViewGridNum) / (kVolumeViewGridNum + 1);
    [_gridArray enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        view.left = (idx + 1) * space + idx * kVolumeViewGridW;
        view.centerY = _volumeView.height / 2;
    }];
}

@end
