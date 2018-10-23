//
//  WDListQuestionHeaderDescViewNew.m
//  TTWenda
//
//  Created by wangqi.kaisa on 2017/10/18.
//

#import "WDListQuestionHeaderDescViewNew.h"
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

/*
 * 3种类型，分别对应.h中描述的三种情况
 */
typedef NS_ENUM(NSInteger, DescTextAndImageFoldStateShowType) {
    DescTextAndImageFoldStateShowTypeOne,
    DescTextAndImageFoldStateShowTypeTwo,
    DescTextAndImageFoldStateShowTypeThree,
};

@interface WDListQuestionHeaderDescViewNew () <TTTAttributedLabelDelegate>

@property (nonatomic, strong) WDListViewModel *viewModel;

@property (nonatomic, strong) TTTAttributedLabel *contentLabel;
@property (nonatomic, strong) WDListQuestionHeaderImageBoxView *imageBoxView;

@property (nonatomic, assign) BOOL isOnlyText; // 是否纯文字
@property (nonatomic, assign) BOOL isOnlyImage; // 是否纯图片
@property (nonatomic, assign) BOOL isTextAndImage; // 是否图文
@property (nonatomic, assign) BOOL isNeedUnfold; // 是否需要展开
@property (nonatomic, assign) BOOL isFoldState;  // 是否折叠状态
@property (nonatomic, assign) DescTextAndImageFoldStateShowType showType; // 含义见定义处
@property (nonatomic, assign) CGFloat cacheLabelWidth; // 仅type==3时使用
@property (nonatomic, assign) BOOL hasAddSubviews;

@end

@implementation WDListQuestionHeaderDescViewNew

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
    if (!isEmptyString(self.entity.content.text)) {
        if (self.entity.content.thumbImageList.count > 0) {
            _isTextAndImage = YES;
        }
        else {
            _isOnlyText = YES;
        }
    }
    else {
        if (self.entity.content.thumbImageList.count > 0) {
            _isOnlyImage = YES;
        }
    }
    
    if (_isOnlyText) {
        CGFloat contentHeight = [self heightForTTContentLabelWithMaxNumberOfLines:[_viewModel defaultNumberOfLines]];
        CGFloat realHeight = [self heightForTTContentLabelWithMaxNumberOfLines:0];
        _isNeedUnfold = !(contentHeight == realHeight);
    }
    else if (_isTextAndImage) {
        // 需要做一些判断 。。。
        CGSize contentSize = [self sizeForTTContentLabelWithMaxNumberOfLines:[_viewModel defaultNumberOfLines]];
        CGFloat labelWidth = ceilf(contentSize.width);
        CGFloat maxWidth = (SSWidth(self)  - kWDCellLeftPadding - kWDCellRightPadding);
        if (labelWidth > maxWidth) {
            // 超过1行
            labelWidth = maxWidth;
            self.showType = DescTextAndImageFoldStateShowTypeOne;
        }
        else {
            CGFloat tokenWidth = [self widthForShortTokenString];
            if (labelWidth + tokenWidth > maxWidth) {
                // 超过1行
                labelWidth = maxWidth - tokenWidth;
                self.showType = DescTextAndImageFoldStateShowTypeTwo;
            }
            else {
                // 仅1行
                self.cacheLabelWidth = labelWidth + tokenWidth;
                self.showType = DescTextAndImageFoldStateShowTypeThree;
            }
        }
        _isNeedUnfold = YES;
    }
    
    [self addSubview:self.contentLabel];
    [self addSubview:self.imageBoxView];
}

- (void)updateContent
{
    self.contentLabel.text = nil;
    self.contentLabel.attributedTruncationToken = nil;
    
    CGFloat fontSize = [WDListLayoutModel questionDescContentFontSize];
    CGFloat lineHeight = [WDListLayoutModel questionDescContentLineHeight];
    
    if (self.isFoldState) {
        NSMutableAttributedString *attributedString = nil;
        NSAttributedString *tokenString = nil;
        if (self.showType == DescTextAndImageFoldStateShowTypeThree) {
            attributedString = [WDLayoutHelper attributedStringWithString:[self descTextInFoldStateTextAndImage] fontSize:fontSize lineHeight:lineHeight];
            NSInteger length0 = [attributedString.string length];
            NSInteger length1 = [self descText].length;
            NSInteger length2 = length0 - length1;
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText14] range:NSMakeRange(0, length1)];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(length1, length2)];
            tokenString = [self tokenAttributeStringShort];
        }
        else if (self.showType == DescTextAndImageFoldStateShowTypeTwo) {
            attributedString = [WDLayoutHelper attributedStringWithString:[self descTextInFoldStateTextAndImage2] fontSize:fontSize lineHeight:lineHeight];
            NSInteger length0 = [attributedString.string length];
            NSInteger length1 = [self descText].length;
            NSInteger length2 = length0 - length1;
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText14] range:NSMakeRange(0, length1)];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(length1, length2)];
            tokenString = [self tokenAttributeString];
        }
        else {
            attributedString = [WDLayoutHelper attributedStringWithString:[self descText] fontSize:fontSize lineHeight:lineHeight];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText14] range:NSMakeRange(0, attributedString.string.length)];
            tokenString = [self tokenAttributeString];
        }
        self.contentLabel.attributedTruncationToken = tokenString;
        self.contentLabel.font = [UIFont systemFontOfSize:fontSize];
        self.contentLabel.attributedText = attributedString;
    }
    else {
        NSMutableAttributedString *attributedString = [WDLayoutHelper attributedStringWithString:[self descText] fontSize:fontSize lineHeight:lineHeight];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText14] range:NSMakeRange(0, attributedString.string.length)];
        self.contentLabel.attributedTruncationToken = [self tokenAttributeString];
        self.contentLabel.font = [UIFont systemFontOfSize:fontSize];
        self.contentLabel.attributedText = attributedString;
    }
    
    [self.imageBoxView refreshImageView];
}

