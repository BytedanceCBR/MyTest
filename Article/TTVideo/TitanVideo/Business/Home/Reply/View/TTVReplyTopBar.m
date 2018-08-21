//
//  TTVReplyTopBar.m
//  Article
//
//  Created by lijun.thinker on 2017/6/2.
//
//

#import "TTVReplyTopBar.h"

static const CGFloat kLinePadding = 0;

@implementation TTVReplyTopBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColorThemeName = kColorBackground4;
        
        _shadowView = [[UIImageView alloc] init];
        _shadowView.image = [UIImage imageNamed:@"video_comment_shadow"];
        [self addSubview:_shadowView];
        
        UIImage *img = [UIImage themedImageNamed:@"tt_titlebar_close"];
        _closeBtn = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        _closeBtn.imageName = @"tt_titlebar_close";
        _closeBtn.highlightedImageName = @"tt_titlebar_close_press";
        _closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
        [self addSubview:_closeBtn];
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.text = NSLocalizedString(@"回复", nil);
        _titleLabel.font = [UIFont systemFontOfSize:17.f];
        _titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        [_titleLabel sizeToFit];
        [self addSubview:_titleLabel];
        _lineView = [[SSThemedView alloc] initWithFrame:CGRectMake(kLinePadding, self.height - [TTDeviceHelper ssOnePixel], self.width - 2 * kLinePadding, [TTDeviceHelper ssOnePixel])];
        _lineView.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_lineView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _shadowView.frame = CGRectMake(0, -9, self.width, 9);
    _closeBtn.right = self.width - 15;
    _closeBtn.centerY = self.height / 2;
    _titleLabel.left = 15;
    _titleLabel.centerY = self.height / 2;
    _lineView.frame = CGRectMake(kLinePadding, self.height - [TTDeviceHelper ssOnePixel], self.width - 2 * kLinePadding, [TTDeviceHelper ssOnePixel]);
}

@end
