//
//  TTPLUnreadNumberView.m
//  Article
//
//  Created by 杨心雨 on 2017/1/9.
//
//

#import "TTPLUnreadNumberView.h"

@interface TTPLUnreadNumberView ()

@property (nonatomic, strong) SSThemedLabel *unreadNumberLabel;

@end

@implementation TTPLUnreadNumberView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.unreadNumber = 0;
        self.backgroundColorThemeKey = kColorBackground7;
        self.layer.cornerRadius = 9;
        self.height = 18;
        self.hidden = YES;
        
        _unreadNumberLabel = [[SSThemedLabel alloc] init];
        _unreadNumberLabel.textColorThemeKey = kColorText7;
        _unreadNumberLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_unreadNumberLabel];
    }
    return self;
}

- (void)setUnreadNumber:(NSUInteger)unreadNumber {
    if (_unreadNumber != unreadNumber) {
        _unreadNumber = unreadNumber;
        if (unreadNumber > 0) {
            self.hidden = NO;
            _unreadNumberLabel.text = [NSString stringWithFormat:@"%@", unreadNumber > 99 ? @"99+" : @(unreadNumber)];
            [self setNeedsLayout];
        } else {
            self.hidden = YES;
        }
    }
}

- (void)layoutSubviews {
    CGFloat right = self.right;
    [_unreadNumberLabel sizeToFit];
    _unreadNumberLabel.size = CGSizeMake(ceil(_unreadNumberLabel.width), ceil(_unreadNumberLabel.height));
    _unreadNumberLabel.left = 5;
    _unreadNumberLabel.centerY = self.height / 2;
    self.width = _unreadNumberLabel.right + 5;
    if (self.width < 18) {
        self.width = 18;
    }
    self.right = right;
}

@end
