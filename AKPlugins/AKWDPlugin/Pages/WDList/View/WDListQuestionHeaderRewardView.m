//
//  WDListQuestionHeaderRewardView.m
//  TTWenda
//
//  Created by wangqi.kaisa on 2017/10/26.
//

#import "WDListQuestionHeaderRewardView.h"
#import "WDListViewModel.h"
#import "WDQuestionEntity.h"
#import "TTImageView.h"
#import "TTTAttributedLabel.h"
#import "TTAlphaThemedButton.h"
#import "WDLayoutHelper.h"
#import "WDUIHelper.h"
#import <TTRoute/TTRoute.h>

@interface WDListQuestionHeaderRewardView()

@property (nonatomic, strong) UIButton *transparentButton;
@property (nonatomic, strong) TTImageView *iconImageView;
@property (nonatomic, strong) TTTAttributedLabel *introduceLabel;
@property (nonatomic, strong) SSThemedLabel *activityProgressLabel;
@property (nonatomic, strong) SSThemedView  *separateLineView;
@property (nonatomic, strong) TTTAttributedLabel *sponsorLabel;
@property (nonatomic, strong) UIButton *sponsorButton;
@property (nonatomic, strong) SSThemedLabel *sponsorActionLabel;
@property (nonatomic, strong) TTAlphaThemedButton *knowMoreButton;
@property (nonatomic, strong) SSThemedView  *bottomLineView;

@property (nonatomic, strong) WDListViewModel *viewModel;

@property (nonatomic, assign) BOOL hasAddSubviews;

@end

@implementation WDListQuestionHeaderRewardView

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(WDListViewModel *)viewModel {
    if (self = [super initWithFrame:frame]) {
        _viewModel = viewModel;
        self.backgroundColorThemeKey = kColorBackground4;
        [self addSubViews];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    if (!_hasAddSubviews) return;
    self.introduceLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    [self updateContent];
    
    NSString *urlString = (TTThemeModeDay == [[TTThemeManager sharedInstance_tt] currentThemeMode]) ? self.viewModel.profitModel.icon_day_url : self.viewModel.profitModel.icon_night_url;
    [self.iconImageView setImageWithURLString:urlString];
    self.iconImageView.backgroundColor = [UIColor clearColor];
}

- (void)reload {
    [self updateContent];
    [self updateLayout];
}

- (void)fontChanged
{
    [self updateContent];
    [self updateLayout];
}

- (void)addSubViews {
    if (_hasAddSubviews) return;
    _hasAddSubviews = YES;
    
    [self addSubview:self.transparentButton];
    [self addSubview:self.iconImageView];
    [self addSubview:self.introduceLabel];
    [self addSubview:self.activityProgressLabel];
    [self addSubview:self.separateLineView];
    [self addSubview:self.sponsorLabel];
    [self addSubview:self.sponsorButton];
    [self addSubview:self.sponsorActionLabel];
    [self addSubview:self.knowMoreButton];
    [self addSubview:self.bottomLineView];
}

- (void)updateContent {
    NSString *urlString = (TTThemeModeDay == [[TTThemeManager sharedInstance_tt] currentThemeMode]) ? self.viewModel.profitModel.icon_day_url : self.viewModel.profitModel.icon_night_url;
    [self.iconImageView setImageWithURLString:urlString];
    if (self.viewModel.profitModel.highlight && self.viewModel.profitModel.highlight.count) {
        WDHighlightStructModel *firstHighlight = self.viewModel.profitModel.highlight.firstObject;
        NSInteger start = firstHighlight.start.integerValue;
        NSInteger end = firstHighlight.end.integerValue;
        NSMutableAttributedString *attributedString = [WDLayoutHelper attributedStringWithString:self.viewModel.profitModel.content fontSize:WDFontSize(16) isBoldFont:YES lineHeight:WDPadding(22) lineBreakMode:NSLineBreakByTruncatingTail];
        NSInteger fullLength = [attributedString.string length];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText1] range:NSMakeRange(0, fullLength)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText4] range:NSMakeRange(start, end - start)];
        self.introduceLabel.attributedText = attributedString;
    }
    else {
        self.introduceLabel.text = self.viewModel.profitModel.content;
    }
    self.activityProgressLabel.text = self.viewModel.profitModel.profit_time;
    self.sponsorActionLabel.text = self.viewModel.profitModel.sponsor_postfix;
    NSString *sponsorContent = self.viewModel.profitModel.sponsor_name;
    if (!isEmptyString(sponsorContent)) {
        NSMutableAttributedString *token = nil;
        NSMutableAttributedString *attributedText = [WDLayoutHelper attributedStringWithString:sponsorContent fontSize:WDConstraintFontSize(12) lineHeight:WDConstraintFontSize(12)];
        if (!isEmptyString(self.viewModel.profitModel.sponsor_url)) {
            [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText5] range:NSMakeRange(0, [attributedText.string length])];
            token = [[NSMutableAttributedString alloc] initWithString:@"..."
                                                           attributes:@{
                                                                        NSFontAttributeName : [UIFont systemFontOfSize:WDConstraintFontSize(12)],
                                                                        NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5]}
                     ];
        }
        else {
            [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText1] range:NSMakeRange(0, [attributedText.string length])];
            token = [[NSMutableAttributedString alloc] initWithString:@"..."
                                                           attributes:@{
                                                                        NSFontAttributeName : [UIFont systemFontOfSize:WDConstraintFontSize(12)],
                                                                        NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1]}
                     ];
        }
        NSMutableAttributedString *token2 = [[NSMutableAttributedString alloc] initWithString:self.viewModel.profitModel.sponsor_postfix
                                                                                   attributes:@{
                                                                                                NSFontAttributeName : [UIFont systemFontOfSize:WDConstraintFontSize(12)],
                                                                                                NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1]}
                                             ];
        [token appendAttributedString:token2];
        self.sponsorLabel.attributedText = attributedText;
        self.sponsorLabel.attributedTruncationToken = token;
    }
    [self.knowMoreButton setTitle:self.viewModel.profitModel.about_text forState:UIControlStateNormal];
}

