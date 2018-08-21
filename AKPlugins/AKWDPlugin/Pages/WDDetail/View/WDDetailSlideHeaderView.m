//
//  WDDetailSlideHeaderView.m
//  Article
//
//  Created by wangqi.kaisa on 2017/5/24.
//
//

#import "WDDetailSlideHeaderView.h"
#import "WDAnswerEntity.h"
#import "WDDetailModel.h"
#import "WDUIHelper.h"
#import "WDLayoutHelper.h"
#import "TTAlphaThemedButton.h"
#import "NSObject+FBKVOController.h"
#import "TTRoute.h"
#import "TTImageView.h"

@interface WDDetailSlideHeaderView ()

@property (nonatomic, strong) SSThemedView *bgView;
@property (nonatomic, strong) SSThemedLabel *questionContentLabel;
@property (nonatomic, strong) TTAlphaThemedButton *transparentButton;
@property (nonatomic, strong) TTAlphaThemedButton *checkAnswerButton;
@property (nonatomic, strong) TTAlphaThemedButton *writeAnswerButton;
@property (nonatomic, strong) TTAlphaThemedButton *middleAnswerButton;
@property (nonatomic, strong) SSThemedImageView *iconImageView;
@property (nonatomic, strong) WDDetailModel *initialDetailModel;
@property (nonatomic, strong) WDDetailModel *currentDetailModel;

@end

@implementation WDDetailSlideHeaderView

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
        [self reloadThemeUI];
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
    self.questionContentLabel.text = self.initialDetailModel.answerEntity.questionTitle;
    NSString *checkAnswerTitle = self.initialDetailModel.allAnswerText;
    checkAnswerTitle = [checkAnswerTitle stringByReplacingOccurrencesOfString:@"全部" withString:@"查看"];
    [self.checkAnswerButton setTitle:checkAnswerTitle forState:UIControlStateNormal];
    [self.writeAnswerButton setTitle:@"回答" forState:UIControlStateNormal];
    self.writeAnswerButton.imageName = @"write_small_ask_details.png";
    [self.questionContentLabel sizeToFit];
    [self.checkAnswerButton sizeToFit];
    if (self.initialDetailModel.showPostAnswer) {
        [self.middleAnswerButton setTitle:self.initialDetailModel.postAnswerText forState:UIControlStateNormal];
        self.middleAnswerButton.imageName = @"write_small_ask_details.png";
    }
}

- (void)updateFrame {
    self.transparentButton.frame = self.bounds;
    self.questionContentLabel.frame = [self frameForContentLabel];
    self.checkAnswerButton.origin = CGPointMake(kWDCellLeftPadding, SSMaxY(self.questionContentLabel) + WDPadding(12));
    self.checkAnswerButton.height = 20;
    self.writeAnswerButton.origin = CGPointMake((SSWidth(self) - kWDCellRightPadding - self.writeAnswerButton.width + 2), SSMaxY(self.questionContentLabel) + WDPadding(12));
    self.writeAnswerButton.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 0);
    self.writeAnswerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 0);
    if (self.initialDetailModel.showPostAnswer) {
        self.middleAnswerButton.width = 131;
        self.middleAnswerButton.height = 28;
        self.middleAnswerButton.centerX = SSWidth(self) /2.0;
        self.middleAnswerButton.top = SSMaxY(self.questionContentLabel) + WDPadding(14);
        self.middleAnswerButton.imageEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 0);
        self.middleAnswerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    }
    self.middleAnswerButton.hidden = !self.initialDetailModel.showPostAnswer;
    self.checkAnswerButton.hidden = self.initialDetailModel.showPostAnswer;
    self.writeAnswerButton.hidden = self.initialDetailModel.showPostAnswer;
    CGFloat baseY = self.initialDetailModel.showPostAnswer ? SSMaxY(self.middleAnswerButton) : SSMaxY(self.checkAnswerButton);
    self.height = baseY + WDPadding(15);
    self.bgView.frame = self.bounds;
}

