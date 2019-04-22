//
//  ExploreCellRecomUserHeaderView.m
//  Article
//
//  Created by Chen Hong on 14-10-26.
//
//

#import "ExploreCellRecomUserHeaderView.h"
#import "SSThemed.h"

#import "TTImageView.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTDeviceHelper.h"
#import "TTThemeManager.h"
#import "UIImage+TTThemeExtension.h"

@interface ExploreCellRecomUserHeaderView ()
@property(nonatomic,weak)id target;
@property(nonatomic,assign)SEL selector;
@property(nonatomic,assign)ExploreCardCellHeaderStyle headStyle;
@end

@implementation ExploreCellRecomUserHeaderView {
    SSThemedLabel *_titleLabel;
    SSThemedLabel *_prefixLabel;
    SSThemedView *_bottomLine;
    TTImageView *_iconView;
    SSThemedImageView *_prefixBgView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        _iconView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        _iconView.enableNightCover = NO;
        [self addSubview:_iconView];
        
        _bottomLine = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _bottomLine.backgroundColorThemeKey = kCellBottomLineBackgroundColor;
        _bottomLine.layer.borderColor = [UIColor tt_themedColorForKey:kCellBottomLineColor].CGColor;
        _bottomLine.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        [self addSubview:_bottomLine];
        
        _prefixBgView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_prefixBgView];
        
        _prefixLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _prefixLabel.backgroundColor = [UIColor clearColor];
        _prefixLabel.font = [UIFont systemFontOfSize:12.f];
        _prefixLabel.textColorThemeKey = kColorText12;
        _prefixLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_prefixLabel];
        
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:kCellInfoLabelFontSize];
        _titleLabel.textColorThemeKey = kCellInfoLabelTextColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification {
   if (_prefixBgView && !_prefixBgView.hidden) {
        _prefixBgView.image = [[UIImage themedImageNamed:@"redtitle_theme_textpage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    }
    
    if (self.headStyle == ExploreCardCellHeaderStyleAlignMiddle) {
        _prefixLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground7];
    }
}

- (void)setTitle:(NSString *)title prefixStr:(NSString *)prefix headStyle:(ExploreCardCellHeaderStyle)headStyle {
    if (isEmptyString(title) && isEmptyString(prefix)) {
        _prefixLabel.text = nil;
        _titleLabel.text = nil;
    } else {
        _prefixLabel.text = prefix;
        _titleLabel.text = title;
        
    }

    self.headStyle = headStyle;
    
    if (headStyle == ExploreCardCellHeaderStyleAlignTop) {
//        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColorThemeKey = kCellInfoLabelTextColor;
    }
    else if (headStyle == ExploreCardCellHeaderStyleAlignMiddle) {
//        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColorThemeKey = kColorText1;
    }
    //UnDo:这个没有标注，所以没改 
    else if (headStyle == ExploreCardCellHeaderStyleVideoPGC) {
        CGFloat prefixFontSize = 15;
        CGFloat titleFontSize = 12.f;
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            prefixFontSize = 17;
            titleFontSize = 12;
        }
        _prefixLabel.font = [UIFont systemFontOfSize:prefixFontSize];
        _prefixLabel.textColorThemeKey = kColorText1;
        _titleLabel.font = [UIFont systemFontOfSize:titleFontSize];
        _titleLabel.textColorThemeKey = kColorText3;
    } else if (headStyle == ExploreCardCellHeaderStyleNew) {
        CGFloat prefixFontSize = 15;
        CGFloat titleFontSize = 12.f;
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            prefixFontSize = 17;
            titleFontSize = 12;
        }
        _prefixLabel.font = [UIFont systemFontOfSize:prefixFontSize];
        _prefixLabel.textColorThemeKey = kColorText4;
        _titleLabel.font = [UIFont systemFontOfSize:titleFontSize];
        _titleLabel.textColorThemeKey = kColorText1;
    }
}

