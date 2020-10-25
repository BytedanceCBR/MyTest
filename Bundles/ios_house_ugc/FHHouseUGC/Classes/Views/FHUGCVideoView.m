//
//  FHUGCVideoView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/9/6.
//

#import "FHUGCVideoView.h"
#import "ExploreArticleCellViewConsts.h"
#import <TTVideoService/VideoFeed.pbobjc.h>
#import <TTVideoService/Common.pbobjc.h>
#import "TTImageInfosModel.h"
#import "TTVFeedItem+ComputedProperties.h"
#import "TTLabelTextHelper.h"
#import "TTImageView+TrafficSave.h"
#import "TTImageInfosModel+Extention.h"
#import "TTAlphaThemedButton.h"
#import <KVOController/KVOController.h>
#import "TTVFeedItem+Extension.h"
#import "TTVVideoArticle+Extension.h"
#import "TTVCellPlayMovie.h"
#import "TTMovieStore.h"
#import "TTUserSettingsManager+FontSettings.h"
#import "ExploreCellHelper.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTVideoArticleService+Action.h"
#import "TTMessageCenter.h"
#import "TTVFeedUserOpDataSyncMessage.h"
#import <libextobjc/extobjc.h>
#import "TTVVideoPlayerModel.h"
#import <TTBaseLib/UIImageAdditions.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import <TTArticleBase/SSCommonLogic.h>
#import "UIFont+House.h"

extern CGFloat ttvs_listVideoMaxHeight(void);
extern UIColor *tt_ttuisettingHelper_cellViewBackgroundColor(void);
extern BOOL ttvs_isEnhancePlayerTitleFont(void);

@interface FHUGCVideoView ()<TTVCellPlayMovieDelegate>

@property (nonatomic, strong) SSThemedLabel *videoRightBottomLabel; //默认显示时间
@property (nonatomic, strong) SSThemedLabel *videoTitleLabel;
@property (nonatomic, strong) UILabel *playTimesLabel;
@property (nonatomic, strong) TTAlphaThemedButton *playButton;
@property (nonatomic ,strong) NSString *videoLeftTime;
//下面的分割线
@property (nonatomic, strong) TTImageView *logo;
@property (nonatomic ,strong) TTVCellPlayMovie *playMovie;
@end

#define kVideoTitleX 15
#define kVideoTitleY 12
#define new_KVideoTitleY 8
#define kSourceLabelFontSize 12
#define kSourceLabelBottomGap 6
#define kDurationLabelFontSize 10
#define kDurationLabelRight 6.0
#define kDurationLabelBottom 6.0
#define kDurationLabelInsetLeft 6.0
#define kDurationLabelHeight 20.0
#define kDurationLabelMinWidth 44.0

#define kTopMaskH 80
#define kBottomMaskH 40

#define kAbstractBottomPadding 8
#define kCommentViewBottomPadding 8
#define kBottomViewH [TTDeviceUIUtils tt_newPadding:6]

@interface FHUGCVideoView ()

@property (nonatomic , strong) UIImageView *videoRightBottomLabelImageView;

@end

@implementation FHUGCVideoView


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _logo = [[TTImageView alloc] initWithFrame:CGRectZero];
        _logo.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _logo.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_logo];
        
        _videoTitleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _videoTitleLabel.backgroundColor = [UIColor clearColor];
        CGFloat fontSize = [[self class] settedTitleFontSize];
        _videoTitleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        _videoTitleLabel.textColor = [UIColor tt_themedColorForKey:kColorText10];
        [self.logo addSubview:_videoTitleLabel];
        _videoTitleLabel.numberOfLines = 2;
        
        _playTimesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _playTimesLabel.font = [UIFont systemFontOfSize:12.f];
        _playTimesLabel.textColor = [UIColor tt_themedColorForKey:kColorText9];
        if (ttvs_isVideoFeedCellHeightAjust() > 1){
            _playTimesLabel.textColor = [UIColor tt_themedColorForKey:kColorLine1];
        }
        _playTimesLabel.textAlignment = NSTextAlignmentLeft;
        _playTimesLabel.text = @"                             ";
        [_playTimesLabel sizeToFit];
        [self.logo addSubview:_playTimesLabel];
        
        _videoRightBottomLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, kCellPicLabelWidth, kCellPicLabelHeight)];
        _videoRightBottomLabel.backgroundColor = [UIColor clearColor];
        _videoRightBottomLabel.font = [UIFont themeFontRegular:10];
        _videoRightBottomLabel.textColor = [UIColor whiteColor];
        _videoRightBottomLabel.textAlignment = NSTextAlignmentCenter;
        
        _videoRightBottomLabelImageView = [[UIImageView alloc] init];
        CGSize imageSize = CGSizeMake(_videoRightBottomLabel.size.width, _videoRightBottomLabel.size.height);
        UIImage *videoRightBottomLabelImage = [UIImage imageWithSize:imageSize cornerRadius:MIN(imageSize.width, imageSize.height) / 2 backgroundColor:[UIColor colorWithHexString:@"00000050"]];
        videoRightBottomLabelImage = [videoRightBottomLabelImage stretchableImageWithLeftCapWidth:videoRightBottomLabelImage.size.width / 2.0 topCapHeight:videoRightBottomLabelImage.size.height / 2.0];
        _videoRightBottomLabelImageView.image = videoRightBottomLabelImage;
        [_videoRightBottomLabelImageView sizeToFit];
        
        [self.logo addSubview:_videoRightBottomLabelImageView];
        [self.logo addSubview:_videoRightBottomLabel];
        
        _playButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        NSString *imageName = @"fh_ugc_icon_videoplay";
        _playButton.imageName = imageName;
        [_playButton addTarget:self action:@selector(playButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.logo addSubview:_playButton];
        
        self.playMovie = [[TTVCellPlayMovie alloc] init];
    }
    return self;
}

