//
//  TTFollowThemeButtonImp.m
//  Article
//
//  Created by 杨心雨 on 2016/11/28.
//
//

#import "TTFollowThemeButtonImp.h"
#import "TTNetworkManager.h"
#import "TTIndicatorView.h"
#import "TTFollowNotifyServer.h"
#import "TTIconFontChatroomDefine.h"
#import "UIButton+TTAdditions.h"
#import <TTKitchen/TTKitchen.h>

#define kFollowText NSLocalizedString(@"关注", nil)
#define kHasFollowText NSLocalizedString(@"已关注", nil)
#define kMutualFollowText NSLocalizedString(@"互相关注", nil)

inline UIColor *SSGetDayColorInThemeArray(NSArray *themeColors);

static UIColor *TTGetDayColorUsingArrayOrKey(NSArray *themeArray, NSString *key) {
    if ([themeArray isKindOfClass:[NSArray class]] && themeArray.count > 0) {
        return SSGetDayColorInThemeArray(themeArray);
    }
    return [UIColor tt_defaultColorForKey:key];
}

@interface TTFollowThemeButtonImp ()

@property (nonatomic, strong) SSThemedLabel *followLabel;
@property (nonatomic, strong) SSThemedImageView *loadingView;

@property (nonatomic, strong) SSThemedImageView *redPacketImageView;
@end

@implementation TTFollowThemeButtonImp

@synthesize beFollowed = _beFollowed;
@synthesize constHeight = _constHeight;
@synthesize constWidth = _constWidth;
@synthesize loading = _loading;
@synthesize followed = _followed;
@synthesize followedType = _followedType;
@synthesize unfollowedType = _unfollowedType;
@synthesize followedMutualType = _followedMutualType;

- (SSThemedLabel *)followLabel {
    if (_followLabel == nil) {
        _followLabel = [[SSThemedLabel alloc] init];
        _followLabel.textAlignment = NSTextAlignmentCenter;
        _followLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_followLabel];
    }
    return _followLabel;
}

- (SSThemedImageView *)loadingView {
    if (_loadingView == nil) {
        _loadingView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        _loadingView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _loadingView.hidden = YES;
        [self addSubview:_loadingView];
        _loadingView.center = CGPointMake(self.width / 2, self.height / 2);
    }
    return _loadingView;
}

- (SSThemedImageView *)redPacketImageView {
    if (_redPacketImageView == nil) {
        _redPacketImageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, 18, 20)];
        _redPacketImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_redPacketImageView];
        _redPacketImageView.hidden = YES;
        _redPacketImageView.imageName = @"red_packet";
    }
    return _redPacketImageView;
}

- (int)constHeight {
    if (_constHeight <= 0) {
        return kDefaultFollowButtonHeight();
    }
    return _constHeight;
}

- (void)setConstHeight:(int)constHeight {
    if (constHeight != _constHeight) {
        _constHeight = constHeight;
        self.height = constHeight;
    }
}

- (void)setConstWidth:(int)constWidth {
    if (constWidth != _constWidth) {
        _constWidth = constWidth;
        [self refreshUI];
    }
}

- (instancetype)initWithUnfollowedType:(TTUnfollowedType)unfollowedType followedType:(TTFollowedType)followedType {
    return [self initWithUnfollowedType:unfollowedType followedType:followedType followedMutualType:TTFollowedMutualTypeNone];
}

- (instancetype)initWithUnfollowedType:(TTUnfollowedType)unfollowedType followedType:(TTFollowedType)followedType followedMutualType:(TTFollowedMutualType)followedMutualType {
    self = [super initWithFrame:CGRectMake(0, 0, kDefaultFollowButtonWidth(), self.constHeight)];
    if (self) {
        self.layer.cornerRadius = 4;
        _followed = NO;
        _loading = NO;
        _unfollowedType = unfollowedType;
        _followedType = followedType;
        _followedMutualType = followedMutualType;
        [self refreshUI];
    }
    return self;
}

