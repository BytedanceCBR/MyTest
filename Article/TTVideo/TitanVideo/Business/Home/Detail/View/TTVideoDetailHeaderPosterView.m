//
//  TTVideoDetailHeaderPosterView.m
//  Article
//
//  Created by pei yun on 2017/4/10.
//
//

#import "TTVideoDetailHeaderPosterView.h"

#import "TTImageView+TrafficSave.h"
#import "ExploreCellHelper.h"
#import "TTDeviceHelper.h"
#import "Article.h"


#define kSourceLabelX 12
#define kBottomMaskH 40
#define kSourceLabelFontSize 12
#define kSourceLabelBottomGap 8
#define kDurationLabelFontSize 12
#define kDurationLabelRight 15


@interface TTVideoDetailHeaderPosterView ()

@property (nonatomic, strong) TTImageView *logo;
@property (nonatomic, strong) SSThemedLabel *videoTypeLabel;
@property (nonatomic, strong) SSThemedLabel *videoSourceLabel;
@property (nonatomic, strong) SSThemedLabel *videoDurationLabel;
@property (nonatomic, strong) UIImageView *bottomMaskView;

@end


@implementation TTVideoDetailHeaderPosterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.logo];
        [self.logo addSubview:self.bottomMaskView];
        [self.logo addSubview:self.videoTypeLabel];
        [self.logo addSubview:self.videoSourceLabel];
        [self.logo addSubview:self.videoDurationLabel];
        [self.logo addSubview:self.playButton];
        
        [self buildConstraints];
        self.bottomMaskView.backgroundColor = [UIColor clearColor];
        self.logo.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_forbidLayout) {
        return;
    }
    [self updateFrame];
}

- (void)updateFrame {
    self.logo.frame = self.bounds;
    self.bottomMaskView.width = self.width;
    self.bottomMaskView.height = kBottomMaskH;
    self.bottomMaskView.left = 0;
    self.bottomMaskView.bottom = self.height;
}

- (void)buildConstraints
{
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.logo);
    }];
    
    [self.videoDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.logo).offset(-kDurationLabelRight);
        make.bottom.equalTo(self.logo).offset(-kSourceLabelBottomGap);
    }];
    
    [self.videoTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.logo).offset(kSourceLabelX + 2);
        make.centerY.equalTo(self.videoSourceLabel);
    }];
    
    [self.videoSourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.logo).offset(kSourceLabelX);
        make.bottom.equalTo(self.logo).offset(-kSourceLabelBottomGap);
    }];
}

- (void)refreshWithArticle:(id<TTVArticleProtocol> )article
{
    if (article) {
        
        NSDictionary *videoLargeImageDict = article.largeImageDict;
        if (!videoLargeImageDict) {
            videoLargeImageDict = [article.videoDetailInfo objectForKey:VideoInfoImageDictKey];
        }
        
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:videoLargeImageDict];
        [self.logo setImageWithModelInTrafficSaveMode:model placeholderImage:nil];
        
        self.videoSourceLabel.text = article.source;
        
        long long duration = [article.videoDuration longLongValue];
        if (duration > 0) {
            int minute = (int)duration / 60;
            int second = (int)duration % 60;
            [self.videoDurationLabel setText:[NSString stringWithFormat:@"%02i:%02i", minute, second]];
        } else {
            [self.videoDurationLabel setText:@""];
        }
        
    }
}

- (UIImage *)logoImage
{
    return self.logo.imageView.image;
}

- (void)refreshUI
{
    if (self.isAD) {
        self.videoTypeLabel.hidden = NO;
        self.videoTypeLabel.text = NSLocalizedString(@"广告", nil);
    } else {
        self.videoTypeLabel.hidden = YES;
    }
    
    if (self.showPlayButton) {
        self.playButton.hidden = NO;
    } else {
        self.playButton.hidden = YES;
    }
    
    if (self.showSourceLabel) {
        self.videoSourceLabel.hidden = NO;
        self.videoDurationLabel.hidden = NO;
    } else {
        self.videoSourceLabel.hidden = YES;
        self.videoDurationLabel.hidden = YES;
        self.videoTypeLabel.hidden = YES;
    }
    
    // 根据图片实际宽高设置其在cell中的高度
    float imageHeight;
    CGFloat maxHeight;
    
    if (self.logo.model && self.logo.model.width > 0 && self.logo.model.height > 0) {
        imageHeight = [self.class heightForImageWidth:self.logo.model.width height:self.logo.model.height constraintWidth:self.width];
        maxHeight = self.width * 9/16;
        imageHeight = MIN(imageHeight, maxHeight);
    } else {
        imageHeight = self.width * 9/16;
    }
    imageHeight = floor(imageHeight);
    
    if (self.videoTypeLabel && !self.videoTypeLabel.hidden) {
        [self.videoSourceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.videoTypeLabel.mas_right).offset(8);
        }];
    } else {
        [self.videoSourceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.logo).offset(kSourceLabelX);
        }];
    }
    
    //    self.height = imageHeight;
    self.logo.frame = self.bounds;
}

