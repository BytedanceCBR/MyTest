//
//  WDDetailSlideWhiteHeaderView.m
//  Article
//
//  Created by wangqi.kaisa on 2017/8/2.
//  Copied by lizhuoli on 2018/1/7
//

#import "WDDetailHeaderView.h"
#import "TTAlphaThemedButton.h"
#import "WDUIHelper.h"
#import "WDLayoutHelper.h"
#import "NSObject+FBKVOController.h"
#import "WDAnswerEntity.h"
#import "WDDetailModel.h"
#import "TTRoute.h"
#import "TTTAttributedLabel.h"
#import "TTImageView.h"
#import <SDWebImage/UIButton+WebCache.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import <TTBaseLib/NSString-Extension.h>

// 旧版Native头部样式，参考左右滑的白底样式拷贝而来

NSString * const kWDDetailHeaderViewAnswerText = @"回答";

@interface WDDetailHeaderView ()

@property (nonatomic, strong) SSThemedView *bgView;
@property (nonatomic, strong) TTTAttributedLabel *questionContentLabel;
@property (nonatomic, strong) TTAlphaThemedButton *transparentButton;
@property (nonatomic, strong) TTAlphaThemedButton *checkAnswerButton;
@property (nonatomic, strong) TTAlphaThemedButton *writeAnswerButton;
@property (nonatomic, strong) TTAlphaThemedButton *middleAnswerButton;
@property (nonatomic, strong) SSThemedView *singleLineView;
@property (nonatomic, strong) SSThemedView *bottomSeparateView;
@property (nonatomic, strong) WDDetailModel *detailModel;
@property (nonatomic, assign) BOOL hasAppear;

@end

@implementation WDDetailHeaderView
@synthesize delegate;

- (instancetype)initWithFrame:(CGRect)frame detailModel:(WDDetailModel *)detailModel {
    if (self = [super initWithFrame:frame]) {
        
        self.detailModel = detailModel;
        [self addSubview:self.bgView];
        [self addSubview:self.questionContentLabel];
        [self addSubview:self.transparentButton];
        [self addSubview:self.checkAnswerButton];
        [self addSubview:self.writeAnswerButton];
        [self addSubview:self.middleAnswerButton];
        [self addSubview:self.singleLineView];
        [self addSubview:self.bottomSeparateView];
        [self reloadView];
        [self addKVO];
    }
    return self;
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    self.hasAppear = YES;
}

- (void)reloadView {
    [self updateContent];
    [self updateFrame];
}

- (void)addKVO {
    NSArray *keyPaths = @[NSStringFromSelector(@selector(allAnswerText)), [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(answerEntity)), NSStringFromSelector(@selector(profitLabel))], NSStringFromSelector(@selector(showTips))];
    WeakSelf;
    [self.KVOController observe:self.detailModel keyPaths:keyPaths options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        [self reloadView];
    }];
    [self.KVOController observe:self keyPath:NSStringFromSelector(@selector(frame)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        if (self.detailModel.showPostAnswer) {
            [self detectGoodAnswerButtonIsShow];
        } else {
            [self detectAnswerButtonIsShow];
        }
    }];
}

- (void)detectAnswerButtonIsShow
{
    if (self.hasAppear) {
        UIButton *answerButton = self.writeAnswerButton;
        CGRect answerFrame = [self convertRect:answerButton.frame toView:nil];
        CGFloat y = CGRectGetMaxY(answerFrame);
        CGFloat yOffset = self.tt_safeAreaInsets.top + TTNavigationBarHeight;
        if (y >= yOffset) {
            if ([self.delegate respondsToSelector:@selector(headerView:answerButtonDidShow:)]) {
                [self.delegate headerView:self answerButtonDidShow:answerButton];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(headerView:answerButtonDidHide:)]){
                [self.delegate headerView:self answerButtonDidHide:answerButton];
            }
        }
    }
}

- (void)detectGoodAnswerButtonIsShow
{
    if (self.hasAppear) {
        UIButton *answerButton = self.middleAnswerButton;
        CGRect answerFrame = [self convertRect:answerButton.frame toView:nil];
        CGFloat y = CGRectGetMaxY(answerFrame);
        CGFloat yOffset = self.tt_safeAreaInsets.top + TTNavigationBarHeight;
        if (y >= yOffset) {
            if ([self.delegate respondsToSelector:@selector(headerView:goodAnswerButtonDidShow:)]) {
                [self.delegate headerView:self goodAnswerButtonDidShow:answerButton];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(headerView:goodAnswerButtonDidHide:)]){
                [self.delegate headerView:self goodAnswerButtonDidHide:answerButton];
            }
        }
    }
}

