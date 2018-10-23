//
//  TTEditAccountNameView.m
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import "TTEditAccountNameView.h"



@interface TTEditAccountNameView ()
@property (nonatomic, strong) SSThemedLabel *leftBracket;
@property (nonatomic, strong) SSThemedLabel *rightBracket;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@end

@implementation TTEditAccountNameView
- (instancetype)initWithFontSize:(CGFloat)fontSize {
    if ((self = [super init])) {
        self.backgroundColor = [UIColor clearColor];
        
        self.leftBracket = [[SSThemedLabel alloc] init];
        _leftBracket.origin = CGPointMake(0, 0);
        _leftBracket.backgroundColor = [UIColor clearColor];
        _leftBracket.font = [UIFont systemFontOfSize:fontSize];
        _leftBracket.textColorThemeKey = kColorText1;
        _leftBracket.text = @"(";
        [_leftBracket sizeToFit];
        [self addSubview:_leftBracket];
        
        self.rightBracket = [[SSThemedLabel alloc] init];
        _rightBracket.backgroundColor = [UIColor clearColor];
        _rightBracket.font = [UIFont systemFontOfSize:fontSize];
        _rightBracket.textColorThemeKey = kColorText1;
        _rightBracket.text = @")";
        [_rightBracket sizeToFit];
        [self addSubview:_rightBracket];
        
        self.nameLabel = [[SSThemedLabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:fontSize];
        _nameLabel.textColorThemeKey = kColorText1;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:_nameLabel];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat offsetX = 0.f;
    CGSize  size = _leftBracket.size;
    CGFloat maxWidthOfNameLabel = self.width - SSWidth(_leftBracket) - SSWidth(_rightBracket);
    _leftBracket.frame = CGRectMake(offsetX, (self.height - size.height)/2, size.width, size.height);
    
    offsetX = _leftBracket.right;
    size = _nameLabel.size;
    _nameLabel.frame = CGRectMake(offsetX, (self.height - size.height)/2, MIN(size.width, maxWidthOfNameLabel), size.height);
    
    offsetX = _nameLabel.right;
    size = _rightBracket.size;
    _rightBracket.frame = CGRectMake(offsetX, (self.height - size.height)/2, size.width, size.height);
}

- (void)refreshWithAccountName:(NSString *)accountName {
    _nameLabel.text = accountName;
    [_nameLabel sizeToFit];
}
@end