- (void)configurePlayMovie
{
    if (!self.playMovie) {
        self.playMovie = [[TTVCellPlayMovie alloc] init];
    }
    self.playMovie.delegate = self;
    self.playMovie.logo = self.logo;
    self.playMovie.frame = self.logo.bounds;
    self.playMovie.fromView = self.logo;
    self.playMovie.cellEntity = self.cellEntity;
}

- (void)readyToPlay {
    [_playMovie readyToPlay];
}

- (void)playButtonClicked
{
    if(self.ttv_playButtonClickedBlock){
        self.ttv_playButtonClickedBlock();
    }
    [self play];
}

- (void)play {
    [_playMovie play];
    self.cellEntity.playVideo = _playMovie.movieView;
    if (self.ttv_playVideoBlock) {
        self.ttv_playVideoBlock();
    }
}

- (void)setPlayMovie:(TTVCellPlayMovie *)playMovie
{
    if (_playMovie != playMovie) {
        _playMovie = playMovie;
        [self configurePlayMovie];
    }
}

- (void)setMuted:(BOOL)muted {
    self.playMovie.movieView.player.muted = muted;
}

#pragma mark TTVCellPlayMovieDelegate

- (void)playerPlaybackState:(TTVVideoPlaybackState)state {
    if (self.ttv_playerPlaybackStateBlock) {
        self.ttv_playerPlaybackStateBlock(state);
    }
}

- (void)playerCurrentPlayBackTimeChange:(NSTimeInterval)currentPlayBackTime duration:(NSTimeInterval)duration {
    if(self.ttv_playerCurrentPlayBackTimeChangeBlock){
        self.ttv_playerCurrentPlayBackTimeChangeBlock(currentPlayBackTime, duration);
    }
}

- (void)ttv_shareButtonOnMovieFinishViewDidPress
{
    if (self.ttv_shareButtonOnMovieFinishViewDidPressBlock) {
        self.ttv_shareButtonOnMovieFinishViewDidPressBlock();
    }
}

- (void)ttv_movieViewWillMoveTosuperView:(UIView *)supView{
    if(self.ttv_movieViewWillMoveToSuperViewBlock){
        self.ttv_movieViewWillMoveToSuperViewBlock(supView, YES);
    }
}

- (void)ttv_shareButtonOnMovieTopViewDidPress
{
    if (self.ttv_shareButtonOnMovieTopViewDidPressBlock) {
        self.ttv_shareButtonOnMovieTopViewDidPressBlock();
    }
}
- (void)ttv_moreButtonOnMovieTopViewDidPress
{
    if (self.ttv_moreButtonOnMovieTopViewDidPressBlock) {
        self.ttv_moreButtonOnMovieTopViewDidPressBlock();
    }
}

- (void)ttv_directShareActionWithActivityType:(NSString *)activityType
{
    if (self.ttv_DirectShareOnMovieFinishViewDidPressBlock) {
        self.ttv_DirectShareOnMovieFinishViewDidPressBlock(activityType);
    }
}

- (void)ttv_directShareActionOnMovieWithActivityType:(NSString *)activityType
{
    if (self.ttv_DirectShareOnMovieViewDidPressBlock) {
        self.ttv_DirectShareOnMovieViewDidPressBlock(activityType);
    }
}

- (void)ttv_moviePlayFinished
{
    if (self.ttv_videoPlayFinishedBlock) {
        self.ttv_videoPlayFinishedBlock();
    }
}

- (void)ttv_movieReplayAction
{
    if (self.ttv_videoReplayActionBlock) {
        self.ttv_videoReplayActionBlock();
    }
}

- (void)setCellEntity:(TTVFeedListItem *)cellEntity
{
    if (_cellEntity != cellEntity) {
        _cellEntity = cellEntity;

        [self configurePlayMovie];
        [self configureUI];
        [self setNeedsLayout];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSNumber *oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    NSNumber *newValue = [change objectForKey:NSKeyValueChangeNewKey];
    if (!newValue || [newValue isKindOfClass:[NSNull class]])
    {
        return;
    }
    
    if ([oldValue isKindOfClass:[NSNull class]] || ([oldValue isKindOfClass:[NSNumber class]] && [newValue isKindOfClass:[NSNumber class]] && ![oldValue isEqualToNumber:newValue])) {
        if ([NSThread isMainThread]) {
            [self observeWithKeyPath:keyPath object:object change:change context:context];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self observeWithKeyPath:keyPath object:object change:change context:context];
            });
        }
    }
}

