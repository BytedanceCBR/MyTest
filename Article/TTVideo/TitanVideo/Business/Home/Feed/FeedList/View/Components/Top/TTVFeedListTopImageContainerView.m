//
//  TTVFeedListTopImageContainerView.m
//  Article
//
//  Created by pei yun on 2017/3/31.
//
//

#import "TTVFeedListTopImageContainerView.h"
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
#import "TTImageView+TrafficSave.h"
#import "TTUserSettingsManager+FontSettings.h"
#import "ExploreCellHelper.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTVideoArticleService+Action.h"
#import "TTMessageCenter.h"
#import "TTVFeedUserOpDataSyncMessage.h"
#import <libextobjc/extobjc.h>
#import "TTVVideoPlayerModel.h"

extern CGFloat ttvs_listVideoMaxHeight(void);
extern UIColor *tt_ttuisettingHelper_cellViewBackgroundColor(void);
extern BOOL ttvs_isEnhancePlayerTitleFont(void);

@interface TTVFeedListTopImageContainerView ()<TTVCellPlayMovieDelegate, TTVPlayerDoubleTap666Delegate>

@property (nonatomic, strong) SSThemedLabel *videoRightBottomLabel; //默认显示时间
@property (nonatomic, strong) SSThemedLabel *videoTitleLabel;
@property (nonatomic, strong) UILabel *playTimesLabel;
@property (nonatomic, strong) TTAlphaThemedButton *playButton;
//下面的分割线
@property (nonatomic, strong) UIImageView *topMaskView;
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

@interface TTVFeedListTopImageContainerView ()
@property (nonatomic ,strong)UIImageView *videoRightBottomLabelImageView;
@end

@implementation TTVFeedListTopImageContainerView

    
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
        _logo.dayModeCoverHexString = @"00000033";
        _logo.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_logo];
        
        UIImage *topMaskImage = [[UIImage imageNamed:@"thr_shadow_video"] resizableImageWithCapInsets:UIEdgeInsetsZero];
        _topMaskView = [[UIImageView alloc] initWithImage:topMaskImage];
        _topMaskView.frame = CGRectMake(0, 0, self.width, kTopMaskH);
        [self.logo addSubview:_topMaskView];
        
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
        _videoRightBottomLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:10]];
        _videoRightBottomLabel.textColorThemeKey = kColorText12;
        _videoRightBottomLabel.textAlignment = NSTextAlignmentCenter;

        _videoRightBottomLabelImageView = [[UIImageView alloc] init];
        CGSize imageSize = CGSizeMake(_videoRightBottomLabel.size.width, _videoRightBottomLabel.size.height);
        UIImage *videoRightBottomLabelImage = [UIImage imageWithSize:imageSize cornerRadius:MIN(imageSize.width, imageSize.height) / 2 backgroundColor:SSGetThemedColorWithKey(kColorBackground15)];
        videoRightBottomLabelImage = [videoRightBottomLabelImage stretchableImageWithLeftCapWidth:videoRightBottomLabelImage.size.width / 2.0 topCapHeight:videoRightBottomLabelImage.size.height / 2.0];
        _videoRightBottomLabelImageView.image = videoRightBottomLabelImage;
        [_videoRightBottomLabelImageView sizeToFit];

        [self.logo addSubview:_videoRightBottomLabelImageView];
        [self.logo addSubview:_videoRightBottomLabel];
        
        _playButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        NSString *imageName = [TTDeviceHelper isPadDevice] ? @"FullPlay" : @"Play";
        _playButton.imageName = imageName;
        [_playButton addTarget:self action:@selector(playButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.logo addSubview:_playButton];
        self.playMovie = [[TTVCellPlayMovie alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSizeChanged) name:kSettingFontSizeChangedNotification object:nil];

    }
    return self;
}

- (void)configurePlayMovie
{
    if (!self.playMovie) {
        self.playMovie = [[TTVCellPlayMovie alloc] init];
    }
    self.playMovie.delegate = self;
    self.playMovie.doubleTap666Delegate = self;
    self.playMovie.logo = self.logo;
    self.playMovie.frame = self.logo.bounds;
    self.playMovie.fromView = self.logo;
    self.playMovie.cellEntity = self.cellEntity;
}

