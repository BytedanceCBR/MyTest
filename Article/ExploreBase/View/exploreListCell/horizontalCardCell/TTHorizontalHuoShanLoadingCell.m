//
//  TTHorizontalHuoShanLoadingCell.m
//  Article
//
//  Created by 邱鑫玥 on 2017/8/1.
//
//

#import "TTHorizontalHuoShanLoadingCell.h"
#import "SSThemed.h"
#import "TTWaitingView.h"
#import "TTArticleCellHelper.h"
#import "NSObject+FBKVOController.h"
#import "EXTKeyPathCoding.h"
#import "TTShortVideoHelper.h"

#define kCoverAspectRatio (1.f / 0.863f)

@interface TTHorizontalHuoShanLoadingCell()

@property (nonatomic, strong) TTImageView *backgroundImageView;
@property (nonatomic, strong) TTWaitingView *loadingView;
@property (nonatomic, strong) UIView *showMoreContainerView;
@property (nonatomic, strong) SSThemedLabel *showMoreTextLabel;
@property (nonatomic, strong) SSThemedImageView *showMoreArrowView;

@end

@implementation TTHorizontalHuoShanLoadingCell

- (void)setDataFetchManager:(id<TSVShortVideoDataFetchManagerProtocol>)dataFetchManager
{
    _dataFetchManager = dataFetchManager;
    
    WeakSelf;
    [self.KVOController unobserveAll];
    [self.KVOController observe:self.dataFetchManager
                        keyPath:@keypath(self.dataFetchManager, isLoadingRequest)
                        options:NSKeyValueObservingOptionNew
                          block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                              StrongSelf;
                              self.loading = self.dataFetchManager.isLoadingRequest;
                          }];
}

- (void)setStyle:(TTHorizontalHuoShanLoadingCellStyle)style
{
    _style = style;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_style == TTHorizontalHuoShanLoadingCellStyle1) {
        self.backgroundImageView.origin = CGPointZero;
        self.backgroundImageView.width = self.contentView.width;
        self.backgroundImageView.height = ceilf(self.contentView.width * kCoverAspectRatio);
    } else {
        self.backgroundImageView.frame = self.contentView.bounds;
    }
    
    CGPoint center = CGPointMake(self.backgroundImageView.width / 2, self.backgroundImageView.height / 2);
    
    self.loadingView.size = CGSizeMake(12, 12);
    self.loadingView.center = center;
    
    [self.showMoreTextLabel sizeToFit];
    self.showMoreArrowView.size = CGSizeMake(8, 14);
    
    if ([TTShortVideoHelper canOpenShortVideoTab]) {
        self.showMoreArrowView.hidden = NO;
        self.showMoreContainerView.width = self.showMoreTextLabel.width + 5 + self.showMoreArrowView.width;
        self.showMoreContainerView.height = MAX(self.showMoreTextLabel.height, self.showMoreArrowView.height);
        self.showMoreContainerView.center = center;
        self.showMoreTextLabel.left = 0;
        self.showMoreTextLabel.centerY = self.showMoreContainerView.height / 2.f;
        self.showMoreArrowView.left = self.showMoreTextLabel.right + 5;
        self.showMoreArrowView.centerY = self.showMoreTextLabel.centerY;
    } else {
        self.showMoreArrowView.hidden = YES;
        self.showMoreContainerView.width = self.showMoreTextLabel.width;
        self.showMoreContainerView.height = self.showMoreTextLabel.height;
        self.showMoreContainerView.center = center;
        self.showMoreTextLabel.left = 0;
        self.showMoreTextLabel.centerY = self.showMoreContainerView.height / 2.f;
    }
}

- (void)setLoading:(BOOL)loading
{
    _loading = loading;
    
    [self refreshUI];
}

- (TTImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[TTImageView alloc] init];
        _backgroundImageView.backgroundColorThemeKey = kColorBackground3;
        _backgroundImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _backgroundImageView.borderColorThemeKey = kColorLine1;
        [self.contentView addSubview:_backgroundImageView];
    }
    return _backgroundImageView;
}

- (TTWaitingView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[TTWaitingView alloc] init];
        _loadingView.imageView.imageName = @"loading";
        [self.backgroundImageView addSubview:_loadingView];
    }
    return _loadingView;
}

- (UIView *)showMoreContainerView
{
    if (!_showMoreContainerView) {
        _showMoreContainerView = [[UIView alloc] init];
        [self.backgroundImageView addSubview:_showMoreContainerView];
    }
    return _showMoreContainerView;
}

- (SSThemedLabel *)showMoreTextLabel
{
    if (!_showMoreTextLabel) {
        _showMoreTextLabel = [[SSThemedLabel alloc] init];
        _showMoreTextLabel.font = [UIFont tt_fontOfSize:14.f];
        _showMoreTextLabel.textColorThemeKey = kColorText15;
        if ([TTShortVideoHelper canOpenShortVideoTab]) {
            _showMoreTextLabel.text = @"更多小视频";
        } else {
            _showMoreTextLabel.text = @"暂无更多小视频";
        }
        [self.showMoreContainerView addSubview:_showMoreTextLabel];
    }
    return _showMoreTextLabel;
}

- (SSThemedImageView *)showMoreArrowView
{
    if (!_showMoreArrowView) {
        _showMoreArrowView = [[SSThemedImageView alloc] init];
        _showMoreArrowView.imageName = @"all_card_arrow";
        [self.showMoreContainerView addSubview:_showMoreArrowView];
    }
    return _showMoreArrowView;
}

- (void)refreshUI
{
    if (self.isLoading) {
        [self.loadingView startAnimating];
        self.showMoreContainerView.hidden = YES;
    } else {
        [self.loadingView stopAnimating];
        self.showMoreContainerView.hidden = NO;
    }
}

@end