- (void)updateContent {
    [self updateQuestionTitleContent];
    NSString *checkAnswerTitle = self.detailModel.allAnswerText;
    checkAnswerTitle = [checkAnswerTitle stringByReplacingOccurrencesOfString:@"全部" withString:@""];
    [self.checkAnswerButton setTitle:checkAnswerTitle forState:UIControlStateNormal];

    [self.writeAnswerButton setTitle:kWDDetailHeaderViewAnswerText forState:UIControlStateNormal];
    self.writeAnswerButton.imageName = @"write_details_ask";
    self.checkAnswerButton.imageName = @"all_card_arrow";
}

- (void)updateQuestionTitleContent {
    CGFloat fontSize = WDFontSize(19);
    CGFloat lineHeight = ceil(26.0 / 19.0 * WDFontSize(19));
    NSString *questionTitle = [NSString stringWithFormat:@"%@",self.detailModel.answerEntity.questionTitle];
    NSMutableAttributedString * attributedString = [WDLayoutHelper attributedStringWithString:questionTitle fontSize:fontSize isBoldFont:YES lineHeight:lineHeight];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText1] range:NSMakeRange(0, [attributedString.string length])];
    self.questionContentLabel.attributedText = attributedString;;
}

- (void)updateFrame {
    self.questionContentLabel.frame = [self frameForContentLabel];
    CGFloat bottomY = 0;
    BOOL shouldHideAnswerButton = self.detailModel.shouldHideAnswerButton; // 是否隐藏回答按钮
    shouldHideAnswerButton = YES;
    BOOL shouldHideLine = self.detailModel.showTips; // 是否隐藏分割线
    if (!self.detailModel.showPostAnswer) {
        self.writeAnswerButton.hidden = NO;
        self.middleAnswerButton.hidden = YES;
        self.bottomSeparateView.hidden = YES;
        [self.checkAnswerButton sizeToFit];
        CGFloat offsetX = kWDCellLeftPadding;
        if (shouldHideAnswerButton) {
            self.writeAnswerButton.size = CGSizeZero;
        } else {
            self.writeAnswerButton.origin = CGPointMake(offsetX, SSMaxY(self.questionContentLabel) + WDPadding(10));
            offsetX = self.writeAnswerButton.right + 30;
        }
        self.checkAnswerButton.origin = CGPointMake(offsetX, SSMaxY(self.questionContentLabel) + WDPadding(10));
        self.checkAnswerButton.height = 20;
        CGFloat imageWidth = self.checkAnswerButton.imageView.bounds.size.width;
        CGFloat labelWidth = self.checkAnswerButton.titleLabel.bounds.size.width;
        self.checkAnswerButton.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+4, 0, -labelWidth);
        self.checkAnswerButton.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth-4, 0, imageWidth);
        self.checkAnswerButton.width = imageWidth + labelWidth + 4;
        if (shouldHideLine) {
            self.singleLineView.size = CGSizeZero;
        }
        self.singleLineView.top = self.checkAnswerButton.bottom + WDPadding(16);
        bottomY = self.singleLineView.bottom;
    }
    else {
        self.writeAnswerButton.hidden = YES;
        self.bottomSeparateView.hidden = NO;
        self.middleAnswerButton.hidden = NO;
        [self.checkAnswerButton sizeToFit];
        self.checkAnswerButton.origin = CGPointMake(kWDCellLeftPadding, SSMaxY(self.questionContentLabel) + WDPadding(10));
        self.checkAnswerButton.height = 20;
        if (shouldHideLine && shouldHideAnswerButton) {
            self.singleLineView.size = CGSizeZero;
        }
        CGFloat offsetY = self.checkAnswerButton.bottom + WDPadding(16);
        self.singleLineView.top = offsetY;
        self.middleAnswerButton.centerX = SSWidth(self)/2.0;
        if (shouldHideAnswerButton) {
            self.middleAnswerButton.size = CGSizeZero;
        } else {
            self.middleAnswerButton.top = offsetY + WDPadding(12);
            offsetY = self.middleAnswerButton.bottom + WDPadding(11);
        }
        if (shouldHideLine) {
            self.bottomSeparateView.size = CGSizeZero;
        }
        self.bottomSeparateView.top = offsetY;
        bottomY = self.bottomSeparateView.bottom;
    }
    self.height = bottomY;
    self.bgView.frame = self.bounds;
    self.transparentButton.frame = self.bounds;
}

- (CGRect)frameForContentLabel {
    CGFloat naviHeight = WDPadding(14);
    return CGRectMake(kWDCellLeftPadding, naviHeight, SSWidth(self) - kWDCellLeftPadding - kWDCellRightPadding, [self heightForContentLabel]);
}

- (CGFloat)heightForContentLabel {
    NSAttributedString *attributedStr = self.questionContentLabel.attributedText;
    CGFloat height = [TTTAttributedLabel sizeThatFitsAttributedString:attributedStr
                                                      withConstraints:CGSizeMake(SSWidth(self) - kWDCellLeftPadding - kWDCellRightPadding, 0.0f)
                                               limitedToNumberOfLines:0].height;
    
    return height;
}

