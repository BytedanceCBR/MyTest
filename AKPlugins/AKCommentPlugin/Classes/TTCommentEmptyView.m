//
//  TTCommentEmptyView.m
//  Article
//
//  Created by 冯靖君 on 16/4/1.
//
//

#import "TTCommentEmptyView.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/UIImageAdditions.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTThemed/TTThemeManager.h>
#import <TTThemed/UIImage+TTThemeExtension.h>


#pragma mark - TTCommentEmptyView

@implementation TTCommentEmptyView

- (void)dealloc
{
    [_emptyButton removeObserver:self forKeyPath:@"highlighted"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshType:self.type];
    _emptyButton.centerX = self.centerX;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundColorThemeKey = kColorBackground4;

        // emptyButton
        self.emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _emptyButton.frame = CGRectMake(0, 0, self.width, self.height);
        _emptyButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _emptyButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
        _emptyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _emptyButton.backgroundColor = [UIColor clearColor];
        [_emptyButton addTarget:self action:@selector(emptyButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_emptyButton addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:NULL];
        [self addSubview:_emptyButton];
        
        // emptyImageView
        self.emptyImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_emptyImageView];
        
        // emptyTipLabel
        self.emptyTipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _emptyTipLabel.backgroundColor = [UIColor clearColor];
        _emptyTipLabel.font = [UIFont systemFontOfSize:15.f];
        _emptyTipLabel.textAlignment = NSTextAlignmentCenter;
        _emptyTipLabel.userInteractionEnabled = YES;
        [_emptyTipLabel addGestureRecognizer:({
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emptyButtonClicked)];
            gesture;
        })];
        [self addSubview:_emptyTipLabel];
        
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.hidesWhenStopped = YES;
        [self addSubview:_indicator];
        
        _emptyTipLabel.textColorThemeKey =  kColorText5;
    }

    return self;
}

- (void)emptyButtonClicked
{
    if (_delegate && [_delegate respondsToSelector:@selector(emptyView:buttonClickedForType:)]) {
        [_delegate emptyView:self buttonClickedForType:_type];
    }
}

- (void)refreshType:(TTCommentEmptyViewType)type
{
    self.type = type;

    _emptyImageView.hidden = NO;
    _emptyTipLabel.hidden = NO;
    _emptyTipLabel.backgroundColor = [UIColor clearColor];
    _emptyTipLabel.font = [UIFont systemFontOfSize:15.f];
    _emptyTipLabel.textColorThemeKey = kColorText5;
    _emptyTipLabel.top = 24.f;
    _emptyTipLabel.centerX = self.width / 2.f;
    _emptyButton.enabled = YES;
    [_indicator stopAnimating];

    switch (type) {
        case TTCommentEmptyViewTypeEmpty:
        {
            _emptyImageView.hidden = YES;
            _emptyTipLabel.text = NSLocalizedString(@"暂无评论，点击抢沙发", nil);
            _emptyTipLabel.textColorThemeKey = kColorText3;
            [_emptyTipLabel sizeToFit];
            _emptyTipLabel.center = CGPointMake(self.width / 2.f, 70.0f);
        }
            break;
        case TTCommentEmptyViewTypeLoading:
        {
            _emptyImageView.hidden = YES;
            _emptyTipLabel.hidden = YES;
            [_indicator startAnimating];
        }
            break;
        case TTCommentEmptyViewTypeNotNetwork:
        {
            _emptyImageView.hidden = YES;
            _emptyTipLabel.text = NSLocalizedString(@"没有网络连接", nil);
            [_emptyTipLabel sizeToFit];
        }
            break;
        case TTCommentEmptyViewTypeFailed:
        {
            _emptyTipLabel.text = NSLocalizedString(@"网络连接异常，点击重试", nil);
            [_emptyTipLabel sizeToFit];
        }
            break;
        case TTCommentEmptyViewTypeForceShowCommentButton:
        {
            _emptyImageView.image = [UIImage themedImageNamed:@"review_details.png"];
            _emptyTipLabel.text = NSLocalizedString(@"点击显示评论", nil);
            _emptyTipLabel.size = CGSizeMake(130, 30);
            [self p_changeEmptyTipLabelState:UIControlStateNormal];
        }
            break;
        case TTCommentEmptyViewTypeHidden:
        {
        }
            break;
        case TTCommentEmptyViewTypeCommentDetailEmpty:
        {
            _emptyImageView.hidden = YES;
            _emptyTipLabel.text = NSLocalizedString(@"抢先评论", nil);
            _emptyTipLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12.f]];
            _emptyTipLabel.textColorThemeKey = kColorText1;
            [_emptyTipLabel sizeToFit];
            _emptyTipLabel.top = [TTDeviceUIUtils tt_newPadding:10.f];
            _emptyTipLabel.left = [TTDeviceUIUtils tt_newPadding:64.f];
            
        }
            break;
        case TTCommentEmptyViewTypeWDDetailEmpty:
        {
            _emptyImageView.hidden = YES;
            _emptyTipLabel.text = NSLocalizedString(@"暂无评论，点击抢沙发", nil);
            _emptyTipLabel.textColorThemeKey = kColorText3;
            [_emptyTipLabel sizeToFit];
            _emptyTipLabel.top = 64;
        }
            break;
        default:
            break;
    }
    [_emptyImageView sizeToFit];
    _emptyImageView.origin = CGPointMake((self.frame.size.width - _emptyImageView.frame.size.width) / 2.f, 30);
    self.hidden = NO;
    _indicator.center = _emptyTipLabel.center;
}

#pragma mark -- KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"highlighted"]) {
        BOOL isHighlighted = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (isHighlighted) {
            [self p_changeEmptyTipLabelState:UIControlStateHighlighted];
        }
        else {
            [self p_changeEmptyTipLabelState:UIControlStateNormal];
        }
    }
}

- (void)p_changeEmptyTipLabelState:(UIControlState)state
{
    if (self.type == TTCommentEmptyViewTypeForceShowCommentButton) {
        UIImage * backgroundImage = nil;
        if (state == UIControlStateNormal) {
            backgroundImage = [UIImage imageWithSize:CGSizeMake(130, 30)
                                        cornerRadius:0
                                         borderWidth:0
                                         borderColor:[UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"e7e7e7" nightColorName:@"303030"]]
                                    backgroundColors:@[
                                                       [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"fafafa" nightColorName:@"2b2b2b"]],
                                                       [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"f8f8f8" nightColorName:@"252525"]]]];
        }
        else {
            backgroundImage = [UIImage imageWithSize:CGSizeMake(130, 30)
                                        cornerRadius:0
                                         borderWidth:0
                                         borderColor:[UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"e7e7e7" nightColorName:@"303030"]]
                                     backgroundColor:[UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"f5f5f5" nightColorName:@"2b2b2b"]]];
        }
        _emptyTipLabel.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    }
    else {
        _emptyTipLabel.backgroundColor = [UIColor clearColor];
    }
}

@end

