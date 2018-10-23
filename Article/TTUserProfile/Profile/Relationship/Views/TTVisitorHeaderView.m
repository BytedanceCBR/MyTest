//
//  TTVisitorHeaderView.m
//  Article
//
//  Created by liuzuopeng on 8/9/16.
//
//

#import "TTVisitorHeaderView.h"
#import "TTProfileThemeConstants.h"


@interface TTVisitorHeaderView ()
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *contentLabel;
@end

@implementation TTVisitorHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.contentView.backgroundColorThemeKey = kColorBackground3;
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.contentLabel];
    }
    return self;
}

- (instancetype)init {
    if ((self = [self initWithFrame:CGRectZero])) {
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _titleLabel.left = [TTDeviceUIUtils tt_padding:kTTProfileInsetLeft];
    _titleLabel.centerY = self.contentView.height / 2;
    
    _contentLabel.left = _titleLabel.right + [TTDeviceUIUtils tt_padding:20.f/2];
    _contentLabel.centerY = self.contentView.height / 2;
}

- (void)reloadWithAllViews:(NSUInteger)allViews latestViews:(NSUInteger)latestViews {
    _titleLabel.text = [NSString stringWithFormat:@"累计访问量：%ld", (unsigned long)allViews];
    _contentLabel.text = [NSString stringWithFormat:@"最近7天访问量：%ld", (unsigned long)latestViews];
    
    [_titleLabel sizeToFit];
    [_contentLabel sizeToFit];
    
    [self layoutIfNeeded];
}

#pragma mark - loazied of properties

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.textColorThemeKey = kColorText2;
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:24.f/2]];
        _titleLabel.text = @"总浏览：0";
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (SSThemedLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[SSThemedLabel alloc] init];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLabel.textColorThemeKey = kColorText2;
        _contentLabel.text = @"最近7天浏览量：0";
        _contentLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:24.f/2]];
        [_contentLabel sizeToFit];
    }
    return _contentLabel;
}

+ (CGFloat)height {
    return [TTDeviceUIUtils tt_padding:80.f/2];
}
@end
