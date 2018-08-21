//
//  TSVCardTopInfoView.m
//  Article
//
//  Created by dingjinlu on 2017/11/29.
//

#import "TSVCardTopInfoView.h"
#import "SSThemed.h"
#import <TTUIWidget/TTAlphaThemedButton.h>
#import "TTShortVideoHelper.h"
#import "TSVCardTopInfoViewModel.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "HorizontalCard.h"
#import "ExploreMixListDefine.h"
#import "UIViewAdditions.h"
#import "TTDeviceUIUtils.h"
#import "TTDeviceHelper.h"
#import "TTArticleCellHelper.h"

#define kLeft                       15

#define kTopInfoIconW               14
#define kTopInfoIconH               16
#define kTopInfoIconRightGap        6
#define kUnInterestedButtonW        60
#define kUnInterestedButtonH        44
#define kUnInterestedIconW          17
#define ktopMoreArrowW              6
#define ktopMoreArrowH              10
#define ktopMoreArrowLeftGap        4
#define kTopInfoViewHeight          40

@interface TSVCardTopInfoView ()

//  ui
@property (nonatomic, strong) UIView                    *containerView;
@property (nonatomic, strong) TTAlphaThemedButton       *unInterestedButton;
@property (nonatomic, strong) TTAlphaThemedButton       *moreButton;    // 跳转底tab
@property (nonatomic, strong) SSThemedImageView         *moreArrow;
@property (nonatomic, strong) SSThemedLabel             *titleLabel;

//  model
@property (nonatomic, strong) TSVCardTopInfoViewModel   *viewModel;

@end

@implementation TSVCardTopInfoView

#pragma mark -

- (void)refreshWithData:(ExploreOrderedData *)data
{
    self.viewModel = [[TSVCardTopInfoViewModel alloc] initWithOrderedData:data];
    self.titleLabel.text = [self.viewModel title];

    [self setNeedsLayout];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    self.containerView.hidden = NO;
    self.containerView.frame = self.bounds;

    TTHorizontalCardContentCellStyle style = [self.viewModel cellStyle];
    if (style == TTHorizontalCardContentCellStyle1 || style == TTHorizontalCardContentCellStyle3 || style == TTHorizontalCardContentCellStyle4) {
        [self p_refreshUIForCellStyle1];
    } else if (style == TTHorizontalCardContentCellStyle2) {
        [self p_refreshUIForCellStyle2];
    } else {
        self.containerView.hidden = YES;
    }
}

- (void)p_refreshUIForCellStyle1
{
    self.moreButton.hidden = YES;
    self.moreArrow.hidden = YES;
    
    [self.titleLabel sizeToFit];
    CGFloat titleLabelMaxWidth = self.containerView.width - kLeft * 2 - kUnInterestedIconW - 12;
    self.titleLabel.width = MIN(self.titleLabel.width, titleLabelMaxWidth);
    self.titleLabel.centerY = self.containerView.height / 2.f;
    self.titleLabel.left = kLeft;
    
    self.unInterestedButton.left = self.width - kLeft - (kUnInterestedButtonW / 2 + kUnInterestedIconW / 2);
    self.unInterestedButton.centerY = self.titleLabel.centerY;
}

- (void)p_refreshUIForCellStyle2
{
    [self p_refreshUIForCellStyle1];
    
    if (![TTShortVideoHelper canOpenShortVideoTab]) {
        
        self.moreArrow.hidden = YES;
        self.moreButton.hidden = YES;
        
    } else {
        
        self.moreArrow.hidden = NO;
        self.moreArrow.left = self.titleLabel.right + ktopMoreArrowLeftGap;
        self.moreArrow.centerY = self.titleLabel.centerY;
        
        self.moreButton.hidden = NO;
        self.moreButton.frame = CGRectMake(0, 0, self.titleLabel.width + ktopMoreArrowLeftGap + ktopMoreArrowW, self.containerView.height);
        self.moreButton.left = self.titleLabel.left;
        self.moreButton.centerY = self.titleLabel.centerY;
    }
}

#pragma mark - UI

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        [self addSubview:_containerView];
    }
    return _containerView;
}

- (TTAlphaThemedButton *)moreButton
{
    if (!_moreButton) {
        _moreButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectZero];
        _moreButton.backgroundColor = [UIColor clearColor];
        WeakSelf;
        [_moreButton addTarget:self withActionBlock:^{
            StrongSelf;
            [TTShortVideoHelper handleClickWithData:[self.viewModel data]];
        } forControlEvent:UIControlEventTouchUpInside];
        [self.containerView addSubview:_moreButton];
    }
    return _moreButton;
}

- (SSThemedImageView *)moreArrow
{
    if (!_moreArrow) {
        _moreArrow = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, ktopMoreArrowW, ktopMoreArrowH)];
        _moreArrow.backgroundColor = [UIColor clearColor];
        _moreArrow.imageName = @"horizontal_more_arrow";
        [self.containerView addSubview:_moreArrow];
    }
    return _moreArrow;
}

- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.backgroundColorThemeKey = kColorBackground4;
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
        [self.containerView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (TTAlphaThemedButton *)unInterestedButton
{
    if (!_unInterestedButton) {
        _unInterestedButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, kUnInterestedButtonW, kUnInterestedButtonH)];
        _unInterestedButton.imageName = @"add_textpage.png";
        _unInterestedButton.backgroundColor = [UIColor clearColor];
        [_unInterestedButton addTarget:self action:@selector(unInterestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:_unInterestedButton];
    }
    return _unInterestedButton;
}

#pragma mark - uninterest

- (void)unInterestButtonClicked:(id)sender
{
    [TTShortVideoHelper uninterestFormView:self.unInterestedButton point:self.unInterestedButton.center withOrderedData:[self.viewModel data]];
}

@end
