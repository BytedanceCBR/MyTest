//
//  TSVFeedPublishCollectionViewCell.m
//  Article
//
//  Created by 王双华 on 2017/11/21.
//

#import "TSVFeedPublishCollectionViewCell.h"
#import "TSVAnimatedImageView.h"
#import <TTUIWidget/TTAlphaThemedButton.h>
#import "TSVFeedPublishCollectionViewCellViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface TSVFeedPublishCollectionViewCell()

@property (nonatomic, strong) TSVAnimatedImageView *coverImageView;
@property (nonatomic, strong) CALayer *imageMaskLayer;
@property (nonatomic, strong) SSThemedImageView *uploadingIndicatorView;
@property (nonatomic, strong) SSThemedLabel *uploadingProgressLabel;
@property (nonatomic, strong) SSThemedLabel *uploadingLabel;
@property (nonatomic, strong) SSThemedLabel *failedLabel;
@property (nonatomic, strong) TTAlphaThemedButton *retryButton;
@property (nonatomic, strong) TTAlphaThemedButton *deleteButton;

@end

@implementation TSVFeedPublishCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (self = [super initWithFrame:frame]) {
        self.coverImageView = ({
            TSVAnimatedImageView *imageView = [[TSVAnimatedImageView alloc] init];
            imageView.backgroundColorThemeKey = kColorBackground3;
            imageView.imageContentMode = TTImageViewContentModeScaleAspectFillRemainTop;
            [self.contentView addSubview:imageView];
            imageView;
        });
        
        self.imageMaskLayer = ({
            CALayer *layer = [[CALayer alloc] init];;
            layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
            [self.coverImageView.layer addSublayer:layer];
            layer;
        });
        
        self.uploadingIndicatorView = ({
            SSThemedImageView *imageView = [[SSThemedImageView alloc] init];
            imageView.imageName = @"hts_video_loading";
            imageView.hidden = YES;
            [self.contentView addSubview:imageView];
            imageView;
        });
        
        self.uploadingProgressLabel = ({
            SSThemedLabel *label = [[SSThemedLabel alloc] init];
            label.font = [UIFont systemFontOfSize:10];
            label.textColorThemeKey = kColorText10;
            label.textAlignment = NSTextAlignmentCenter;
            label.hidden = YES;
            [self.contentView addSubview:label];
            label;
        });
        
        self.uploadingLabel = ({
            SSThemedLabel *label = [[SSThemedLabel alloc] init];
            label.font = [UIFont systemFontOfSize:12];
            label.textColorThemeKey = kColorText10;
            label.textAlignment = NSTextAlignmentCenter;
            label.hidden = YES;
            [self.contentView addSubview:label];
            label;
        });
        
        self.failedLabel = ({
            SSThemedLabel *label = [[SSThemedLabel alloc] init];
            label.font = [UIFont systemFontOfSize:12];
            label.textColorThemeKey = kColorText10;
            label.textAlignment = NSTextAlignmentCenter;
            label.hidden = YES;
            [self.contentView addSubview:label];
            label;
        });
        
        self.retryButton = ({
            TTAlphaThemedButton *button = [[TTAlphaThemedButton alloc] init];
            [button setTitle:@"重试" forState:UIControlStateNormal];
            button.layer.cornerRadius = 4;
            button.layer.borderWidth = 1;
            button.borderColorThemeKey = kColorText10;
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.titleColorThemeKey = kColorText10;
            button.hidden = YES;
            [button addTarget:self action:@selector(retryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:button];
            button;
        });
        
        self.deleteButton = ({
            TTAlphaThemedButton *button = [[TTAlphaThemedButton alloc] init];
            [button setTitle:@"删除" forState:UIControlStateNormal];
            button.layer.cornerRadius = 4;
            button.layer.borderWidth = 1;
            button.borderColorThemeKey = kColorText10;
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.titleColorThemeKey = kColorText10;
            button.hidden = YES;
            [button addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:button];
            button;
        });
        
        [self startLoading];
        [self updateSubviewsVisibleWithUploadingIsFailed:NO];
        [self bindWithViewModel];
    }
    [CATransaction commit];
    return self;
}

