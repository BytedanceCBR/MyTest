//
//  TTVideoFloatFollowButton.m
//  Article
//
//  Created by panxiang on 16/7/11.
//
//

#import "TTVideoFloatFollowButton.h"
#import "TTStatusButton.h"
#import "TTVideoFloatProtocol.h"

@interface TTVideoFloatFollowButton ()
{
    TTStatusButton *_button;
    SSThemedLabel *_titleLabel;
}
@end

@implementation TTVideoFloatFollowButton

- (void)dealloc
{
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:kFloatVideoCellBackgroundColor];
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1;
        
        _titleLabel  = [[SSThemedLabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
        _button = [TTStatusButton buttonWithType:UIButtonTypeCustom];
        _button.delegate = self;
        _button.enabled = YES;
        _button.backgroundColor = [UIColor clearColor];
        [self addSubview:_button];
        
        self.isSubscribed = NO;
    }
    return self;
}

- (void)statusButtonHighlighted:(BOOL)highlighted
{
    _titleLabel.highlighted = highlighted;
}

- (void)layoutSubviews
{
    _titleLabel.frame = CGRectMake(self.layer.cornerRadius, self.layer.cornerRadius, CGRectGetWidth(self.frame) - 2 *self.layer.cornerRadius, CGRectGetHeight(self.frame)- 2 * self.layer.cornerRadius);
    _button.frame = self.bounds;
    [super layoutSubviews];
}

- (void)setIsSubscribed:(BOOL)isSubscribed
{
    _isSubscribed = isSubscribed;
    if (isSubscribed) {
        self.layer.borderColor = [UIColor colorWithHexString:@"505050"].CGColor;
        _titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText2];
    }
    else
    {
        self.layer.borderColor = [UIColor colorWithHexString:@"707070"].CGColor;
        _titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
    }
    _titleLabel.text = isSubscribed ? @"已关注" : @"关注";
    [self setNeedsLayout];
}

- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [_button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

@end