- (void)playButtonClicked
{
    [self configurePlayMovie];
    [_playMovie play];
    self.cellEntity.playVideo = _playMovie.movieView;
    [self.logo addSubview:[_playMovie currentMovieView]];
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

- (void)addCommodity
{
    [self configurePlayMovie];
    [self.playMovie addCommodity];
}

#pragma mark TTVCellPlayMovieDelegate

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


- (void)ttv_commodityViewClosed
{
    if (self.ttv_commodityViewClosedBlock) {
        self.ttv_commodityViewClosedBlock();
    }
}

- (void)ttv_commodityViewShowed
{
    if (self.ttv_commodityViewShowedBlock) {
        self.ttv_commodityViewShowedBlock();
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
        if ([self.playMovie.movieView.playerModel.videoID isEqualToString:cellEntity.article.videoId] && !isEmptyString(cellEntity.article.videoId)) {
            if (![self.playMovie isRotating]) { //iOS8 旋转过程中会触发layout,导致视频被移出
                [self.playMovie invalideMovieViewAfterDelay:YES];//invalideMovieViewAfterDelay 会把movieView置为nil
            }
        }
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
    TTVVideoArticle *article = [self article];
    self.logo.userInteractionEnabled = YES;
    self.videoTitleLabel.text = article.title;
    CGFloat fontSize = [[self class] settedTitleFontSize];
    self.videoTitleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    _playTimesLabel.text = self.cellEntity.playTimes;
    [self updatePic];
    _videoRightBottomLabel.text = self.cellEntity.durationTimeString;
    _videoRightBottomLabel.hidden = article.videoDetailInfo.videoDuration > 0 ? NO : YES;
    self.videoRightBottomLabelImageView.hidden = self.videoRightBottomLabel.hidden;
    self.playButton.hidden = ![self.cellEntity.originData isListShowPlayVideoButton];
    _playButton.userInteractionEnabled = ![self.cellEntity isPlayInDetailView];
}

+ (CGFloat)obtainHeightForFeed:(TTVFeedListItem *)cellEntity cellWidth:(CGFloat)width
{
    if (cellEntity && !cellEntity.imageHeight) {
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithImageUrlList:cellEntity.article.largeImageList];
        // 根据图片实际宽高设置其在cell中的高度
        BOOL isPad = [TTDeviceHelper isPadDevice];
        float picWidth = isPad ? (width - 2 * kCellLeftPadding) : width;
        
        float imageHeight = [[self class] heightForImageWidth:model.width height:model.height constraintWidth:picWidth proportion:cellEntity.article.videoProportion];
        cellEntity.imageHeight = ceil(imageHeight);
    }

    return cellEntity ? cellEntity.imageHeight : 0;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self adjustFrameOfSubviews];
}

- (void)adjustFrameOfSubviews
{
    [self layoutPic];
    _topMaskView.frame = CGRectMake(0, 0, self.logo.width, kTopMaskH);
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
    BOOL isPad = [TTDeviceHelper isPadDevice];
    float left = isPad ? kCellLeftPadding : 0;
    float picWidth = [self getLogoWidth];
    if (!self.cellEntity.imageHeight) {
        float imageHeight = [[self class] heightForImageWidth:self.logo.model.width height:self.logo.model.height constraintWidth:picWidth proportion:[self article].videoProportion];
        self.cellEntity.imageHeight = imageHeight;
    }
    self.logo.frame = CGRectMake(left, 0, picWidth, self.cellEntity.imageHeight);
}

- (float)getLogoWidth {
    // 根据图片实际宽高设置其在cell中的高度
    BOOL isPad = [TTDeviceHelper isPadDevice];
    float picWidth = isPad ? (self.width - 2 * kCellLeftPadding) : self.width;
    return picWidth;
}


#pragma mark - TTVPlayerDoubleTap666Delegate

- (TTVDoubleTapDigType)ttv_doubleTapDigType {
    if (!isEmptyString(self.cellEntity.originData.adIDStr)) {
        return TTVDoubleTapDigTypeForbidDig;
    }
    if (self.cellEntity.originData.userBury) {
        return TTVDoubleTapDigTypeAlreadyBury;
    }
    if (self.cellEntity.originData.userDigg) {
        return TTVDoubleTapDigTypeAlreadyDig;
    }
    return TTVDoubleTapDigTypeCanDig;
}