- (void)updateLayout {
    self.iconImageView.left = kWDCellLeftPadding;
    self.introduceLabel.left = self.iconImageView.right + 10;
    self.introduceLabel.top = 10;
    [self.introduceLabel sizeToFit];
    // 根据实际内容决定是一行还是两行，一行高度22，两行高度44
    CGFloat maxWidth = self.width - self.iconImageView.right - 10 - kWDCellRightPadding;
    if (self.introduceLabel.width > maxWidth) {
        self.height = WDPadding(82);
        self.introduceLabel.width = maxWidth;
        self.introduceLabel.numberOfLines = 2;
        self.introduceLabel.height = WDPadding(44);
    }
    else {
        self.height = WDPadding(60);
        self.introduceLabel.numberOfLines = 1;
        self.introduceLabel.height = WDPadding(22);
    }
    self.iconImageView.centerY = self.height / 2.0;
    self.activityProgressLabel.left = self.introduceLabel.left;
    self.activityProgressLabel.top = self.introduceLabel.bottom + 2;
    [self.activityProgressLabel sizeToFit];
    self.activityProgressLabel.height = WDPadding(16);
    [self.knowMoreButton sizeToFit];
    self.knowMoreButton.right = self.width - kWDCellRightPadding;
    self.knowMoreButton.centerY = self.activityProgressLabel.centerY;
    NSString *sponsorContent = self.viewModel.profitModel.sponsor_name;
    if (!isEmptyString(sponsorContent)) {
        self.separateLineView.hidden = NO;
        self.sponsorLabel.hidden = NO;
        self.sponsorButton.hidden = NO;
        self.separateLineView.left = ceilf(self.activityProgressLabel.right) + 6;
        self.separateLineView.height = WDConstraintPadding(12);
        self.separateLineView.width = [TTDeviceHelper ssOnePixel];
        self.separateLineView.centerY = self.activityProgressLabel.centerY;
        self.sponsorLabel.left = ceilf(self.separateLineView.right) + 5.5;
        [self.sponsorLabel sizeToFit];
        self.sponsorLabel.centerY = self.activityProgressLabel.centerY + 1;
        self.sponsorActionLabel.top = self.activityProgressLabel.top;
        self.sponsorActionLabel.left = ceilf(self.sponsorLabel.right);
        [self.sponsorActionLabel sizeToFit];
        self.sponsorActionLabel.height = self.activityProgressLabel.height;
        CGFloat constraintWidth = self.width - ceilf(self.separateLineView.right + 5.5 + self.knowMoreButton.width + kWDCellRightPadding + WDPadding(20) + self.sponsorActionLabel.width);
        if (self.sponsorLabel.width > constraintWidth) {
            NSString *fullContent = [NSString stringWithFormat:@"%@%@",sponsorContent,self.viewModel.profitModel.sponsor_postfix];
            NSMutableAttributedString *attributedText = [WDLayoutHelper attributedStringWithString:fullContent fontSize:WDConstraintFontSize(12) lineHeight:WDConstraintFontSize(12)];
            if (!isEmptyString(self.viewModel.profitModel.sponsor_url)) {
                [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText5] range:NSMakeRange(0, [attributedText.string length])];
            }
            else {
                [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText1] range:NSMakeRange(0, [attributedText.string length])];
            }
            self.sponsorLabel.attributedText = attributedText;
            self.sponsorLabel.width = constraintWidth + self.sponsorActionLabel.width;
            self.sponsorLabel.centerY = self.activityProgressLabel.centerY + 1;
            self.sponsorActionLabel.hidden = YES;
        }
        else {
            self.sponsorActionLabel.hidden = NO;
        }
        self.sponsorButton.left = self.sponsorLabel.left - 20;
        self.sponsorButton.top = self.sponsorLabel.top - 20;
        self.sponsorButton.width = self.sponsorLabel.width + 40;
        self.sponsorButton.height = self.sponsorLabel.height + 40;
    }
    else {
        self.separateLineView.hidden = YES;
        self.sponsorLabel.hidden = YES;
        self.sponsorActionLabel.hidden = YES;
        self.sponsorButton.hidden = YES;
    }
    self.bottomLineView.height = [TTDeviceHelper ssOnePixel];
    self.bottomLineView.left = kWDCellLeftPadding;
    self.bottomLineView.width = self.width - kWDCellLeftPadding - kWDCellRightPadding;
    self.bottomLineView.bottom = self.height;
    self.transparentButton.frame = self.bounds;
}

