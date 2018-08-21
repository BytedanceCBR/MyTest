//
//  WDDetailSlideWhiteHeaderView.m
//  Article
//
//  Created by wangqi.kaisa on 2017/8/2.
//
//

#import "WDDetailSlideWhiteHeaderView.h"
#import "TTAlphaThemedButton.h"
#import "WDUIHelper.h"
#import "WDLayoutHelper.h"
#import "NSObject+FBKVOController.h"
#import "WDAnswerEntity.h"
#import "WDDetailModel.h"
#import "TTRoute.h"
#import "TTTAttributedLabel.h"
#import "TTImageView.h"

@interface WDDetailSlideWhiteHeaderView ()

@property (nonatomic, strong) SSThemedView *bgView;
@property (nonatomic, strong) TTTAttributedLabel *questionContentLabel;
@property (nonatomic, strong) TTAlphaThemedButton *transparentButton;
@property (nonatomic, strong) TTAlphaThemedButton *checkAnswerButton;
@property (nonatomic, strong) TTAlphaThemedButton *writeAnswerButton;
@property (nonatomic, strong) TTAlphaThemedButton *middleAnswerButton;
@property (nonatomic, strong) SSThemedImageView *iconImageView;
@property (nonatomic, strong) SSThemedView *singleLineView;
@property (nonatomic, strong) SSThemedView *bottomSeparateView;
@property (nonatomic, strong) WDDetailModel *initialDetailModel;
@property (nonatomic, strong) WDDetailModel *currentDetailModel;

@end

@implementation WDDetailSlideWhiteHeaderView

- (instancetype)initWithFrame:(CGRect)frame detailModel:(WDDetailModel *)detailModel {
    if (self = [super initWithFrame:frame]) {
        
        self.initialDetailModel = detailModel;
        self.currentDetailModel = detailModel;
        [self addSubview:self.bgView];
        [self addSubview:self.iconImageView];
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

- (void)updateCurrentDetailModel:(WDDetailModel *)detailModel {
    self.currentDetailModel = detailModel;
}

- (void)reloadView {
    [self updateContent];
    [self updateFrame];
}

- (void)addKVO {
    WeakSelf;
    [self.KVOController observe:self.initialDetailModel keyPath:@"allAnswerText" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        [self reloadView];
    }];
}

- (void)updateContent {
    [self updateQuestionTitleContent];
    NSString *checkAnswerTitle = self.initialDetailModel.allAnswerText;
    checkAnswerTitle = [checkAnswerTitle stringByReplacingOccurrencesOfString:@"全部" withString:@""];
    [self.checkAnswerButton setTitle:checkAnswerTitle forState:UIControlStateNormal];
    if (self.initialDetailModel.showPostAnswer) {
        [self.middleAnswerButton setTitle:self.initialDetailModel.postAnswerText forState:UIControlStateNormal];
        self.middleAnswerButton.imageName = @"write_details_ask_blue";
        self.checkAnswerButton.imageName = nil;
    }
    else {
        [self.writeAnswerButton setTitle:@"回答" forState:UIControlStateNormal];
        self.writeAnswerButton.imageName = @"write_details_ask";
        self.checkAnswerButton.imageName = @"all_card_arrow";
    }
}

- (void)updateQuestionTitleContent {
    CGFloat fontSize = 19.0;
    CGFloat lineHeight = 26.0;
    NSString *questionTitle = [NSString stringWithFormat:@"          %@",self.initialDetailModel.answerEntity.questionTitle];
    NSMutableAttributedString * attributedString = [WDLayoutHelper attributedStringWithString:questionTitle fontSize:fontSize isBoldFont:YES lineHeight:lineHeight];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText1] range:NSMakeRange(0, [attributedString.string length])];
    self.questionContentLabel.attributedText = attributedString;;
}

