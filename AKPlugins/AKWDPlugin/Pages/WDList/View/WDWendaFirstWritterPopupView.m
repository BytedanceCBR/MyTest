//
//  WDWendaFirstWritterPopupView.m
//  Article
//
//  Created by 延晋 张 on 16/4/21.
//
//

#import "WDWendaFirstWritterPopupView.h"

#import "SSThemed.h"
#import "TTDeviceUIUtils.h"
#import "WDDefines.h"


static NSUInteger const kWendaDetailMaskViewTag = 20160424;

static CGFloat const kContentViewWidth = 290.0f;
static CGFloat const kContentViewHeight = 358.5f;

static CGFloat const kDescLabelFontSize = 17.0f;
static CGFloat const kOkButtonFontSize = 14.0f;

static CGFloat const kDescLabelMargin = 22.0f;

static CGFloat const kDescLabelPadding = 15.0f;
static CGFloat const kDescLabelImagePadding = 26.0f;
static CGFloat const kDescLabelButtonPadding = 26.0f;

static CGFloat const kOkButtonHeight = 31.0f;

static CGFloat const kFirstWritterCornerRadius = 6.0f;

static NSString * const kFirstTintString = @"欢迎来问答分享你的知识、观点或故事";
static NSString * const kSecondTintString = @"精彩回答会被推荐上头条，与数亿用户分享";
static NSString * const kThirdTintString = @"不鼓励吐槽，认真的回答才会被推荐";
static NSString * const kOkButtonHint = @"我明白了";

@interface WDWendaFirstWritterPopupView ()

@property (nonatomic, strong) UIButton *maskView;

@property (nonatomic, strong) SSThemedView *contentBgView;

@property (nonatomic, strong) SSThemedImageView *imageView;
@property (nonatomic, strong) SSThemedLabel *firstContentLabel;
@property (nonatomic, strong) SSThemedLabel *secondContentLabel;
@property (nonatomic, strong) SSThemedLabel *thirdContentLabel;

@property (nonatomic, strong) SSThemedButton *okButton;

@property (nonatomic, assign) CGFloat yOffset;

@property (nonatomic, copy) NSArray<NSString *> *hintArray;

@end

@implementation WDWendaFirstWritterPopupView

#pragma mark - view lifecycle
- (instancetype)initWithFrame:(CGRect)frame hintArray:(NSArray<NSString *> *)hintArray
{
    if (self = [super initWithFrame:SSGetMainWindow().frame]) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        [self reloadWithHintArray:hintArray];

        [self.maskView addSubview:self];
        [self.maskView addSubview:self.contentBgView];
        [self.contentBgView addSubview:self.imageView];
        [self.contentBgView addSubview:self.firstContentLabel];
        [self.contentBgView addSubview:self.secondContentLabel];
        [self.contentBgView addSubview:self.thirdContentLabel];
        [self.contentBgView addSubview:self.okButton];
        
        [self reloadThemeUI];
        [self refreshFrame];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame hintArray:[WDWendaFirstWritterPopupView defaultHintArray]];
}

- (void)refreshFrame
{
    self.imageView.frame = [self frameForImageView];
    self.firstContentLabel.frame = [self frameForFirstContentLabel];
    self.secondContentLabel.frame = [self frameForSecondContentLabel];
    self.thirdContentLabel.frame = [self frameForThirdContentLabel];
    self.okButton.frame = [self frameForOKButton];
    self.contentBgView.height = SSMaxY(self.okButton) + 31.0f;
}

- (void)reloadWithHintArray:(NSArray *)hintArray
{
    if (hintArray && (hintArray.count == 3)) {
        _hintArray = [hintArray copy];
    } else {
        _hintArray = [[WDWendaFirstWritterPopupView defaultHintArray] copy];
    }
}

#pragma mark - frame

- (CGRect)frameForImageView
{
    return CGRectMake((SSWidth(self.contentBgView) - SSWidth(self.imageView))/2.0f, 21.0f, SSWidth(self.imageView), SSHeight(self.imageView));
}