+ (CGFloat)sourceLabelFontSize
{
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        return 14.0;
    } else {
        return 12.0;
    }
}

+ (float)heightForImageWidth:(float)width height:(float)height constraintWidth:(float)cWidth
{
    return [ExploreCellHelper heightForVideoImageWidth:width height:height constraintWidth:cWidth];
}

#pragma mark -
#pragma mark Setters and getters

- (TTImageView *)logo
{
    if (!_logo) {
        _logo = [[TTImageView alloc] initWithFrame:CGRectZero];
        _logo.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground5];
        _logo.dayModeCoverHexString = @"00000026";
        _logo.imageContentMode = TTImageViewContentModeScaleAspectFill;
    }
    return _logo;
}

- (UIImageView *)bottomMaskView
{
    if (!_bottomMaskView) {
        UIImage *bottomMaskImage = [[UIImage imageNamed:@"down_textshade_video.png"] resizableImageWithCapInsets:UIEdgeInsetsZero];
        _bottomMaskView = [[UIImageView alloc] initWithImage:bottomMaskImage];
        _bottomMaskView.frame = CGRectMake(0, self.logo.height - kBottomMaskH, self.width, kBottomMaskH);
    }
    return _bottomMaskView;
}

- (SSThemedLabel *)videoTypeLabel
{
    if (!_videoTypeLabel) {
        _videoTypeLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _videoTypeLabel.backgroundColor = [UIColor clearColor];
        CGFloat fontSize = [[self class] sourceLabelFontSize];
        _videoTypeLabel.font = [UIFont systemFontOfSize:fontSize - 2];
        _videoTypeLabel.textColorThemeKey = kColorVideoCellTitle;
        _videoTypeLabel.borderColorThemeKey = kColorVideoCellTitle;
        _videoTypeLabel.textAlignment  = NSTextAlignmentCenter;
        _videoTypeLabel.layer.cornerRadius = 2;
        _videoTypeLabel.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _videoTypeLabel.clipsToBounds = YES;
    }
    return _videoTypeLabel;
}

- (SSThemedLabel *)videoSourceLabel
{
    if (!_videoSourceLabel) {
        _videoSourceLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _videoSourceLabel.backgroundColor = [UIColor clearColor];
        CGFloat fontSize = [[self class] sourceLabelFontSize];
        _videoSourceLabel.font = [UIFont systemFontOfSize:fontSize];
        _videoSourceLabel.textColorThemeKey = kColorVideoCellTitle;
    }
    return _videoSourceLabel;
}

- (SSThemedLabel *)videoDurationLabel
{
    if (!_videoDurationLabel) {
        _videoDurationLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _videoDurationLabel.backgroundColor = [UIColor clearColor];
        CGFloat fontSize = [[self class] sourceLabelFontSize];
        _videoDurationLabel.font = [UIFont systemFontOfSize:fontSize];
        _videoDurationLabel.textColorThemeKey = kColorVideoCellTitle;
    }
    return _videoDurationLabel;
}

- (SSThemedButton *)playButton
{
    if (!_playButton) {
        _playButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _playButton.imageName = [TTDeviceHelper isPadDevice] ? @"FullPlay" : @"Play";
    }
    return _playButton;
}

- (void)setShowPlayButton:(BOOL)showPlayButton {
    _showPlayButton = showPlayButton;
    _playButton.hidden = !showPlayButton;
}

- (void)removeAllActions
{
    [self.playButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDown];
}
@end
