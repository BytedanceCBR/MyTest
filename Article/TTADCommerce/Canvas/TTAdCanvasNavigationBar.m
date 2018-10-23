//
//  TTAdCanvasNavigationBar.m
//  Article
//
//  Created by carl on 2017/6/6.
//
//

#import "TTAdCanvasNavigationBar.h"

@interface TTAdCanvasNavigationBar ()
@property (nonatomic, strong) CAGradientLayer *backgroundLayer;
@end

@implementation TTAdCanvasNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor colorWithHexString:@"#0000000"];
    self.alpha = 0.5;
    [self.layer addSublayer:self.backgroundLayer];
}

- (void)setLeftButton:(TTAlphaThemedButton *)leftButton {
    if (_leftButton) {
        [_leftButton removeFromSuperview];
    }
    _leftButton = leftButton;
    [self addSubview:_leftButton];
}

- (void)setRightButton:(TTAlphaThemedButton *)rightButton {
    if (_rightButton) {
        [_rightButton removeFromSuperview];
    }
    _rightButton = rightButton;
    [self addSubview:_rightButton];
}

- (CAGradientLayer *)backgroundLayer {
    if (!_backgroundLayer) {
        _backgroundLayer = [[CAGradientLayer alloc] init];
        _backgroundLayer.colors = [NSArray arrayWithObjects:(id)([UIColor blackColor].CGColor), (id)([UIColor clearColor].CGColor), nil];
        _backgroundLayer.frame = self.bounds;
    }
    return _backgroundLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundLayer.frame = self.bounds;
    
    self.leftButton.frame = CGRectMake(0, 0, self.height, self.height);
    self.rightButton.frame = CGRectMake(self.width - self.height, 0, self.height, self.height);
}

@end

