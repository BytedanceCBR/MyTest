//
//  TTVPlayerTipRetry.m
//  Article
//
//  Created by panxiang on 2017/5/17.
//
//

#import "TTVPlayerTipRetry.h"
#import "UIColor+TTThemeExtension.h"
#import "UIViewAdditions.h"
#import "TTBaseMacro.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"
#import "UIButton+TTAdditions.h"

@interface TTVPlayerTipRetry ()
@property(nonatomic, strong)UIButton *retryButton;
@property(nonatomic, strong)UILabel *retryLabel;
@property(nonatomic, assign)BOOL hiddenRetryBtnIfNeed;
@end

@implementation TTVPlayerTipRetry
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        self.retryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _retryLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
        _retryLabel.font = [UIFont systemFontOfSize:14.f];
        _retryLabel.text = @"视频加载失败";
        [_retryLabel sizeToFit];
        [self addSubview:_retryLabel];

        self.retryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 72, 28)];
        [_retryButton setTitle:@"点击重试" forState:UIControlStateNormal];
        _retryButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_retryButton setTitleColor:[UIColor tt_defaultColorForKey:kColorText12] forState:UIControlStateNormal];
        _retryButton.layer.borderColor = [UIColor tt_defaultColorForKey:kColorLine12].CGColor;
        _retryButton.layer.borderWidth = 1;
        _retryButton.layer.cornerRadius = 6;
        _retryButton.layer.masksToBounds = YES;
        __weak typeof(self) wself = self;
        [_retryButton addTarget:self withActionBlock:^{
            __strong typeof(wself) self = wself;
            [self executeRetryAction];
        } forControlEvent:UIControlEventTouchUpInside];
        
        [self addSubview:_retryButton];
    }
    return self;
}

- (void)executeRetryAction
{
    if ([self errorCodeTextWithCode:self.errorCode]) {
        return;
    }
    self.retryButton.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.retryButton.userInteractionEnabled = YES;
    });
    if (self.retryAction) {
        self.retryAction();
    }
}

- (NSString *)errorCodeTextWithCode:(NSInteger)errorCode
{
    NSDictionary *mappings = @{@"3"      :@"转码中，视频暂时无法播放",
                               @"4"      :@"转码中，视频暂时无法播放",
                               @"20"     :@"转码中，视频暂时无法播放",
                               @"30"     :@"转码中，视频暂时无法播放",
                               @"40"     :@"视频已删除，无法播放",
                               @"1000"   :@"转码中，视频暂时无法播放",
                               @"1002"   :@"视频已删除，无法播放"
                               };
    NSString *text = [mappings valueForKey:@(errorCode).stringValue];
    return text;
}

- (void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
    [self setNeedsLayout];
}

- (void)setErrorCode:(NSInteger)errorCode
{
    if (_errorCode != errorCode) {
        _errorCode = errorCode;
        NSString *text = [self errorCodeTextWithCode:errorCode];
        if (text) {
            _hiddenRetryBtnIfNeed = YES;
            _retryLabel.text = text;
        }else{
            _hiddenRetryBtnIfNeed = NO;
            _retryLabel.text = @"视频加载失败";
        }
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    self.frame = CGRectMake((self.width - self.superview.width) / 2, (self.height - self.superview.height) / 2, self.superview.width, self.superview.height);

    CGFloat fontSize = self.isFullScreen ? 17.f : 14.f;
    _retryLabel.font = [UIFont systemFontOfSize:fontSize];
    CGRect rect = self.isFullScreen ? CGRectMake(0, 0, 108, 42) : CGRectMake(0, 0, 72, 28);
    _retryButton.frame = rect;
    _retryButton.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    [_retryLabel sizeToFit];

    CGFloat height = _retryLabel.height + 14 + _retryButton.height;
    if (_hiddenRetryBtnIfNeed) {
        _retryLabel.centerY = self.height / 2;
        _retryLabel.centerX = self.width / 2;
        _retryButton.hidden = YES;
    }else{
        _retryLabel.top = (self.height - height) / 2;
        _retryLabel.centerX = self.width / 2;
        _retryButton.top = _retryLabel.bottom + 14;
        _retryButton.centerX = _retryLabel.centerX;
        _retryButton.hidden = NO;
    }

    [super layoutSubviews];
}
@end