- (void)allAnswerButtonTapped:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(headerView:bgButtonDidTap:)]) {
        [self.delegate headerView:self bgButtonDidTap:button];
    }
}

- (void)writeAnswerButtonTapped:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(headerView:answerButtonDidTap:)]) {
        [self.delegate headerView:self answerButtonDidTap:button];
    }
}

- (void)goodAnswerWriteButtonTapped:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(headerView:goodAnswerButtonDidTap:)]) {
        [self.delegate headerView:self goodAnswerButtonDidTap:button];
    }
}

#pragma mark - notification

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    self.questionContentLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    [self updateContent];
}

#pragma mark - getter

- (SSThemedView *)bgView {
    if (!_bgView) {
        _bgView = [[SSThemedView alloc] initWithFrame:self.bounds];
        _bgView.backgroundColorThemeKey = kColorBackground4;
    }
    return _bgView;
}

- (TTTAttributedLabel *)questionContentLabel {
    if (!_questionContentLabel) {
        CGFloat naviHeight = 0;
        _questionContentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _questionContentLabel.top = naviHeight;
        _questionContentLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        _questionContentLabel.backgroundColor = [UIColor clearColor];
        _questionContentLabel.numberOfLines = 0;
        _questionContentLabel.font = [UIFont boldSystemFontOfSize:WDFontSize(19)];
        _questionContentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _questionContentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _questionContentLabel;
}

- (TTAlphaThemedButton *)transparentButton {
    if (!_transparentButton) {
        _transparentButton = [[TTAlphaThemedButton alloc] init];
        _transparentButton.backgroundColor = [UIColor clearColor];
        [_transparentButton addTarget:self action:@selector(allAnswerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _transparentButton;
}

- (TTAlphaThemedButton *)checkAnswerButton {
    if (!_checkAnswerButton) {
        _checkAnswerButton = [[TTAlphaThemedButton alloc] init];
        _checkAnswerButton.frame = CGRectMake(0, SSMaxY(self.questionContentLabel) + WDPadding(10), 0, 20); // 71, 59
        _checkAnswerButton.titleLabel.font = [UIFont systemFontOfSize:WDFontSize(14)];
        _checkAnswerButton.titleColorThemeKey = kColorText1;
        [_checkAnswerButton addTarget:self action:@selector(allAnswerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkAnswerButton;
}

- (TTAlphaThemedButton *)writeAnswerButton {
    if (!_writeAnswerButton) {
        _writeAnswerButton = [[TTAlphaThemedButton alloc] init];
        _writeAnswerButton.titleLabel.font = [UIFont systemFontOfSize:WDFontSize(14)];
        CGFloat width = [kWDDetailHeaderViewAnswerText tt_sizeWithMaxWidth:CGFLOAT_MAX font:_writeAnswerButton.titleLabel.font].width;
        _writeAnswerButton.frame = CGRectMake(0, SSMaxY(self.questionContentLabel) + WDPadding(10), width + 20, 20); // 图片16pt，间隔3.5pt，取个整
        _writeAnswerButton.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0);
        _writeAnswerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
        _writeAnswerButton.titleColorThemeKey = kColorText1;
        [_writeAnswerButton addTarget:self action:@selector(writeAnswerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _writeAnswerButton;
}

- (TTAlphaThemedButton *)middleAnswerButton {
    if (!_middleAnswerButton) {
        _middleAnswerButton = [[TTAlphaThemedButton alloc] init];
        _middleAnswerButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _middleAnswerButton.frame = CGRectMake(0, SSMaxY(self.checkAnswerButton) + WDPadding(32), CGRectGetWidth(self.bounds), 22);
        _middleAnswerButton.titleLabel.font = [UIFont systemFontOfSize:WDFontSize(16)];
        _middleAnswerButton.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 3);
        _middleAnswerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, -3);
        [_middleAnswerButton addTarget:self action:@selector(goodAnswerWriteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _middleAnswerButton;
}

- (SSThemedView *)singleLineView {
    if (!_singleLineView) {
        _singleLineView = [[SSThemedView alloc] initWithFrame:CGRectMake(kWDCellLeftPadding, 0, CGRectGetWidth(self.bounds) - kWDCellLeftPadding - kWDCellRightPadding, [TTDeviceHelper ssOnePixel])];
        _singleLineView.backgroundColorThemeKey = kColorLine1;
        _singleLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _singleLineView;
}

- (SSThemedView *)bottomSeparateView {
    if (!_bottomSeparateView) {
        _bottomSeparateView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), WDPadding(6))];
        _bottomSeparateView.backgroundColorThemeKey = kColorBackground3;
        _bottomSeparateView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _bottomSeparateView;
}

@end
