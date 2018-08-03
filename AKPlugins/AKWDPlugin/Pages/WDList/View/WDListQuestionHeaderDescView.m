//
//  WDListQuestionHeaderDescView.m
//  Article
//
//  Created by 延晋 张 on 16/8/22.
//
//

#import "WDListQuestionHeaderDescView.h"
#import "WDListLayoutModel.h"
#import "WDListViewModel.h"
#import "WDQuestionEntity.h"
#import "WDQuestionDescEntity.h"
#import "WDListQuestionHeaderImageBoxView.h"
#import "WDSettingHelper.h"
#import "WDLayoutHelper.h"
#import "WDUIHelper.h"
#import "WDFontDefines.h"

#import "TTTAttributedLabel.h"
#import "TTAlphaThemedButton.h"
#import "NSObject+FBKVOController.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"

@interface WDListQuestionHeaderDescView () <TTTAttributedLabelDelegate>

@property (nonatomic, strong) WDListViewModel *viewModel;

@property (nonatomic, strong) TTTAttributedLabel *contentLabel;
@property (nonatomic, strong) WDListQuestionHeaderImageBoxView *imageBoxView;

@property (nonatomic, assign) BOOL isNeedUnfold; // 是否需要展开
@property (nonatomic, assign) BOOL isFoldState;  // 是否折叠状态
@property (nonatomic, assign) BOOL hasAddSubviews;

@end

@implementation WDListQuestionHeaderDescView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(WDListViewModel *)viewModel
{
    if (self = [super initWithFrame:frame]) {
        _viewModel = viewModel;
        _isFoldState = YES;
        
        self.backgroundColorThemeKey = kColorBackground4;
        self.borderColorThemeKey = kColorLine1;
        
        if (!isEmptyString(self.entity.content.text) || self.entity.content.thumbImageList) {
            [self addSubViews];
        }
        
        WeakSelf;
        [self.KVOController observe:self.viewModel.questionEntity keyPath:@"content" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            [self addSubViews];
            [self updateContent];
            [self updateFrame];
        }];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    if (!_hasAddSubviews) return;
    self.contentLabel.textColor = [UIColor tt_themedColorForKey:kColorText14];
    self.contentLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    [self updateContent];
}

- (void)reload
{
    [self updateContent];
    [self updateFrame];
}

#pragma mark - update

- (void)fontChanged
{
    [self updateContent];
    [self updateFrame];
}

- (void)addSubViews {
    if (_hasAddSubviews) return;
    _hasAddSubviews = YES;
    
    CGFloat contentHeight = [self heightForTTContentLabelWithMaxNumberOfLines:[_viewModel defaultNumberOfLines]];
    CGFloat realHeight = [self heightForTTContentLabelWithMaxNumberOfLines:0];
    
    _isNeedUnfold = !(contentHeight == realHeight);
    
    [self addSubview:self.contentLabel];
    [self addSubview:self.imageBoxView];
}

- (void)updateContent
{
    self.contentLabel.text = nil;
    self.contentLabel.attributedTruncationToken = nil;
    
    CGFloat fontSize = [WDListLayoutModel questionDescContentFontSize];
    CGFloat lineHeight = [WDListLayoutModel questionDescContentLineHeight];
    NSMutableAttributedString *attributedString = [WDLayoutHelper attributedStringWithString:[self descText] fontSize:fontSize lineHeight:lineHeight];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText14] range:NSMakeRange(0, attributedString.string.length)];
    self.contentLabel.attributedTruncationToken = [self tokenAttributeString];

    self.contentLabel.font = [UIFont systemFontOfSize:fontSize];
    self.contentLabel.attributedText = attributedString;
    [self.imageBoxView refreshImageView];
}

#pragma mark - frame

- (void)updateFrame {
    if (!isEmptyString(self.entity.content.text)) {
        self.contentLabel.frame = [self frameForContentLabel];
        if ([self.imageBoxView viewHeight] > 0) {
            self.imageBoxView.hidden = NO;
            self.imageBoxView.frame = CGRectMake(kWDCellLeftPadding, SSMaxY(self.contentLabel) + WDPadding(10.0f), SSWidth(self) - kWDCellLeftPadding - kWDCellRightPadding, [self.imageBoxView viewHeight]);
            self.height = (SSMaxY(self.imageBoxView));
        } else {
            CGFloat totalHeight = SSMaxY(self.contentLabel);
            self.height = totalHeight;
        }
    } else {
        if ([self.imageBoxView viewHeight] > 0) {
            self.imageBoxView.hidden = NO;
            self.imageBoxView.frame = CGRectMake(kWDCellLeftPadding, WDPadding(0), SSWidth(self) - kWDCellLeftPadding - kWDCellRightPadding, [self.imageBoxView viewHeight]);
            self.height = SSMaxY(self.imageBoxView);
        } else {
            self.height = 0;
        }
    }
}

