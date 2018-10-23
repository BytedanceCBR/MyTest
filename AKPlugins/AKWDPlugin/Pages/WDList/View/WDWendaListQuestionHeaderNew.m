//
//  WDWendaListQuestionHeaderNew.m
//  Pods
//
//  Created by wangqi.kaisa on 2017/9/14.
//
//

#import "WDWendaListQuestionHeaderNew.h"
//ViewModel
#import "WDListViewModel.h"
//Model
#import "WDQuestionEntity.h"
#import "WDQuestionDescEntity.h"
//View
#import "WDListQuestionHeaderRewardView.h"
#import "WDListQuestionHeaderTitleView.h"
#import "WDListQuestionHeaderDescViewNew.h"
#import "WDListQuestionHeaderTagView.h"
#import "WDListQuestionHeaderAnswerView.h"
#import "WDPrimaryQuestionTipsView.h"
#import "WDSecondaryQuestionTipsView.h"
//Util
#import "WDUIHelper.h"
#import "WDSettingHelper.h"
//Lib
#import <TTBaseLib/UIButton+TTAdditions.h>
#import <KVOController/NSObject+FBKVOController.h>

@interface WDWendaListQuestionHeaderNew ()

@property (nonatomic, strong) WDListViewModel *viewModel;
@property (nonatomic, strong) SSThemedView *containerView;
@property (nonatomic, strong) WDPrimaryQuestionTipsView *primaryView;
@property (nonatomic, strong) WDSecondaryQuestionTipsView *secondaryView;
@property (nonatomic, strong) WDListQuestionHeaderTagView *tagView;
@property (nonatomic, strong) WDListQuestionHeaderRewardView *rewardView;
@property (nonatomic, strong) WDListQuestionHeaderTitleView *titleView;
@property (nonatomic, strong) WDListQuestionHeaderDescViewNew *descView;
@property (nonatomic, strong) WDListQuestionHeaderAnswerView *answerCountView;

@end

@implementation WDWendaListQuestionHeaderNew

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(WDListViewModel *)viewModel
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.hidden = YES;
        self.clipsToBounds = YES;
        
        _viewModel = viewModel;
        self.backgroundColorThemeKey = kColorBackground3;
        
        [self.containerView addSubview:self.tagView];
        [self.containerView addSubview:self.rewardView];
        [self.containerView addSubview:self.titleView];
        [self.containerView addSubview:self.descView];
        [self.containerView addSubview:self.answerCountView];
        [self.containerView addSubview:self.primaryView];
        [self.containerView addSubview:self.secondaryView];
        [self addSubview:self.containerView];
        
        WeakSelf;
        [self.KVOController observe:self.descView keyPath:@"frame" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            CGRect newFrame = [change[@"new"] CGRectValue];
            CGRect oldFrame = [change[@"old"] CGRectValue];
            if (newFrame.size.height != oldFrame.size.height) {
                [self refreshLayout];
            }
        }];
    }
    return self;
}

#pragma mark - Public Methods

- (void)reload
{
    [self.answerCountView reload];
    
    switch (self.viewModel.questionRelatedStatus) {
        case WDQuestionRelatedStatusNormal:
            break;
        case WDQuestionRelatedStatusPrimary:
            [self.secondaryView reload];
            break;
        case WDQuestionRelatedStatusSecondary:
            [self.primaryView reload];
            break;
    }
    
    [self.titleView reload];
    [self.descView reload];
    [self.tagView reload];
    [self.rewardView reload];
}

- (void)refreshLayout
{
    if (SSHeight(self.titleView) == 0 ) {
        return;
    }
    
    //((问题重定向状态view&标签view)||红包悬赏view)&问题Title
    [self layoutQuestionHeaderViews];
    
    //问题描述
    self.descView.origin = CGPointMake(0, SSMaxY(self.titleView) + [self descPadding]);
    
    CGFloat originY = SSMaxY(self.descView);
    
    //涉及AB测的逻辑
    originY = [self layoutOldVersionViews:originY];
    
    //整体view高度逻辑
    self.containerView.height = originY;
    self.height = originY + 6.0f;
}

#pragma mark - Private Layout

- (void)layoutQuestionHeaderViews {
    if (self.viewModel.showRewardView) {
        [self layoutOnlyRewardView];
    }
    else {
        self.rewardView.hidden = YES;
        [self layoutQuestionHeaderWithStatus:self.viewModel.questionRelatedStatus];
    }
}

- (void)layoutQuestionHeaderWithStatus:(WDQuestionRelatedStatus)relatedStatus
{
    switch (relatedStatus) {
        case WDQuestionRelatedStatusNormal:{
            [self layNormalHeader];
        }
            break;
        case WDQuestionRelatedStatusPrimary:{
            [self laySecondaryHeader];
        }
            break;
        case WDQuestionRelatedStatusSecondary:{
            [self layPrimaryHeader];
        }
            break;
    }
}

- (void)layoutOnlyRewardView {
    self.primaryView.hidden = YES;
    self.secondaryView.hidden = YES;
    self.tagView.hidden = YES;
    self.rewardView.origin = CGPointMake(0, 0);
    self.titleView.origin = CGPointMake(0, SSMaxY(self.rewardView) + WDPadding(12));
}