- (void)knowMoreButtonTapped {
    NSString *schema = self.viewModel.profitModel.about_url;
    if (!isEmptyString(schema)) {
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:schema] userInfo:nil];
    }
}

- (void)sponsorLabelTapped {
    NSString *schema = self.viewModel.profitModel.sponsor_url;
    if (!isEmptyString(schema)) {
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:schema] userInfo:nil];
    }
    else {
        [self knowMoreButtonTapped];
    }
}

- (UIButton *)transparentButton {
    if (!_transparentButton) {
        _transparentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _transparentButton.backgroundColor = [UIColor clearColor];
        [_transparentButton addTarget:self action:@selector(knowMoreButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _transparentButton;
}

- (TTImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, WDPadding(36), WDPadding(44))];
        _iconImageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.backgroundColor = [UIColor clearColor];
        _iconImageView.enableNightCover = NO;
        _iconImageView.userInteractionEnabled = NO;
    }
    return _iconImageView;
}

- (TTTAttributedLabel *)introduceLabel {
    if (!_introduceLabel) {
        _introduceLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _introduceLabel.numberOfLines = 0;
        _introduceLabel.font = [UIFont boldSystemFontOfSize:WDFontSize(16)];
        _introduceLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        _introduceLabel.userInteractionEnabled = NO;
    }
    return _introduceLabel;
}

- (SSThemedLabel *)activityProgressLabel {
    if (!_activityProgressLabel) {
        _activityProgressLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _activityProgressLabel.font = [UIFont systemFontOfSize:WDConstraintFontSize(12)];
        _activityProgressLabel.textColorThemeKey = kColorText1;
    }
    return _activityProgressLabel;
}

- (SSThemedView *)separateLineView {
    if (!_separateLineView) {
        _separateLineView = [[SSThemedView alloc] init];
        _separateLineView.backgroundColorThemeKey = kColorLine1;
    }
    return _separateLineView;
}

- (TTTAttributedLabel *)sponsorLabel {
    if (!_sponsorLabel) {
        _sponsorLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _sponsorLabel.font = [UIFont systemFontOfSize:WDConstraintFontSize(12)];
        _sponsorLabel.numberOfLines = 1;
    }
    return _sponsorLabel;
}

- (UIButton *)sponsorButton {
    if (!_sponsorButton) {
        _sponsorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sponsorButton.backgroundColor = [UIColor clearColor];
        [_sponsorButton addTarget:self action:@selector(sponsorLabelTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sponsorButton;
}

- (SSThemedLabel *)sponsorActionLabel {
    if (!_sponsorActionLabel) {
        _sponsorActionLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _sponsorActionLabel.font = [UIFont systemFontOfSize:WDConstraintFontSize(12)];
        _sponsorActionLabel.textColorThemeKey = kColorText1;
    }
    return _sponsorActionLabel;
}

- (TTAlphaThemedButton *)knowMoreButton {
    if (!_knowMoreButton) {
        _knowMoreButton = [[TTAlphaThemedButton alloc] init];
        _knowMoreButton.titleColorThemeKey = kColorText1;
        _knowMoreButton.titleLabel.font = [UIFont systemFontOfSize:WDConstraintFontSize(12)];
        _knowMoreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-15, -15, -15, -15);
        [_knowMoreButton setTitle:@"了解更多" forState:UIControlStateNormal];
        [_knowMoreButton addTarget:self action:@selector(knowMoreButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _knowMoreButton;
}

- (SSThemedView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[SSThemedView alloc] init];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
    }
    return _bottomLineView;
}

@end

