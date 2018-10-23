//
//  WDNewDetailHeaderView.m
//  wenda
//
//  Created by 延晋 张 on 2017/6/27.
//  Copyright © 2017年 Bytedance Inc. All rights reserved.
//

#import "WDNewDetailHeaderView.h"
#import "WDDetailModel.h"
#import "WDUIHelper.h"
#import "WDFontDefines.h"
#import "SSThemed.h"

#import <TTRoute/TTRoute.h>
#import <TTBaseLib/NSString-Extension.h>
#import "WDAnswerEntity.h"
#import <KVOController/NSObject+FBKVOController.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>

static CGFloat WDNewDetailHeaderViewLeftMargin = 10.0f;
static CGFloat WDDetailCardViewTopMargin = 4.0f;
static CGFloat WDDetailTitleLabelTopMargin = 12.0f;

#define WDDetailTitleFontSize WDFontSize(22.0f)
#define WDDetailTitleLineHeight WDPadding(28.0f)

#define DetailTitleFont [UIFont boldSystemFontOfSize:WDDetailTitleFontSize]

@interface WDNewDetailHeaderView ()

@property (nonatomic, weak) WDDetailModel *detailModel;
@property (nonatomic, strong) UIButton *bgButton;

@property (nonatomic, strong) SSThemedView *cardView;

@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *answerCountLabel;

@property (nonatomic, strong) UIButton *answerButton;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, assign) BOOL hasAppear;

@end

@implementation WDNewDetailHeaderView
@synthesize delegate;

- (instancetype)initWithFrame:(CGRect)frame
                  detailModel:(WDDetailModel *)detailModel
{
    if (self = [super initWithFrame:frame]) {
        _detailModel = detailModel;
        self.backgroundColorThemeKey = kColorBackground4;
        
        [self addSubview:self.bgButton];
        [self addSubview:self.cardView];
        [self.cardView addSubview:self.titleLabel];
        [self.cardView addSubview:self.answerCountLabel];
        [self.cardView addSubview:self.answerButton];
        
        [self layoutViews];
    }
    return self;
}

- (void)layoutViews
{
    self.titleLabel.height = [self titleHeight];
    self.answerCountLabel.top = SSMaxY(self.titleLabel) + 10.5;
    self.answerButton.top = SSMaxY(self.titleLabel) + 11.0f;
    
    self.cardView.height = self.answerCountLabel.bottom + 13.5;
    self.height = self.cardView.bottom + 10.0f;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self.cardView) {
        return self.bgButton;
    }
    return view;
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    self.hasAppear = YES;
}

#pragma mark - Publick

- (void)addHeaderKVO
{
    [self.KVOController observe:self keyPath:NSStringFromSelector(@selector(frame)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        WDNewDetailHeaderView *headerView = observer;
        if (headerView.hasAppear) {
            [headerView detectAnswerButtonIsShow];

            CGRect newFrame = [change[NSKeyValueChangeNewKey] CGRectValue];
            CGRect oldFrame = [change[NSKeyValueChangeOldKey] CGRectValue];
            if (newFrame.origin.y != oldFrame.origin.y) {
            }
        }
    }];
}

- (void)detectAnswerButtonIsShow
{
//    if (self.hasAppear) {
//        UIButton *answerButton = self.answerButton;
//        CGRect answerFrame = [self convertRect:answerButton.frame toView:nil];
//        CGFloat y = CGRectGetMaxY(answerFrame);
//        CGFloat yOffset = self.tt_safeAreaInsets.top + TTNavigationBarHeight;
//        if (y >= yOffset) {
//            if ([self.delegate respondsToSelector:@selector(headerViewAnswerButtonHasShown:)]) {
//                [self.delegate headerViewAnswerButtonHasShown:self];
//            }
//        } else {
//            if ([self.delegate respondsToSelector:@selector(headerViewAnswerButtonHasHidden:)]){
//                [self.delegate headerViewAnswerButtonHasHidden:self];
//            }
//        }
//    }
   
}

#pragma mark - Actions

- (void)answerButtonClicked:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(headerView:answerButtonDidTap:)]) {
        [self.delegate headerView:self answerButtonDidTap:button];
    }
}

- (void)bgButtonClicked:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(headerView:bgButtonDidTap:)]) {
        [self.delegate headerView:self bgButtonDidTap:button];
    }
}

#pragma mark - Util

+ (CGFloat)heightForTitle:(NSString *)title width:(CGFloat)width
{
    width = floorf(width);
    CGFloat height = [title tt_sizeWithMaxWidth:width font:[UIFont boldSystemFontOfSize:WDDetailTitleFontSize] lineHeight:WDDetailTitleLineHeight numberOfLines:2].height;
    height = ceil(height + (WDDetailTitleLineHeight - ceil([UIFont boldSystemFontOfSize:WDDetailTitleFontSize].pointSize)));
    return ceilf(height);
}

#pragma mark - Getter

- (CGFloat)titleHeight
{
    if (isEmptyString([self title])) {
        return 0.0f;
    } else if (self.lineHeight == 0.0f){
        self.lineHeight = [[self class] heightForTitle:self.title width:SSWidth(self.titleLabel)];
    }
    return self.lineHeight;
}