- (void)layNormalHeader
{
    self.primaryView.hidden = YES;
    self.secondaryView.hidden = YES;
    
//    if ([TTDeviceHelper isPadDevice] || (!self.viewModel.canEditTags && !self.viewModel.hasTags)) {
        self.tagView.hidden = YES;
        self.titleView.origin = CGPointMake(0, WDPadding(12.0f));
//    }
//    else {
//        self.tagView.hidden = NO;
//        self.titleView.origin = CGPointMake(0, SSMaxY(self.tagView) + WDPadding(12));
//    }
}

- (void)layPrimaryHeader
{
    self.tagView.hidden = YES;
    self.secondaryView.hidden = YES;
    self.primaryView.origin = CGPointMake(0, 0);
    self.titleView.origin = CGPointMake(0, SSMaxY(self.primaryView) + WDPadding(10.0f));
}

- (void)laySecondaryHeader
{
    self.primaryView.hidden = YES;
    self.secondaryView.hidden = NO;
    
    self.secondaryView.origin = CGPointMake(15.0f, WDPadding(15.0f));
    
    if ([TTDeviceHelper isPadDevice] || (!self.viewModel.canEditTags && !self.viewModel.hasTags)) {
        self.tagView.hidden = YES;
        self.titleView.origin = CGPointMake(0, SSMaxY(self.secondaryView) + WDPadding(12.0f));
    } else {
        self.tagView.hidden = NO;
        self.tagView.origin = CGPointMake(kWDCellLeftPadding, SSMaxY(self.secondaryView) + WDPadding(15.0f));
        self.titleView.origin = CGPointMake(0, SSMaxY(self.tagView) + WDPadding(12));
    }
}

- (CGFloat)layoutOldVersionViews:(CGFloat)originY
{
    CGFloat answerCountY = SSMaxY(self.descView);
    if (self.descView.height == 0) {
        answerCountY = SSMaxY(self.titleView);
    }
    self.answerCountView.origin = CGPointMake(kWDCellLeftPadding, answerCountY);
    CGFloat top = SSMaxY(self.answerCountView);
    top += WDPadding(8);
    return originY;
}

#pragma mark - Util

- (CGFloat)descPadding
{
    return WDPadding(4);
}

#pragma mark - getter

- (SSThemedView *)containerView
{
    if (!_containerView) {
        _containerView = [[SSThemedView alloc] initWithFrame:self.bounds];
        _containerView.backgroundColorThemeKey = kColorBackground4;
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _containerView;
}

- (WDListQuestionHeaderTagView *)tagView
{
    if (!_tagView) {
        CGFloat height = [TTDeviceHelper isPadDevice] ? 0 : 20.0f;
        _tagView = [[WDListQuestionHeaderTagView alloc] initWithFrame:CGRectMake(kWDCellLeftPadding, WDPadding(15), SSWidth(self) - kWDCellLeftPadding - kWDCellRightPadding, height) viewModel:self.viewModel];
        _tagView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        if ([TTDeviceHelper isPadDevice] || (!_viewModel.canEditTags && !_viewModel.hasTags)) {
            _tagView.hidden = YES;
        }
    }
    return _tagView;
}

- (WDListQuestionHeaderRewardView *)rewardView {
    if (!_rewardView) {
        _rewardView = [[WDListQuestionHeaderRewardView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SSWidth(self), WDPadding(60.0f)) viewModel:self.viewModel];
        _rewardView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _rewardView;
}

- (WDPrimaryQuestionTipsView *)primaryView
{
    if (!_primaryView) {
        _primaryView = [[WDPrimaryQuestionTipsView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SSWidth(self), WDPadding(36.0f)) viewModel:self.viewModel];
        _primaryView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _primaryView;
}

- (WDSecondaryQuestionTipsView *)secondaryView
{
    if (!_secondaryView) {
        _secondaryView = [[WDSecondaryQuestionTipsView alloc] initWithFrame:CGRectMake(kWDCellLeftPadding, WDPadding(kWDCellLeftPadding), SSWidth(self) - 2*kWDCellLeftPadding, WDPadding(90.0f)) viewModel:self.viewModel];
        _secondaryView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _secondaryView;
}

- (WDListQuestionHeaderTitleView *)titleView
{
    if (!_titleView) {
        CGFloat y = SSMaxY(self.tagView);
        if ([TTDeviceHelper isPadDevice] || (!_viewModel.canEditTags && !_viewModel.hasTags)) {
            y = 0;
        }
        y += WDPadding(12);
        _titleView = [[WDListQuestionHeaderTitleView alloc] initWithFrame:CGRectMake(0, y, SSWidth(self), 0) viewModel:self.viewModel];
        _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _titleView;
}

- (WDListQuestionHeaderDescViewNew *)descView
{
    if (!_descView) {
        CGFloat y = SSMaxY(self.titleView) + [self descPadding];
        _descView = [[WDListQuestionHeaderDescViewNew alloc] initWithFrame:CGRectMake(0, y, SSWidth(self), 0) viewModel:self.viewModel];
        _descView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _descView;
}

- (WDListQuestionHeaderAnswerView *)answerCountView
{
    if (!_answerCountView) {
        CGFloat y = SSMaxY(self.descView);
        _answerCountView = [[WDListQuestionHeaderAnswerView alloc] initWithFrame:CGRectMake(kWDCellLeftPadding, y, SSWidth(self) - kWDCellLeftPadding - kWDCellRightPadding, 0) viewModel:self.viewModel];
        _answerCountView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _answerCountView;
}

@end
