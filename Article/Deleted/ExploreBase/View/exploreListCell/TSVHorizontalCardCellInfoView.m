//
//  TSVHorizontalCardCellInfoView.m
//  Article
//
//  Created by dingjinlu on 2018/2/27.
//

#import "TSVHorizontalCardCellInfoView.h"
#import "TTShortVideoHelper.h"
#import "HorizontalCard.h"
#import "ExploreMixListDefine.h"
#import "UIViewAdditions.h"
#import "TTDeviceUIUtils.h"
#import "TTDeviceHelper.h"
#import "TTUISettingHelper.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "SSThemed.h"
#import <TTUIWidget/TTAlphaThemedButton.h>

#define kLeft                       15
#define kUnInterestedButtonW        60
#define kUnInterestedButtonH        44
#define kUnInterestedIconW          17

@interface TSVHorizontalCardCellInfoView ()

@property (nonatomic, strong) UIView                    *containerView;
@property (nonatomic, strong) TTAlphaThemedButton       *unInterestedButton;
@property (nonatomic, strong) TTAlphaThemedButton       *moreButton;
@property (nonatomic, strong) SSThemedImageView         *moreArrow;
@property (nonatomic, strong) SSThemedLabel             *titleLabel;

@property (nonatomic, strong) HorizontalCard            *horizontalCard;
@property (nonatomic, strong) ExploreOrderedData        *orderedData;

@end

@implementation TSVHorizontalCardCellInfoView

- (void)refreshWithData:(ExploreOrderedData *)data
{
    if ([data.horizontalCard isKindOfClass:[HorizontalCard class]]) {
        self.orderedData = data;
        self.horizontalCard = data.horizontalCard;
        NSUInteger cardType = [self.horizontalCard.cardType integerValue];
        if (cardType == 0) {
            self.titleLabel.text = self.horizontalCard.showMoreModel.title?:@"精彩小视频";
        } else if (cardType == 1) {
            self.titleLabel.text = self.horizontalCard.cardTitle?:@"精彩小视频";
        }
        [self setNeedsLayout];
    }
}

#pragma mark - Layout

- (void)layoutSubviews
{
    self.containerView.hidden = NO;
    self.containerView.frame = self.bounds;
    
    [self.titleLabel sizeToFit];
    CGFloat titleLabelMaxWidth = self.containerView.width - kLeft * 2 - kUnInterestedIconW - 12;
    self.titleLabel.width = MIN(self.titleLabel.width, titleLabelMaxWidth);
    self.titleLabel.centerY = self.containerView.height / 2.f;
    self.titleLabel.left = kLeft;
    
    self.unInterestedButton.left = self.width - kLeft - (kUnInterestedButtonW / 2 + kUnInterestedIconW / 2);
    self.unInterestedButton.centerY = self.titleLabel.centerY;
    
    if (![TTShortVideoHelper canOpenShortVideoTab] || ![TTShortVideoHelper shouldHandleClickWithData:self.orderedData]) {
        self.moreArrow.hidden = YES;
        self.moreButton.hidden = YES;
    } else {
        self.moreArrow.hidden = NO;
        self.moreArrow.left = self.titleLabel.right + 4;
        self.moreArrow.centerY = self.titleLabel.centerY;
        
        self.moreButton.hidden = NO;
        self.moreButton.frame = CGRectMake(0, 0, self.titleLabel.width + 10, self.containerView.height);
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
        [_moreButton addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:_moreButton];
    }
    return _moreButton;
}

- (SSThemedImageView *)moreArrow
{
    if (!_moreArrow) {
        _moreArrow = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, 6, 10)];
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
        _titleLabel.backgroundColors = [TTUISettingHelper cellViewBackgroundColors];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
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

#pragma mark - action

- (void)moreButtonClicked:(id)sender
{
    [TTShortVideoHelper handleClickWithData:self.orderedData];
}

- (void)unInterestButtonClicked:(id)sender
{
    [TTShortVideoHelper uninterestFormView:self.unInterestedButton point:self.unInterestedButton.center withOrderedData:self.orderedData];
}

@end