- (NSMutableAttributedString *)titleString
{
    NSDictionary *attributesLogo = @{NSFontAttributeName : [UIFont fontWithName:wd_iconfont size:13],
                                 NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1]};
    NSMutableAttributedString *iconStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", ask_detail_write_small] attributes:attributesLogo];
    
    NSDictionary *attributeText = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:13],
                                    NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1]};
    NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithString:@"回答" attributes:attributeText];
    
    [iconStr appendAttributedString:titleStr];
    return iconStr;
}

- (NSMutableAttributedString *)answerCountTextWithCount:(NSNumber *)answerCount
{
    if (answerCount == nil) {
        answerCount = @(0); //避免由于String Format显示成null
    }
    NSString *answerCountText = [NSString stringWithFormat:@"查看%@个回答", answerCount];
    NSDictionary *attributeText = @{NSFontAttributeName : [UIFont systemFontOfSize:13],
                                    NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText3]};
    NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithString:answerCountText attributes:attributeText];
    
    NSDictionary *attributesLogo = @{NSFontAttributeName : [UIFont fontWithName:wd_iconfont size:13],
                                     NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText3]};
    NSMutableAttributedString *iconStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", ask_arrow_right] attributes:attributesLogo];
    
    [titleStr appendAttributedString:iconStr];
    return titleStr;
}

- (NSString *)title
{
    return self.detailModel.answerEntity.questionTitle;
}

- (SSThemedView *)cardView
{
    if (!_cardView) {
        _cardView = [[SSThemedView alloc] initWithFrame:CGRectMake(WDNewDetailHeaderViewLeftMargin, WDDetailCardViewTopMargin, SSWidth(self) - 2*WDNewDetailHeaderViewLeftMargin, 0.0f)];
        _cardView.backgroundColorThemeKey = kColorBackground4;
        _cardView.layer.shadowColor = [UIColor blackColor].CGColor;
        _cardView.layer.shadowOffset = CGSizeMake(0, 0);
        _cardView.layer.shadowOpacity = 0.08;
        _cardView.layer.shadowRadius = 15.f;
    }
    return _cardView;
}

- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(WDNewDetailHeaderViewLeftMargin, WDDetailTitleLabelTopMargin, SSWidth(self.cardView) - 2*WDNewDetailHeaderViewLeftMargin, 0.0f)];
        _titleLabel.font = [UIFont boldSystemFontOfSize:WDDetailTitleFontSize];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 0;
        if (isEmptyString([self title])) {
            [_titleLabel.KVOController observe:self.detailModel.answerEntity keyPath:NSStringFromSelector(@selector(questionTitle)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                UILabel *label = observer;
                label.attributedText = [[self title] tt_attributedStringWithFont:[UIFont boldSystemFontOfSize:WDDetailTitleFontSize] lineHeight:WDDetailTitleLineHeight];
                [self layoutViews];
            }];
        } else {
            _titleLabel.attributedText = [[self title] tt_attributedStringWithFont:[UIFont boldSystemFontOfSize:WDDetailTitleFontSize] lineHeight:WDDetailTitleLineHeight];
        }
    }
    return _titleLabel;
}

- (SSThemedLabel *)answerCountLabel
{
    if (!_answerCountLabel) {
        _answerCountLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _answerCountLabel.font = [UIFont systemFontOfSize:13.0f];
        NSNumber *answerCount = self.detailModel.answerEntity.ansCount;
        _answerCountLabel.attributedText = [self answerCountTextWithCount:answerCount];
        [_answerCountLabel sizeToFit];
        _answerCountLabel.frame = CGRectMake(SSWidth(self.cardView) - WDNewDetailHeaderViewLeftMargin - SSWidth(_answerCountLabel), WDNewDetailHeaderViewLeftMargin, SSWidth(_answerCountLabel), SSHeight(_answerCountLabel));
        WeakSelf;
        [_answerCountLabel.KVOController observe:self.detailModel.answerEntity keyPath:NSStringFromSelector(@selector(ansCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            UILabel *label = observer;
            WDAnswerEntity *entity = object;
            NSNumber *answerCount = entity.ansCount;
            label.attributedText = [self answerCountTextWithCount:answerCount];
            [label sizeToFit];
            label.left = SSWidth(self.cardView) - WDNewDetailHeaderViewLeftMargin - SSWidth(label);
        }];
    }
    return _answerCountLabel;
}

- (UIButton *)answerButton
{
    if (!_answerButton) {
        
        _answerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_answerButton setTitleColor:[UIColor tt_themedColorForKey:kColorText2] forState:UIControlStateNormal];
        _answerButton.width = 45.0f;
        _answerButton.height = 16.0f;
        _answerButton.left = WDNewDetailHeaderViewLeftMargin;
        _answerButton.top = SSMaxY(self.titleLabel) + 8.0f;
        _answerButton.titleLabel.font = [UIFont fontWithName:wd_iconfont size:14];
        [_answerButton setAttributedTitle:[self titleString] forState:UIControlStateNormal];
        [_answerButton addTarget:self action:@selector(answerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _answerButton;
}

- (UIButton *)bgButton
{
    if (!_bgButton) {
        _bgButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _bgButton.frame = self.bounds;
        _bgButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_bgButton addTarget:self action:@selector(bgButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgButton;
}

@end
