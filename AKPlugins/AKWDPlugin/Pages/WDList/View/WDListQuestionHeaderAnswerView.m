//
//  WDListQuestionHeaderAnswerView.m
//  Article
//
//  Created by xuzichao on 16/8/21.
//
//

#import "WDListQuestionHeaderAnswerView.h"
#import "WDListLayoutModel.h"
#import "WDListViewModel.h"
#import "WDQuestionEntity.h"
#import "WDUIHelper.h"
#import "NSObject+FBKVOController.h"
#import "TTDeviceHelper.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"

CGFloat const WDListQuestionHeaderAnswerViewHeight = 44.0f;

@interface WDListQuestionHeaderAnswerView ()

@property (nonatomic, strong) WDListViewModel *viewModel;

// A方案
@property (nonatomic, strong) SSThemedLabel *followAnswerLabel;
// B方案
@property (nonatomic, strong) SSThemedLabel *answerCountLabel;
@property (nonatomic, strong) SSThemedLabel *middleDotLabel;
@property (nonatomic, strong) SSThemedLabel *followCountLabel;

@end

@implementation WDListQuestionHeaderAnswerView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(WDListViewModel *)viewModel
{
    if (self = [super initWithFrame:frame]) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _viewModel = viewModel;
        
        self.backgroundColorThemeKey = kColorBackground4;
        self.clipsToBounds = YES;
        
        [self addAllSubviews];
        
        [self.KVOController observe:self.viewModel.questionEntity keyPaths: @[NSStringFromSelector(@selector(normalAnsCount)), NSStringFromSelector(@selector(niceAnsCount)), NSStringFromSelector(@selector(followCount))] options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            WDListQuestionHeaderAnswerView *answerView = observer;
            [answerView updateContent];
            [answerView updateFrame];
        }];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [self updateContent];
}

- (void)reload
{
    [self updateContent];
    [self updateFrame];
}

- (void)addAllSubviews {
    [self addSubview:self.followAnswerLabel];
    self.followAnswerLabel.hidden = YES;
}

#pragma mark - update

- (void)fontChanged
{
    [self updateContent];
    [self updateFrame];
}

- (void)updateContent {
    NSString *answerStr = @"暂无回答";
    NSNumber *answerCount = self.viewModel.questionEntity.allAnsCount;
    if (answerCount.integerValue > 0) {
        answerStr = [NSString stringWithFormat:@"%@个回答",[TTBusinessManager formatCommentCount:answerCount.longLongValue]];
    }
    
    NSString *followStr = @"暂无收藏";
    NSNumber *followCount = self.viewModel.questionEntity.followCount;
    if (followCount.integerValue > 0) {
        followStr = [NSString stringWithFormat:@"%@人收藏",[TTBusinessManager formatCommentCount:followCount.longLongValue]];
    }
    
    NSString *followAnswerStr = [NSString stringWithFormat:@"%@ · %@",answerStr,followStr];
    
    self.followAnswerLabel.font = [UIFont systemFontOfSize:[WDListLayoutModel questionFollowCountFontSize]];
    self.followAnswerLabel.text = followAnswerStr;
    [self.followAnswerLabel sizeToFit];
}

- (void)updateFrame {
    self.followAnswerLabel.hidden = NO;
    
    CGRect frame = self.frame;
    frame.size.height = WDPadding(WDListQuestionHeaderAnswerViewHeight);
    self.frame = frame;
    
    CGFloat maxWidth = self.width;
    CGSize size = self.followAnswerLabel.size;
    self.followAnswerLabel.width = MIN(maxWidth, ceilf(size.width));
    self.followAnswerLabel.height = ceilf(size.height);
    self.followAnswerLabel.left = 0;
    self.followAnswerLabel.top = self.height/2 - self.followAnswerLabel.height/2;
}

#pragma mark - getter

- (SSThemedLabel *)followAnswerLabel
{
    if (!_followAnswerLabel) {
        _followAnswerLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _followAnswerLabel.backgroundColorThemeKey = kColorBackground4;
        _followAnswerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _followAnswerLabel.textColorThemeKey = kColorText14;
    }
    return _followAnswerLabel;
}

- (SSThemedLabel *)followCountLabel {
    if (!_followCountLabel) {
        _followCountLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _followCountLabel.backgroundColorThemeKey = kColorBackground4;
        _followCountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _followCountLabel.textColorThemeKey = kColorText14;
    }
    return _followCountLabel;
}

- (SSThemedLabel *)answerCountLabel {
    if (!_answerCountLabel) {
        _answerCountLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _answerCountLabel.backgroundColorThemeKey = kColorBackground4;
        _answerCountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _answerCountLabel.textColorThemeKey = kColorText14;
    }
    return _answerCountLabel;
}

- (SSThemedLabel *)middleDotLabel {
    if (!_middleDotLabel) {
        _middleDotLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _middleDotLabel.backgroundColorThemeKey = kColorBackground4;
        _middleDotLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _middleDotLabel.textColorThemeKey = kColorText14;
    }
    return _middleDotLabel;
}

@end
