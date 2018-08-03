//
//  WDSecondaryQuestionTipsView.m
//  Article
//
//  Created by 延晋 张 on 2017/7/27.
//
//

#import "WDSecondaryQuestionTipsView.h"
#import "WDListViewModel.h"
#import "WDLayoutHelper.h"
#import "WDUIHelper.h"
#import <KVOController/NSObject+FBKVOController.h>
#import <TTRoute/TTRoute.h>

static CGFloat const kWDSecondaryTipsTitleFontSize = 19.0f;
static CGFloat const kWDSecondaryTipsTitleLineHeight = 26.0f;

@interface WDSecondaryQuestionTipsView ()

@property (nonatomic, strong) WDListViewModel *viewModel;

@property (nonatomic, strong) SSThemedLabel *tipsLabel;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedButton *reasonButton;

@property (nonatomic, assign) CGFloat topMargin;

@end

@implementation WDSecondaryQuestionTipsView

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(WDListViewModel *)viewModel
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColorThemeKey = kColorBackground3;
        self.layer.cornerRadius = 2.0f;
        self.topMargin = 20.0f;
        
        _viewModel = viewModel;
        
        [self addSubview:self.tipsLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.reasonButton];
        
        [self refreshTitleLabel];
        [self.KVOController observe:self.viewModel keyPath:NSStringFromSelector(@selector(relatedQuestionTitle)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            NSString *newTitle = [change tt_stringValueForKey:NSKeyValueChangeNewKey];
            NSString *oldTitle = [change tt_stringValueForKey:NSKeyValueChangeOldKey];
            if (![newTitle isEqualToString:oldTitle]) {
                WDSecondaryQuestionTipsView *tipsView = observer;
                [tipsView refreshTitleLabel];
            }
        }];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(primaryTaped:)];
        [self addGestureRecognizer:gesture];
    }
    return self;
}

#pragma mark - Override Methods

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [self refreshContent:self.viewModel.relatedQuestionTitle];
}

#pragma mark - Public

- (void)reload
{
    [self refreshTitleLabel];
    [self layoutLabels];
}

- (void)layoutLabels
{
    self.tipsLabel.origin = [self originForTipsLabel];
    self.titleLabel.frame = [self frameForTitleLabel];
    self.height = self.titleLabel.bottom + WDPadding(self.topMargin);
}

- (void)refreshTitleLabel
{
    NSString *title = self.viewModel.relatedQuestionTitle;
    if (isEmptyString(title)) {
        return;
    }
    
    CGFloat height = [WDLayoutHelper heightOfText:title fontSize:WDFontSize(kWDSecondaryTipsTitleFontSize) isBoldFont:YES lineWidth:SSWidth(self) - 2*kWDCellLeftPadding lineHeight:WDPadding(kWDSecondaryTipsTitleLineHeight) maxNumberOfLines:2];

    if (height > kWDSecondaryTipsTitleLineHeight) {
        self.topMargin = 15.0f;
    }
    self.titleLabel.height = height;
    [self refreshContent:title];
    
    [self layoutLabels];
}

- (void)refreshContent:(NSString *)title
{
    NSMutableAttributedString *attributeString = [WDLayoutHelper attributedStringWithString:title fontSize:WDFontSize(kWDSecondaryTipsTitleFontSize) isBoldFont:YES lineHeight:WDPadding(kWDSecondaryTipsTitleLineHeight) lineBreakMode:NSLineBreakByTruncatingTail];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText5] range:NSMakeRange(0.0f, title.length)];
    self.titleLabel.attributedText = [attributeString copy];
}

#pragma mark - Actions & Reponse

- (void)primaryTaped:(UITapGestureRecognizer *)gesutre
{
    if ([self.viewModel listPageneedReturn]) {
        [self.viewModel closePage];
    } else {
        if ([NSURL URLWithString:self.viewModel.relatedQuestionSchema]) {
            [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:self.viewModel.relatedQuestionSchema] userInfo:TTRouteUserInfoWithDict(@{kWDListNeedReturnKey : @1})];
        }
    }
}

- (void)reasonButtonClicked:(SSThemedButton *)button
{
    if ([NSURL URLWithString:self.viewModel.relatedReasonUrl]) {
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:self.viewModel.relatedReasonUrl] userInfo:nil];
    }
}

#pragma mark - Frame

- (CGPoint)originForTipsLabel
{
    return CGPointMake(kWDCellLeftPadding, WDPadding(self.topMargin));
}

- (CGRect)frameForTitleLabel
{
    return CGRectMake(kWDCellLeftPadding, SSMaxY(self.tipsLabel) + WDPadding(6.0f), SSWidth(self) - 2*kWDCellLeftPadding, SSHeight(self.titleLabel));
}

#pragma mark - Getter

- (SSThemedLabel *)tipsLabel
{
    if (!_tipsLabel) {
        _tipsLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(kWDCellLeftPadding, WDPadding(self.topMargin), SSWidth(self) - 70.0f - kWDCellLeftPadding, 0.0f)];
        _tipsLabel.font = WDFont(14.0f);
        _tipsLabel.textColorThemeKey = kColorText1;
        _tipsLabel.text = @"问题重复，已被合并到：";
        [_tipsLabel sizeToFit];
    }
    return _tipsLabel;
}

- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(kWDCellLeftPadding, SSMaxY(self.tipsLabel) + WDPadding(6.0f), SSWidth(self) - 2*kWDCellLeftPadding, 0.0f)];
        _titleLabel.font = [UIFont boldSystemFontOfSize:WDFontSize(kWDSecondaryTipsTitleFontSize)];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (SSThemedButton *)reasonButton
{
    if (!_reasonButton) {
        _reasonButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _reasonButton.backgroundImageName = @"reason_bg_ask";
        [_reasonButton setTitle:@"查看原因？" forState:UIControlStateNormal];
        _reasonButton.frame = CGRectMake(SSWidth(self) - 70.0f, WDPadding(6.0f), 74.0f, 24.0f);
        _reasonButton.titleEdgeInsets = UIEdgeInsetsMake(2.0f, 1.0f, -2.0f, -1.0f);
        _reasonButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _reasonButton.titleColorThemeKey = kColorText14;
        [_reasonButton addTarget:self action:@selector(reasonButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _reasonButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }
    return _reasonButton;
}

@end