- (void)refreshUI {
    [_prefixLabel sizeToFit];
    [_titleLabel sizeToFit];
    
    _prefixLabel.frame = CGRectIntegral(_prefixLabel.frame);
    _titleLabel.frame = CGRectIntegral(_titleLabel.frame);
    
    CGFloat maxWidth = self.width - kCellLeftPadding - kCellRightPadding - 20; // 左右边距15 不感兴趣20
    
    if (_prefixLabel.width > 200) {
        _prefixLabel.width = 200;
    }
    
    CGFloat iconW = 0;
    if (!isEmptyString(self.iconUrl)) {
        iconW = 30;
    }
    
    if (_titleLabel.width + _prefixLabel.width + 16 + 4 + iconW > maxWidth) {
        _titleLabel.width = maxWidth - _prefixLabel.width - 16 - 4 - iconW;
    }
    
    CGFloat labelH = 0;
    if (_prefixLabel.text.length > 0) {
        labelH = _prefixLabel.height;
    } else if (_titleLabel.text.length > 0) {
        labelH = _titleLabel.height;
    }

    _iconView.left = kCellLeftPadding;
    _iconView.centerY = self.height/2 + 2;
    
    CGFloat x = kCellLeftPadding;
    if (!isEmptyString(self.iconUrl)) {
        x += _iconView.width + 6;
    }
    
    CGFloat y = roundf((self.height-labelH)/2);
    _prefixLabel.origin = CGPointMake(x, y);
    _titleLabel.origin = CGPointMake(_prefixLabel.right, y);
    //_topLine.frame = CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel]);

    if (labelH > 0) {
        _bottomLine.frame = CGRectMake(15, self.height-[TTDeviceHelper ssOnePixel], self.width-15*2, [TTDeviceHelper ssOnePixel]);
    }
    
    [self updateHeaderIconView];
    
    if (self.headStyle == ExploreCardCellHeaderStyleAlignTop) {
        // 标签顶部对齐
        _bottomLine.hidden = YES;
        if (_prefixLabel.text.length > 0) {
            _prefixBgView.hidden = NO;
            _prefixBgView.image = [[UIImage themedImageNamed:@"redtitle_theme_textpage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            _prefixBgView.frame = CGRectMake(x, 0, _prefixLabel.width + 16, self.height);
            _prefixLabel.backgroundColor = [UIColor clearColor];

            _prefixLabel.center = _prefixBgView.center;
            _titleLabel.left = _prefixBgView.right + 6;
        } else {
            _prefixBgView.hidden = YES;
        }
    }
    else if (self.headStyle == ExploreCardCellHeaderStyleAlignMiddle) {
        // 标签居中对齐
        _prefixBgView.hidden = YES;
        _bottomLine.hidden = NO;
        if (_prefixLabel.text.length > 0) {
            _prefixLabel.frame = CGRectMake(x, 8, _prefixLabel.width + 16, 24);
            _prefixLabel.layer.cornerRadius = 4;
            _prefixLabel.clipsToBounds = YES;
            _prefixLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground7];

            _titleLabel.left = _prefixLabel.right + 6;
            _titleLabel.centerY = _prefixLabel.centerY;
        }
    } else if (self.headStyle == ExploreCardCellHeaderStyleVideoPGC) {
        _prefixBgView.hidden = YES;
        _bottomLine.hidden = NO;
        if (_prefixLabel.text.length > 0) {
            _prefixLabel.left = x;
            _prefixLabel.centerY = self.height / 2;
            
            _titleLabel.left = _prefixLabel.right + 8;
            _titleLabel.centerY = _prefixLabel.centerY;
        }
    } else if (self.headStyle == ExploreCardCellHeaderStyleNew) {
        _prefixBgView.hidden = YES;
        _bottomLine.hidden = NO;
        if (_prefixLabel.text.length > 0) {
            _prefixLabel.left = x;
            _prefixLabel.centerY = self.height / 2;
            
            _titleLabel.left = _prefixLabel.right + 8;
            _titleLabel.centerY = _prefixLabel.centerY;
        }
    }
}

- (void)setTarget:(id)target selector:(SEL)selector {
    _target = target;
    _selector = selector;
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognize {
    if (_target && [_target respondsToSelector:_selector])  {
        NSMethodSignature *signature = [_target methodSignatureForSelector:_selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:_target];
        [invocation setSelector:_selector];
        [invocation invoke];
    }
}

- (void)updateHeaderIconView {
    if (!isEmptyString(self.iconUrl)) {
        _iconView.hidden = NO;
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay || [TTDeviceHelper isPadDevice]) {
            [_iconView setImageWithURLString:self.iconUrl];
        } else {
            [_iconView setImageWithURLString:self.nightIconUrl];
        }
    } else {
        _iconView.hidden = YES;
        [_iconView setImageWithURLString:nil];
    }
    _iconView.backgroundColor = [UIColor clearColor];
}

@end
