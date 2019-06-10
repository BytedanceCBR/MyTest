//
//  TTPlayerIndicatorView.m
//  Article
//
//  Created by 赵晶鑫 on 31/03/2017.
//
//

#import "TTPlayerIndicatorView.h"

@interface TTPlayerIndicatorView ()

@property (nonatomic, strong) UILabel *indicatorLabel;

@end

@implementation TTPlayerIndicatorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.54f];
        [self _buildViewHierarchy];
        [self _buildViewConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.layer.cornerRadius = self.height / 2;
}

#pragma mark -
#pragma mark public methods

- (void)switchResolutionWithType:(TTVideoEngineResolutionType)resolution state:(TTPlayerResolutionSwitchState)state {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hideSelf:) object:@YES];
    NSString *content = nil;
    NSArray *ranges = nil;
    NSArray *colors = nil;
    switch (state) {
        case TTPlayerResolutionSwitchStateStart: {
            if (resolution != TTVideoEngineResolutionTypeAuto) {
                content = [NSString stringWithFormat:@"正在切换到%@，请稍等...", @[@"标清", @"高清", @"超清", @"蓝光", @"4K"][resolution]];
                ranges = @[@0, @5, @5, @2, @7, @7];
                colors =@[[UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f], [UIColor redColor], [UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f]];
            }
        }
            break;
        case TTPlayerResolutionSwitchStateDone: {
            if (resolution != TTVideoEngineResolutionTypeAuto) {
                content = [NSString stringWithFormat:@"清晰度已成功切换到%@", @[@"标清", @"高清", @"超清", @"蓝光", @"4K"][resolution]];
                ranges = @[@0, @9, @9, @2];
                colors = @[[UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f], [UIColor redColor]];
            } else {
                content = [NSString stringWithFormat:@"网速不好，已为您自动切换为标清以流畅播放"];
                ranges = @[@0, @13, @13, @2, @15, @5];
                colors = @[[UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f], [UIColor redColor], [UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f]];
            }
        }
            break;
        case TTPlayerResolutionSwitchStateFailed: {
            content = @"清晰度切换失败，请重试";
            ranges = @[@0, @11];
            colors = @[[UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f]];
        }
            break;
        default:
            break;
    }
    self.indicatorLabel.attributedText = [self _generateMutipleColorsAttributedStringWithString:content ranges:ranges colors:colors];
    self.hidden = (self.indicatorLabel.attributedText ? NO : YES);
    if (state == TTPlayerResolutionSwitchStateDone || state == TTPlayerResolutionSwitchStateFailed) {
        [self performSelector:@selector(_hideSelf:) withObject:@YES afterDelay:3.0f];
    }
}

- (void)switchPlaybackSpeedWithTip:(NSString *)tip {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hideSelf:) object:@YES];
    NSString *content = [NSString stringWithFormat:@"已为您开启%@播放", tip];
    NSArray *ranges = @[@5, @(tip.length)];
    NSArray *colors = @[[UIColor redColor]];
    self.indicatorLabel.attributedText = [self _generateMutipleColorsAttributedStringWithString:content ranges:ranges colors:colors];
    self.hidden = (self.indicatorLabel.attributedText ? NO : YES);
    [self performSelector:@selector(_hideSelf:) withObject:@YES afterDelay:3.0f];
}

- (void)hide {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hideSelf:) object:@YES];
    self.hidden = YES;
}

#pragma mark -
#pragma mark private methods

- (NSAttributedString *)_generateMutipleColorsAttributedStringWithString:(NSString *)str
                                                                  ranges:(NSArray <NSNumber *> *)ranges
                                                                  colors:(NSArray <UIColor *> *)colors {
    if (!str || !ranges || !colors || (ranges.count != colors.count * 2)) {
        return nil;
    }
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] initWithString:str];
    [ret addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[TTVPlayerUtility tt_fontSize:13.0f]] range:NSMakeRange(0, str.length)];
    [ret addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f] range:NSMakeRange(0, str.length)];
    
    int index = 0;
    for (UIColor *color in colors) {
        [ret addAttribute:NSForegroundColorAttributeName
                    value:color
                    range:NSMakeRange([ranges[index] intValue], [ranges[index + 1] intValue])];
        index += 2;
    }
    return [ret copy];
}

- (void)_hideSelf:(NSNumber *)hidden {
    self.hidden = [hidden boolValue];
}

#pragma mark -
#pragma mark UI

- (void)_buildViewHierarchy {
    [self addSubview:self.indicatorLabel];
}

- (void)_buildViewConstraints {
    [self.indicatorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(7, 16, 7, 16));
    }];
}

#pragma mark -
#pragma mark getters

- (UILabel *)indicatorLabel {
    if (!_indicatorLabel) {
        _indicatorLabel = [[UILabel alloc] init];
    }
    return _indicatorLabel;
}

@end
