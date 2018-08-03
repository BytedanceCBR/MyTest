//
//  WDPrimaryQuestionTipsView.m
//  Article
//
//  Created by 延晋 张 on 2017/7/27.
//
//

#import "WDPrimaryQuestionTipsView.h"
#import "WDListViewModel.h"

#import "WDUIHelper.h"
#import "WDLayoutHelper.h"
#import <KVOController/NSObject+FBKVOController.h>
#import <TTRoute/TTRoute.h>

@interface WDPrimaryQuestionTipsView ()

@property (nonatomic, strong) WDListViewModel *viewModel;

@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedView *bottomLine;

@end

@implementation WDPrimaryQuestionTipsView

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(WDListViewModel *)viewModel
{
    if (self = [super initWithFrame:frame]) {
        _viewModel = viewModel;
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.bottomLine];
        
        [self refreshContentWithTitle:self.viewModel.relatedQuestionTitle];
        
        [self.KVOController observe:self.viewModel keyPath:NSStringFromSelector(@selector(relatedQuestionTitle)) options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            NSString *newTitle = [change tt_stringValueForKey:NSKeyValueChangeNewKey];
            NSString *oldTitle = [change tt_stringValueForKey:NSKeyValueChangeOldKey];
            if (![newTitle isEqualToString:oldTitle]) {
                WDPrimaryQuestionTipsView *tipsView = observer;
                [tipsView refreshContentWithTitle:newTitle];
            }
        }];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(primaryTaped:)];
        [self addGestureRecognizer:gesture];
    }
    return self;
}

- (void)reload
{
    self.titleLabel.frame = [self frameForTitleLabel];
}

- (void)refreshContentWithTitle:(NSString *)title
{
    NSString *digText = [NSString stringWithFormat:@"原问题：%@", title];
    NSMutableDictionary *attributedTextInfo = [NSMutableDictionary dictionary];
    [attributedTextInfo setValue:digText forKey:kSSThemedLabelText];
    [attributedTextInfo setValue:kColorText3 forKey:NSStringFromRange(NSMakeRange(0, 4))];
    [attributedTextInfo setValue:kColorText5 forKey:NSStringFromRange(NSMakeRange(4, title.length))];
    self.titleLabel.attributedTextInfo = [attributedTextInfo copy];
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

#pragma mark - Frame

- (CGRect)frameForTitleLabel
{
    CGFloat avaibleWidth = self.width  - 2 * kWDCellLeftPadding;
    return CGRectMake(kWDCellLeftPadding, 0.0f, avaibleWidth, SSHeight(self));
}

#pragma mark - Getter

- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:[self frameForTitleLabel]];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.font = WDFont(14.0f);
    }
    return _titleLabel;
}

- (SSThemedView *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [[SSThemedView alloc] initWithFrame:CGRectMake(0.0f, SSHeight(self) - [TTDeviceHelper ssOnePixel], SSWidth(self), [TTDeviceHelper ssOnePixel])];
        _bottomLine.backgroundColorThemeKey = kColorLine1;
        _bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _bottomLine;
}

@end