#pragma mark - frame

- (void)updateFrame {
    if (self.isTextAndImage) {
        if (self.isFoldState) {
            if (self.showType == DescTextAndImageFoldStateShowTypeThree) {
               self.contentLabel.frame = [self frameForContentLabelInFoldStateTextAndImage];
            }
            else {
                self.contentLabel.frame = [self frameForContentLabel];
            }
            self.height = SSMaxY(self.contentLabel);
        }
        else {
            self.imageBoxView.hidden = NO;
            self.contentLabel.frame = [self frameForContentLabel];
            self.imageBoxView.frame = CGRectMake(kWDCellLeftPadding, SSMaxY(self.contentLabel) + WDPadding(10.0f), SSWidth(self) - kWDCellLeftPadding - kWDCellRightPadding, [self.imageBoxView viewHeight]);
            self.height = (SSMaxY(self.imageBoxView));
        }
    }
    else if (self.isOnlyImage) {
        self.imageBoxView.hidden = NO;
        self.imageBoxView.frame = CGRectMake(kWDCellLeftPadding, WDPadding(0), SSWidth(self) - kWDCellLeftPadding - kWDCellRightPadding, [self.imageBoxView viewHeight]);
        self.height = SSMaxY(self.imageBoxView);
    }
    else if (self.isOnlyText) {
        self.contentLabel.frame = [self frameForContentLabel];
        self.height = SSMaxY(self.contentLabel);
    }
    else {
        self.height = 0;
    }
}

// 仅图文折叠状态使用 (仅适用type == 3)
- (CGRect)frameForContentLabelInFoldStateTextAndImage {
    
    CGFloat lineHeight = [WDListLayoutModel questionDescContentLineHeight];
    return CGRectMake(kWDCellLeftPadding, 0, self.cacheLabelWidth, lineHeight);
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

- (CGFloat)widthForShortTokenString {
    CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:[self tokenAttributeStringShort]
                                                   withConstraints:CGSizeMake(SSWidth(self)  - kWDCellLeftPadding - kWDCellRightPadding, 0.0f)
                                            limitedToNumberOfLines:0];
    return ceilf(size.width);
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

// 仅图文折叠状态使用 (仅适用type == 3)
- (NSString *)descTextInFoldStateTextAndImage {
    NSString *questionAbstrct = self.entity.content.text;
    NSString *blankString = [NSString stringWithFormat:@"%@ %@",ask_list_descr_img,@"展开描述"];
    questionAbstrct = [NSString stringWithFormat:@"%@%@", questionAbstrct, blankString];
    return questionAbstrct;
}

// 仅图文折叠状态使用 (仅适用type == 2)
- (NSString *)descTextInFoldStateTextAndImage2 {
    NSString *questionAbstrct = self.entity.content.text;
    NSString *blankString = [NSString stringWithFormat:@"... %@ %@",ask_list_descr_img,@"展开描述"];
    questionAbstrct = [NSString stringWithFormat:@"%@%@", questionAbstrct, blankString];
    return questionAbstrct;
}

- (WDQuestionEntity *)entity
{
    return self.viewModel.questionEntity;
}

// 仅图文折叠状态使用 (仅适用type == 3)
- (NSAttributedString *)tokenAttributeStringShort {
    CGFloat fontSize = [WDListLayoutModel questionDescContentFontSize];
    NSString *imgString = [NSString stringWithFormat:@"%@",ask_list_descr_img];
    NSMutableAttributedString *imgToken = [[NSMutableAttributedString alloc] initWithString:imgString
                                                                                 attributes:@{NSBaselineOffsetAttributeName : @(-1),
                                                                                              NSFontAttributeName : [UIFont fontWithName:wd_iconfont size:fontSize + 2],
                                                                                              NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5]}
                                           ];
    NSString *foldString = @"展开描述";
    NSMutableAttributedString *foldToken = [[NSMutableAttributedString alloc] initWithString:foldString
                                                                                  attributes:@{
                                                                                               NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                                                                                               NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5]}
                                            ];
    [imgToken appendAttributedString:foldToken];
    return imgToken;
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
    NSString *imgString = [NSString stringWithFormat:@"%@",ask_list_descr_img];
    NSMutableAttributedString *imgToken = [[NSMutableAttributedString alloc] initWithString:imgString
                                                                                 attributes:@{NSBaselineOffsetAttributeName : @(-1),
                                                                                              NSFontAttributeName : [UIFont fontWithName:wd_iconfont size:fontSize + 2],
                                                                                              NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5]}
                                           ];
    NSString *foldString = @"展开描述";
    NSMutableAttributedString *foldToken = [[NSMutableAttributedString alloc] initWithString:foldString
                                                                                  attributes:@{
                                                                                               NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                                                                                               NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5]}
                                            ];
    // text & image
    if (_isTextAndImage) {
        [token appendAttributedString:imgToken];
    }
    [token appendAttributedString:foldToken];
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