- (void)updateFrame {
    self.questionContentLabel.frame = [self frameForContentLabel];
    CGFloat bottomY = 0;
    if (!self.initialDetailModel.showPostAnswer) {
        self.writeAnswerButton.hidden = NO;
        self.middleAnswerButton.hidden = YES;
        self.bottomSeparateView.hidden = YES;
        [self.checkAnswerButton sizeToFit];
        self.writeAnswerButton.origin = CGPointMake(kWDCellLeftPadding, SSMaxY(self.questionContentLabel) + WDPadding(10));
        self.checkAnswerButton.origin = CGPointMake(self.writeAnswerButton.right + 30, SSMaxY(self.questionContentLabel) + WDPadding(10));
        self.checkAnswerButton.height = 20;
        CGFloat imageWidth = self.checkAnswerButton.imageView.bounds.size.width;
        CGFloat labelWidth = self.checkAnswerButton.titleLabel.bounds.size.width;
        self.checkAnswerButton.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+4, 0, -labelWidth);
        self.checkAnswerButton.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth-4, 0, imageWidth);
        self.checkAnswerButton.width = imageWidth + labelWidth + 4;
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
        self.singleLineView.top = self.checkAnswerButton.bottom + WDPadding(16);
        self.middleAnswerButton.centerX = SSWidth(self)/2.0;
        self.middleAnswerButton.top = SSMaxY(self.checkAnswerButton) + WDPadding(28);
        self.bottomSeparateView.top = self.middleAnswerButton.bottom + WDPadding(11);
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
    CGFloat fontSize = 19.0;
    CGFloat lineHeight = 26.0;
    NSString *questionTitle = [NSString stringWithFormat:@"          %@",self.initialDetailModel.answerEntity.questionTitle];
    
    NSDictionary *attribute = [WDLayoutHelper attributesWithFontSize:fontSize
                                                        isBoldFont:YES
                                                        lineHeight:lineHeight];
    NSAttributedString *attributedStr = [[NSAttributedString alloc] initWithString:questionTitle attributes:attribute];
    CGFloat height = [TTTAttributedLabel sizeThatFitsAttributedString:attributedStr
                                            withConstraints:CGSizeMake(SSWidth(self) - kWDCellLeftPadding - kWDCellRightPadding, 0.0f)
                                     limitedToNumberOfLines:0].height;
    
    return height;
}

- (void)allAnswerButtonTapped {
    if (_delegate && [_delegate respondsToSelector:@selector(wdDetailSlideHeaderViewShowAllAnswers)]) {
        [_delegate wdDetailSlideHeaderViewShowAllAnswers];
    }
}

- (void)writeAnswerButtonTapped {
    if (!isEmptyString(self.initialDetailModel.answerEntity.postAnswerSchema)) {
        NSString *schema = self.initialDetailModel.answerEntity.postAnswerSchema;
        schema = [schema stringByAppendingString:@"&source=answer_detail_write_answer"];
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:schema] userInfo:nil];
    }
    
    NSString *checkAnswerTitle = self.initialDetailModel.allAnswerText;
    checkAnswerTitle = [checkAnswerTitle stringByReplacingOccurrencesOfString:@"全部" withString:@""];
    checkAnswerTitle = [checkAnswerTitle stringByReplacingOccurrencesOfString:@"个回答" withString:@""];
    NSMutableDictionary * goDetailDict = [NSMutableDictionary dictionaryWithDictionary:self.currentDetailModel.gdExtJsonDict];
    [goDetailDict setValue:@"answer_detail_write_answer" forKey:@"tag"];
    [goDetailDict setValue:checkAnswerTitle forKey:@"t_ans_num"];
    [goDetailDict setValue:@"umeng" forKey:@"category"];
    [TTTrackerWrapper eventV3:@"answer_detail_write_answer" params:goDetailDict];
}