- (void)observeWithKeyPath:(NSString *)keyPath object:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"updated"]) {
        [self configureUI];
    }
}

- (TTVVideoArticle *)article
{
    return self.cellEntity.originData.article;
}

- (void)configureUI
{
    self.logo.userInteractionEnabled = YES;
    [self updatePic];
    _videoRightBottomLabel.text = self.cellEntity.durationTimeString;
    _videoRightBottomLabel.hidden = self.cellEntity.durationTimeString ? NO : YES;
    self.videoRightBottomLabelImageView.hidden = self.videoRightBottomLabel.hidden;
    self.playButton.hidden = NO;
    _playButton.userInteractionEnabled = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self adjustFrameOfSubviews];
}

- (void)adjustFrameOfSubviews
{
    [self layoutPic];

    if (self.cellEntity.titleHeight < 1) {
        CGFloat height = [TTLabelTextHelper heightOfText:self.videoTitleLabel.text fontSize:[[self class] settedTitleFontSize] forWidth:[self getLogoWidth] - kVideoTitleX * 2 constraintToMaxNumberOfLines:2];
        self.cellEntity.titleHeight = height;
    }
    self.videoTitleLabel.height = self.cellEntity.titleHeight;
    
    CGSize size = CGSizeMake(self.logo.width - kVideoTitleX * 2, self.videoTitleLabel.height);
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        _videoTitleLabel.frame = CGRectMake(kVideoTitleX, new_KVideoTitleY, size.width, size.height);
    }else{
        _videoTitleLabel.frame = CGRectMake(kVideoTitleX, kVideoTitleY, size.width, size.height);
    }
    _playTimesLabel.left = _videoTitleLabel.left;
    _playTimesLabel.top = _videoTitleLabel.bottom + 3;
    
    _videoRightBottomLabel.right = self.logo.width - [TTDeviceUIUtils tt_padding:kDurationLabelRight];
    _videoRightBottomLabel.bottom = self.logo.height - [TTDeviceUIUtils tt_padding:kSourceLabelBottomGap];
    _videoRightBottomLabelImageView.frame = _videoRightBottomLabel.frame;
    _playButton.frame = self.logo.bounds;
}

- (void)layoutPic
{
    float left = 0;
    float picWidth = [self getLogoWidth];
    if (!self.cellEntity.imageHeight) {
        self.cellEntity.imageHeight = self.height;
    }
    self.logo.frame = CGRectMake(left, 0, picWidth, self.cellEntity.imageHeight);
}

- (float)getLogoWidth {
    // 根据图片实际宽高设置其在cell中的高度
    float picWidth = self.width;
    return picWidth;
}

#pragma mark - helpers

- (void)updatePic
{
    self.logo.backgroundColorThemeKey = kColorBackground2;
    @weakify(self);
    [self.logo setImageWithModelInTrafficSaveMode:self.cellEntity.imageModel placeholderImage:nil success:nil failure:^(NSError *error) {
        @strongify(self);
        [self.logo setImage:nil];
    }];
}

static NSDictionary *fontSizes = nil;

+ (float)settedTitleFontSize {
    if (ttvs_isEnhancePlayerTitleFont()){
        fontSizes = @{@"iPad" : @[@20, @22, @24, @28],
                      @"iPhone667": @[@18,@19,@20,@22],
                      @"iPhone736" : @[@19, @20, @21, @23],
                      @"iPhone" : @[@16, @17, @18, @20]};
        
    }else{
        fontSizes = @{@"iPad" : @[@19, @22, @24, @29],
                      @"iPhone667": @[@16,@18,@20,@23],
                      @"iPhone736" : @[@16, @18, @20, @23],
                      @"iPhone" : @[@14, @16, @18, @21]};
    }
    
    NSString *key = nil;
    if ([TTDeviceHelper isPadDevice]) {
        key = @"iPad";
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        key = @"iPhone667";
    } else if ([TTDeviceHelper is736Screen]) {
        key = @"iPhone736";
    } else {
        key = @"iPhone";
    }
    NSArray *fonts = [fontSizes valueForKey:key];
    NSInteger index = 1;// 默认大
    NSInteger selectedIndex = [TTUserSettingsManager settingFontSize];
    switch (selectedIndex) {
        case TTFontSizeSettingTypeMin:
            index = 0;
            break;
        case TTFontSizeSettingTypeNormal:
            index = 1;
            break;
        case TTFontSizeSettingTypeBig:
            index = 2;
            break;
        case TTFontSizeSettingTypeLarge:
            index = 3;
            break;
        default:
            break;
    }
    return [fonts[index] floatValue];
}

- (UIView *)ttv_playerSuperView
{
    return self.logo;
}

@end