- (void)setFollowed:(BOOL)followed {
    if (_followed != followed) {
        _followed = followed;
        if (!_loading) {
            [self refreshUI];
        }
    }
}

- (void)setBeFollowed:(BOOL)beFollowed {
    if (_beFollowed != beFollowed) {
        _beFollowed = beFollowed;
        if (!_loading) {
            [self refreshUI];
        }
    }
}

- (void)setUnfollowedType:(TTUnfollowedType)unfollowedType {
    if (_unfollowedType != unfollowedType) {
        _unfollowedType = unfollowedType;
        if (!self.hidden && !_loading && !_followed) {
            [self refreshUnfollowedUI];
        }
    }
}

- (void)startLoading {
    if (_loading) {
        return;
    }
    _loading = YES;
    [self refreshUI];
}

- (void)stopLoading:(void (^)())finishLoading {
    _loading = NO;
    [_loadingView.layer removeAllAnimations];
    [self refreshUI];
    if (finishLoading) {
        finishLoading();
    }
}

- (void)refreshUI {
    if (_loading) {
        [self refreshLoadingUI];
    } else {
        if (_followed) { //已关注 先判断是否是 互相关注
            if (_beFollowed && _followedMutualType != TTFollowedMutualTypeNone) {
                [self refreshFollowedMutualUI];
            } else {
                [self refreshFollowedUI];
            }
        } else {
            [self refreshUnfollowedUI];
        }
    }
}

