//
//  TSVCardMoreView.m
//  Article
//
//  Created by 邱鑫玥 on 2017/10/11.
//

#import "TSVCardBottomInfoView.h"
#import "TSVCardBottomInfoViewModel.h"
#import "ExploreOrderedData.h"
#import "SSThemed.h"
#import "TTDeviceUIUtils.h"
#import "TTArticleCellHelper.h"
#import "ExploreMixListDefine.h"
#import <TTUIWidget/TTAlphaThemedButton.h>

#define kLeft 15
#define kArrowGap   4
#define kUnInterestedButtonW        60
#define kUnInterestedButtonH        44
#define kUnInterestedIconW          17

@interface TSVCardBottomInfoView ()

@property (nonatomic, strong) TSVCardBottomInfoViewModel  *viewModel;

@property (nonatomic, strong) UIView                *containerView;
@property (nonatomic, strong) SSThemedLabel         *titleLabel;
@property (nonatomic, strong) SSThemedImageView     *imageView;
@property (nonatomic, strong) SSThemedView          *separateLine;
@property (nonatomic, strong) TTAlphaThemedButton       *moreButton;
@property (nonatomic, strong) TTAlphaThemedButton       *unInterestedButton;

@end

@implementation TSVCardBottomInfoView

#pragma mark - Public Method

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.containerView];
        [self.containerView addSubview:self.titleLabel];
        [self.containerView addSubview:self.imageView];
        [self.containerView addSubview:self.moreButton];
        [self.containerView addSubview:self.separateLine];
    }
    return self;
}

- (void)refreshWithData:(ExploreOrderedData *)data
{
    self.viewModel = [[TSVCardBottomInfoViewModel alloc] initWithOrderedData:data];
    self.titleLabel.text = [self.viewModel title];
    if (![TTShortVideoHelper canOpenShortVideoTab] || isEmptyString(self.titleLabel.text)) {
        self.titleLabel.text = @"精彩小视频";
    }
    self.imageView.imageName = [self.viewModel imageName];
}

#pragma mark -
- (void)layoutSubviews
{
    CGFloat space = 0.f;
    
    self.separateLine.hidden = YES;

    TTHorizontalCardContentCellStyle style = [self.viewModel cellStyle];

    self.containerView.frame = self.bounds;
    
    
    
    self.imageView.size = CGSizeMake(6, 10);
    
    self.moreButton.frame = self.containerView.bounds;
    
    space = 5.f;
    
    self.titleLabel.font = [UIFont tt_fontOfSize:14];
    [self.titleLabel sizeToFit];
    self.titleLabel.width = MIN(self.titleLabel.width, self.width - 2 * kLeft - self.imageView.width - space);
    self.titleLabel.centerY = self.containerView.height / 2;
    
    self.imageView.centerY = self.titleLabel.centerY;
    if (self.viewModel.contentStyle == TSVCardBottomInfoContentStyleDownload) {
        self.imageView.left = kLeft;
        self.titleLabel.left = self.imageView.right + space;
    } else {
        self.titleLabel.left = kLeft;
        self.imageView.left = self.titleLabel.right + kArrowGap;
    }
    
    if (style == TTHorizontalCardContentCellStyle5 || style == TTHorizontalCardContentCellStyle6 || style == TTHorizontalCardContentCellStyle7 || style == TTHorizontalCardContentCellStyle8) {
        self.unInterestedButton.hidden = NO;
        self.unInterestedButton.left = self.width - kLeft - (kUnInterestedButtonW / 2 + kUnInterestedIconW / 2);
        self.unInterestedButton.centerY = self.titleLabel.centerY;
    } else {
        self.unInterestedButton.hidden = YES;
    }
    
    if (![TTShortVideoHelper canOpenShortVideoTab]) {
        self.moreButton.hidden = YES;
        self.imageView.hidden = YES;
    }
}

#pragma mark - UI

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
    }
    return _containerView;
}

- (SSThemedLabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.backgroundColorThemeKey = kColorBackground4;
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
    }
    return _titleLabel;
}

- (SSThemedImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[SSThemedImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (SSThemedView *)separateLine
{
    if (!_separateLine) {
        _separateLine = [[SSThemedView alloc] init];
        _separateLine.backgroundColorThemeKey = kColorLine1;
    }
    return _separateLine;
}



- (TTAlphaThemedButton *)moreButton
{
    if (!_moreButton) {
        _moreButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectZero];
        _moreButton.backgroundColor = [UIColor clearColor];
        [_moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:_moreButton];
    }
    return _moreButton;
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
#pragma mark - Click

- (void)moreButtonClick:(id)sender
{
    [self.viewModel handleClick];
}

- (void)unInterestButtonClicked:(id)sender
{
    [TTShortVideoHelper uninterestFormView:self.unInterestedButton point:self.unInterestedButton.center withOrderedData:[self.viewModel data]];
}
@end