- (void)ttv_doDigActionWhenDoubleTap:(TTVDoubleTapDigType)digType {
    if (digType == TTVDoubleTapDigTypeForbidDig || digType == TTVDoubleTapDigTypeAlreadyBury) {
        return;
    }
    NSMutableDictionary *pramas = [NSMutableDictionary dictionary];
    if ([self.cellEntity.categoryId isEqualToString:kTTMainCategoryID]) {
        [pramas setValue:@"click_headline" forKey:@"enter_from"];
    }else{
        [pramas setValue:@"click_category" forKey:@"enter_from"];
    }
    [pramas setValue:self.cellEntity.categoryId forKey:@"category_name"];
    [pramas setValue:self.cellEntity.originData.groupModel.groupID forKey:@"group_id"];
    [pramas setValue:self.cellEntity.originData.groupModel.itemID forKey:@"item_id"];
    [pramas setValue:@"list" forKey:@"position"];
    [pramas setValue:(self.playMovie.isFullScreen ? @"fullscreen" : @"notfullscreen") forKey:@"fullscreen"];
    [pramas setValue:@"double_like" forKey:@"action_type"];
    [TTTrackerWrapper eventV3:@"rt_like" params:pramas];
    
    int diggCount = self.cellEntity.originData.diggCount;
    diggCount ++;
    if (digType == TTVDoubleTapDigTypeCanDig) {
        TTVideoArticleService *articleService = [[TTServiceCenter sharedInstance] getService:[TTVideoArticleService class]];
        TTVideoDiggBuryParameter *parameter = [[TTVideoDiggBuryParameter alloc] init];
        parameter.aggr_type = self.cellEntity.originData.aggrType;
        parameter.item_id = self.cellEntity.originData.itemID;
        parameter.group_id = self.cellEntity.originData.groupModel.groupID;
        parameter.ad_id = self.cellEntity.originData.adIDNumber.longLongValue > 0 ? self.cellEntity.originData.adIDNumber.stringValue : nil;
        NSString *unique_id = parameter.group_id ? parameter.group_id : parameter.ad_id;
        @weakify(self);
        [articleService digg:parameter completion:^(TT2DataItemActionResponseModel *response, NSError *error) {
            @strongify(self);
            if (error) {
                return;
            }
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggChanged:uniqueIDStr:), ttv_message_feedDiggChanged:YES uniqueIDStr:unique_id);
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggCountChanged:uniqueIDStr:), ttv_message_feedDiggCountChanged:diggCount uniqueIDStr:unique_id);
        }];
    }
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
    
    return;
}

/**
 *  width:图片宽度 height:图片高度 cwidth:容器宽度 proportionControllable:宽高比是否可控 proportion:宽高比
 */

+ (float)heightForImageWidth:(float)width height:(float)height constraintWidth:(float)cWidth proportion:(float)proportion
{
    if (proportion > 0.01) {//大于0.01做保护
        CGFloat height = cWidth / proportion;
        CGFloat maxHeight = ttvs_listVideoMaxHeight();
        if (maxHeight > 0 && height > maxHeight) {
            height = maxHeight;
        }
        height = ceilf(height);
        return height;
    }
    return [ExploreCellHelper heightForVideoImageWidth:width height:height constraintWidth:cWidth];
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
    
#pragma mark - NSNotification

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    _videoTitleLabel.textColor = [UIColor tt_themedColorForKey:kColorText10];
    _playTimesLabel.textColor = [UIColor tt_themedColorForKey:kColorText9];
    self.backgroundColor = tt_ttuisettingHelper_cellViewBackgroundColor();
}

- (void)fontSizeChanged{
    CGFloat height = [TTLabelTextHelper heightOfText:self.videoTitleLabel.text fontSize:[[self class] settedTitleFontSize] forWidth:[self getLogoWidth] - kVideoTitleX * 2 constraintToMaxNumberOfLines:2];
    self.cellEntity.titleHeight = height;
    CGFloat fontSize = [[self class] settedTitleFontSize];
    self.videoTitleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    [self setNeedsLayout];
}
#pragma mark - actions

@end