- (void)refreshLoadingUI {
    if (!self.loadingView.hidden) {//由于外部直接调用refreshUI会引起loading变色
        return;
    }
    self.followLabel.hidden = YES;
    self.loadingView.hidden = NO;
    _redPacketImageView.hidden = YES;
    if (_followed) {
        if (_beFollowed && _followedMutualType != TTFollowedMutualTypeNone) {
            _loadingView.imageName = @"toast_keywords_refresh_gray";
        } else {
            switch (_followedType) {
                case TTFollowedType101:
                case TTFollowedType102:
                case TTFollowedType103:
                case TTFollowedType104:
                case TTFollowedType105:
                    _loadingView.imageName = @"toast_keywords_refresh_gray";
                    break;
                default:
                    _loadingView.imageName = nil;
                    break;
            }
        }
    } else {
        switch (_unfollowedType) {
            case TTUnfollowedType102:
            case TTUnfollowedType103:
            case TTUnfollowedType202:
                _loadingView.imageName = @"toast_keywords_refresh_gray";
                break;
            case TTUnfollowedType101:
            case TTUnfollowedType104:
            case TTUnfollowedType201:
                _loadingView.imageName = @"toast_keywords_refresh_white";
                break;
            case TTUnfollowedType203:
                _loadingView.imageName = @"toast_keywords_refresh_white";
                break;
            case TTUnfollowedType204:
                _loadingView.imageName = @"toast_keywords_refresh_gray";
                break;
            default:
                _loadingView.imageName = nil;
                break;
        }
    }
    
    CGFloat duration = 0.4f;
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = duration;
    rotationAnimation.repeatCount = NSUIntegerMax;
    
    [_loadingView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)refreshUnfollowedUI {
    _followLabel.hidden = NO;
    _loadingView.hidden = YES;
    _redPacketImageView.hidden = YES;
    CGFloat width = _constWidth;
    _followLabel.textColors = nil;
    self.borderColors = nil;
    switch (_unfollowedType) {
        case TTUnfollowedType101:
        {
            if (width <= 0) {
                width = kDefaultFollowButtonWidth();
            }
            self.followLabel.font = [UIFont systemFontOfSize:TTFollowButtonFloat(14.0)];
            _followLabel.text = @"关注";
            _followLabel.textColorThemeKey = kColorText12;
            
            self.backgroundColorThemeKey = [SSCommonLogic followButtonDefaultColorStyleRed] ? kColorBackground7 : kColorBackground8;
            self.borderColorThemeKey = nil;
        }
            break;
        case TTUnfollowedType104:
        {
            if (width <= 0) {
                width = kDefaultFollowButtonWidth();
            }
            self.followLabel.font = [UIFont boldSystemFontOfSize:TTFollowButtonFloat(14.0)];
            _followLabel.text = @"关注";
            _followLabel.textColorThemeKey = kColorText12;
            
            self.backgroundColorThemeKey = [SSCommonLogic followButtonDefaultColorStyleRed] ? kColorBackground7 : kColorBackground8;
            self.borderColorThemeKey = nil;
        }
            break;
        case TTUnfollowedType201:
        {
            if (width <= 0) {
                width = kRedPacketFollowButtonWidth();
            }
            self.followLabel.font = [UIFont systemFontOfSize:TTFollowButtonFloat(14.0)];
            _followLabel.text = @"关注";
            if ([SSCommonLogic followButtonDefaultColorStyleRed]) {
                _followLabel.textColors = @[@"FFF3BC", @"98916E"];
                _followLabel.textColorThemeKey = @"";
            } else {
                _followLabel.textColors = nil;
                _followLabel.textColorThemeKey = kColorText12;
            }
            
            self.backgroundColorThemeKey = [SSCommonLogic followButtonDefaultColorStyleRed] ? kColorBackground7 : kColorBackground8;
            self.borderColorThemeKey = nil;
        }
            break;
        case TTUnfollowedType203:
        {
            if (width <= 0) {
                width = kRedPacketFollowButtonWidth();
            }
            self.followLabel.font = [UIFont systemFontOfSize:TTFollowButtonFloat(14.0)];
            _followLabel.text = !isEmptyString([TTKitchen getString:kTTKUGCRedpacketNoIconStyleText]) ? [TTKitchen getString:kTTKUGCRedpacketNoIconStyleText] : @"关注领钱";
            _followLabel.textColorThemeKey = kColorText12;
            
            self.backgroundColorThemeKey = [SSCommonLogic followButtonDefaultColorStyleRed] ? kColorBackground7 : kColorBackground8;
            self.borderColorThemeKey = nil;
        }
            break;
        case TTUnfollowedType102:
        {
            self.followLabel.font = [UIFont boldSystemFontOfSize:TTFollowButtonFloat(14.0)];
            _followLabel.text = @"关注";
            _followLabel.textColorThemeKey = [SSCommonLogic followButtonDefaultColorStyleRed] ? kColorText4 : kColorText6;
            
            self.backgroundColorThemeKey = nil;
            self.borderColorThemeKey = nil;
        }
            break;
        case TTUnfollowedType202: {
            self.followLabel.font = [UIFont boldSystemFontOfSize:TTFollowButtonFloat(14.0)];
            _followLabel.text = @"关注";
            _followLabel.textColorThemeKey = kColorText4;
            
            self.backgroundColorThemeKey = nil;
            self.borderColorThemeKey = nil;
        }
            break;
        case TTUnfollowedType204:
        {
            self.followLabel.font = [UIFont boldSystemFontOfSize:TTFollowButtonFloat(14.0)];
            _followLabel.text = !isEmptyString([TTKitchen getString:kTTKUGCRedpacketNoIconStyleText]) ? [TTKitchen getString:kTTKUGCRedpacketNoIconStyleText] : @"关注领钱";
            _followLabel.textColorThemeKey = [SSCommonLogic followButtonDefaultColorStyleRed] ? kColorText4 : kColorText6;
            
            self.backgroundColorThemeKey = nil;
            self.borderColorThemeKey = nil;
        }
            break;
        case TTUnfollowedType103:
        {
            if (width <= 0) {
                width = kDefaultFollowButtonWidth();
            }
            self.followLabel.font = [UIFont systemFontOfSize:TTFollowButtonFloat(14.0)];
            _followLabel.text = @"关注";
            _followLabel.textColorThemeKey = kColorText12;
            
            self.backgroundColorThemeKey = nil;
            self.borderColorThemeKey = kColorLine12;
        }
            break;
    }
    [self layoutSubviewsWithWidth:width];

    [self tryFitColor];
}

- (void)refreshFollowedUI {
    _followLabel.hidden = NO;
    _loadingView.hidden = YES;
    _redPacketImageView.hidden = YES;
    CGFloat width = _constWidth;
    
    if (width <= 0 && _unfollowedType == TTUnfollowedType201) {
        width = kRedPacketFollowButtonWidth();
    }
    _followLabel.textColors = nil;
    self.borderColors = nil;

    switch (_followedType) {
        case TTFollowedType101:
        {
            if (width <= 0) {
                width = kDefaultFollowButtonWidth();
            }
            self.followLabel.font = [UIFont systemFontOfSize:TTFollowButtonFloat(14.0)];
            _followLabel.text = @"已关注";
            _followLabel.textColorThemeKey = kColorText3;
            
            self.backgroundColorThemeKey = nil;
            self.borderColorThemeKey = kColorLine1;
        }
            break;
        case TTFollowedType102:
        {
            self.followLabel.font = [UIFont systemFontOfSize:TTFollowButtonFloat(14.0)];
            _followLabel.text = @"已关注";
            _followLabel.textColorThemeKey = kColorText3;
            
            self.backgroundColorThemeKey = nil;
            self.borderColorThemeKey = nil;
        }
            break;
        case TTFollowedType103:
        {
            if (width <= 0) {
                width = kDefaultFollowButtonWidth();
            }
            self.followLabel.font = [UIFont systemFontOfSize:TTFollowButtonFloat(14.0)];
            _followLabel.text = @"已关注";
            _followLabel.textColors = @[@"FFFFFF7F", @"CACACA7F"];
            
            self.backgroundColorThemeKey = nil;
            self.borderColors = @[@"FFFFFF7F", @"CACACA7F"];
        }
            break;
        case TTFollowedType104:
        {
            if (width <= 0) {
                width = kDefaultFollowButtonWidth();
            }
            self.followLabel.font = [UIFont systemFontOfSize:TTFollowButtonFloat(14.0)];
            _followLabel.text = @"已关注";
            _followLabel.textColorThemeKey = kColorText3;
            
            self.backgroundColorThemeKey = nil;
            self.borderColorThemeKey = kColorLine1;
        }
            break;
        case TTFollowedType105:
        {
            if (width <= 0) {
                width = kDefaultFollowButtonWidth();
            }
            self.followLabel.font = [UIFont boldSystemFontOfSize:TTFollowButtonFloat(14.0)];
            _followLabel.text = @"已关注";
            _followLabel.textColors = @[@"FFFFFF7F", @"CACACA7F"];
            
            self.backgroundColorThemeKey = nil;
            self.borderColors = @[@"FFFFFF7F", @"CACACA7F"];
        }
            break;
    }
    [self layoutSubviewsWithWidth:width];
    
    [self tryFitColor];
}

- (void)refreshFollowedMutualUI {
    _followLabel.hidden = NO;
    _loadingView.hidden = YES;
    _redPacketImageView.hidden = YES;
    CGFloat width = _constWidth;
    if (width <= 0 && _unfollowedType == TTUnfollowedType201) {
        width = kRedPacketFollowButtonWidth();
    }
    _followLabel.textColors = nil;
    self.borderColors = nil;

    switch (_followedMutualType) {
        case TTFollowedMutualTypeNone:
        {
            //error Type
        }
            break;
        case TTFollowedMutualType101:
        {
            if (width <= 0) {
                width = kDefaultFollowButtonWidth();
            }
            if (width > 58) {
                self.followLabel.font = [UIFont systemFontOfSize:TTFollowButtonFloat(14.0)];
            } else {
                self.followLabel.font = [UIFont systemFontOfSize:TTFollowButtonFloat(12.0)];
            }
            _followLabel.text = @"互相关注";
            _followLabel.textColorThemeKey = kColorText3;
            
            self.backgroundColorThemeKey = nil;
            self.borderColorThemeKey = kColorLine1;
        }
            break;
        case TTFollowedMutualType102:
        {
            self.followLabel.font = [UIFont systemFontOfSize:TTFollowButtonFloat(14.0)];
            _followLabel.text = @"互相关注";
            _followLabel.textColorThemeKey = kColorText3;
            
            self.backgroundColorThemeKey = nil;
            self.borderColorThemeKey = nil;
        }
            break;
        case TTFollowedMutualType103:
        {
            if (width <= 0) {
                width = kDefaultFollowButtonWidth();
            }
            self.followLabel.font = [UIFont systemFontOfSize:TTFollowButtonFloat(14.0)];
            _followLabel.text = @"互相关注";
            _followLabel.textColorThemeKey = kColorText12;
            
            self.backgroundColorThemeKey = nil;
            self.borderColorThemeKey = kColorLine12;
        }
            break;
        case TTFollowedMutualType104:
        {
            if (width <= 0) {
                width = kDefaultFollowButtonWidth();
            }
            self.followLabel.font = [UIFont boldSystemFontOfSize:TTFollowButtonFloat(14.0)];
            _followLabel.text = @"互相关注";
            _followLabel.textColorThemeKey = kColorText12;
            
            self.backgroundColorThemeKey = nil;
            self.borderColorThemeKey = kColorLine12;
        }
            break;
    }
    [self layoutSubviewsWithWidth:width];
    
    [self tryFitColor];
}

- (void)setHighlighted:(BOOL)highlighted {
    UIColor *borderColor = [UIColor colorWithCGColor:self.layer.borderColor];
    [super setHighlighted:highlighted];
    self.layer.borderColor = [borderColor CGColor];
}

- (void)tryFitColor {
    if (self.forbidNightMode) {
        UIColor *textColor = TTGetDayColorUsingArrayOrKey(_followLabel.textColors, _followLabel.textColorThemeKey);
        UIColor *bgColor =  TTGetDayColorUsingArrayOrKey(self.backgroundColors, self.backgroundColorThemeKey);
        UIColor *borderColor = TTGetDayColorUsingArrayOrKey(self.borderColors, self.borderColorThemeKey);
        
        _followLabel.textColors = nil;
        _followLabel.textColorThemeKey = nil;
        self.backgroundColors = nil;
        self.backgroundColorThemeKey = nil;
        self.borderColors = nil;
        self.borderColorThemeKey = nil;
        
        _followLabel.textColor = textColor;
        self.backgroundColor = bgColor;
        self.layer.borderColor = borderColor.CGColor;
    }
}

- (void)layoutSubviewsWithWidth:(int)width {
    if (width <= 0) { //自适应宽度
        [_followLabel sizeToFit];
        _followLabel.frame = CGRectMake(0, 0, ceil(_followLabel.width), self.constHeight);
        _followLabel.centerY = self.height /2;
        self.hitTestEdgeInsets = UIEdgeInsetsZero;
    } else {
        _followLabel.frame = CGRectMake(0, 0, width, self.constHeight);
        self.hitTestEdgeInsets = UIEdgeInsetsZero;
    }
    
    if (self.width != _followLabel.width) {//保持右侧位置不变，适应大多数场景
        CGFloat right = self.right;
        self.width = _followLabel.width;
        self.right = right;
    }
    
    if (self.height != _followLabel.height) {
        self.height = _followLabel.height;
    }
    
    if (!isEmptyString(self.borderColorThemeKey) || self.borderColors.count > 0) {
        self.layer.borderWidth = 1;
    } else {
        self.layer.borderWidth = 0;
    }
}

@end
