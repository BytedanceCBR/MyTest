//
//  TTVideoFloatActionButton.m
//  Article
//
//  Created by panxiang on 16/7/11.
//
//

#import "TTVideoFloatActionButton.h"
#import "TTStatusButton.h"

@interface TTVideoFloatActionButton ()
{
    TTStatusButton *_button;
    UIImageView *_iconImageView;
    SSThemedLabel *_titleLabel;
    UIView *_containView;
    NSString *_normalImageName;
    NSString *_normalImageNameHighlighted;
}
@end

@implementation TTVideoFloatActionButton

- (void)dealloc
{
    
}

- (UIImageView *)iconImageView
{
    return _iconImageView;
}

- (instancetype)initWithImageName:(NSString *)imageName
             highlightedImageName:(NSString *)highlightedImageName
{
    self = [super init];
    if (self) {
        _normalImageName = [imageName copy];
        _normalImageNameHighlighted = [highlightedImageName copy];
        self.backgroundColor = [UIColor colorWithHexString:kFloatVideoCellBackgroundColor];
        _containView = [[UIView alloc] init];
        _containView.backgroundColor = self.backgroundColor;
        [self addSubview:_containView];
        
        _titleLabel  = [[SSThemedLabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = [UIColor colorWithHexString:@"0x707070"];
        _titleLabel.highlightedTextColor = [UIColor tt_themedColorForKey:kColorText4];
        _titleLabel.backgroundColor = self.backgroundColor;
        
        [_containView addSubview:_titleLabel];
        
        _iconImageView = [[SSThemedImageView alloc] init];
        self.seleted = NO;
        [_containView addSubview:_iconImageView];
        
        _button = [TTStatusButton buttonWithType:UIButtonTypeCustom];
        _button.delegate = self;
        _button.backgroundColor = [UIColor clearColor];
//        [_button addTarget:self action:@selector(clicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
        
        
    }
    return self;
}

- (void)setEnable:(BOOL)enable
{
    _enable = enable;
    _button.enabled = enable;
}

- (void)setSeleted:(BOOL)seleted
{
    _seleted = seleted;
    _button.selected = seleted;
    _titleLabel.highlighted = seleted;
    if (seleted) {
        _iconImageView.image = [UIImage imageNamed:_seletedImageName];
        _iconImageView.highlightedImage = [UIImage imageNamed:_seletedImageNameHighlighted];
    }
    else
    {
        _iconImageView.image = [UIImage imageNamed:_normalImageName];
        _iconImageView.highlightedImage = [UIImage imageNamed:_normalImageNameHighlighted];
    }
    [_iconImageView sizeToFit];
}

- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [_button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)statusButtonHighlighted:(BOOL)highlighted
{
    _iconImageView.highlighted = highlighted;
}

//- (void)clicked
//{
//    NSLog(@"bouched");
//}

- (void)setTitle:(NSString *)title
{
    _title = title;
    _titleLabel.text = _title;
    [_titleLabel sizeToFit];
}

- (void)layoutSubviews
{
    if (!_title) {
        return;
    }
    _iconImageView.frame = CGRectMake(0, self.bounds.size.height / 2.0, _iconImageView.width, _iconImageView.height);
    _iconImageView.centerY = self.bounds.size.height / 2.0;
    _titleLabel.frame = CGRectMake([TTDeviceUIUtils tt_newPaddingSpecialElement:5] + _iconImageView.right, 0, _titleLabel.width, _titleLabel.height);
    _titleLabel.text = _title;
    [_titleLabel sizeToFit];
    _titleLabel.centerY = _iconImageView.centerY;
    
    _containView.frame = CGRectMake((self.width - _titleLabel.right) / 2.0,0, _titleLabel.right, self.height);
    _button.frame = self.bounds;
    
    _containView.centerY = self.bounds.size.height / 2.0;
    [super layoutSubviews];
}

@end