- (CGRect)frameForFirstContentLabel
{
    return CGRectMake([TTDeviceUIUtils tt_padding:kDescLabelMargin] + [[self class] honrizontalGap], SSMaxY(self.imageView) + kDescLabelImagePadding, SSWidth(self.contentBgView) - 2*[TTDeviceUIUtils tt_padding:kDescLabelMargin], SSHeight(self.firstContentLabel));
}

- (CGRect)frameForSecondContentLabel
{
    return CGRectMake([TTDeviceUIUtils tt_padding:kDescLabelMargin] + [[self class] honrizontalGap], SSMaxY(self.firstContentLabel) + kDescLabelPadding, SSWidth(self.contentBgView) - 2*[TTDeviceUIUtils tt_padding:kDescLabelMargin], SSHeight(self.secondContentLabel));
}

- (CGRect)frameForThirdContentLabel
{
    return CGRectMake([TTDeviceUIUtils tt_padding:kDescLabelMargin] + [[self class] honrizontalGap], SSMaxY(self.secondContentLabel) + kDescLabelPadding, SSWidth(self.contentBgView) - 2*[TTDeviceUIUtils tt_padding:kDescLabelMargin], SSHeight(self.thirdContentLabel));
}

- (CGRect)frameForOKButton
{
    return CGRectMake((SSWidth(self.contentBgView) - SSWidth(self.okButton))/2.0f, SSMaxY(self.thirdContentLabel) + kDescLabelButtonPadding, SSWidth(self.okButton), SSHeight(self.okButton));
}

#pragma mark - Public Methods
- (void)show
{
    UIWindow *window = SSGetMainWindow();
    UIView *maskView = [window viewWithTag:kWendaDetailMaskViewTag];
    if (maskView) {
        [maskView removeFromSuperview];
        maskView = nil;
    }
    [window addSubview:self.maskView];
    
    self.alpha = 0.f;
    self.maskView.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        self.alpha = 1.f;
        self.maskView.alpha = 1.f;
    } completion:^(BOOL finished) {
        self.alpha = 1.f;
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

#pragma mark - Private Methods
- (void)dismiss:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(popUpViewWillDimissed)]) {
        [self.delegate popUpViewWillDimissed];
    }
    
    if (!animated) {
        [self.maskView removeFromSuperview];
        self.maskView = nil;
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        _maskView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_maskView removeFromSuperview];
        self.maskView = nil;
    }];
    
    if ([self.delegate respondsToSelector:@selector(popUpViewDidDimissed)]) {
        [self.delegate popUpViewDidDimissed];
    }
}

- (CGFloat)labelFontSize
{
    return kDescLabelFontSize;
}

+ (CGFloat)honrizontalGap
{
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return 0.0f;
        case TTDeviceMode812:
        case TTDeviceMode736: return 1.0f;
        case TTDeviceMode667: return 6.0f;
        case TTDeviceMode568:
        case TTDeviceMode480: return 4.0f;
    }
    return 0.0f;
}

#pragma mark - Util Methods

+ (NSArray *)defaultHintArray
{
    static NSArray *defaultHintArray = nil;
    if (!defaultHintArray) {
        defaultHintArray = @[kFirstTintString, kSecondTintString, kThirdTintString];
    }
    return defaultHintArray;
}

- (NSAttributedString *)attrubiteStringWithString:(NSString *)originString
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:originString];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineHeightMultiple:1.05];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
    return [attributedString copy];
}

#pragma mark - Event & Response
- (void)okBtnClicked:(id)sender
{
    [self dismiss:YES];
}

#pragma mark - Custom Accessors

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [UIButton buttonWithType:UIButtonTypeCustom];
        _maskView.frame = self.bounds;
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [_maskView addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        _maskView.tag = kWendaDetailMaskViewTag;
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _maskView;
}

