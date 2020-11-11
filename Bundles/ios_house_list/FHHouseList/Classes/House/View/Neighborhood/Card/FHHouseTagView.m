//
//  FHHouseTagView.m
//  ABRInterface
//
//  Created by bytedance on 2020/11/10.
//

#import "FHHouseTagView.h"
#import "UIFont+House.h"
#import "FHHouseTagViewModel.h"
#import "NSString+BTDAdditions.h"

@interface FHHouseTagView()
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@end

@implementation FHHouseTagView

+ (CGFloat)calculateViewHeight:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseTagViewModel.class]) return 0.0f;
    FHHouseTagViewModel *tagViewModel = (FHHouseTagViewModel *)viewModel;
    return tagViewModel.tagHeight;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.textLabel];
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.backgroundColor = [UIColor clearColor];
    }
    return _textLabel;
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
    }
    return _gradientLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectInset(self.bounds, 3, 1);
    self.gradientLayer.frame = self.bounds;
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    FHHouseTagViewModel *tagViewModel = (FHHouseTagViewModel *)self.viewModel;
    self.textLabel.text = tagViewModel.text;
    self.textLabel.font = tagViewModel.textFont;
    self.textLabel.textColor = tagViewModel.textColor;
    if (tagViewModel.isGradient) {
        self.gradientLayer.colors = @[(__bridge id)tagViewModel.topBackgroundColor.CGColor, (__bridge id)tagViewModel.bottomBackgroundColor.CGColor];
        self.gradientLayer.startPoint = CGPointMake(0, 0);
        self.gradientLayer.endPoint = CGPointMake(1, 1);
        self.gradientLayer.cornerRadius = 2.0f;
        [self.layer insertSublayer:self.gradientLayer atIndex:0];
    } else {
        [self.gradientLayer removeFromSuperlayer];
    }
    
//    self.layer.cornerRadius = 2;
    self.backgroundColor = tagViewModel.backgroundColor;
    [self setNeedsLayout];
}

@end