- (void)layoutSubviews
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [super layoutSubviews];
    
    self.coverImageView.frame = self.contentView.bounds;
    self.imageMaskLayer.frame = self.coverImageView.bounds;
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat height = self.contentView.bounds.size.height;
    CGFloat centerX = width / 2;
    
    ///上传中的UI
    CGFloat uploadingIndicatorViewHeight = 32;
    self.uploadingIndicatorView.width = 32;
    self.uploadingIndicatorView.height = uploadingIndicatorViewHeight;
    self.uploadingIndicatorView.centerX = centerX;
    
    CGFloat uploadingLabelTopPadding = 10;
    CGFloat uploadingLabelHeight = 17;
    self.uploadingLabel.width = width - 30;
    self.uploadingLabel.height = uploadingLabelHeight;
    self.uploadingLabel.centerX = centerX;
    
    CGFloat uploadingTop = ceilf((height - uploadingIndicatorViewHeight - uploadingLabelTopPadding - uploadingLabelHeight) / 2);
    self.uploadingIndicatorView.top = uploadingTop;
    
    self.uploadingProgressLabel.width = width - 30;
    self.uploadingProgressLabel.height = 14;
    self.uploadingProgressLabel.center = self.uploadingIndicatorView.center;
    
    self.uploadingLabel.top = uploadingTop + uploadingIndicatorViewHeight + uploadingLabelTopPadding;
    
    ///失败后的UI
    CGFloat failedLabelHeight = 17;
    self.failedLabel.width = width - 30;
    self.failedLabel.height = failedLabelHeight;
    self.failedLabel.centerX = centerX;
    
    CGFloat buttonTopPadding = 15;
    CGFloat buttonSpacing = 15;
    CGFloat buttonWidth = 58;
    CGFloat buttonHeight = 28;
    
    CGFloat failedLabelTop = ceilf((height - failedLabelHeight - buttonTopPadding - buttonHeight) / 2);
    self.failedLabel.top = failedLabelTop;
    
    CGFloat retryButtonLeft = ceilf((width - 2 * buttonWidth - buttonSpacing) / 2);
    CGFloat buttonTop = failedLabelTop + failedLabelHeight + buttonTopPadding;
    self.retryButton.frame = CGRectMake(retryButtonLeft, buttonTop, buttonWidth, buttonHeight);
    self.deleteButton.frame = CGRectMake(retryButtonLeft + buttonWidth + buttonSpacing, buttonTop, buttonWidth, buttonHeight);
    [CATransaction commit];
}

- (void)bindWithViewModel
{
    @weakify(self);
    [RACObserve(self, viewModel.coverImage) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [UIView performWithoutAnimation:^{
            ///这里竟然也会导致出现动画
            [self.coverImageView setImage:self.viewModel.coverImage];
        }];
    }];
    RAC(self, uploadingProgressLabel.text) = RACObserve(self, viewModel.uploadingProgress);
    RAC(self, uploadingLabel.text) = RACObserve(self, viewModel.uploadingStr);
    RAC(self, failedLabel.text) = RACObserve(self, viewModel.failedStr);
    [RACObserve(self, viewModel.isFailed) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self updateSubviewsVisibleWithUploadingIsFailed:self.viewModel.isFailed];
    }];
}

- (void)updateSubviewsVisibleWithUploadingIsFailed:(BOOL)isFailed
{
    self.uploadingIndicatorView.hidden = isFailed;
    self.uploadingProgressLabel.hidden = isFailed;
    self.uploadingLabel.hidden = isFailed;
    
    self.failedLabel.hidden = !isFailed;
    self.retryButton.hidden = !isFailed;
    self.deleteButton.hidden = !isFailed;
    
    if (!isFailed) {
        [self startLoading];
    } else {
        [self loadFailed];
    }
}

- (void)startLoading
{
    [self.uploadingIndicatorView.layer removeAllAnimations];
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.duration = 1.0f;
    rotateAnimation.repeatCount = CGFLOAT_MAX;
    rotateAnimation.toValue = @(M_PI * 2);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.uploadingIndicatorView.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
    });
}

- (void)loadFailed
{
    [self.uploadingIndicatorView.layer removeAllAnimations];
}

- (void)retryButtonClicked:(id)sender
{
    [self.viewModel handleRetryButtonClick];
}

- (void)deleteButtonClicked:(id)sender
{
    [self.viewModel handleDeleteButtonClick];
}

- (void)willDisplay
{
    if (self.viewModel.isFailed) {
        [self loadFailed];
    } else {
        [self startLoading];
    }
}

@end