- (CGRect)frameForContentLabel
{
    if (self.isFoldState) {
        CGFloat contentHeight = [self heightForTTContentLabelWithMaxNumberOfLines:[_viewModel defaultNumberOfLines]];
        return CGRectMake(kWDCellLeftPadding, 0, SSWidth(self) - kWDCellLeftPadding - kWDCellRightPadding, contentHeight);
    } else {
        CGFloat realHeight = [self heightForTTContentLabelWithMaxNumberOfLines:0];
        return CGRectMake(kWDCellLeftPadding, 0, SSWidth(self) - kWDCellLeftPadding - kWDCellRightPadding, realHeight);
    }
}

- (CGSize)sizeForTTContentLabelWithMaxNumberOfLines:(NSInteger)numberOfLines
{
    CGFloat fontSize = [WDListLayoutModel questionDescContentFontSize];
    CGFloat lineHeight = [WDListLayoutModel questionDescContentLineHeight];
    NSDictionary *attribute = [WDLayoutHelper attributesWithFontSize:fontSize isBoldFont:NO lineHeight:lineHeight];
    NSAttributedString *attributedStr = [[NSAttributedString alloc] initWithString:[self descText] attributes:attribute];
    CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedStr
                                                   withConstraints:CGSizeMake(SSWidth(self)  - kWDCellLeftPadding - kWDCellRightPadding, 0.0f)
                                            limitedToNumberOfLines:numberOfLines];
    return size;
}

- (CGFloat)heightForTTContentLabelWithMaxNumberOfLines:(NSInteger)numberOfLines
{
    if (numberOfLines != 0) {
        CGFloat lineHeight = [WDListLayoutModel questionDescContentLineHeight];
        return numberOfLines * lineHeight;
    }
    CGSize size = [self sizeForTTContentLabelWithMaxNumberOfLines:numberOfLines];
    return ceilf(size.height);
}

#pragma mark - action & response

- (void)extentView
{
    if (!self.isFoldState) return;
    self.contentLabel.numberOfLines = 0;
    self.isFoldState = NO;
    [self updateContent];
    [self updateFrame];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.viewModel.gdExtJson];
    [TTTracker eventV3:@"question_unfold_question" params:[params copy]];
}

#pragma mark - getter

- (NSString *)descText
{
    return self.entity.content.text;
}

- (WDQuestionEntity *)entity
{
    return self.viewModel.questionEntity;
}

- (NSAttributedString *)tokenAttributeString
{
    if (!_isFoldState || !_isNeedUnfold) {
        return nil;
    }
    
    CGFloat fontSize = [WDListLayoutModel questionDescContentFontSize];
    
    NSMutableAttributedString *token = [[NSMutableAttributedString alloc] initWithString:@"... "
                                                                              attributes:@{
                                                                                           NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                                                                                           NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText14]}
                                        ];
    NSString *foldString = @"展开";
    NSMutableAttributedString *foldToken = [[NSMutableAttributedString alloc] initWithString:foldString
                                                                                  attributes:@{
                                                                                               NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                                                                                               NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5]}
                                            ];
    NSString *arrowString = [NSString stringWithFormat:@" %@",ask_arrow_down];
    NSMutableAttributedString *tokenArrow = [[NSMutableAttributedString alloc] initWithString:arrowString
                                                                                   attributes:@{NSBaselineOffsetAttributeName:@(fontSize/2 - 6),
                                                                                                NSFontAttributeName : [UIFont fontWithName:wd_iconfont size:10],
                                                                                                NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5]}
                                             ];
    [token appendAttributedString:foldToken];
    [token appendAttributedString:tokenArrow];
    return token;
}

- (TTTAttributedLabel *)contentLabel
{
    if (!_contentLabel) {
        CGFloat fontSize = [WDListLayoutModel questionDescContentFontSize];
        _contentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(kWDCellLeftPadding, WDLabelPadding(10.0f, fontSize), SSWidth(self) - kWDCellLeftPadding - kWDCellRightPadding, 0.0f)];
        _contentLabel.numberOfLines = [_viewModel defaultNumberOfLines];
        _contentLabel.font = [UIFont systemFontOfSize:fontSize];
        _contentLabel.textColor = [UIColor tt_themedColorForKey:kColorText14];
        _contentLabel.userInteractionEnabled = YES;
        _contentLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        if (_isNeedUnfold) {
            [_contentLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(extentView)]];
        }
    }
    return _contentLabel;
}

- (WDListQuestionHeaderImageBoxView *)imageBoxView
{
    if (!_imageBoxView) {
        _imageBoxView = [[WDListQuestionHeaderImageBoxView alloc] initWithViewModel:self.viewModel frame:CGRectMake(kWDCellLeftPadding, SSMaxY(self.contentLabel), SSWidth(self) - kWDCellLeftPadding - kWDCellRightPadding, 0.0f)];
        _imageBoxView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _imageBoxView.hidden = YES;
    }
    return _imageBoxView;
}

@end
