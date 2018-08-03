//
//  WDListQuestionHeaderTitleView.m
//  Article
//
//  Created by 延晋 张 on 16/8/21.
//
//

#import "WDListQuestionHeaderTitleView.h"
#import "WDListViewModel.h"
#import "WDQuestionEntity.h"
#import "WDUIHelper.h"
#import "WDLayoutHelper.h"
#import "NSObject+FBKVOController.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"

CGFloat const kHeaderTitleLabelPadding = 80.0f;

@interface WDListQuestionHeaderTitleView ()

@property (nonatomic, strong) WDListViewModel *viewModel;

@property (nonatomic, strong) SSThemedLabel *titleLabel;

@end

@implementation WDListQuestionHeaderTitleView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(WDListViewModel *)viewModel
{
    if (self = [super initWithFrame:frame]) {
        _viewModel = viewModel;
        
        self.backgroundColorThemeKey = kColorBackground4;

        [self addSubview:self.titleLabel];
        
        
        WeakSelf;
        [self.KVOController observe:self.viewModel.questionEntity keyPath:@"followCount" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            [self updateContent];
            [self updateFrame];
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

#pragma mark - update

- (void)fontChanged
{
    [self updateContent];
    [self updateFrame];
}

- (void)updateContent
{
    if (isEmptyString(self.entity.title)) {
        return;
    }

    CGFloat fontSize = WDFontSize(19.0f);
    self.titleLabel.text = self.entity.title;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
}

#pragma mark - frame

- (void)updateFrame
{
    if (isEmptyString(self.entity.title)) {
        return;
    }
    
    self.titleLabel.frame = [self frameForTitleLabel];
    self.height = SSMaxY(self.titleLabel);
}

- (CGRect)frameForTitleLabel
{
    return CGRectMake(kWDCellLeftPadding, 0, SSWidth(self) - kWDCellLeftPadding - kWDCellRightPadding, [self heightForTitleLabel]);
}

- (CGFloat)heightForTitleLabel
{
    CGFloat fontSize = WDFontSize(19.0f);
    CGFloat lineHeight = WDFontSize(19.0f) * 1.4;
    CGFloat height = [WDLayoutHelper heightOfText:self.entity.title
                                       fontSize:fontSize
                                     isBoldFont:YES
                                      lineWidth:SSWidth(self) - kWDCellLeftPadding - kWDCellRightPadding
                                     lineHeight:lineHeight
                               maxNumberOfLines:0];
    return height;
}

#pragma mark - getter

- (WDQuestionEntity *)entity
{
    return self.viewModel.questionEntity;
}

- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColorThemeKey = kColorBackground4;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.font = [UIFont boldSystemFontOfSize:WDFontSize(19.0f)];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _titleLabel;
}

@end
