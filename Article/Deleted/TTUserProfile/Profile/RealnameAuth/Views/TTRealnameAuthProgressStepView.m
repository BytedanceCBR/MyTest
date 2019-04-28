//
//  TTRealnameAuthProgressStepView.m
//  Article
//
//  Created by lizhuoli on 16/12/18.
//
//

#import "TTRealnameAuthProgressStepView.h"
#import "UIColor+TTThemeExtension.h"

@interface TTRealnameAuthProgressStepView ()

@property (nonatomic, strong) SSThemedView *circleView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) CAShapeLayer *circleLayer;

@end

@implementation TTRealnameAuthProgressStepView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _circleView = [SSThemedView new];
        _titleLabel = [SSThemedLabel new];
        
        [self addSubview:_circleView];
        [self addSubview:_titleLabel];
        
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    [self.circleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.size.mas_equalTo(18);
        make.centerX.equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.circleView.mas_bottom).with.offset(8);
        make.left.and.right.equalTo(self);
    }];
    
    self.circleLayer = [CAShapeLayer layer];
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 18, 18)];
    
    [self.circleLayer setPath:circlePath.CGPath];
    [self.circleLayer setStrokeColor:[UIColor tt_themedColorForKey:kColorBackground1].CGColor];
    [self.circleLayer setFillColor:[UIColor tt_themedColorForKey:kColorBackground7].CGColor];
    
    self.circleLayer.lineWidth = 2;
    [self.circleView.layer addSublayer:self.circleLayer];
    
    
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textColorThemeKey = kColorText4;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
}

- (void)setHighlight:(BOOL)highlight
{
    _highlight = highlight;
    if (_highlight) {
        self.titleLabel.textColorThemeKey = kColorText4;
        [self.circleLayer setStrokeColor:[UIColor tt_themedColorForKey:kColorBackground7].CGColor];
        [self.circleLayer setFillColor:[UIColor tt_themedColorForKey:kColorBackground7].CGColor];
    } else {
        self.titleLabel.textColorThemeKey = kColorText3;
        [self.circleLayer setStrokeColor:[UIColor tt_themedColorForKey:kColorBackground1].CGColor];
        [self.circleLayer setFillColor:[UIColor clearColor].CGColor];
    }
    [self setNeedsDisplay];
}

- (void)setTitle:(NSString *)title
{
    if ([_title isEqualToString:title]) {
        return;
    }
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    [self setNeedsDisplay];
}

@end