- (SSThemedView *)contentBgView
{
    if (!_contentBgView) {
        _contentBgView = [[SSThemedView alloc] initWithFrame:CGRectMake((self.width - [TTDeviceUIUtils tt_padding:kContentViewWidth]) / 2.0f, (self.height - kContentViewHeight) / 2.0f, [TTDeviceUIUtils tt_padding:kContentViewWidth], kContentViewHeight)];
        _contentBgView.layer.cornerRadius = kFirstWritterCornerRadius;
        _contentBgView.clipsToBounds = YES;
        _contentBgView.backgroundColorThemeKey = kColorBackground4;
        _contentBgView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    return _contentBgView;
}

- (SSThemedImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _imageView.imageName = @"prompt_icon";
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_imageView sizeToFit];
    }
    return _imageView;
}

- (SSThemedLabel *)firstContentLabel
{
    if (!_firstContentLabel) {
        _firstContentLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, SSWidth(self.contentBgView) - 2*[TTDeviceUIUtils tt_padding:kDescLabelMargin], 20.0f)];
        _firstContentLabel.backgroundColor = [UIColor clearColor];
        [_firstContentLabel setFont:[UIFont systemFontOfSize:[self labelFontSize]]];
        _firstContentLabel.textColorThemeKey = kColorText1;
        NSString *firstString = [NSString stringWithFormat:@"1.%@", self.hintArray[0]];
        _firstContentLabel.attributedText = [self attrubiteStringWithString:NSLocalizedString(firstString, nil)];
        _firstContentLabel.numberOfLines = 0;
        [_firstContentLabel sizeToFit];
    }
    return _firstContentLabel;
}

- (SSThemedLabel *)secondContentLabel
{
    if (!_secondContentLabel) {
        _secondContentLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, SSWidth(self.contentBgView) - 2*[TTDeviceUIUtils tt_padding:kDescLabelMargin], 20.0f)];
        _secondContentLabel.backgroundColor = [UIColor clearColor];
        [_secondContentLabel setFont:[UIFont systemFontOfSize:[self labelFontSize]]];
        NSString *secondString = [NSString stringWithFormat:@"2.%@", self.hintArray[1]];
        _secondContentLabel.attributedText = [self attrubiteStringWithString:NSLocalizedString(secondString, nil)];
        _secondContentLabel.textColorThemeKey = kColorText1;
        _secondContentLabel.numberOfLines = 0;
        [_secondContentLabel sizeToFit];
    }
    return _secondContentLabel;
}

- (SSThemedLabel *)thirdContentLabel
{
    if (!_thirdContentLabel) {
        _thirdContentLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, SSWidth(self.contentBgView) - 2*[TTDeviceUIUtils tt_padding:kDescLabelMargin], 20.0f)];
        _thirdContentLabel.backgroundColor = [UIColor clearColor];
        [_thirdContentLabel setFont:[UIFont systemFontOfSize:[self labelFontSize]]];
        NSString *thirdString = [NSString stringWithFormat:@"3.%@", self.hintArray[2]];
        _thirdContentLabel.attributedText = [self attrubiteStringWithString:NSLocalizedString(thirdString, nil)];
        _thirdContentLabel.textColorThemeKey = kColorText1;
        _thirdContentLabel.numberOfLines = 0;
        [_thirdContentLabel sizeToFit];
    }
    return _thirdContentLabel;
}

- (SSThemedButton *)okButton
{
    if (!_okButton) {
        _okButton = [[SSThemedButton alloc] initWithFrame:CGRectZero];
        [_okButton.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:kOkButtonFontSize]]];
        _okButton.titleColorThemeKey = kColorText7;
        [_okButton setTitle:NSLocalizedString(kOkButtonHint, nil) forState:UIControlStateNormal];
        [_okButton addTarget:self action:@selector(okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _okButton.backgroundColorThemeKey = kColorBackground7;
        _okButton.highlightedBackgroundColorThemeKey = kColorBackground7Highlighted;
        _okButton.layer.cornerRadius = [TTDeviceUIUtils tt_padding:kOkButtonHeight] / 2;
        CGFloat width = [kOkButtonHint sizeWithAttributes:@{NSFontAttributeName : _okButton.titleLabel.font}].width;
        _okButton.bounds = CGRectMake(0, 0, width + 30.0f, kOkButtonHeight);
    }
    return _okButton;
}

@end