- (CGRect)frameForContentLabel {
    CGFloat naviHeight = 0;
    return CGRectMake(kWDCellLeftPadding, naviHeight, SSWidth(self) - kWDCellLeftPadding - kWDCellRightPadding, [self heightForContentLabel]);
}

- (CGFloat)heightForContentLabel {
    CGFloat height = [WDLayoutHelper heightOfText:self.initialDetailModel.answerEntity.questionTitle
                                       fontSize:WDFontSize(22.0f)
                                     isBoldFont:YES
                                      lineWidth:SSWidth(self) - kWDCellLeftPadding - kWDCellRightPadding
                                     lineHeight:WDFontSize(22.0f) * 1.4
                               maxNumberOfLines:0];
    return height;
}

- (void)allAnswerButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wdDetailSlideHeaderViewShowAllAnswers)]) {
        [self.delegate wdDetailSlideHeaderViewShowAllAnswers];
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

- (void)themeChanged:(NSNotification *)notification {
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        self.backgroundColor = [UIColor clearColor];
        self.bgView.backgroundColor = [UIColor colorWithHexString:@"#67778B"];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
        self.bgView.backgroundColor = [UIColor colorWithHexString:@"#333B45"];
    }
}

#pragma mark - getter

- (SSThemedView *)bgView {
    if (!_bgView) {
        _bgView = [[SSThemedView alloc] initWithFrame:self.bounds];
        _bgView.backgroundColor = [UIColor clearColor];
    }
    return _bgView;
}

- (SSThemedImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[SSThemedImageView alloc] init];
        _iconImageView.imageName = @"bg_list_ask";
        _iconImageView.frame = CGRectMake(0, 0, 68, 72);
    }
    return _iconImageView;
}

- (SSThemedLabel *)questionContentLabel {
    if (!_questionContentLabel) {
        CGFloat naviHeight = 0;
        _questionContentLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _questionContentLabel.top = naviHeight;
        _questionContentLabel.textColorThemeKey = kColorText10;
        _questionContentLabel.backgroundColor = [UIColor clearColor];
        _questionContentLabel.numberOfLines = 0;
        _questionContentLabel.font = [UIFont boldSystemFontOfSize:WDFontSize(22.0f)];
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
        _checkAnswerButton.frame = CGRectMake(kWDCellLeftPadding, SSMaxY(self.questionContentLabel) + WDPadding(15), 70, 20);
        _checkAnswerButton.titleLabel.font = [UIFont systemFontOfSize:WDConstraintFontSize(12)];
        _checkAnswerButton.titleColorThemeKey = kColorText10;
        [_checkAnswerButton addTarget:self action:@selector(allAnswerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkAnswerButton;
}

- (TTAlphaThemedButton *)writeAnswerButton {
    if (!_writeAnswerButton) {
        _writeAnswerButton = [[TTAlphaThemedButton alloc] init];
        _writeAnswerButton.frame = CGRectMake(0, SSMaxY(self.questionContentLabel) + WDPadding(15), 45, 20);
        _writeAnswerButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _writeAnswerButton.titleColorThemeKey = kColorText10;
        [_writeAnswerButton addTarget:self action:@selector(writeAnswerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _writeAnswerButton;
}

- (TTAlphaThemedButton *)middleAnswerButton {
    if (!_middleAnswerButton) {
        _middleAnswerButton = [[TTAlphaThemedButton alloc] init];
        _middleAnswerButton.frame = CGRectMake(0, SSMaxY(self.questionContentLabel) + WDPadding(15), 131, 28);
        _middleAnswerButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _middleAnswerButton.titleColorThemeKey = kColorText10;
        _middleAnswerButton.borderColorThemeKey = kColorLine11;
        _middleAnswerButton.layer.borderWidth = 0.5;
        _middleAnswerButton.layer.cornerRadius = 4.0;
        [_middleAnswerButton addTarget:self action:@selector(goodAnswerWriteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _middleAnswerButton;
}

- (CGFloat)titleHeight {
    return SSMaxY(self.questionContentLabel);
}

@end