- (void)goodAnswerWriteButtonTapped {
    if (!isEmptyString(self.initialDetailModel.answerEntity.postAnswerSchema)) {
        NSString *schema = self.initialDetailModel.answerEntity.postAnswerSchema;
        schema = [schema stringByAppendingString:@"&source=answer_detail_top_write_answer"];
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:schema] userInfo:nil];
    }
    
    NSString *checkAnswerTitle = self.initialDetailModel.allAnswerText;
    checkAnswerTitle = [checkAnswerTitle stringByReplacingOccurrencesOfString:@"全部" withString:@""];
    checkAnswerTitle = [checkAnswerTitle stringByReplacingOccurrencesOfString:@"个回答" withString:@""];
    NSMutableDictionary * goDetailDict = [NSMutableDictionary dictionaryWithDictionary:self.currentDetailModel.gdExtJsonDict];
    [goDetailDict setValue:@"answer_detail_top_write_answer" forKey:@"tag"];
    [goDetailDict setValue:checkAnswerTitle forKey:@"t_ans_num"];
    [goDetailDict setValue:@"umeng" forKey:@"category"];
    [TTTrackerWrapper eventV3:@"answer_detail_top_write_answer" params:goDetailDict];
}

#pragma mark - notification

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    self.questionContentLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    [self updateQuestionTitleContent];
}

#pragma mark - getter

- (SSThemedView *)bgView {
    if (!_bgView) {
        _bgView = [[SSThemedView alloc] initWithFrame:self.bounds];
        _bgView.backgroundColorThemeKey = kColorBackground4;
    }
    return _bgView;
}

- (SSThemedImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[SSThemedImageView alloc] init];
        _iconImageView.imageName = @"ask_logo";
        _iconImageView.frame = CGRectMake(kWDCellLeftPadding, WDPadding(20), 36, 18);
    }
    return _iconImageView;
}

- (TTTAttributedLabel *)questionContentLabel {
    if (!_questionContentLabel) {
        CGFloat naviHeight = 0;
        _questionContentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _questionContentLabel.top = naviHeight;
        _questionContentLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        _questionContentLabel.backgroundColor = [UIColor clearColor];
        _questionContentLabel.numberOfLines = 0;
        _questionContentLabel.font = [UIFont boldSystemFontOfSize:19.0f];
        _questionContentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _questionContentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _questionContentLabel;
}

- (TTAlphaThemedButton *)transparentButton {
    if (!_transparentButton) {
        _transparentButton = [[TTAlphaThemedButton alloc] init];
        _transparentButton.backgroundColor = [UIColor clearColor];
        [_transparentButton addTarget:self action:@selector(allAnswerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _transparentButton;
}

- (TTAlphaThemedButton *)checkAnswerButton {
    if (!_checkAnswerButton) {
        _checkAnswerButton = [[TTAlphaThemedButton alloc] init];
        _checkAnswerButton.frame = CGRectMake(0, SSMaxY(self.questionContentLabel) + WDPadding(10), 0, 20); // 71, 59
        _checkAnswerButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _checkAnswerButton.titleColorThemeKey = kColorText1;
        [_checkAnswerButton addTarget:self action:@selector(allAnswerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkAnswerButton;
}

- (TTAlphaThemedButton *)writeAnswerButton {
    if (!_writeAnswerButton) {
        _writeAnswerButton = [[TTAlphaThemedButton alloc] init];
        _writeAnswerButton.frame = CGRectMake(0, SSMaxY(self.questionContentLabel) + WDPadding(10), 48, 20);
        _writeAnswerButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _writeAnswerButton.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0);
        _writeAnswerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
        _writeAnswerButton.titleColorThemeKey = kColorText1;
        [_writeAnswerButton addTarget:self action:@selector(writeAnswerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _writeAnswerButton;
}

- (TTAlphaThemedButton *)middleAnswerButton {
    if (!_middleAnswerButton) {
        _middleAnswerButton = [[TTAlphaThemedButton alloc] init];
        _middleAnswerButton.frame = CGRectMake(0, SSMaxY(self.checkAnswerButton) + WDPadding(32), 120, 22);
        _middleAnswerButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _middleAnswerButton.imageEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 0);
        _middleAnswerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        _middleAnswerButton.titleColorThemeKey = kColorText5;
        [_middleAnswerButton addTarget:self action:@selector(goodAnswerWriteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
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
